COMPLETION_WAITING_DOTS="false"

_suffix_fg=`micro-hostname-suffix`

case $_suffix_fg in
  black)
    _suffix_fg="white"
    ;;
  orange)
    _suffix_fg="red"
    ;;
  purple)
    _suffix_fg="magenta"
    ;;
esac

_suffix_bg="black"

if ( $SSHED ) ; then
  PROMPT=$'->%{$fg_bold[blue]%}[SSH]%{$reset_color%}-[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]$(pwd-home-count)->%{$bg[$_suffix_bg]%}%{$fg_bold[$_suffix_fg]%}%m$%{$reset_color%} '
fi
