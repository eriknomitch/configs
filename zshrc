# ================================================
# ZSHRC ==========================================
# ================================================

# ------------------------------------------------
# CONFIGURATION ----------------------------------
# ------------------------------------------------
export USE_ATUIN=false

# ------------------------------------------------
# INITIAL-CWD ------------------------------------
# ------------------------------------------------

# This is used in some scripts to force an initial working directory.
test -n $INITIAL_CWD && cd $INITIAL_CWD

# ------------------------------------------------
# SOURCE->SHARED ---------------------------------
# ------------------------------------------------
source /etc/zsh/shared.zsh

# ------------------------------------------------
# HISTORY ----------------------------------------
# ------------------------------------------------
export HISTSIZE=100000
export SAVEHIST=100000
setopt HIST_IGNORE_DUPS # Ignore duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS # If a new command is a duplicate, remove the older one
setopt HIST_FIND_NO_DUPS # When searching history, don't show duplicates
setopt HIST_SAVE_NO_DUPS # When saving history, don't save duplicates
setopt EXTENDED_HISTORY # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_SPACE  # Commands starting with a space are not saved to history

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.local/bin"

# ------------------------------------------------
# ALIASES ----------------------------------------
# ------------------------------------------------
function preferred-ls() {
  if command-exists exa; then
    eza --icons --classify --oneline --long --no-permissions --no-user --time-style relative --git --level 1 --tree
  else
    ls $*
  fi
}

# FIX: Add export -f to some of these for script use
alias e="edit-common"
alias arp="sudo arp"
alias route="sudo route"
alias rg="rg --smart-case"
alias lg="lazygit"
alias ncdu="ncdu --color dark-bg -e --exclude .git --exclude node_modules"
alias ping="prettyping --nolegend"
alias dsp="docker system prune --force"
alias jl='jupyter lab --notebook-dir "${HOME}/.jupyter-notebooks"'

# ------------------------------------------------
# FUNCTIONS --------------------------------------
# ------------------------------------------------

# UTILITY
# ------------------------------------------------
function hr() {
  printf '%*s\n' "$(tput cols)" '' | tr ' ' '─'
}

# Load secrets
# ------------------------------------------------
function load-secrets() {
  local secrets_files=("$HOME/.env" "$HOME/.secrets")
  local loaded_count=0
  local quiet=false

  # Initialize/clear the loaded secrets tracking
  export LOADED_SECRETS_FILES=()
  export LOADED_SECRETS_VARS=()

  # Parse arguments
  for arg in "$@"; do
    case $arg in
      --quiet|-q) quiet=true ;;
    esac
  done

  for secrets_file in $secrets_files; do
    if [[ -f $secrets_file ]]; then
      # Store variables before sourcing
      local vars_before=($(env | cut -d= -f1 | sort))

      source $secrets_file
      ((loaded_count++))
      $quiet || echo "✓ Loaded secrets from $secrets_file"

      # Track which file was loaded
      LOADED_SECRETS_FILES+=("$secrets_file")

      # Find newly added variables
      local vars_after=($(env | cut -d= -f1 | sort))
      local new_vars=($(comm -13 <(printf '%s\n' "${vars_before[@]}") <(printf '%s\n' "${vars_after[@]}")))

      # Add new variables to tracking
      for var in $new_vars; do
        LOADED_SECRETS_VARS+=("$var")
      done

      # Ensure proper permissions
      chmod 600 "$secrets_file" 2>/dev/null
    fi
  done

  if [[ $loaded_count -eq 0 ]] && ! $quiet; then
    echo "⚠️  No secrets files found (checked: ${secrets_files[*]})"
  fi
}

