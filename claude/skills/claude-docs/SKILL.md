---
name: claude-docs
description: Ground Claude Code configuration and feature work — and any work on Anthropic's products — in the latest OFFICIAL docs instead of training knowledge, which drifts because these ship constantly. Three doc hosts. Claude Code (code.claude.com) — skills, hooks, subagents, slash/custom commands, MCP servers, settings.json, permissions, plugins, statusline, output styles, memory/CLAUDE.md, the CLI, the Agent SDK. The Anthropic API / developer platform (platform.claude.com) — Messages API, models, prompt caching, tool use, batch, files, citations, prompt engineering, Managed Agents, Agent Skills. The Help Center (support.claude.com) — account, billing, SSO/JIT/SCIM, Connectors, Claude in Chrome, how-to guides, release notes. Use when building, editing, auditing, reviewing, or debugging any of the above, or answering "how does Claude Code / the Claude API do X" or "what's the latest way to configure X". Always prefer this over guessing.
when_to_use: Use to GROUND work in current official docs — look up the authoritative page, verify a field or behavior, cite it. For actually building, debugging, or migrating a Claude API / Anthropic SDK app (prompt caching, model version bumps, tool-use wiring) prefer the claude-api skill; this skill supplies the docs, not the implementation.
---

# Claude docs (live)

Fetch current official Anthropic documentation on demand. Never answer a Claude Code,
Claude API, or Anthropic product question from memory when the live docs can confirm it —
these products ship often and training data drifts.

## The three hosts (route by domain of the question)

Pick the authoritative host first; don't blend them.

| Host | Authoritative for | Index (`llms.txt`) |
|------|-------------------|--------------------|
| **code.claude.com/docs** | **Claude Code** — CLI, skills, hooks, subagents, slash/custom commands, MCP servers, settings.json, permissions, plugins, statusline, output styles, memory/CLAUDE.md, **Agent SDK** | `https://code.claude.com/docs/llms.txt` (~30 KB) |
| **platform.claude.com** | **Anthropic API / dev platform** — Messages API, models, prompt caching, tool use, batch, files, citations, prompt engineering, Managed Agents, Agent Skills, build-with-claude | `https://platform.claude.com/llms.txt` (~167 KB) |
| **support.claude.com** | **Help Center** — account, billing, SSO/JIT/SCIM, Connectors, Claude in Chrome, how-to guides, release notes (multilingual) | `https://support.claude.com/llms.txt` (~172 KB) |

Routing rules:

- A **Claude Code** config/feature question → **code.claude.com** is authoritative. If a
  `support.claude.com` how-to article and a `code.claude.com` reference page disagree, the
  `code.claude.com` page wins — support is end-user help, not the spec. ("Skills" appears on
  all three hosts; for *Claude Code* skill-building, use `code.claude.com`.)
- Building or debugging an **API/SDK app** (calling Claude, caching, tool use, models) →
  **platform.claude.com**.
- **Account / billing / SSO / "how do I use X in the app" / release notes** →
  **support.claude.com**. Its `llms.txt` is multilingual — stay in the **## English** section.

## The docs contract (stable; everything else is fetched live)

All three are Mintlify-hosted and share these conventions. Do **not** memorize page slugs —
they change.

1. **Raw markdown for ANY page — append `.md`.** Append `.md` to any bare docs/article URL on
   these hosts to get clean markdown with no nav chrome:
   `…/en/hooks` → `…/en/hooks.md`, `…/articles/123-foo` → `…/articles/123-foo.md`. The bare
   HTML URL is a multi-MB SPA shell; the `.md` is small, pure content. **Never double-append**
   (`.md.md` falls back to HTML). Verified on code, platform, and support alike.
2. **Index per host:** the `llms.txt` files in the table above — every page with a one-line
   description and its `.md` URL. The source of truth for "which page covers what." Start here
   only when you don't already have a URL.
3. **Aliases:** `docs.claude.com` and `docs.anthropic.com` both 301-redirect to
   `platform.claude.com`. Use `platform.claude.com` canonically; don't hardcode the aliases.
