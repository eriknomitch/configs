_suffix_color=`micro-hostname-suffix`

if [[ $_suffix_color == "black" ]] ; then
  _suffix_color="white"
fi

PROMPT=$'->%{$fg_bold[blue]%}[SSH]%{$reset_color%}-[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]$(pwd-home-count)->%{$fg[magenta]%}micro-%{$reset_color%}%{$fg[magenta]%}%{$fg[$_suffix_color]%}$%{$reset_color%} '