# List loaded secrets
# ------------------------------------------------
function list-secrets() {
  local show_values=false

  # Parse arguments
  for arg in "$@"; do
    case $arg in
      --values|-v) show_values=true ;;
      --help|-h)
        echo "Usage: list-secrets [--values|-v] [--help|-h]"
        echo ""
        echo "  --values, -v    Show variable values (masked for security)"
        echo "  --help, -h      Show this help message"
        return 0
        ;;
    esac
  done

  if [[ ${#LOADED_SECRETS_FILES[@]} -eq 0 ]]; then
    echo "⚠️  No secrets files have been loaded yet"
    echo "💡 Run 'load-secrets' to load secrets first"
    return 1
  fi

  echo "🔐 LOADED SECRETS"
  echo "================="

  # Show loaded files
  echo "📁 Files loaded:"
  for file in "${LOADED_SECRETS_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      local file_size=$(wc -c < "$file" | tr -d ' ')
      local file_lines=$(wc -l < "$file" | tr -d ' ')
      echo "   ✓ $file (${file_lines} lines, ${file_size} bytes)"
    else
      echo "   ❌ $file (no longer exists)"
    fi
  done

  echo ""

  # Show loaded variables
  if [[ ${#LOADED_SECRETS_VARS[@]} -eq 0 ]]; then
    echo "📝 No environment variables were added"
  else
    echo "📝 Environment variables loaded (${#LOADED_SECRETS_VARS[@]}):"
    for var in "${LOADED_SECRETS_VARS[@]}"; do
      if [[ -n "${(P)var}" ]]; then
        if $show_values; then
          # Mask the value for security (show first 4 chars + ***)
          local value="${(P)var}"
          local masked_value
          if [[ ${#value} -le 4 ]]; then
            masked_value="***"
          else
            masked_value="${value:0:4}***"
          fi
          echo "   ✓ $var = $masked_value"
        else
          echo "   ✓ $var"
        fi
      else
        echo "   ⚠️  $var (empty or unset)"
      fi
    done

    if ! $show_values; then
      echo ""
      echo "💡 Use 'list-secrets --values' to see masked values"
    fi
  fi
}

# Add a secret
# ------------------------------------------------
function add-secret() {
  local var_name=""
  local var_value=""
  local target_file="$HOME/.env"
  local force=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --file|-f)
        target_file="$2"
        shift 2
        ;;
      --force)
        force=true
        shift
        ;;
      --help|-h)
        echo "Usage: add-secret [VAR_NAME] [VALUE] [options]"
        echo ""
        echo "Add a new environment variable to your secrets file."
        echo ""
        echo "Arguments:"
        echo "  VAR_NAME    Name of the environment variable"
        echo "  VALUE       Value of the environment variable"
        echo ""
        echo "Options:"
        echo "  --file, -f FILE    Target file (default: ~/.env)"
        echo "  --force            Overwrite existing variable"
        echo "  --help, -h         Show this help message"
        echo ""
        echo "Examples:"
        echo "  add-secret API_KEY sk-1234567890"
        echo "  add-secret DATABASE_URL postgresql://user:pass@host/db"
        echo "  add-secret --file ~/.secrets TOKEN abc123"
        return 0
        ;;
      *)
        if [[ -z "$var_name" ]]; then
          var_name="$1"
        elif [[ -z "$var_value" ]]; then
          var_value="$1"
        else
          echo "❌ Too many arguments. Use --help for usage."
          return 1
        fi
        shift
        ;;
    esac
  done

  # Interactive mode if no arguments provided
  if [[ -z "$var_name" ]]; then
    echo "🔐 ADD SECRET"
    echo "============="
    echo -n "Variable name: "
    read var_name
  fi

  if [[ -z "$var_value" ]]; then
    echo -n "Variable value: "
    read -s var_value
    echo
  fi

  # Validate variable name
  if [[ ! "$var_name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
    echo "❌ Invalid variable name: $var_name"
    echo "💡 Variable names should be UPPERCASE, start with a letter or underscore,"
    echo "   and contain only letters, numbers, and underscores."
    return 1
  fi

  # Check if variable already exists
  if [[ -f "$target_file" ]] && grep -q "^export $var_name=" "$target_file"; then
    if ! $force; then
      echo "⚠️  Variable $var_name already exists in $target_file"
      echo -n "Overwrite? (y/N): "
      read -r answer
      if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "❌ Cancelled"
        return 1
      fi
    fi

    # Remove existing line
    if command -v sed >/dev/null; then
      sed -i.bak "/^export $var_name=/d" "$target_file"
      rm -f "${target_file}.bak"
    else
      grep -v "^export $var_name=" "$target_file" > "${target_file}.tmp" && mv "${target_file}.tmp" "$target_file"
    fi
  fi

  # Create target file if it doesn't exist
  if [[ ! -f "$target_file" ]]; then
    echo "# Environment variables" > "$target_file"
    echo "# Generated by add-secret function" >> "$target_file"
    echo "" >> "$target_file"
  fi

  # Add the new variable
  echo "export $var_name=\"$var_value\"" >> "$target_file"

  # Set secure permissions
  chmod 600 "$target_file"

  # Update current environment
  export "$var_name"="$var_value"

  # Update tracking if load-secrets was already run
  if [[ -n "$LOADED_SECRETS_FILES" ]]; then
    # Add to tracking arrays if not already present
    if [[ ! " ${LOADED_SECRETS_FILES[*]} " =~ " ${target_file} " ]]; then
      LOADED_SECRETS_FILES+=("$target_file")
    fi
    if [[ ! " ${LOADED_SECRETS_VARS[*]} " =~ " ${var_name} " ]]; then
      LOADED_SECRETS_VARS+=("$var_name")
    fi
  fi

  echo "✅ Added $var_name to $target_file"
  echo "🔄 Variable is now available in current session"
  echo "💡 Run 'load-secrets' to reload all secrets in future sessions"
}

# Main secrets command with subcommands
# ------------------------------------------------
function secrets() {
  local subcommand="$1"
  shift

  case "$subcommand" in
    load|l)
      load-secrets "$@"
      ;;
    list|ls)
      list-secrets "$@"
      ;;
    add|a)
      add-secret "$@"
      ;;
    reload|r)
      echo "🔄 Reloading secrets..."
      load-secrets "$@"
      ;;
    edit|e)
      _secrets_edit "$@"
      ;;
    template|t)
      _secrets_template "$@"
      ;;
    check|c)
      _secrets_check "$@"
      ;;
    help|h|--help|-h)
      _secrets_help
      ;;
    "")
      _secrets_help
      ;;
    *)
      echo "❌ Unknown subcommand: $subcommand"
      echo "💡 Use 'secrets help' for available commands"
      return 1
      ;;
  esac
}

