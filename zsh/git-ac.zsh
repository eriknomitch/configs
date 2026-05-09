# AICOMMITS->COMMIT
# ------------------------------------------------
# Sourced from both zshrc (for interactive `git-ac`) and the
# `git ac` alias in gitconfig — single source of truth.

# Fallback `hr` for the alias path (zshrc isn't sourced there).
# In interactive shells the zshrc-defined `hr` already exists and wins.
if (( ! ${+functions[hr]} )); then
  function hr() {
    local cols=${COLUMNS:-0}
    (( cols > 0 )) || cols=$(tput cols 2>/dev/null) || cols=80
    (( cols > 0 )) || cols=80
    printf '%*s\n' "$cols" '' | tr ' ' '─'
  }
fi

function git-ac() {

  # If this isn't a git repo, just return
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
    echo "Not a git repo. Exiting."
    return
  fi

  # Warn about untracked files (aicommits --all only stages tracked changes)
  local untracked
  untracked=$(git ls-files --others --exclude-standard)
  if [[ -n "$untracked" ]]; then
    echo "Warning: the following untracked files will NOT be included:"
    echo "$untracked" | sed 's/^/  /'
    echo "(use \`git add\` first if you want them in this commit)"
    echo
    local reply
    read "reply?Continue anyway? [y/N] "
    if [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # If repo is clean, just return
  if git diff-index --quiet HEAD --; then
    echo "Repo is clean. Nothing to commit. Exiting."
    return
  fi

  # Pre-flight: drop largest files from AI analysis when the diff is too big.
  # aicommits sends `git diff --cached` as the prompt; generated files
  # (db/structure.sql, lockfiles) routinely blow past Groq's 8K TPM cap.
  # Default budget ~20000 chars ≈ 5000 tokens, leaving room for aicommits'
  # own system prompt overhead under an 8K limit. Override per-shell with
  # AICOMMITS_MAX_CHARS if you move to a higher-tier model.
  local max_chars=${AICOMMITS_MAX_CHARS:-20000}
  local -a excludes sized_files
  local total=0 f sz line
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    sz=$(git diff HEAD -- "$f" | wc -c | tr -d ' ')
    sized_files+=("$sz $f")
    (( total += sz ))
  done < <(git diff HEAD --name-only)

  if (( total > max_chars )); then
    echo "Staged diff ~$total chars exceeds budget $max_chars."
    echo "Excluding largest files from AI analysis (still staged & committed):"
    local file_count=${#sized_files[@]}
    while IFS= read -r line; do
      sz=${line%% *}
      f=${line#* }
      excludes+=("$f")
      (( total -= sz ))
      echo "  - $f (${sz} chars)"
      # Always leave at least one file for the model to look at.
      if (( ${#excludes[@]} >= file_count - 1 )); then
        echo "  (kept smallest file so aicommits has something to analyze)"
        break
      fi
      (( total <= max_chars )) && break
    done < <(printf '%s\n' "${sized_files[@]}" | sort -rn)
    echo "Remaining diff for AI: ~$total chars."
    echo
  fi

  local -a ai_args=(--all --yes)
  if (( ${#excludes[@]} > 0 )); then
    ai_args+=(--exclude "${(j:,:)excludes}")
  fi

  aicommits "${ai_args[@]}" && \
    hr && \
    git log -n 1 --color=always && \
    hr

  # If the commit was successful, push (unless --no-push is specified)
  if [[ $? -eq 0 ]]; then
    echo
    if [[ $@ != *--no-push* ]]; then
      echo "Pushing..."
      git push
    else
      echo "Skipping push due to --no-push option."
    fi
  fi
}
