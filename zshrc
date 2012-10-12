# ------------------------------------------------
# INITIAL CWD ------------------------------------
# ------------------------------------------------
if [[ -n $INITIAL_CWD ]] ; then
  cd $INITIAL_CWD
fi

if [[ ! -f $HOME/.zsh-wd ]] ; then
  echo $HOME > $HOME/.zsh-wd
fi

# ------------------------------------------------
# SOURCE -----------------------------------------
# ------------------------------------------------
source /etc/zshrc-shared

# ------------------------------------------------
# RVM --------------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.rvm/scripts/rvm

# ------------------------------------------------
# PRELANG ----------------------------------------
# ------------------------------------------------
source-if-exists $HOME/.repositories/prelang/system/shell/prelang.sh

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
# FANTRAVEL --------------------------------------
# ------------------------------------------------
if [[ $HOST == "linode-fantravel" ]] ; then
  alias pl="fantravel push-live"
fi

_ft_cpl() {
  reply=()
  for file in `ls /var/www/dev.fantravel/bin | grep "fantravel-" | sed "s/fantravel-//"`
  do
    reply[$(($#reply+1))]=$file
  done
}

compctl -K _ft_cpl fantravel

test -d $HOME/.repositories/fantravel && PATH=$PATH:$HOME/.repositories/fantravel/bin
alias ft="fantravel"

# ------------------------------------------------
# PLEX -------------------------------------------
# ------------------------------------------------
export PLEX_HOME=$HOME/.media/plex

# ------------------------------------------------
# OTHER ------------------------------------------
# ------------------------------------------------
export EDITOR="vim"

expdisp

# ------------------------------------------------
# TEMPORARY --------------------------------------
# ------------------------------------------------
export PATH=$PATH:$HOME/notifier