# Secrets help function
# ------------------------------------------------
function _secrets_help() {
  cat << 'EOF'
🔐 SECRETS MANAGEMENT
====================

Usage: secrets <subcommand> [options]

SUBCOMMANDS:
  load, l      Load secrets from files
  list, ls     List loaded secrets
  add, a       Add a new secret
  reload, r    Reload all secrets
  edit, e      Edit secrets file
  template, t  Copy template to create new secrets file
  check, c     Check secrets file status
  help, h      Show this help

EXAMPLES:
  secrets load                    # Load secrets quietly
  secrets load --verbose          # Load with feedback
  secrets list                    # Show loaded secrets
  secrets list --values           # Show with masked values
  secrets add API_KEY sk-123      # Add new secret
  secrets add                     # Interactive mode
  secrets reload                  # Reload all secrets
  secrets edit                    # Edit ~/.env file
  secrets template                # Copy template to ~/.env
  secrets check                   # Check file status

DETAILED USAGE:

  secrets load [--quiet|-q]
    Load environment variables from ~/.env and ~/.secrets
    --quiet, -q    Load silently (default during shell startup)

  secrets list [--values|-v] [--help|-h]
    Display loaded secrets information
    --values, -v   Show variable values (masked for security)
    --help, -h     Show detailed help for list command

  secrets add [VAR_NAME] [VALUE] [options]
    Add new environment variable to secrets file
    VAR_NAME       Name of environment variable (UPPERCASE_FORMAT)
    VALUE          Value of environment variable
    --file, -f     Target file (default: ~/.env)
    --force        Overwrite existing variable without confirmation
    --help, -h     Show detailed help for add command

FILES:
  ~/.env         Primary secrets file
  ~/.secrets     Alternative secrets file
  ~/.env.template Example template file

SECURITY:
  • Files are automatically set to 600 permissions (owner read/write only)
  • Values are masked when displayed
  • Files are gitignored to prevent accidental commits
  • Interactive mode hides password input

For more details on any subcommand, use:
  secrets <subcommand> --help
EOF
}

# Secrets helper functions
# ------------------------------------------------
function _secrets_edit() {
  local target_file="${1:-$HOME/.env}"

  if [[ ! -f "$target_file" ]]; then
    echo "⚠️  File $target_file doesn't exist"
    echo -n "Create it? (Y/n): "
    read -r answer
    if [[ "$answer" != "n" && "$answer" != "N" ]]; then
      secrets template "$target_file"
    else
      return 1
    fi
  fi

  echo "📝 Opening $target_file in editor..."
  ${EDITOR:-vim} "$target_file"

  # Set secure permissions after editing
  chmod 600 "$target_file"
  echo "🔒 Set secure permissions (600) on $target_file"
}

function _secrets_template() {
  local target_file="${1:-$HOME/.env}"

  if [[ -f "$target_file" ]]; then
    echo "⚠️  File $target_file already exists"
    echo -n "Overwrite? (y/N): "
    read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "❌ Cancelled"
      return 1
    fi
  fi

  if [[ -f "$HOME/.env.template" ]]; then
    cp "$HOME/.env.template" "$target_file"
    chmod 600 "$target_file"
    echo "✅ Copied template to $target_file"
    echo "📝 Edit the file to add your actual values"
  else
    echo "❌ Template file ~/.env.template not found"
    return 1
  fi
}

