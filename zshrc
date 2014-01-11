# ------------------------------------------------
# INITIAL CWD ------------------------------------
# ------------------------------------------------
if [[ -n $INITIAL_CWD ]] ; then
  cd $INITIAL_CWD
fi

# ------------------------------------------------
# SOURCE -----------------------------------------
# ------------------------------------------------
source $HOME/.g/g.zsh
source $HOME/.persistent-working-directory/persistent-working-directory.zsh
source /etc/zshrc-shared
source-if-exists $HOME/.repositories/fantravel-v2/system/fantravel.sh

# ------------------------------------------------
# PWD --------------------------------------------
# ------------------------------------------------
export PWD_BIND_TO_WORKSPACE=true

# ------------------------------------------------
# RVM --------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.rvm/scripts/rvm

# ------------------------------------------------
# PROJECT ----------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/project/project.zsh

# ------------------------------------------------
# PRELANG ----------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/prelang/core/system/core.sh

alias p="prelang"

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
# CUDA -------------------------------------------
# ------------------------------------------------
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/lib/nvidia-current
export LIBRARY_PATH=$LIBRARY_PATH:/usr/lib/nvidia-current

# ------------------------------------------------
# PLEX -------------------------------------------
# ------------------------------------------------
export PLEX_HOME=$HOME/.media/plex

# ------------------------------------------------
# GIT-FLOW-COMPLETION ----------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/git-flow-completion/git-flow-completion.zsh

# ------------------------------------------------
# TO ---------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/to/to.sh

# ------------------------------------------------
# OTHER ------------------------------------------
# ------------------------------------------------
export EDITOR="vim"

if [[ `uname ` == "Darwin" ]] ; then
  alias d="cd ~/Desktop && clear && pwd && ls -1"
fi

expdisp

# ------------------------------------------------
# TEMPORARY --------------------------------------
# ------------------------------------------------
export PATH=$PATH:$HOME/notifier

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

export META_PATH_ROOT=$HOME/.meta
export META_PATH_ASDF=$HOME/.asdf

