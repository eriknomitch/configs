# Language and style
- Always respond in English.
- Do not introduce em-dashes or en-dashes in prose, code comments, or files you write. Use a comma, colon, period, or parentheses instead. Leave existing dashes in files you edit unless asked to remove them.
- Do not write mannered prose: metaphor or flourish where a literal phrase exists. Write "a parameter worth varying," not "a dial worth turning"; "this point still matters," not "this point earns its keep." When a literal phrase is available, use it.

# Git and files
- Use `git rm` / `git mv` for files tracked by git. Use plain `rm` / `mv` only for untracked files (build artifacts, scratch files).

# Toolchain
- asdf shims are on PATH via the SessionStart hook in `~/.claude/hooks/asdf-path.sh`; `.tool-versions` is honored.

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
