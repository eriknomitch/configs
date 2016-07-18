# ------------------------------------------------
# ENV->GLOBALS -----------------------------------
# ------------------------------------------------

# ------------------------------------------------
# INITIAL-CWD ------------------------------------
# ------------------------------------------------

# This is used in some scripts to force an initial working directory.
if [[ -n $INITIAL_CWD ]] ; then
  cd $INITIAL_CWD
fi

# ------------------------------------------------
# ENV --------------------------------------------
# ------------------------------------------------
export SUBNET_PREFIX="192.168.1."

# ------------------------------------------------
# SOURCE -----------------------------------------
# ------------------------------------------------

# Source zshrc-oh-my-zsh first so we can override the theme/prompt
source $HOME/.configs/zshrc-oh-my-zsh

# Source the shared zshrc (shared between users and root)
source /etc/zshrc-shared

# Source sensitive ENV vars (~/.env)
source-if-exists $HOME/.env

# Source various scripts embedded in repos
_repos=(
  prelang/aci/system/shell/development-utility.zsh
  persistent-working-directory/persistent-working-directory.zsh
  g/g.zsh
  notes/notes.zsh
  project/project.zsh
  git-flow-completion/git-flow-completion.zsh
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
# RBENV ------------------------------------------
# ------------------------------------------------
export RBENV_ROOT="${HOME}/.rbenv"

if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi

# ------------------------------------------------
# ANSIBLE ----------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/host-setup/bin"
export ANSIBLE_NOCOWS=1

# ------------------------------------------------
# PUCK -------------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/puck/bin"

# ------------------------------------------------
# THEFUCK ----------------------------------------
# ------------------------------------------------
command-exists thefuck && eval "$(thefuck --alias)"

# ------------------------------------------------
# KEY-BINDINGS->PROMPT-DUMPS->DEFINER ------------
# ------------------------------------------------
# Meta definer for dump commands
function _define_buffer_dump() {

  local _function_suffix=$1
  local _bindkey=$2
  local _lbuffer=$3
  local _rbuffer=$4

  local _function_name="_dump_$_function_suffix"

  test -n $_rbuffer || _rbuffer=''

  eval "
function $_function_name() {
  LBUFFER+='$_lbuffer'; RBUFFER+='$_rbuffer'
  #expand-or-complete-with-dots
  zle expand-or-complete
  zle redisplay
}

zle -N $_function_name
bindkey '$_bindkey' $_function_name
  "

}

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
_define_buffer_dump micro '^[m' "micro "
_define_buffer_dump micro_looped '^[M' "micro -l "

# 'hosts'
# ------------------------------------------------
_define_buffer_dump hosts '^[h' "hosts "


# LAN Prefix
# ------------------------------------------------
_define_buffer_dump ip_lan '^[1' $LAN_PREFIX

# 'puck '
# ------------------------------------------------
_define_buffer_dump puck '^[p' "puck-ssh "

# ------------------------------------------------
# AMAZON -----------------------------------------
# ------------------------------------------------
export EC2_KEYPAIR=default
export EC2_URL=https://ec2.us-west-1.amazonaws.com
export EC2_PRIVATE_KEY=$HOME/.ec2/pk-Y3LLWLPQGW2WN3RIOOKTHRE5MNJFEWNC.pem
export EC2_CERT=$HOME/.ec2/cert-Y3LLWLPQGW2WN3RIOOKTHRE5MNJFEWNC.pem
export JAVA_HOME=/usr/lib/jvm/java-6-sun/

# ------------------------------------------------
# ANDROID ----------------------------------------
# ------------------------------------------------
export JAVA_HOME=/usr/lib/jvm/java-6-sun/

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
# SPECIAL->DARWIN --------------------------------
# ------------------------------------------------
if ( $ON_DARWIN ) ; then

  # "cd" Aliases
  alias d="cd ~/Desktop && clear && pwd && ls -1"
  alias dl="cd ~/Downloads && clear && pwd && ls -1"

  # Other Aliases
  alias updatedb="sudo /usr/libexec/locate.updatedb"
  alias il="irc-loop"
  alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc"

  source-if-exists /sw/bin/init.sh

fi

# ------------------------------------------------
# SPECIAL->MICRO ---------------------------------
# ------------------------------------------------
if ( $ON_MICRO ) ; then
  alias raspi-config="sudo raspi-config"
fi

# ------------------------------------------------
# DISPLAY ----------------------------------------
# ------------------------------------------------

# For remote sessions, this exports the display to the main
# display of the machine.
expdisp

# ------------------------------------------------
# ZSHRC-MARKS ------------------------------------
# ------------------------------------------------
alias to="jump"

function tos {
  jump $* && sw
}

# ------------------------------------------------
# SPINNER ----------------------------------------
# ------------------------------------------------
#function spinner()
#{
    #local pid=$!
    #local delay=0.1
    #local spinstr='|/-\'
    #while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        #local temp=${spinstr#?}
        #printf " [%c]  " "$spinstr"
        #local spinstr=$temp${spinstr%"$temp"}
        #sleep $delay
        #printf "\b\b\b\b\b\b"
    #done
    #printf "    \b\b\b\b"
#}

# ------------------------------------------------
# SOURCE->HOST-SPECIFIC --------------------------
# ------------------------------------------------
source-if-exists $HOME/.configs/zshrc-specific-to-os/`uname`.zsh
source-if-exists $HOME/.configs/zshrc-specific-to-host/$HOST.zsh

# FIX: Use short hostname or something else?
if ( $ON_MICRO ) ; then
  source-if-exists $HOME/.configs/zshrc-specific-to-group/micro.zsh
fi

if [[ -n $PUCK_LOCATION ]] ; then
  ON_MICRO_PUCK=true
fi

if ( $ON_MICRO_PUCK ) ; then
  source-if-exists $HOME/.configs/zshrc-specific-to-group/micro-puck.zsh
fi

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
alias e="edit-common"
alias arp="sudo arp"
alias pls="play-live-stream-npr-wbez"

# Notes
# ------------------------------------------------
alias n="notes"
alias nn="notes notes ${@:2}"
alias ng="notes --grep"
alias nls="notes --list"
alias rem="notes-reminders"

# SSH
# ------------------------------------------------
alias S="ssh server"

# ------------------------------------------------
# GIT-SUBMODULE-TOOLS ----------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/git-submodule-tools/bin"

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

_puck_cpl() {
  reply=()
  for suffix in `puck-ssh --list-completions`
  do
    reply[$(($#reply+1))]=$suffix
  done
}

compctl -K _puck_cpl puck-ssh

# ------------------------------------------------
# FZF --------------------------------------------
# ------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
export ZSHRC_SOURCED=true

# Check for shell level 1 so we do not clear in 
# scripts which source this file.
if [[ $SHLVL == 1 ]] ; then
  clear
fi

#if ( $ON_LINUX && ! x-server-is-running && test -z $SSH_CLIENT ) ; then
  #echo "Starting X server in: 1 second..."
  #sleep 1
  #startx
#else
  #clear
#fi

if [[ -n $PUCK_LOCATION ]] ; then
  echo "Acting as Puck in: `stylize $PUCK_LOCATION`"

  if pulseaudio --check; then
    echo "       Pulseaudio: Running"
  else
    echo "       Pulseaudio: `stylize NOT RUNNING`"
  fi
  echo

fi

