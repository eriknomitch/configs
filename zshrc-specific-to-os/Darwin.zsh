# ------------------------------------------------
# UTILITY ----------------------------------------
# ------------------------------------------------
function eject-all() {
  ls -1 /Volumes
  echo "----------"
  echo -n "Ejecting... "
  osascript -e 'tell application "Finder" to eject (every disk whose ejectable is true)'
  echo "Done.  Your new list of Volumes is:"
  echo "----------"
  ls -1 /Volumes
}

# ------------------------------------------------
# PROMPT -----------------------------------------
# ------------------------------------------------
_prompt_color="$fg_bold[green]"

# ------------------------------------------------
# SYNTAX-HIGHLIGHTING ----------------------------
# ------------------------------------------------
source-if-exists /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------------------------
# ALIASES ----------------------------------------
# ------------------------------------------------

# "cd" Aliases
alias d="cd ~/Desktop && clear && pwd && ls -1"
alias dl="cd ~/Downloads && clear && pwd && ls -1"

# Other Aliases
alias updatedb="sudo /usr/libexec/locate.updatedb"
alias il="irc-loop"
alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc"
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'

source-if-exists /sw/bin/init.sh

# ------------------------------------------------
# FIX: -------------------------------------------
# ------------------------------------------------
source-if-exists ~/.configs/iterm2.zsh

# ------------------------------------------------
# POSTGRES ---------------------------------------
# ------------------------------------------------
test -d /Applications/Postgres.app/Contents/Versions/latest/bin && export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

# ------------------------------------------------
# GCLOUD -----------------------------------------
# ------------------------------------------------
if test -d "$(brew --prefix)/Caskroom/google-cloud-sdk"; then
  source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi
