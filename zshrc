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
# G ----------------------------------------------
# ------------------------------------------------

function _dump_g_cmp() {
  LBUFFER+='g cmp "'; RBUFFER+='"'
}

# Bind to wrap buffer with 'g cmp "<cursor>"'
zle -N _dump_g_cmp
#bindkey '^G' _dump_g_cmp
bindkey '^[g' _dump_g_cmp

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
# ------------------------------------------------
# ------------------------------------------------
export ZSHRC_SOURCED=true

alias n="notes"

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------
if ( $ON_LINUX && ! x-server-is-running && test -z $SSH_CLIENT ) ; then
  echo "Starting X server in: 1 second..."
  sleep 1
  startx
fi

