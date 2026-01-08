#### This is managed by Ansible ####



# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar
shopt -s dotglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    LAST_COMMAND_COLOR="\[\033[38;5;160m\]"
    LAST_COMMAND_COLOR_BRACKET="\[\033[0m\]"
    BRACKET_COLOR="\[\033[38;5;35m\]"
    CLOCK_COLOR="\[\033[38;5;35m\]"
    JOB_COLOR="\[\033[38;5;33m\]"
    PATH_COLOR="\[\033[38;5;33m\]"
    LINE_BOTTOM="\342\224\200"
    LINE_BOTTOM_CORNER="\342\224\224"
    LINE_COLOR="\[\033[38;5;248m\]"
    LINE_STRAIGHT="\342\224\200"
    LINE_UPPER_CORNER="\342\224\214"
    END_CHARACTER="|"
    tty -s && export PS1='$(ret=$?; ((ret!=0)) && echo "\[\033[38;5;160m\]($ret) \[\033[0m\]")'"$LINE_COLOR$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT$BRACKET_COLOR[$CLOCK_COLOR\t$BRACKET_COLOR]$LINE_COLOR$LINE_STRAIGHT$BRACKET_COLOR[$JOB_COLOR\j$BRACKET_COLOR]$LINE_COLOR$LINE_STRAIGHT$BRACKET_COLOR[\u@\H:\]$PATH_COLOR\w$BRACKET_COLOR]\n$LINE_COLOR$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM$END_CHARACTER\[$(tput sgr0)\] "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF --group-directories-first' 
alias la='ls -A'
alias l='ls -CF'
alias h='history'
alias clc='copy_to_local_clipboard'
alias ip="ip -br -c addr"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# copy to terminal clipboard
copy_to_local_clipboard() {
  local max_size=$((1024 * 1024 * 10))  # 10 MB limit

  if [ -z "$1" ]; then
    echo "Usage: clc path/to/file"
    return 1
  fi

  if ! [ -f "$1" ]; then
    echo "File '$1' not found."
    return 2
  fi

  local filesize
  filesize=$(stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null)
  if [ -z "$filesize" ]; then
    echo "Error: Could not determine file size."
    return 4
  fi

  if (( filesize > max_size )); then
    echo "Error: File size ($filesize bytes) exceeds limit of $max_size bytes."
    return 5
  fi

  # Read file and base64 encode it
  local content
  content=$(base64 < "$1" | tr -d '\n')

  # OSC 52 sequence to copy to clipboard on local terminal
  printf "\e]52;c;%s\a" "$content"
}

# Print bash colors to screen
colors ()
{
  local i;
  for i in {0..255};
  do
    printf "\x1b[38;5;${i}mcolor %d\n" "$i";
  done;
  tput sgr0
}

# Auto-activate playbooks-bootstrap venv
if [ -f "$HOME/ansible-venv/bin/activate" ]; then
    source "$HOME/ansible-venv/bin/activate"
fi

# include .local/bin to Path
export PATH=$HOME/.local/bin:$PATH

# check if fzf is available, then include "key-bindings.bash" & completion to bashrc
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)" || true

# npm + node 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PIP Envirment for ansible + ansible-lint
source ~/.venvs/bin/activate

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Use 256-color terminal by default
export TERM=xterm-256color

