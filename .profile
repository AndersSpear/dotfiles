# Shared by bash and zsh. Keep this file portable and personal.

export EDITOR="vi"

# User-installed binaries take precedence over system binaries.
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

alias npro='nano ~/.profile'
alias vpro='vi ~/.profile'
alias pro='. ~/.profile'
alias lg='lazygit'
alias gst='git status'
alias ll='ls -aFGhl'
alias l='ls -FG'
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
