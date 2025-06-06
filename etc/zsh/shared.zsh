# ------------------------------------------------
# ZSH->CONFIGURATION -----------------------------
# ------------------------------------------------

# Required for Zsh installed with brew
test -d "/usr/local/share/zsh/functions" && \
  export FPATH="/usr/local/share/zsh/functions:$FPATH"

autoload -Uz zsh/terminfo
autoload -Uz colors; colors
autoload -Uz add-zsh-hook
autoload -Uz compinit

# Ignore comments in interactive mode
setopt interactivecomments

# Restrict compinit to only run once every 24 hours
if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

source /etc/zsh/colors.zsh

# Allow for functions in the prompt
setopt promptsubst
setopt prompt_subst

# Enable auto-execution of functions.
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

setopt nohup
setopt no_check_jobs
setopt extendedglob
setopt extended_glob
setopt no_nomatch
setopt alwaystoend

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.history
ORIGINAL_HISTFILE=$HISTFILE

# Auto-rehash
zstyle ':completion:*' rehash true

# ------------------------------------------------
# VI-MODE ----------------------------------------
# ------------------------------------------------
# NOTE: You probably also have the vi-mode oh-my-zsh plugin.
# https://dougblack.io/words/zsh-vi-mode.html
bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# Prompt settings for vi mode
# ------------------------------------------------
function zle-line-init zle-keymap-select {
  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
  RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=40

# ------------------------------------------------
# LOCALES ----------------------------------------
# ------------------------------------------------
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_TYPE="en_US.UTF-8"

# ------------------------------------------------
# UTILITY->SOURCING ------------------------------
# ------------------------------------------------
function resource() {
  _current_pwd=`pwd`

  unset ZSHRC_SOURCED
  source $HOME/.zshrc

  clear

  cd $_current_pwd
}

alias src="resource"
alias rh="rehash"
alias reset-compinit="rm $HOME/.zshcompdump*; compinit"

function source-if-exists() {
  test -f $1 && source $1
}

function command-exists() {
  typeset -f $1 > /dev/null || command -v $1 > /dev/null 2>&1
}

function extend-path() {
  _path=$1

  if [[ -z $_path ]]; then
    echo "fatal: $0: No path supplied."
    return 1
  fi

  # If it's found append it and echo (we can't assign here)
  if [[ -d $_path ]] ; then
    echo "$PATH:$_path"
    return
  fi

  # If not, do not strictly require it. Just echo PATH
  echo $PATH
}

# ------------------------------------------------
# PATHS ------------------------------------------
# ------------------------------------------------
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:$HOME/.bin/bin
export PATH=$PATH:$HOME/.bin/.bin

_os_bin_path="$HOME/.bin/bin-`uname`"

if [[ -d $_os_bin_path ]] ; then
  export PATH=$PATH:$_os_bin_path
fi

unset _os_bin_path

export PATH=$PATH:$HOME/.gexecute
export PATH=$PATH:$HOME/.android/bin
export PATH=$PATH:$HOME/.android/platform-tools
export PATH=$PATH:$HOME/.neo4j-bin
export PATH=$PATH:$HOME/.repositories/mkdir-scripts/bin

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib

# ------------------------------------------------
# SWITCHES ---------------------------------------
# ------------------------------------------------
export ON_DARWIN=false
export ON_LINUX=false
export ON_MICRO=false
export ON_MICRO_PUCK=false
export SSHED=false

case `uname` in
  "Darwin")
    ON_DARWIN=true
    ;;
  "Linux")
    ON_LINUX=true
    ;;
esac

if command-exists micro-localhost-is-micro && micro-localhost-is-micro ; then
  ON_MICRO=true
fi

# http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [[ -n ${SSH_CLIENT} ]]; then; SSHED=true; fi

# ------------------------------------------------
# UNIX -------------------------------------------
# ------------------------------------------------
if ( $ON_DARWIN ) ; then
  alias l="ls -lh -G"
  alias ls="ls -G"
  alias la="ls -lha -G"
  alias lf="ls -lh -G | grep -i"
  alias lfa="ls -lha -G | grep -i"
else
  alias l="ls -lh --color"
  alias ls="ls --color"
  alias la="ls -lha --color"
  alias lf="ls -lh --color | grep -i"
  alias lfa="ls -lha --color | grep -i"
