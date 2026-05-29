---
name: relevant-skills
description: >
  Scan every skill available this session and recommend the ones that could help with the
  current context but did NOT already auto-invoke. Use when the user asks "what skills could
  help here", "are there skills for this", "did I miss any skills", "recommend skills",
  "which skills apply", "/relevant-skills", or wants a second look after a response to catch a
  better tool. Can be run with an explicit prompt/topic to evaluate against, run retroactively
  right after Claude answers (context = the last request + what was just done), or invoked any
  time mid-session. Returns a ranked table — skill (with slash), brief description, why it could
  help, and a color-coded confidence — or plainly says nothing clears the bar. Read-only: it
  recommends, it does not invoke the skills it surfaces.
---

# Relevant skills

Look at the work in front of you, look at the full roster of skills this session has, and point
out the ones that **could have helped or could still help** — but only the ones that did *not*
already fire on their own. The output is advisory: a short, ranked table the user can act on (or
ignore). You never invoke the recommended skills; surfacing them is the whole job.

The bar is **usefulness, not novelty**. Recommending a skill that already auto-invoked, or one
that's only tangentially on-topic, is noise. Under-recommend rather than pad.

## Step 1 — Fix the context to match against

Decide *what* you're judging relevance to, in this order:

1. **Explicit argument** — if invoked with a prompt/topic (`/relevant-skills migrate the docs to
   mintlify`), that text is the context. Match against it directly.
2. **Retroactive** — if invoked right after a response with no argument, the context is **the
   user's most recent request plus what was just done** in that turn. Frame recommendations as
   "could have helped with that" / "would help on the next pass".
3. **Ambient** — if invoked mid-task with no argument, use the active task: the current request,
   the files in play, the goal you're working toward.

If you genuinely can't tell what to evaluate against (e.g. a bare invocation at the very start of
a session with no task yet), ask one short question naming the ambiguity rather than guessing.

## Step 2 — Gather the candidate roster

The full list of available skills is already in this session's context — the **available-skills
roster** the harness injects (each line is a slug + description, including plugin skills in
`plugin:skill` form). That list *is* your candidate set. You do not need to scan the filesystem;
the roster reflects exactly what can be invoked right now.

If for some reason the roster isn't in context, enumerate installed skills from disk:

```bash
find ~/.claude/skills ~/.claude/plugins .claude/skills ./claude/skills \
     -maxdepth 4 -name SKILL.md 2>/dev/null | while read -r f; do
  name=$(sed -n 's/^name:[[:space:]]*//p' "$f" | head -1)
  printf '%s\t%s\n' "${name:-$(basename "$(dirname "$f")")}" "$f"
done | sort -u
```

## Step 3 — Subtract what already fired (the core filter)

Recommending a skill that already ran is the main failure mode. Exclude:

- **Skills that auto-invoked this session.** Scan the transcript for prior `Skill` tool calls —
  each is a skill that already fired. Drop those from the candidate set; the user has them.
- **This skill itself** (`relevant-skills`) and the obvious meta/discovery skills
  (`describe-skill`, `find-skills`, `skill-creator`) — unless the user's context is *specifically*
  about skills, in which case they're fair game.

What remains are skills that were available but stayed silent. Those are the only ones worth
evaluating.

## Step 4 — Score relevance and confidence

For each remaining skill, judge against the context using its **description** (the description is
the skill's own trigger logic — a strong match there is a strong signal). Assign confidence:

| Confidence | Meaning | Include? |
|------------|---------|----------|
| 🟢 **High** | Context squarely hits the skill's stated triggers; it's clearly the right tool and it's surprising it didn't fire | Always |
| 🟡 **Medium** | Plausibly helpful — depends on the user's actual intent or a likely next step | Yes |
| 🔴 **Low** | Tangential; only adjacent to the work | Only if the user asked to be exhaustive, OR nothing higher exists |

Default floor is **🟡 Medium**. Don't list 🔴 Low matches unless the user asked for everything or
the table would otherwise be empty and a long-shot is still worth naming. Cap a normal run at
roughly the **top 5** — this is a shortlist, not a re-print of the roster.

Watch for **near-duplicates**: when several skills overlap (e.g. the `firecrawl*` family, the
`obsidian*` family), recommend the one that best fits the context and mention the family in its
rationale rather than listing every sibling as its own row.

## Step 5 — Emit the table

Sort highest confidence first. One row per skill:

```markdown
| Skill | Description | Why it could help | Confidence |
|-------|-------------|-------------------|------------|
| `/deep-research` | Fan-out, fact-checked research report | You're chasing a claim across several sources by hand — this verifies and cites it | 🟢 High |
| `/code-review` | Review the current diff for bugs and cleanups | A diff is staged but unreviewed; this catches correctness issues before push | 🟡 Medium |
```

Column rules:

- **Skill** — the invocable slug **with a leading slash**, in backticks. Plugin skills keep their
  namespace: `/slack:standup`, `/interface-design:audit`.
- **Description** — one short clause, your own words, not the full frontmatter line.
- **Why it could help** — the rationale tied to *this* context: name the specific thing in the
  task the skill addresses. Generic ("helps with research") is useless; specific ("verifies the
  three load-bearing claims you're citing") earns the row.
- **Confidence** — the colored marker plus its word: `🟢 High`, `🟡 Medium`, `🔴 Low`.

After the table, add at most one line of guidance if it helps (e.g. which to reach for first).

**When nothing clears the bar, say so plainly** — "No additional skills look relevant here; the
ones that applied (`X`, `Y`) already ran." Do not manufacture rows to fill the table. An honest
empty result is the correct output when the active skills already covered the work.

## Principles

- **Subtract before you suggest.** The value is in the gap — skills that *fit but didn't fire*.
  Re-recommending what already ran is the cardinal sin.
- **Specific rationale or no row.** Every recommendation must name the concrete thing in the
  context it addresses. If you can't, the match isn't real — drop it.
- **Rank, then trim.** A focused top-5 beats an exhaustive dump. The user wants a pointer, not the
  catalog.
- **Recommend, don't run.** This skill never invokes the skills it surfaces — the user decides.
- **Empty is a valid answer.** If the active skills covered the work, say nothing else applies
  rather than padding with low-confidence noise.
