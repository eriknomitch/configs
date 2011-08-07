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