fi

alias lc="ls -1 | wc -l"
alias b="cd .."
alias f="cd -"
alias x="exit"
alias c="clear"
alias sd="sudo"
alias s="sudo su"
alias reboot="sudo reboot"
alias halt="sudo halt"
alias ts="du -sh"
alias grep="grep --color"
alias lsdir="ls -d */"
alias lsadir="ls -d .*/"
alias rs="clear; rspec --format nested --color $*"
alias sc="screen"
alias scl="screen -ls"
alias ccat="vimcat"

function t() {
  if [[ -z $1 ]]; then
    tmux
    return
  fi

  # For each line of output
  for valid in `tmuxp ls`; do
    if [[ $valid == $1 ]]; then
      tmuxp load $1
      return
    fi
  done

  tmux $*
}

psg()
{
  if [[ -z $1 ]] ; then
    echo "$0: usage: QUERY"
  fi
}
mw()
{
  mv "$@" && cd "${@[-1]}";
}
gst()
{
  grep -IHiRe $1 ./ ;
}
fnd()
{
  if command-exists fd; then
    fd $*
    return
  fi

  _name="$1"
  shift
  find ./ -iname "*$_name*" $* ;
}
is-sshed()
{
  if ( $SSHED ); then; return 0; else return 1; fi
}
rex()
{
  sudo reboot &>/dev/null exit
}
pox()
{
  sudo shutdown -h now &>/dev/null exit
}

# ------------------------------------------------
# RUN --------------------------------------------
# ------------------------------------------------
function r() {
  if [[ ! -x ./run ]] ; then
    echo "fatal: ./run does not exist or is not executable."
    return 1
  fi

  clear
  ./run $*
}

alias rr="reset; r"

# ------------------------------------------------
# HISTORY ----------------------------------------
# ------------------------------------------------
function disable-history-for-session() {
  HISTFILE=/dev/null
  echo "HISTFILE set to /dev/null."
}

function rm-history() {

  if [[ $HISTFILE != $ORIGINAL_HISTFILE ]]; then
    echo "fatal: HISTFILE does not match the originally set HISTFILE location. Exiting."
    return 1
  fi

  if test -f $HISTFILE ; then
    echo "Removing '$HISTFILE'"
    rm $HISTFILE
  fi

  _directory_history_path="$HOME/.directory_history"

  if test -d $_directory_history_path; then
    echo "Removing '$_directory_history_path'"
    rm -rf $_directory_history_path
  fi

  _session_path="$HOME/.zsh_sessions"

  if test -d $_session_path; then
    echo "Removing '$_session_path'"
    rm -rf $_session_path
  fi

  _z_history="$HOME/.z"

  if test -f $_z_history; then
    echo "Removing '$_z_history'"
    rm $_z_history
  fi

  # _other_history_paths="~/.bash_history ~/.sh_history ~/.zsh_history"
}


# ------------------------------------------------
# ALIASES/FUNCTIONS ------------------------------
# ------------------------------------------------
alias tree="tree -C"
alias treed="tree -C -d"
alias ra="clear && ./reset-all"
alias use-opendns="sudo cp /etc/resolv.conf.opendns /etc/resolv.conf"
alias use-google-dns="sudo cp /etc/resolv.conf.google /etc/resolv.conf"
alias sync-time-san-francisco="sudo ntpdate tick.ucla.edu"
alias sync-time-chicago="sudo ntpdate ntp-1.mcs.anl.gov"
alias wake="export DISPLAY=:0.0 && xset dpms force on"
alias blank="export DISPLAY=:0.0 && xset dpms force off"
alias expdisp="export DISPLAY=:0.0"
alias emacs="emacs -nw"
alias slime="emacs -nw -f slime"
alias push="./push $*"
alias rails-env-production="export RAILS_ENV=production"
alias rails-env-development="export RAILS_ENV=development"
alias re-p="rails-env-production"
alias re-d="rails-env-development"
alias rails-env-test="export RAILS_ENV=test"
alias v="vim"
alias dv="ssh desktop-virtual"
alias o="ofe"
alias np="notify-push"
alias p="pwd"
alias sshn="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias dh="disable-history-for-session"
alias ht="htop"
alias htn="htop --user=nobody"
alias gpi="grep --ignore-case"
alias pgrep="pgrep -il"
alias torrent="screen -d -R torrent"

