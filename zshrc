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
source /etc/zsh/shared

# ------------------------------------------------
# ALIASES ----------------------------------------
# ------------------------------------------------
# FIX: Add export -f to some of these for script use
alias T="tree"
alias e="edit-common"
alias arp="sudo arp"
alias route="sudo route"
alias rg="rg --smart-case"
alias tm="tmuxinator"
alias tms="tmuxinator start"
alias lg="lazygit"
alias ncdu="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias ping="prettyping --nolegend"
alias dsp="docker system prune --force"

# Kubernetes
# ------------------------------------------------
alias kc="kubectl"
alias kp="kube-prompt"
alias mk="minikube"

function gitignore-io() {
  curl -L -s https://www.gitignore.io/api/$@;
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
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# ------------------------------------------------
# ANTIBODY ---------------------------------------
# ------------------------------------------------
# function antibody-install() {
#   antibody bundle < $HOME/.configs/zshrc-antibody-plugins.txt > $HOME/.configs/zshrc-antibody-plugins.sh
# }

if command-exists antibody; then
  source <(antibody init)
  antibody bundle < $HOME/.configs/zshrc-antibody-plugins.txt
else
  echo "Warning: antibody not installed."
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

CD() {
  cd $* && ls -lh
}

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

compctl -K _micro_cpl micro

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
# MONGOOSE-OS (MOS) ------------------------------
# ------------------------------------------------
if [[ -d $HOME/.mos ]] ; then
  export MOS_PORT=/dev/tty.SLAB_USBtoUART
  export PATH=$PATH:$HOME/.mos/bin
fi

# ------------------------------------------------
# FLUTTER ----------------------------------------
# ------------------------------------------------
if [[ -d $HOME/.repositories/flutter ]] ; then
  export PATH=$PATH:$HOME/.repositories/flutter/bin
fi

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

# chmod go-w '/usr/local/share'

# ------------------------------------------------
# ANACONDA ---------------------------------------
# ------------------------------------------------
_anaconda_path="$HOME/.anaconda3"

if [ -f "$_anaconda_path/etc/profile.d/conda.sh" ]; then
  . "$_anaconda_path/etc/profile.d/conda.sh"
elif [ -d $_anaconda_path ] ; then
  export PATH="$_anaconda_path/bin:$PATH"
fi

unset _anaconda_path

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
# ------------------------------------------------
# ------------------------------------------------
# export PATH="${PATH}:${HOME}/Library/Android/sdk/platform-tools"
# export PATH="${PATH}:${HOME}/Library/Android/sdk/tools"
# export PATH="${PATH}:${HOME}/Library/Android/sdk/emulator"

# ------------------------------------------------
# PROMPT -----------------------------------------
# ------------------------------------------------
source $HOME/.configs/zshrc-prompt

