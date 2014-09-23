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

# Source various scripts
source-if-exists $HOME/.persistent-working-directory/persistent-working-directory.zsh
source-if-exists $HOME/.g/g.zsh
source-if-exists $HOME/.repositories/notes/notes.zsh
source-if-exists $HOME/.repositories/fantravel-v2/system/fantravel.sh
source-if-exists $HOME/.repositories/project/project.zsh
source-if-exists $HOME/.repositories/git-flow-completion/git-flow-completion.zsh

# ------------------------------------------------
# PWD --------------------------------------------
# ------------------------------------------------
if [[ `uname` != "Darwin" ]] ; then
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
if [[ `uname ` == "Darwin" ]] ; then
  alias d="cd ~/Desktop && clear && pwd && ls -1"
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
