---
name: describe-skill
description: >
  Read an entire skill — its SKILL.md frontmatter and body plus every bundled script,
  reference doc, and asset — and produce a readable, concise summary of what it does, when it
  triggers, what resources it ships, and any gotchas. Trigger on: "describe this skill",
  "summarize the X skill", "what does the X skill do", "explain this skill", "what's in this
  skill", "give me a rundown of skill X", or when a user points at a skill directory / SKILL.md
  and wants to understand it without reading the whole thing themselves. Works for skills in
  ~/.claude/skills, a project's .claude/skills, plugin skill dirs, or an arbitrary path the user
  names. Invoked with no target (a bare /describe-skill), it lists every available skill so the
  user can pick one.
---

# Describe Skill

Turn a skill — possibly sprawling across a SKILL.md plus scripts and reference docs — into a
short, faithful summary a person can read in under a minute. The goal is **fidelity over
flourish**: report what the skill actually does, not what its name implies.

## What counts as "the whole skill"

A skill is a directory containing `SKILL.md` and, optionally, supporting files:

- `SKILL.md` — YAML frontmatter (`name`, `description`, sometimes `when_to_use`,
  `allowed-tools`/`allowed_tools`, `license`, etc.) followed by the markdown playbook. **The
  primary source of truth.**
- `scripts/` (or loose `.py`/`.sh`/`.js`) — executable helpers the skill shells out to.
- `references/`, `docs/`, or other `.md` files — deep-dive material the body links to but
  doesn't inline.
- `assets/`, `templates/`, `examples/` — files the skill copies or fills in.

"Looking through the entire skill" means accounting for all of these — not just paraphrasing the
description. A skill's real behavior often lives in its scripts and reference docs.

## Step 0 — No target named? List all skills instead

If invoked with **no argument** (e.g. a bare `/describe-skill`), don't ask "which one?" — show
the user the menu. List every available skill as a slug + one-line gist so they can pick one,
then end with a prompt to re-run against a specific slug.

You usually already have the full skill roster in this session's context (the available-skills
list). Use it: print each skill's slug and the first sentence of its description, grouped by
source — **user/project** skills first, then **plugin** skills (the `plugin:skill` form). If
that list isn't in context, enumerate from disk:

```bash
# every installed SKILL.md across the standard locations
find ~/.claude/skills ~/.claude/plugins .claude/skills ./claude/skills \
     -maxdepth 4 -name SKILL.md 2>/dev/null | while read -r f; do
  name=$(sed -n 's/^name:[[:space:]]*//p' "$f" | head -1)
  printf '%s\t%s\n' "${name:-$(basename "$(dirname "$f")")}" "$f"
done | sort -u
```

Keep each line to one gist — don't paste full descriptions; the roster is for picking, not
reading. End with: *"Re-run `/describe-skill <slug>` (or give a path) for a full summary of any
one."* Then stop — listing is the whole job when there's no target.

## Step 1 — Resolve the target

The user names a skill by slug (`csv-multi-search`), by path (`./claude/skills/foo`), or by
pointing at a `SKILL.md`. Find the directory:

- **Given a path** → use it directly. If it's a `SKILL.md`, the skill dir is its parent.
- **Given a slug** → search the standard locations, in order, and report which matched (a slug
  can exist in more than one place):

  ```bash
  # name comes from the user, e.g. NAME=csv-multi-search
  find ~/.claude/skills .claude/skills ./claude/skills \
       ~/.claude/plugins -maxdepth 4 -type d -name "$NAME" 2>/dev/null
  # broader sweep if the above misses (plugin layouts vary):
  find ~/.claude -maxdepth 5 -name SKILL.md -path "*$NAME*" 2>/dev/null
  ```

