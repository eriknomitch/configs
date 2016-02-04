_suffix_fg=`micro-hostname-suffix`

case $_suffix_fg in
  black)
    _suffix_fg="white"
    ;;
  orange)
    _suffix_fg="red"
    ;;
esac

_suffix_bg="black"

if ( $SSHED ) ; then
  PROMPT=$'->%{$fg_bold[blue]%}[SSH]%{$reset_color%}-[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]$(pwd-home-count)->micro-%{$bg[$_suffix_bg]%}%{$fg[$_suffix_fg]%}$(micro-hostname-suffix)$%{$reset_color%} '
fi
