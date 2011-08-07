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
# NF ---------------------------------------------
# ------------------------------------------------
#export PATH_NF_ZSHRC=$HOME/.src/nf/nf-zshrc
#source $PATH_NF_ZSHRC

#alias nff="nf --files"

# ------------------------------------------------
# META -------------------------------------------
# ------------------------------------------------
export PATH=$PATH:$HOME/.meta/executables
export PATH=$PATH:$HOME/.meta-materials/bin
export META_PATH_ROOT=$HOME/.meta
export META_PATH_ASDF=$HOME/.asdf # FIX: You can get rid of this by doing a PUSHNEW on the libraries directory?

compctl -k "(--compile zsh-completion-rules   shell   server   scratch   repository  --developer-api-key --device-name psql   program-new   lines-of-code   edit   chip --dry-run --default --passphrase android  )" meta

# ------------------------------------------------
# AMAZON -----------------------------------------
# ------------------------------------------------
export EC2_KEYPAIR=prelang_0_key
export EC2_URL=https://ec2.us-west-1.amazonaws.com
export EC2_PRIVATE_KEY=$HOME/.ec2/pk-7JJ4YP4B73S7OPLJZKFAHZPPS7QL5FG.pem
export EC2_CERT=$HOME/.ec2/cert-7JJ4YP4B73S7OPLJZKFAHZPPS7QL5FG7.pem
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/

# ------------------------------------------------
# OTHER ------------------------------------------
# ------------------------------------------------
#export PATH=$PATH:$HOME/.src/syncfg/
#export PATH=$PATH:$HOME/.arduino/
#export SCREENATTACH="irssi ssh -o SendEnv=SCREENATTACH linode@linode"

expdisp

# ------------------------------------------------
# TEMPORARY --------------------------------------
# ------------------------------------------------
export PATH=$PATH:$HOME/notifier