function _secrets_check() {
  local files=("$HOME/.env" "$HOME/.secrets" "$HOME/.env.template")

  echo "🔍 SECRETS FILE STATUS"
  echo "======================"

  for file in "${files[@]}"; do
    echo -n "$(basename "$file"): "
    if [[ -f "$file" ]]; then
      local perms=$(stat -f "%Mp%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
      local size=$(wc -c < "$file" | tr -d ' ')
      local lines=$(wc -l < "$file" | tr -d ' ')

      if [[ "$perms" == "600" ]]; then
        echo "✅ EXISTS (${lines} lines, ${size} bytes, secure permissions)"
      else
        echo "⚠️  EXISTS (${lines} lines, ${size} bytes, permissions: ${perms})"
        echo "   💡 Run 'chmod 600 $file' to secure"
      fi
    else
      echo "❌ NOT FOUND"
      if [[ "$(basename "$file")" == ".env.template" ]]; then
        echo "   💡 Run 'secrets template' to create from template"
      fi
    fi
  done

  echo ""
  echo "🔐 Current session:"
  if [[ ${#LOADED_SECRETS_FILES[@]} -gt 0 ]]; then
    echo "   ✅ ${#LOADED_SECRETS_VARS[@]} variables loaded from ${#LOADED_SECRETS_FILES[@]} files"
  else
    echo "   ⚠️  No secrets loaded in current session"
    echo "   💡 Run 'secrets load' to load secrets"
  fi
}

# AIDER->COMMIT
# ------------------------------------------------
function aider-commit() {

  # If this isn't a git repo, just return
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
    echo "Not a git repo. Exiting."
    return
  fi

  # If repo is clean, just return
  if git diff-index --quiet HEAD --; then
    echo "Repo is clean. Nothing to commit. Exiting."
    return
  fi

  # Perform the commit
  aider --commit && \
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

# Make `git aider-commit` available as `git ac`
alias git-ac=aider-commit
alias ac=aider-commit

alias edit-claude-desktop-config="${EDITOR} \"${HOME}/Library/Application Support/Claude/claude_desktop_config.json\""

# AIDER->MAIN
# ------------------------------------------------
function a() {
  test -f $HOME/.configs/zshrc-asdf && source $HOME/.configs/zshrc-asdf

  # If the first argument is 'h' or '--help', show help
  if [[ $1 == "h" || $1 == "--help" ]] ; then
    cat << 'EOF'
Usage: a [OPTION] [AIDER_ARGS...]

A wrapper function for aider with convenient shortcuts.

OPTIONS:
  h, --help    Show this help message
  u            Upgrade aider to the latest version
  c            Run aider-commit and exit

EXAMPLES:
  a                    Start aider with default settings
  a u                  Upgrade aider
  a c                  Commit changes with aider
  a --model gpt-4      Start aider with specific model
  a file1.py file2.py  Edit specific files with aider

DEFAULT SETTINGS:
  • Dark mode enabled
  • Auto-commits disabled
  • All other aider arguments passed through

For full aider documentation, see: https://aider.chat/docs/
EOF
    return
  fi

  # If the first argument is 'u', upgrade aider
  if [[ $1 == "u" ]] ; then
    shift
    pip install --upgrade aider-chat
    echo "AIDER upgraded."
    return
  fi

  # If the first argument is 'c', commit with aider and exit
  if [[ $1 == "c" ]] ; then
    aider-commit
    return
  fi

  # AIDER_MODEL="gpt-4-1106-preview"
  # clear
  # echo "AIDER_MODEL: $AIDER_MODEL"
  # echo

  # If there are more arguments, pass them to aider
  if [[ $# -gt 0 ]] ; then
    echo "AIDER: $*"
    echo
  fi

  aider \
    --dark-mode \
    --no-auto-commits \
    $*
    # --model $AIDER_MODEL \
}

# ------------------------------------------------
function autopage() {
    # Get the height of the terminal
    local terminal_height=$(tput lines)

    # Use a buffer to count lines without consuming them
    local buffer
    local line_count=0

    # Read from stdin line by line
    while IFS= read -r line; do
        # Increment line count and append to buffer
        ((line_count++))
        buffer+="$line"$'\n'

        # Break the loop if line count exceeds terminal height
        if (( line_count > terminal_height )); then
            break
        fi
    done

    # Check if we need to use a pager
    if (( line_count > terminal_height )); then
        # Output the buffer and continue reading from stdin
        { echo -n "$buffer"; cat; } | less
    else
        # Just output the buffer
        echo -n "$buffer"
    fi
}

alias ap=autopage

# Codebase Analysis
# ------------------------------------------------
function codebase-analysis() {
    local exclude_dirs="node_modules|.git|dist|build|__pycache__|.next|target|vendor|coverage|.pytest_cache"

    # Add any additional directories you want to exclude from the arguments
    for dir in "$@"; do
        exclude_dirs="$exclude_dirs|$dir"
    done

    # Print summary header
    echo -e "\n🔍 CODEBASE ANALYSIS"
    echo "====================="
    echo "Analyzing codebase in: $(pwd)"
    echo "Excluding directories: $exclude_dirs"
    echo

    echo "📁 FILE STRUCTURE"
    echo "=================="
    tree -I "$exclude_dirs" --dirsfirst --noreport

    echo -e "\n📊 CODE ANALYSIS"
    echo "================"
    scc --exclude-dir node_modules --exclude-dir .git --exclude-dir dist --exclude-dir build --exclude-dir __pycache__ .

    echo -e "\n🧑‍💻 GIT REPO ANALYSIS"
    echo "==================="
    git log --pretty=format:"%h %ad | %s%d [%an]" --date=short | head -20


    echo -e "\n📈 GIT STATISTICS"
    echo "==================="
    git shortlog -sne | head -20


    echo -e "\n📦 DEPENDENCIES & FRAMEWORKS"
    echo "============================="
    syft . --exclude "**/node_modules/**" --exclude "**/.git/**" --exclude "**/dist/**" --exclude "**/build/**" -o table 2>/dev/null | head -20
}

# Kubernetes
# ------------------------------------------------
alias kc="kubectl"
alias kp="kube-prompt"
alias mk="minikube"

function gitignore-io() {
  curl -L -s https://www.gitignore.io/api/$@;
}

function T() {
  # If we're not in a git repo, just execute tree
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
    tree $@
    return
  fi

  # If we're in a git repo, execute tree with the git ls-tree output
  git ls-tree -r --name-only HEAD . | tree --fromfile
}

# ------------------------------------------------
# CD ---------------------------------------------
# ------------------------------------------------
function _virtualenv_chpwd() {
  if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" != $PWD ]] ; then
    deactivate
  fi

  test -f ./venv/bin/activate && . ./venv/bin/activate
  test -f ./env/bin/activate && . ./env/bin/activate
}

# Notes
# ------------------------------------------------
alias n="notes"
alias nn="notes notes ${@:2}"
alias ng="notes --grep"
alias nls="notes --list"
alias rem="notes-reminders"

# SSH
# ------------------------------------------------
alias S="ssh server.local || ssh server"
alias A="ssh ai"
alias V="ssh virtual-linux"

# ------------------------------------------------
# ASDF -------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.configs/zshrc-asdf

# ------------------------------------------------
# AUTOJUMP ---------------------------------------
# ------------------------------------------------
# [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# ------------------------------------------------
# ZPLUG ------------------------------------------
# ------------------------------------------------
if [[ -f ~/.zplug/init.zsh ]]; then
  source $HOME/.configs/zshrc-zplug-init.sh
else
  echo "Warning: zplug not installed."
  sleep 0.5
fi

# ------------------------------------------------
# SOURCE->USER -----------------------------------
# ------------------------------------------------

# Load secrets from multiple locations
load-secrets --quiet

# Source various scripts embedded in repos
_repos=(
  prwd/prwd.zsh
  g/g.zsh
  notes/notes.zsh
  project/project.zsh
)

for _repo in $_repos; do
  source-if-exists $HOME/.repositories/$_repo
done

unset _repos _repo

# ------------------------------------------------
# PWD --------------------------------------------
# ------------------------------------------------
if ( $ON_LINUX ) ; then
  export PWD_BIND_TO_WORKSPACE=true
fi

# ------------------------------------------------
# ANSIBLE ----------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/host-setup/bin"
export ANSIBLE_NOCOWS=1

# ------------------------------------------------
# TUNNEL -----------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/tunnel/bin"

# ------------------------------------------------
# KEY-BINDINGS->PROMPT-DUMPS->DEFINITIONS --------
# ------------------------------------------------

# 'ssh'
# ------------------------------------------------
_define_buffer_dump ssh '^[s' "ssh "

# 'g cmp "<cursor>"'
# ------------------------------------------------
_define_buffer_dump g_cmp '^[g' "g cmp \"" "\""

# 'ai ask "<cursor>"'
# ------------------------------------------------
_define_buffer_dump ai_ask '^[a' "ai ask \"" "\""

# 'micro'
# ------------------------------------------------
#_define_buffer_dump micro '^[m' "micro "
#_define_buffer_dump micro_looped '^[M' "micro -l "

# 'hosts'
# ------------------------------------------------
_define_buffer_dump hosts '^[h' "hosts "


# LAN Prefix
# ------------------------------------------------
_define_buffer_dump ip_lan '^[1' $LAN_PREFIX

# ------------------------------------------------
# PLEX -------------------------------------------
# ------------------------------------------------
export PLEX_HOME=$HOME/.media/plex

# ------------------------------------------------
# HEROKU -----------------------------------------
# ------------------------------------------------
### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# ------------------------------------------------
# SPECIAL->MICRO ---------------------------------
# ------------------------------------------------
command-exists raspi-config && alias raspi-config="sudo raspi-config"

# ------------------------------------------------
# ZSHRC-MARKS ------------------------------------
# ------------------------------------------------
alias to="jump"

function tos {
  jump $* && sw
}

# ------------------------------------------------
# SOURCE->HOST-SPECIFIC --------------------------
# ------------------------------------------------
source-if-exists $HOME/.configs/zshrc-specific-to-os/`uname`.zsh
source-if-exists $HOME/.configs/zshrc-specific-to-host/$HOST.zsh

# ------------------------------------------------
# GIT-SUBMODULE-TOOLS ----------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/git-submodule-tools/bin"

# ------------------------------------------------
# RUST -------------------------------------------
# ------------------------------------------------
export PATH=`extend-path "$HOME/.cargo/bin"`

# ------------------------------------------------
# G ----------------------------------------------
# ------------------------------------------------
function G() {
  case $1 in
    f)
      local _count_repos=`gr | wc -l | awk '{print $1}'`
      echo -n "Fetching $_count_repos Repositories..."
      # FIX: This will not fail with a warning/fatal error.
      silence gr git fetch
      echo " Done."
      G
      ;;
    u)
      if [[ -z $2 ]] ; then
        gr git up && G
        return
      fi

      _original_pwd=$PWD
      cd `bookmark-lookup $2`
      git up
      cd $_original_pwd

      ;;
    *)

      if [[ $# -gt 0 ]] ; then
        gr $* && G
        exit $?
      fi

      gr status
      ;;
  esac
}

# http://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
#
# Example: echo "Cloning into 'machine'..." | regex-capture "Cloning into '(.*)'\.\.\.$"'
function regex-capture { gawk 'match($0,/'$1'/, ary) {print ary['${2:-'1'}']}'; }

# FIX: Handle errors
function repo() {
  cd $HOME/.repositories
  local _name=`git clone $* |& regex-capture "Cloning into '(.*)'\.\.\.$.*"`
  cd $_name
}

alias grfm="git rebase-from master --yes"

# function _ls_home_dir_macos_clean() {
#   ls -l --color=always $HOME | grep --color=always -Ev 'Applications|Clean|Creative Cloud Files|Desktop|Documents|Downloads|Google Drive|Library|Movies|Music|Pictures|Postman|Public|Remotes|Repositories|Shared' | grep --color=always -v 'total '
# }
#
# CD() {
#   cd $*
#
#   if [[ $PWD == $HOME ]] ; then
#     _ls_home_dir_macos_clean
#   else
#     ls -lh --color=always
#   fi
#
#   echo "CD"
# }

# ------------------------------------------------
# COMPLETIONS->MICRO -----------------------------
# ------------------------------------------------
_micro_cpl() {
  reply=()
  for suffix in `micro --ls | sed "s/micro-//"`
  do
    reply[$(($#reply+1))]=$suffix
  done
}

# compctl -K _micro_cpl micro

# ------------------------------------------------
# FZF --------------------------------------------
# ------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------------------------------------------------
# HUB --------------------------------------------
# ------------------------------------------------
#if command-exists hub; then
  #alias git="hub"
#fi

# ================================================
# MAIN ===========================================
# ================================================
export ZSHRC_SOURCED=true
export SKIP_ZSH_CLEAR=true

# Check if we're in an interactive shell because
# we only clear when we are. We don't want to
# clear when we're sourcing this from a script.
if [[ -z $SKIP_ZSH_CLEAR ]] ; then
  if [[ $0 == "-zsh" || $0 == "zsh" ]] ; then
    clear
  fi
fi

#if ( $ON_LINUX && ! x-server-is-running && test -z $SSH_CLIENT ) ; then
  #echo "Starting X server in: 1 second..."
  #sleep 1
  #startx
#else
  #clear
#fi

if [[ -n $TUNNEL_LOCATION ]] ; then
  echo "Acting as Tunnel in: `stylize $TUNNEL_LOCATION`"

  if pulseaudio --check; then
    echo "       Pulseaudio: Running"
  else
    echo "       Pulseaudio: `stylize NOT RUNNING`"
  fi
  echo

fi

# ------------------------------------------------
# TMUX -------------------------------------------
# ------------------------------------------------

# http://askubuntu.com/questions/441744/pressing-enter-produces-m-instead-of-a-newline
stty sane

if [[ $TMUX_EACH_SESSION = "true" ]] ; then
  if command-exists tmux; then
    case $- in *i*)
      if [ -z "$TMUX" ]; then exec tmux; fi;;
    esac
  fi
fi

# tmuxp
export DISABLE_AUTO_TITLE='true'

# ------------------------------------------------
# BREW -------------------------------------------
# ------------------------------------------------
# https://github.com/settings/tokens
export HOMEBREW_GITHUB_API_TOKEN=5e62b045f2eeaa1320c544a2ff0e6cc0c3b7fb40

# ------------------------------------------------
# MPM (DEVELOPMENT) ------------------------------
# ------------------------------------------------
if [[ ! `command-exists mpm` && -d $HOME/.repositories/mpm-cr ]] ; then
  export PATH=$PATH:$HOME/.repositories/mpm-cr/bin
fi

# ------------------------------------------------
# KUBECTL ----------------------------------------
# ------------------------------------------------
command-exists kubectl && source <(kubectl completion zsh)

# ------------------------------------------------
# GIT-EXTRAS -------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/git-extras/etc/git-extras-completion.zsh

# ------------------------------------------------
# DLDC -------------------------------------------
# ------------------------------------------------
export PATH=`extend-path "$HOME/.repositories/dldc/bin"`

# ------------------------------------------------
# CONFIG->PRWD -----------------------------------
# ------------------------------------------------
export PRWD_BIND_TO_TMUX=true

# ------------------------------------------------
# HOTKEYS ----------------------------------------
# ------------------------------------------------
# Ctrl-G
# bindkey "^G" gw

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
source-if-exists /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ -f /usr/local/share-/zsh-completions ]] ; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# ------------------------------------------------
# CONDA ------------------------------------------
# ------------------------------------------------
test -f $HOME/.miniconda3/etc/profile.d/conda.sh && source $HOME/.miniconda3/etc/profile.d/conda.sh

# ------------------------------------------------
# GCLOUD -----------------------------------------
# ------------------------------------------------
_google_cloud_sdk_path="$HOME/.google-cloud-sdk"

if test -d $_google_cloud_sdk_path; then
  # The next line updates PATH for the Google Cloud SDK.
  . "${_google_cloud_sdk_path}/path.zsh.inc"

  # The next line enables shell command completion for gcloud.
  . "${_google_cloud_sdk_path}/completion.zsh.inc"
fi

# ------------------------------------------------
# ATUIN ------------------------------------------
# ------------------------------------------------
if [[ "$USE_ATUIN" == "true" ]] && ( command-exists atuin ) ; then
  # Only bind Ctrl-R, not up arrow (--disable-up-arrow)
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ------------------------------------------------
# ZOXIDE -----------------------------------------
# ------------------------------------------------
if ( command-exists zoxide ) ; then
  eval "$(zoxide init zsh)"

  export _ZO_EXCLUDE_DIRS="$HOME:$HOME/.enct-*"

  alias cd="z"
fi

# ------------------------------------------------
# POETRY -----------------------------------------
# ------------------------------------------------
if ( command-exists poetry ) ; then
  # poetry completions zsh > ~/.zfunc/_poetry
  # fpath+=~/.zfunc
  # autoload -Uz compinit && compinit
fi

# ------------------------------------------------
# PROMPT -----------------------------------------
# ------------------------------------------------
source $HOME/.configs/zshrc-prompt

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/bit bit

# ------------------------------------------------
# AI/CHATGPT -------------------------------------
# ------------------------------------------------
AI_AC_ZSH_SETUP_PATH=$HOME/Library/Caches/ai/autocomplete/zsh_setup && test -f $AI_AC_ZSH_SETUP_PATH && source $AI_AC_ZSH_SETUP_PATH; # ai autocomplete setup

# ------------------------------------------------
# BREW -------------------------------------------
# ------------------------------------------------
function br() {
    # Check if brew command exists
    if ! command -v brew > /dev/null; then
        echo "Error: brew command not found."
        return 1
    fi

    brew "$@"

    # Only proceed if the command was 'install' or 'upgrade'
    if [[ "$1" == "install" || "$1" == "upgrade" ]]; then

        # Create a temporary Brewfile
        local temp_brewfile=$(mktemp)
        brew bundle dump --force --file="$temp_brewfile"

        # Check for differences
        if ! diff -q "$temp_brewfile" ~/.configs/Brewfile > /dev/null; then
            echo "Differences detected between your Brewfile and the current setup."
            echo -n "Update the Brewfile to match current setup? (y/n) "
            read -r answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                mv "$temp_brewfile" ~/.configs/Brewfile
                echo "Brewfile updated!"
            else
                echo "Brewfile not updated."
                rm -f "$temp_brewfile"
            fi
        else
            # Cleanup if no differences are found
            rm -f "$temp_brewfile"
        fi
    fi
}

# ------------------------------------------------
# YAZI -------------------------------------------
# ------------------------------------------------
function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ------------------------------------------------
# TEA --------------------------------------------
# ------------------------------------------------
test -d "$HOME/.tea" && source <("$HOME/.tea/tea.xyz/v*/bin/tea" --magic=zsh --silent)

source-if-exists $HOME/.cargo/env

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/Users/erik/.cache/lm-studio/bin"

# bun completions
[ -s "/Users/erik/.bun/_bun" ] && source "/Users/erik/.bun/_bun"

. "$HOME/.cargo/env"

# Added by Windsurf
export PATH="/Users/erik/.codeium/windsurf/bin:$PATH"

# ------------------------------------------------
# QUMIS ------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.configs/zsh/qumis.zsh

# ------------------------------------------------
# GHOSTTY ----------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.config/ghostty/ghostty-colors.zsh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/erik/.lmstudio/bin"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/erik/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

export PATH="$PATH:/Users/erik/.local/bin"

function cld() {

  CLAUDE_PATH=~/.local/bin/claude
  local extra_args=()

  # Handle --yes flag for skipping permissions
  if [[ "$1" == "--yes" ]]; then
    echo "⚠️  Warning: Running with --dangerously-skip-permissions - all tool calls will be auto-approved!"
    extra_args+=(--dangerously-skip-permissions)
    shift
  fi

  if [[ -f $CLAUDE_PATH ]] ; then
    SHELL=/opt/homebrew/bin/bash $CLAUDE_PATH "${extra_args[@]}" "$@"
    return
  fi

  echo "Warning: Using system claude command. Consider installing local version at: $CLAUDE_PATH"
  echo

  which claude
  claude -v
  echo
  sleep 5

  SHELL=/opt/homebrew/bin/bash claude "${extra_args[@]}" "$@"

  # SHELL=/opt/homebrew/bin/bash claude "$@"
  #
  # $HOME/.claude/local/claude "$@"

  # if [[ -f ~/.claude/local/claude]]; then
  #   SHELL=/opt/homebrew/bin/bash ~/.claude/local/claude "$@"
  # else
  #   SHELL=/opt/homebrew/bin/bash claude "$@"
  # fi
}

# opencode
export PATH=/Users/erik/.opencode/bin:$PATH

complete -o nospace -C /opt/homebrew/bin/terraform terraform

eval "$(git machete completion zsh)"  # or, if it doesn't work:
source <(git machete completion zsh)

source-if-exists $HOMEBREW_PREFIX/opt/git-extras/share/git-extras/git-extras-completion.zsh

# Added by Antigravity
# export PATH="/Users/erik/.antigravity/antigravity/bin:$PATH"
#
#
# # FROM: https://tonydehnke.com/blog/claude-code-iphone-ssh-zellij/
# # rc = Run Claude: Start new session with auto-generated name
# # Note: Must use -n (--new-session-with-layout) to CREATE a new session.
# # Using --layout with --session tries to ADD to an existing session.
# rc() {
#     zellij -n claude
# }
#
# # rq = Run Qumis: Attach to existing qumis session or start new one
# rq() {
#     # Try to attach - if session is alive this works
#     if ! zellij attach qumis 2>/dev/null; then
#         # Attach failed - delete any dead session and create fresh
#         zellij delete-session qumis 2>/dev/null
#         zellij -s qumis -n qumis
#     fi
# }
#
# # rj = Run Join: Quick attach to session
# rj() {
#     local session="${1:-$(zellij list-sessions | head -1 | awk '{print $1}')}"
#     zellij attach "$session"
# }
#
# # rl = Run List: Interactive session picker with cleanup
# rl() {
#     local sessions=()
#     while IFS= read -r line; do
#         sessions+=("$line")
#     done < <(zellij list-sessions 2>/dev/null)
#
#     if [[ ${#sessions[@]} -eq 0 ]]; then
#         echo "No sessions. Use 'rc' to start one."
#         return 1
#     fi
#
#     echo "Sessions:"
#     local i=1
#     for session in "${sessions[@]}"; do
#         echo "  $i) $session"
#         ((i++))
#     done
#     echo "  c) Clean EXITED sessions"
#     echo "  d) Delete sessions >24h old"
#
#     read -r "choice?Select: "
#
#     case "$choice" in
#         c)
#             local deleted=0
#             for line in "${sessions[@]}"; do
#                 if [[ "$line" == *"EXITED"* ]]; then
#                     local name=$(echo "$line" | awk '{print $1}')
#                     zellij delete-session "$name" 2>/dev/null && ((deleted++))
#                 fi
#             done
#             echo "Deleted $deleted exited session(s)"
#             ;;
#         d)
#             local deleted=0
#             for line in "${sessions[@]}"; do
#                 if [[ "$line" == *"day"* ]]; then
#                     local name=$(echo "$line" | awk '{print $1}')
#                     zellij delete-session --force "$name" 2>/dev/null && ((deleted++))
#                 fi
#             done
#             echo "Deleted $deleted session(s) older than 24h"
#             ;;
#         [0-9]*)
#             local name=$(echo "${sessions[$choice]}" | awk '{print $1}')
#             zellij attach "$name"
#             ;;
#     esac
# }


# --- Private mode / history controls (zsh) -----------------------------------

# Internal state
typeset -g __PRIVATE_MODE=0
typeset -g __PRIVATE_HISTFILE_SAVED=""
typeset -g __PRIVATE_HISTSIZE_SAVED=""
typeset -g __PRIVATE_SAVEHIST_SAVED=""
typeset -g __PRIVATE_EVENTNO_START=0
typeset -g __PRIVATE_TIMER_PID=""

# Enable a prompt indicator (customizable)
typeset -g __PRIVATE_PROMPT_TAG='[%F{red}PRIVATE%f] '

# Hook: prepend tag to prompt when private mode is on
__private_prompt_precmd() {
  if (( __PRIVATE_MODE )); then
    PROMPT="${__PRIVATE_PROMPT_TAG}${PROMPT#${__PRIVATE_PROMPT_TAG}}"
  else
    PROMPT="${PROMPT#${__PRIVATE_PROMPT_TAG}}"
  fi
}

# Ensure the hook is installed once
autoload -Uz add-zsh-hook
add-zsh-hook precmd __private_prompt_precmd

# Wipe any commands entered since private mode started (session memory)
__private_wipe_session_history() {
  # Delete history lines added since we entered private mode.
  # event numbers are 1-based and monotonically increase.
  local start=$__PRIVATE_EVENTNO_START
  local now=$HISTCMD

  # If history isn't active, HISTCMD still advances; try best-effort.
  if (( start > 0 && now >= start )); then
    local i
    for (( i = now; i >= start; i-- )); do
      fc -p >/dev/null 2>&1 || true   # no-op safeguard
      fc -d $i >/dev/null 2>&1 || true
    done
  fi
}

private_on() {
  if (( __PRIVATE_MODE )); then
    echo "private mode: already ON"
    return 0
  fi

  __PRIVATE_MODE=1

  # Save current history settings
  __PRIVATE_HISTFILE_SAVED="${HISTFILE:-}"
  __PRIVATE_HISTSIZE_SAVED="${HISTSIZE:-}"
  __PRIVATE_SAVEHIST_SAVED="${SAVEHIST:-}"

  # Mark where we started so we can wipe later
  __PRIVATE_EVENTNO_START=$HISTCMD

  # Turn off history in memory + file
  setopt HIST_NO_STORE            # don't store in history list
  unsetopt INC_APPEND_HISTORY     # don't append incrementally
  unsetopt SHARE_HISTORY          # don't share between sessions
  unset HISTFILE                  # don't write to a file
  HISTSIZE=0
  SAVEHIST=0

  echo "private mode: ON (history disabled)"
}

private_off() {
  if (( ! __PRIVATE_MODE )); then
    echo "private mode: already OFF"
    return 0
  fi

  # Stop any pending timer
  if [[ -n "$__PRIVATE_TIMER_PID" ]]; then
    kill "$__PRIVATE_TIMER_PID" >/dev/null 2>&1 || true
    __PRIVATE_TIMER_PID=""
  fi

  # Wipe what was typed during private mode from session memory (best effort)
  __private_wipe_session_history

  __PRIVATE_MODE=0

  # Restore history settings
  unsetopt HIST_NO_STORE
  setopt INC_APPEND_HISTORY SHARE_HISTORY

  if [[ -n "$__PRIVATE_HISTFILE_SAVED" ]]; then
    export HISTFILE="$__PRIVATE_HISTFILE_SAVED"
  else
    export HISTFILE=~/.zsh_history
  fi

  HISTSIZE="${__PRIVATE_HISTSIZE_SAVED:-50000}"
  SAVEHIST="${__PRIVATE_SAVEHIST_SAVED:-50000}"

  # Reload persisted history file
  fc -R "$HISTFILE" 2>/dev/null

  echo "private mode: OFF (history enabled)"
}

toggle_history() {
  if (( __PRIVATE_MODE )); then
    private_off
  else
    private_on
  fi
}

# Run a single command with history disabled (even if currently enabled)
private() {
  # Usage: private <command...>
  if (( $# == 0 )); then
    echo "usage: private <command...>"
    return 2
  fi

  local was_private=$__PRIVATE_MODE
  if (( ! was_private )); then
    private_on
  fi

  # Run the command without adding to history
  command "$@"
  local rc=$?

  if (( ! was_private )); then
    private_off
  fi

  return $rc
}

# Auto-enable private mode for N minutes, then restore
private_for() {
  # Usage: private_for 10   (minutes)
  local mins="$1"
  if [[ -z "$mins" || "$mins" -le 0 ]]; then
    echo "usage: private_for <minutes>"
    return 2
  fi

  private_on

  # Cancel existing timer if any
  if [[ -n "$__PRIVATE_TIMER_PID" ]]; then
    kill "$__PRIVATE_TIMER_PID" >/dev/null 2>&1 || true
    __PRIVATE_TIMER_PID=""
  fi

  # Background timer (disowned) to switch off later
  (
    sleep "$(( mins * 60 ))"
    # Only turn off if still in private mode
    if (( __PRIVATE_MODE )); then
      private_off
    fi
  ) &!

  __PRIVATE_TIMER_PID=$!
  echo "private mode: will turn OFF in ${mins} minute(s)"
}

# ---------------------------------------------------------------------------
# End private mode / history controls