4. **Everything (last resort):** each host has an `llms-full.txt` (entire docs concatenated).
   Sizes differ wildly — **code ≈ 4 MB, platform ≈ 71 MB**. Use only for full-text search when
   the index can't locate a term. **Do not WebFetch it** (it summarizes MBs through a small
   model every call) and **never casually curl platform's whole 71 MB** — `curl` + `grep` it as
   a search index, caching once to `/tmp` if grepping several terms this session:

   ```bash
   # locate which page mentions a term (-i case-insensitive, -n line numbers)
   curl -s https://code.claude.com/docs/llms-full.txt | grep -ni 'disable-model-invocation'
   # several terms this session? fetch once (CDN caches ~daily), then grep /tmp:
   curl -s https://code.claude.com/docs/llms-full.txt -o /tmp/cc-llms-full.txt
   grep -ni -B2 -A8 'your-term' /tmp/cc-llms-full.txt
   ```

   Only grep output enters context, never the raw file. No manual cleanup — the OS reaps
   `/tmp`, and the cached copy warms the next lookup.

## Workflow

**Delegate the lookup to a subagent** so the index and page bodies stay out of the main
context — doing it inline floods the transcript and burns the main context window. Spawn a
subagent (the `Agent` tool, `subagent_type: "Explore"` or `general-purpose`) that fetches in
its own isolated context and returns **only** the distilled answer plus the page name to cite.

Always `curl` — **not WebFetch** — because the pages are static markdown on a CDN: instant,
free, not rate-limited. WebFetch throttles (the `attempt N/10` retries) and returns a lossy
small-model summary. If `curl` is ever blocked (unexpected for these static files), fall back
to `firecrawl scrape "<url>"` (costs credits). Do **not** use context7 — it indexes libraries,
not these live docs.

The subagent's steps:

1. **Already have a doc URL? Fast-path it.** `curl -s <url>.md` (append `.md` to the bare URL,
   or use it as-is if it already ends in `.md`) and read it. No index round-trip — the index is
   only for discovery.
2. **Otherwise route, then discover.** Pick the host from the table above. `curl -s <host-llms.txt>`
   and find the entry whose title/description matches. Take its `.md` URL.
3. **Read the page.** `curl -s <that-.md-url>` and read the relevant section.
4. **Fallbacks, in order:** index has no clear match → `curl` + `grep` that host's
   `llms-full.txt` (see contract), then resolve its `.md`; a `.md` 404s → curl the bare path
   (HTML still works).
5. **Return shape.** Reply with just (a) the answer to the specific question and (b) the page
   name(s) for citation — not the index, not the full page body.

Then **cite it** in your own work — name the page the subagent reported, e.g.
"per `code.claude.com … hooks.md` → PreToolUse" — so the user can verify.

## Examples

**Build a new Claude Code skill, want official guidance.**
Spawn a subagent: "Route via `https://code.claude.com/docs/llms.txt`, find the best-practices /
skills page, curl its `.md`, and summarize what the Create skills section recommends. Return
only that plus the page name." It resolves `code.claude.com/docs/en/best-practices.md`, reads
`#create-skills`, returns the summary. Apply and cite.

**Someone pasted `https://support.claude.com/en/articles/12512198-how-to-create-custom-skills`.**
Fast-path it — `curl -s …/12512198-how-to-create-custom-skills.md` returns clean markdown, no
index needed. (That's the end-user how-to; for the authoritative Claude Code skill spec, prefer
`code.claude.com`.)

**Tuning prompt caching in an API app.** Route to `platform.claude.com`: `curl` its `llms.txt`,
find the prompt-caching page, curl that `.md`.

## Notes

- Prefer the index→page path (or the URL fast-path) over `llms-full.txt`; it's far cheaper in tokens.
- This skill complements the built-in `claude-code-guide` agent and the vendored `claude-api`
  skill — use this to *ground your own build/config work* in current docs.
