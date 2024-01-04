# ================================================
# ZSHRC ==========================================
# ================================================

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

# ------------------------------------------------
# FUNCTIONS --------------------------------------
# ------------------------------------------------
function hr() {

    printf '\n'

    # Switch to line drawing character set
    printf '\e(0'

    # Repeat the 'q' character across the width of the terminal
    printf 'q%.0s' $(seq $(tput cols))

    # Switch back to the regular character set
    printf '\e(B'
}


# SEE: aider
function aider-commit() {

  # If this isn't a git repo, just exit
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
    echo "Not a git repo. Exiting."
    exit
  fi

  # If repo is clean, just exit
  if git diff-index --quiet HEAD --; then
    echo "Repo is clean. Nothing to commit. Exiting."
    exit
  fi

  # Perform the commit, and push if the user says so
  aider --commit && \
    git show -1 | condpipe && \
    echo -n "Push to default? (Y/n): " && \
    read -r answer && \
    if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "" ]]; then
      git push
    fi
}

# SEE: aider
function a() {
  test -f $HOME/.configs/zshrc-asdf && source $HOME/.configs/zshrc-asdf

  # If the first argument is 'u', upgrade aider
  if [[ $1 == "u" ]] ; then
    shift
    pip install --upgrade aider-chat
    clear
  fi

  # If the first argument is 'c', commit with aider and exit
  if [[ $1 == "c" ]] ; then
    aider-commit
    return
  fi

  AIDER_MODEL="gpt-4-1106-preview"
  clear
  echo "AIDER_MODEL: $AIDER_MODEL"
  echo
  # If there are more arguments, pass them to aider
  if [[ $# -gt 0 ]] ; then
    echo "AIDER: $*"
    echo
  fi
  aider \
    --dark-mode \
    --no-auto-commits \
    --model $AIDER_MODEL \
    $*
}

function condpipe() {
    # Set default line count to the number of columns in the current terminal
    local n=${1:-$(tput cols)}

    # Capture the command output
    local output=$(cat)
    local lines=$(echo "$output" | wc -l | tr -d ' ')

    # Decide whether to pipe to moar based on line count
    if (( lines > n )); then
        echo "$output" | moar
    else
        echo "$output"
    fi
}

# Usage:
# your_command | condpipe [line_count]
# Example:
# git show --color | condpipe 30


function jl() {
  jupyter lab --notebook-dir "${HOME}/.jupyter-notebooks"
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

# Source sensitive ENV vars (~/.env)
source-if-exists $HOME/.env

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
# WHISPER/WHISPER.NVIM ---------------------------
# ------------------------------------------------
export WHISPER_CPP_HOME=$HOME/.repositories/whisper.cpp


# JINA_CLI_BEGIN

## autocomplete
if [[ ! -o interactive ]]; then
    return
fi

compctl -K _jina jina

_jina() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(jina commands)"
  else
    completions="$(jina completions ${words[2,-2]})"
  fi

  reply=(${(ps:
:)completions})
}

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# JINA_CLI_END
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

test -d "$HOME/.tea" && source <("$HOME/.tea/tea.xyz/v*/bin/tea" --magic=zsh --silent)
