

function eject-all() {
  ls -1 /Volumes
  echo "----------"
  echo -n "Ejecting... "
  osascript -e 'tell application "Finder" to eject (every disk whose ejectable is true)'
  echo "Done.  Your new list of Volumes is:"
  echo "----------"
  ls -1 /Volumes
}
      
#PROMPT=$'->%{$fg_bold[white]%}[.]%{$reset_color%}->\xEF\xA3\xBF %{$fg[green]%}%m$%{$reset_color%} '
#pwd_is_wd=`pwd-is-wd`
#echo $pwd_is_wd

#_host_char=`echo -en "\xEF\xA3\xBF"`
#PROMPT=$'[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]-> %{$_host_char%} %{$fg[green]%}%m$%{$reset_color%} '

PROMPT=$'[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]-> %{$fg[green]%}%m$%{$reset_color%} '
