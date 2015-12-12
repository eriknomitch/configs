# ------------------------------------------------
# INITIAL-CWD ------------------------------------
# ------------------------------------------------

#if [[ -n $ZSHRC_SOURCED ]] ; then
  #return
#fi

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


# Source various scripts
source-if-exists $HOME/.repositories/prelang/aci/system/shell/development-utility.zsh
source-if-exists $HOME/.persistent-working-directory/persistent-working-directory.zsh
source-if-exists $HOME/.g/g.zsh
source-if-exists $HOME/.repositories/notes/notes.zsh
source-if-exists $HOME/.repositories/fantravel-v2/system/fantravel.sh
source-if-exists $HOME/.repositories/project/project.zsh
source-if-exists $HOME/.repositories/git-flow-completion/git-flow-completion.zsh

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
# ------------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.zshrc.host-specific

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
alias n="notes"
alias e="edit"
alias rem="notes-reminders"
alias grs="gr status"
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
fi