If several match, list them and ask which one (or summarize the project-local one first, since
that's usually what the user means). If none match, say so and show the closest slugs you found
rather than guessing.

## Step 2 — Inventory before reading

Cheap, and it tells you how big the job is:

```bash
SKILL_DIR=<resolved dir>
# tree if available, else find
( command -v tree >/dev/null && tree -L 3 --filesfirst "$SKILL_DIR" ) \
  || find "$SKILL_DIR" -maxdepth 3 -type f | sort
wc -l "$SKILL_DIR/SKILL.md"
```

This reveals whether the skill is a lone SKILL.md (read it directly) or carries scripts and
reference docs (size the reading accordingly).

## Step 3 — Read, scaling effort to size

**Small skill (lone SKILL.md, a few hundred lines):** read `SKILL.md` directly with the Read
tool. Skim any one or two short helper files inline.

**Large skill (many reference docs / scripts, thousands of lines total):** don't flood the main
context. **Delegate the deep read to a subagent** (the `Agent` tool, `subagent_type: "Explore"`
or `general-purpose`) so the bodies stay in its isolated context. Hand it this skill's
"Summary shape" below and have it return only the filled-in summary. This mirrors how the
`claude-docs` skill keeps large doc bodies out of the main transcript.

What to extract while reading:

- **Frontmatter** — `name`, the full `description` (this *is* the trigger logic — note the
  literal trigger phrases and any explicit "do NOT trigger / SKIP" carve-outs), `when_to_use`,
  and any `allowed-tools` restriction.
- **Body** — the actual workflow: the steps it runs, decision trees, the default path vs.
  opt-in paths, and what output it produces.
- **Scripts** — for each, one line on what it does and how the skill invokes it (read the
  top-of-file docstring/usage and the argument parsing, not the whole implementation).
- **References/assets** — what they contain and when the body pulls them in.
- **External dependencies** — CLIs, packages, MCP servers, or env/secrets the skill assumes
  exist (e.g. `brew install qsv`, `pip install duckdb`, an API key).
- **Gotchas** — opt-in gates, destructive actions, cost/credit warnings, rate limits, "last
  resort" mechanics, version sensitivities.

## Step 4 — Emit the summary

Concise and skimmable. Lead with the one-liner; a reader who stops there should still be
correctly oriented. Use this shape (drop any section that's genuinely empty rather than padding
it):

```markdown
**<skill-name>** — <one sentence: what it does and for whom>

**Triggers on:** <the real trigger phrases / conditions from the description>, when it should
fire. Note any explicit "won't trigger / SKIP" carve-outs.

**What it does:**
- <step or capability 1>
- <step or capability 2>
- <default path vs. opt-in path, if the skill branches>

**Bundles:** <scripts (one line each), reference docs, assets — or "nothing, pure-prompt skill">

**Needs:** <external CLIs / packages / MCP servers / keys it assumes, or "no external deps">

**Watch out for:** <opt-in gates, costs, destructive steps, version quirks — omit if none>
```

Keep the whole thing to roughly a screen. If the user asked for *just* a one-liner, give only
the lead sentence. Match length to the request.

**Emphasis discipline.** Readability dies when everything is emphasized. Ration it:

- **Bold** the section labels and at most one or two genuinely load-bearing words per section —
  not whole clauses. If half the lines are bold, none of them register; cut back until the bold
  marks only what a reader would lose money for missing.
- Reserve `backticks` for literal tokens the reader could paste — paths, filenames, flags,
  commands, hostnames (`llms.txt`, `.md`, `curl`, `code.claude.com`). Never use them for
  English emphasis ("`not`", "`official`").
- If it overflows a screen, cut clauses — don't shrink the prose into denser walls. Prefer a
  short bullet over a comma-spliced sentence carrying three ideas.

## Principles

- **Fidelity over the name.** A skill called "audit" might only check three things; a modest
  name might hide a large workflow. Describe the behavior you actually read, and if the name
  oversells or undersells it, say so plainly.
- **Surface the trigger, not just the purpose.** Half a skill's value is *when it fires*. Always
  report the trigger conditions and any SKIP carve-outs — that's what tells a user whether it'll
  activate when they expect.
- **Don't transcribe — distill.** Compress the playbook into its decision points. Skip boilerplate
  and obvious prose. The user can open SKILL.md if they want the full text.
- **Flag the sharp edges.** Opt-in confirmations, credit/cost warnings, destructive operations,
  and "this overrides default behavior" notes matter more than feature lists. Lead with them in
  "Watch out for."
- **Don't run the skill.** This is read-only inspection. Never execute the skill's scripts or
  perform its actions while summarizing.
```
