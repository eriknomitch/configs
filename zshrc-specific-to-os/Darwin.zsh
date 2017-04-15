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
      
#PROMPT=$'->%{$fg_bold[white]%}[.]%{$reset_color%}->\xEF\xA3\xBF %{$fg[green]%}%m$%{$reset_color%} '
#pwd_is_wd=`pwd-is-wd`
#echo $pwd_is_wd

#_host_char=`echo -en "\xEF\xA3\xBF"`
#PROMPT=$'[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]-> %{$_host_char%} %{$fg[green]%}%m$%{$reset_color%} '

PROMPT=$'[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]$(pwd-home-count)-> %{$fg[green]%}%m$%{$reset_color%} '

# ------------------------------------------------
# SYNTAX-HIGHLIGHTING ----------------------------
# ------------------------------------------------
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

