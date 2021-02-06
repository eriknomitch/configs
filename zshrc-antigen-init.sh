


# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle zsh-navigation-tools
antigen bundle docker
antigen bundle docker-compose
antigen bundle jump
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle zsh-users/zsh-completions
antigen bundle psprint/zsh-navigation-tools
antigen bundle rupa/z
antigen bundle mafredri/zsh-async
antigen bundle jocelynmallon/zshmarks

# Tell Antigen that you're done.
antigen apply
