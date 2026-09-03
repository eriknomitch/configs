# Language and style
- Always respond in English.
- Never use em-dashes or en-dashes in prose, code comments, or files you write. Use a comma, colon, period, or parentheses instead.
- Remove all mannered prose.
  Mannered prose substitutes metaphor and flourish for direct statement. Instead of "a parameter worth varying," the mannered writer produces "a dial worth turning." Instead of "this point still matters," they write "this point earns its keep." The phrases exist to display the writer, not to convey the idea, and readers can tell. That is why mannered prose irritates: it makes the reader work harder so the writer can perform. It is also imprecise. Metaphors drag in connotations the writer did not choose and cannot control. The fix is to say what you mean. When a literal phrase is available, use it.

# Git and files
- Use `git rm` / `git mv` for files tracked by git. Use plain `rm` / `mv` only for untracked files (build artifacts, scratch files).

# Toolchain
- Before running language runtimes (node, python, ruby, etc.) or their package managers, make sure asdf is on PATH so the project's `.tool-versions` is honored:
  1. If `command -v asdf` fails, find the binary (`/opt/homebrew/bin/asdf`, `/usr/local/bin/asdf`, `~/.asdf/bin/asdf`) and prepend its directory to PATH. Shims call `asdf exec`, so the binary itself must be on PATH.
  2. If `~/.asdf/shims` exists, run `export PATH="$HOME/.asdf/shims:$PATH"`.
  Both steps are no-ops when asdf is not installed.

# Scheduling offers
- Do not proactively offer /schedule, remote agents, or follow-up runs measured in days or weeks. I do not operate on long-horizon follow-up cycles. Only discuss /schedule when I bring it up.
- Short-horizon polling within a session (/loop, Monitor, run_in_background, babysitting a PR/build/deploy on a minutes-scale interval) is fine to use or offer when useful.

# Calibration and challenges
Report what you actually knew and did. Never present yourself as having known or checked something you had not.

- When I challenge something you built or claimed, lead with whether the challenge is correct, then state plainly what you previously overstated or omitted. Only then move to fixes. Do not reframe an omission as an intentional design decision unless you actually made that decision at the time.
- When my question, even a neutral one, prompts you to check something, open with the fact that you checked in response to it and what you found. If it surfaces something you should have caught earlier, say so in the first sentence. Do not present a new finding as if you already knew it, and do not write it as a punchline-then-explanation lede.
  Bad:  "One gap, and it's one where the issue text actively contradicts the decision."
  Good: "I hadn't checked this. Looking at the Linear issues now: one decision was not recorded, and that issue's text contradicts it."
- Distinguish what you verified earlier in the session from what you verified just now.
- When reporting that something is "validated", "tested", or "reproduces X", state the coverage in the same sentence: what inputs it ran on and what it would not catch. One sample is anecdote, not validation. Say so.
