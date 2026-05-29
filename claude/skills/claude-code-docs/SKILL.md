---
name: claude-code-docs
description: Ground any Claude Code configuration or feature work in the latest OFFICIAL docs at code.claude.com instead of relying on training knowledge. Use when building, editing, auditing, reviewing, or debugging skills, hooks, subagents, slash/custom commands, MCP servers, settings.json, permissions, plugins, statusline, output styles, memory/CLAUDE.md, the CLI, or the Agent SDK — and when answering "how does Claude Code do X" or "what's the latest way to configure X". Always prefer this over guessing, because Claude Code ships frequently and training data goes stale.
---

# Claude Code Docs (live)

Fetch the current official Claude Code documentation on demand. Never answer Claude
Code configuration/feature questions from memory when the live docs can confirm it —
the product ships often and training data drifts.

## When to use

- Building, editing, **auditing, or reviewing** a **skill, hook, subagent, slash
  command, MCP server, plugin, statusline, output style, or settings.json** in this
  or any repo.
- Debugging Claude Code config (permissions not applying, a hook not firing, an MCP
  server not connecting, frontmatter not recognized).
- Answering "how do I configure X", "what fields does Y take", "what's the latest way
  to Z" for Claude Code or the Agent SDK.
- Before asserting a fact about Claude Code behavior, frontmatter, or file format —
  verify it against the page rather than recalling it.

## The docs contract (stable; everything else is fetched live)

The docs are Mintlify-hosted and expose LLM-friendly endpoints. Only these conventions
are fixed — do **not** memorize individual page slugs, they change:

1. **Index:** `https://code.claude.com/docs/llms.txt` — a compact list of every page
   with a one-line description and its `.md` URL. This is the source of truth for
   "which page covers what". Always start here.
2. **Raw page:** append `.md` to any docs path to get clean markdown with no nav chrome,
   e.g. `https://code.claude.com/docs/en/best-practices.md`.
3. **Everything (fallback):** `https://code.claude.com/docs/llms-full.txt` is the entire
   docs concatenated. It is large — use only when the index doesn't resolve the topic.

WebFetch caches each URL for ~15 min; the docs CDN caches `llms*.txt` ~daily.

## Workflow

1. **Route via the index.** Fetch `https://code.claude.com/docs/llms.txt` and find the
   entry whose title/description matches the task. Take its `.md` URL.
2. **Read the page.** Fetch that `.md` URL. Ask WebFetch a pointed question (e.g. the
   exact field, anchor, or section you need) so it returns the relevant slice.
3. **Cite it.** When you apply what you found, name the page so the user can verify —
   e.g. "per `best-practices.md` → Create skills".
4. **Fallbacks, in order:** if the index has no clear match → fetch `llms-full.txt` and
   search it; if a `.md` URL 404s → fetch the same path without `.md` (HTML still works).

## Example

Task: build a new skill, want the official guidance.

1. Fetch `llms.txt`; locate the Best-practices entry → `.../en/best-practices.md`.
2. Fetch `https://code.claude.com/docs/en/best-practices.md` asking "what does the
   Create skills section recommend?" — its `### Create skills` heading is the
   `#create-skills` anchor the user referenced.
3. Apply and cite. For the full skill spec, the index also points to the dedicated
   skills page (`.../en/skills.md`) — resolve it from the index, don't assume the slug.

## Notes

- Prefer the index→page path over `llms-full.txt`; it is far cheaper in tokens.
- This skill complements the built-in `claude-code-guide` agent (which answers user
  questions). Use this skill to *ground your own config/build work* in current docs.
