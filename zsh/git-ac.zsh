# AICOMMITS->COMMIT
# ------------------------------------------------
# Sourced from both zshrc (for interactive `git-ac`) and the
# `git ac` alias in gitconfig — single source of truth.

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

  # Perform the commit
  aicommits --all --yes && \
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
