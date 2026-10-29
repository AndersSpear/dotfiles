# shellcheck shell=bash
# Nothing below applies to non-interactive shells such as scp or scripts.
case $- in
  *i*) ;;
  *) return ;;
esac

# .profile sources this file for login shells, and this file sources .profile
# for non-login shells. Load each one only once.
[[ -n "${_dotfiles_bashrc_loaded:-}" ]] && return
_dotfiles_bashrc_loaded=1
[[ -n "${_dotfiles_profile_loaded:-}" ]] || . "$HOME/.profile"

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
  . /etc/bash_completion
fi

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

# Green user@host, blue working directory.
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