if [[ "$USER" != "root" ]] ; then
  alias apt-get="sudo apt-get"
  alias apt="sudo apt"
  alias aptitude="sudo aptitude"
  alias snap="sudo snap"
  alias service="sudo service"
  alias dpkg="sudo dpkg"
  alias updatedb="sudo updatedb"
  alias locate="sudo locate"
fi

# Darwin
# ------------------------------------------------
if ( $ON_DARWIN ) ; then
  alias htop="sudo htop"
  alias op="open"
  alias del="rmtrash"
fi

# Linux
# ------------------------------------------------
if ( $ON_LINUX ) ; then
  if [[ $USER != $ROOT ]] ; then
    alias ifconfig="/sbin/ifconfig"
  fi
fi

# ------------------------------------------------
# FUNCTIONS --------------------------------------
# ------------------------------------------------
function update() {
  case $1 in
    "-y"|"-Y")
      sudo apt-get update && \
        sudo apt-get -y upgrade
      ;;
    *)
      sudo apt-get update && \
        sudo apt-get upgrade
      ;;
  esac
}

function mvw() {
  mv $* && cd $2
}

# startx
function sx()
{
  startx &

  sleep 1.5

  export DISPLAY=:0.0

  if [[ $1 == "m" ]] ; then
    display-mode monitor
  else
    display-mode no-monitor
  fi
}

# Extract
function ex()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1;;
      *.tar.gz)    tar xvzf $1;;
      *.bz2)       bunzip2 $1;;
      *.rar)       unrar x $1;;
      *.gz)        gunzip $1;;
      *.tar)       tar xvf $1;;
      *.tbz2)      tar xvjf $1;;
      *.tgz)       tar xvzf $1;;
      *.zip)       unzip $1;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1;;
      *.xz)        unxz $1;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
    return 1
  fi
}

function rsync-partial()
{
  rsync --partial --progress --rsh=ssh $*
}

function tmux-is-running() {
  tmux ls > /dev/null 2>&1
}

