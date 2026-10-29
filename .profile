# Shared by bash and zsh. Keep this file portable and personal.

# Lets .bashrc tell whether this file has already been loaded.
_dotfiles_profile_loaded=1

export EDITOR="vi"

# User-installed binaries take precedence over system binaries.
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

alias npro='nano ~/.profile'
alias vpro='vi ~/.profile'
alias pro='. ~/.profile'
alias lg='lazygit'
alias gst='git status'
alias grep='grep --color=auto'

# GNU ls (Linux) and BSD ls (macOS) use different color flags; on GNU ls, -G
# means --no-group.
if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls --color=auto -aFhl'
  alias l='ls --color=auto -F'
else
  alias ll='ls -aFGhl'
  alias l='ls -FG'
fi
alias svenv='. ~/.venv/bin/activate'
alias gcam='git commit -am'

# Copy the current commit SHA using the clipboard utility available on this OS.
if command -v pbcopy >/dev/null 2>&1; then
  alias copysha='git rev-parse --verify HEAD | pbcopy'
elif command -v wl-copy >/dev/null 2>&1; then
  alias copysha='git rev-parse --verify HEAD | wl-copy'
elif command -v xclip >/dev/null 2>&1; then
  alias copysha='git rev-parse --verify HEAD | xclip -selection clipboard'
fi

# Keep machine- or employer-specific additions outside this repository.
if [ -r "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi

# Bash login shells (WSL, most Linux terminals) read only this file, so load
# the interactive bash configuration from here too.
if [ -n "${BASH_VERSION:-}" ] && [ -r "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
