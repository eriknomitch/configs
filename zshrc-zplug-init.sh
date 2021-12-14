# FROM: https://github.com/zplug/zplug#example
source ~/.zplug/init.zsh

# ------------------------------------------------
zplug "plugins/zsh-navigation-tools", from:oh-my-zsh
# zplug "plugins/jump", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh

# ------------------------------------------------
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# ------------------------------------------------
zplug "mafredri/zsh-async"
# zplug "sindresorhus/pure"
zplug "jocelynmallon/zshmarks"
zplug "rupa/z"

# ------------------------------------------------
# ------------------------------------------------
# ------------------------------------------------

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
#zplug load --verbose
zplug load
clear
