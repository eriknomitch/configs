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

# ------------------------------------------------
# PUCK -------------------------------------------
# ------------------------------------------------
export PATH="$PATH:$HOME/.repositories/puck/bin"

# ------------------------------------------------
# THEFUCK ----------------------------------------
# ------------------------------------------------
command-exists thefuck && eval "$(thefuck --alias)"

# ------------------------------------------------
# ANSIBLE ----------------------------------------
# ------------------------------------------------
export ANSIBLE_NOCOWS=1

# ------------------------------------------------
# KEY-BINDINGS->PROMPT-DUMPS----------------------
# ------------------------------------------------

# 'g'
# ------------------------------------------------
# Bind to wrap buffer with 'g cmp "<cursor>"'

function _dump_g_cmp() {
  LBUFFER+='g cmp "'; RBUFFER+='"'
}

zle -N _dump_g_cmp
bindkey '^[g' _dump_g_cmp

# 'ssh'
# ------------------------------------------------
function _dump_ssh() {
  LBUFFER+='ssh '; RBUFFER+=''
}

zle -N _dump_ssh
bindkey '^[s' _dump_ssh

# 'micro'
# ------------------------------------------------
function _dump_micro() {
  LBUFFER+='micro '; RBUFFER+=''
}

zle -N _dump_micro
bindkey '^[m' _dump_micro

# 'hosts'
# ------------------------------------------------
function _dump_hosts() {
  LBUFFER+='hosts '; RBUFFER+=''
}

zle -N _dump_hosts
bindkey '^[h' _dump_hosts

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
  alias d="cd ~/Desktop && clear && pwd && ls -1"
  alias Do="cd ~/Downloads && clear && pwd && ls -1"
  alias updatedb="sudo /usr/libexec/locate.updatedb"
  alias il="irc-loop"

  source-if-exists /sw/bin/init.sh

  if [[ -z $ITERM_PROFILE ]] ; then
    #echo "REMINDER: Use iTerm!"
  fi
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

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
alias n="notes"
alias e="edit-common"
alias rem="notes-reminders"
alias nn="notes notes ${@:2}"

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
      gr git up && G
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

_micro_cpl() {
  reply=()
  for suffix in `cat ~/.ssh/config | \grep "^Host micro-" | sed "s/Host micro-//"`
  do
    reply[$(($#reply+1))]=$suffix
  done
}

CD() {
  cd $* && ls -lh
}

compctl -K _micro_cpl micro

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
export ZSHRC_SOURCED=true

if ( $ON_LINUX && ! x-server-is-running && test -z $SSH_CLIENT ) ; then
  echo "Starting X server in: 1 second..."
  sleep 1
  startx
else
  clear
fi

if [[ -n $PUCK_LOCATION ]] ; then
  echo "Acting as Puck in: `stylize $PUCK_LOCATION`"
fi