function list-commands() {
  # SEE: https://stackoverflow.com/a/949006/1764073

  # If no argument, default to ALL
  if [[ $# -eq 0 ]] ; then
    compgen  -abckA function | sort
    return
  fi

  compgen $* | sort
}

function find-command() {
  list-commands | fzf
}

# ------------------------------------------------
# STTY -------------------------------------------
# ------------------------------------------------

# Prevent C-s from hanging terminal
# http://unix.stackexchange.com/questions/72086/ctrl-s-hang-terminal-emulator
stty -ixon

# ------------------------------------------------
# PROMPTS ----------------------------------------
# ------------------------------------------------
function pwd-is-wd-character() {
  if command-exists pwd-is-wd && pwd-is-wd ; then
    echo "*"
  elif [[ $PWD == $HOME ]] ; then
    echo "~"
  else
    echo " "
  fi
}

function pwd-home-count() {
  if [[ $PWD == $HOME ]] ; then

    _home_count=`ls -1 | count-lines`

    if ( $ON_DARWIN ) ; then
      let _home_count=_home_count-28
    fi

    if [[ $_home_count > 0 ]] ; then
      echo -n "+$_home_count"
    fi

  fi
}

# Root
# ------------------------------------------------
if [[ $USER == "root" ]] ; then
  PROMPT=$'%{\e[31m%}%m# %{\e[0m%}'

  # Non-Privileged
  # ------------------------------------------------
else
  if ( $SSHED ) ; then
    PROMPT=$'->%{$fg_bold[blue]%}[SSH]%{$reset_color%}-[%{$fg_bold[white]%}$(pwd-is-wd-character)%{$reset_color%}]$(pwd-home-count)->%{$fg[magenta]%}%m$%{$reset_color%} '
  else
    PROMPT=$'%{$fg[green]%}%m$%{$reset_color%} '
  fi
fi

# ------------------------------------------------
# GI ---------------------------------------------
# ------------------------------------------------

# Go to git repository I'm inside.
function gi() {
  _toplevel=`git rev-parse --show-toplevel || return`

  cd-skip-chpwd $_toplevel

  clear
  ls -lh
  g
  stylize `pwd-tilde`"\n"
}

# ------------------------------------------------
# KEY-BINDINGS->PROMPT-DUMPS->DEFINER ------------
# ------------------------------------------------
# Meta definer for dump commands
function _define_buffer_dump() {

  local _function_suffix=$1
  local _bindkey=$2
  local _lbuffer=$3
  local _rbuffer=$4

  local _function_name="_dump_$_function_suffix"

  test -n $_rbuffer || _rbuffer=''

  eval "
function $_function_name() {
  LBUFFER+='$_lbuffer'; RBUFFER+='$_rbuffer'
  #expand-or-complete-with-dots
  zle expand-or-complete
  zle redisplay
}

zle -N $_function_name
bindkey '$_bindkey' $_function_name
  "

}

# ------------------------------------------------
# PRECMD -----------------------------------------
# ------------------------------------------------
function _base_precmd() {
  if [[ $HISTFILE = "/dev/null" ]] ; then
    echo `stylize "History disabled."`
  fi

  if ( $ON_LINUX ) ; then
    if ! swap-empty; then
      echo -e "${On_IRed}${BWhi}Swap usage is > 0${RCol}"
    fi
  fi

}

# Split these so that if we override precmd elsewhere
# we can always call _base_precmd.
function precmd() {
  _base_precmd
}

# ------------------------------------------------
# CHPWD ------------------------------------------
# ------------------------------------------------
function cd-skip-chpwd() {
  SKIP_CHPWD=true
  cd $*
  SKIP_CHPWD=false
}

function _ls_home_dir_macos_clean() {
  ls -l --color=always $HOME | grep --color=always -Ev 'Applications|Clean|Creative Cloud Files|Desktop|Documents|Downloads|Google Drive|Library|Movies|Music|Pictures|Postman|Public|Remotes|Repositories|Shared|tmp|insta360|Screen Captures|Virtual Machines.localized' | grep --color=always -v 'total '
}

function chpwd() {
  if (( $SKIP_CHPWD )) ; then; return; fi

  test -f .ls-ignore && return

  test $PWD == $HOME && clear

  if [[ $PWD == $HOME ]]; then
    if [[ $ON_DARWIN ]] ; then
      _ls_home_dir_macos_clean
      return
    fi
  fi

  command-exists _g_chpwd && _g_chpwd
  command-exists _virtualenv_chpwd && _virtualenv_chpwd
}

function eza_tree() {
  local options=(--icons --classify --oneline --long --no-permissions --no-user --time-style relative --git --level 1 --tree)
  [[ $1 == 't' ]] && options+=(--sort time --reverse)
  eza "${options[@]}"
}

function short-uuidgen() {
  uuidgen | cut -c1-8 | tr '[:upper:]' '[:lower:]'
}

# ------------------------------------------------

# Load the development tmuxp in a new session
function tdev() {
  tmuxp load -s `short-uuidgen` development
}

alias dev="tdev"

# ------------------------------------------------
# ENV->EDITOR/NVIM -------------------------------
# ------------------------------------------------
if command-exists nvim; then
  export EDITOR="nvim"
  alias vim="nvim"
else
  export EDITOR="vim"
fi

# ------------------------------------------------
# COLORED-BANNER ---------------------------------
# ------------------------------------------------
function colored_banner() {
    local title="$1"
    local color="${2:-$Cya}"  # Default to cyan if no color argument is provided
    local reset_code="$RCol"
    local line_length=50
    local padded_title="${title} "
    local padding_length=$((line_length - ${#title} - 1))  # Adjusted to -1 for correct alignment
    local border_line=""

    # Generate border line dynamically based on line_length
    for (( i=0; i<line_length; i++ )); do
        border_line+="="
    done

    for (( i=0; i<padding_length; i++ )); do
        padded_title+="="
    done

    echo -e "${color}${border_line}"
    echo -e "${padded_title}"
    echo -e "${border_line}${reset_code}"
}

# ------------------------------------------------
# ASDF -------------------------------------------
# ------------------------------------------------

# For some reason, if node is installed via asdf we need to add the shim directory to our path
# else we'll get an error of 'env: node: No such file or directory' when opening a shell.
test -f $HOME/.asdf/shims/node && export PATH=$PATH:$HOME/.asdf/shims
