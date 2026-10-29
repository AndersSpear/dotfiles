#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
SKIP_PACKAGES=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--skip-packages]

  --dry-run        Print changes without making them
  --skip-packages  Link configuration but do not install software
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --skip-packages) SKIP_PACKAGES=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

run() {
  if "$DRY_RUN"; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_as_root() {
  if ((EUID == 0)); then
    run "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run sudo "$@"
  else
    echo "Root privileges are required to install packages, but sudo is unavailable." >&2
    return 1
  fi
}

backup_and_link() {
  local source_path="$1"
  local target_path="$2"
  local backup_path

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    echo "Already linked: $target_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up $target_path to $backup_path"
    run mv "$target_path" "$backup_path"
  fi

  run ln -s "$source_path" "$target_path"
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi
  echo "Installing Homebrew..."
  if "$DRY_RUN"; then
    echo '+ /bin/bash Homebrew installer from brew.sh'
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
}

install_macos_packages() {
  install_homebrew
  run brew install git fzf lazygit direnv powerlevel10k

  if [[ ! -d /Applications/iTerm.app && ! -d "$HOME/Applications/iTerm.app" ]]; then
    run brew install --cask iterm2
  else
    echo "iTerm2 is already installed."
  fi

  if [[ ! -f "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" && ! -f "/Library/Fonts/MesloLGS NF Regular.ttf" ]]; then
    run brew install --cask font-meslo-lg-nerd-font
  else
    echo "MesloLGS NF is already installed."
  fi
}

install_linux_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root apt-get install -y git zsh curl fzf direnv wl-clipboard xclip
    if apt-cache show lazygit >/dev/null 2>&1; then
      run_as_root apt-get install -y lazygit
    else
      echo "lazygit is not available from the configured apt repositories; skipping it."
    fi
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y git zsh curl fzf direnv wl-clipboard xclip
    if ! run_as_root dnf install -y lazygit; then
      echo "lazygit is not available from the configured dnf repositories; skipping it."
    fi
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -S --needed git zsh curl fzf direnv lazygit wl-clipboard xclip
  else
    echo "No supported package manager found (apt, dnf, or pacman)." >&2
    echo "Install git, zsh, curl, fzf, direnv, lazygit, and a clipboard utility manually." >&2
  fi
}

configure_iterm2() {
  local profile_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  local profile_source="$DOTFILES_DIR/iterm2/dotfiles.json"
  local profile_target="$profile_dir/dotfiles.json"

  run mkdir -p "$profile_dir"
  backup_and_link "$profile_source" "$profile_target"
  run defaults write com.googlecode.iterm2 'Default Bookmark Guid' -string '7C0A68EA-37B6-43BC-9C18-DF97EA01BE14'
  run defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true
  run defaults write com.googlecode.iterm2 ApplePressAndHoldEnabled -bool false
  run defaults write com.googlecode.iterm2 AppleScrollAnimationEnabled -bool false
  run defaults write com.googlecode.iterm2 AppleWindowTabbingMode -string manual
  run defaults write com.googlecode.iterm2 AlwaysOpenWindowAtStartup -bool true
  run defaults write com.googlecode.iterm2 ClickToSelectCommand -bool false
  run defaults write com.googlecode.iterm2 HapticFeedbackForEsc -bool false
}

case "$(uname -s)" in
  Darwin)
    if ! "$SKIP_PACKAGES"; then install_macos_packages; fi
    ;;
  Linux)
    if ! "$SKIP_PACKAGES"; then install_linux_packages; fi
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

for file in .profile .bashrc .zprofile .zshrc .p10k.zsh; do
  backup_and_link "$DOTFILES_DIR/$file" "$HOME/$file"
done

if [[ "$(uname -s)" == Darwin ]]; then
  backup_and_link "$DOTFILES_DIR/.iterm2_shell_integration.zsh" "$HOME/.iterm2_shell_integration.zsh"
  configure_iterm2
fi

if command -v git >/dev/null 2>&1; then
  run git config --global init.defaultBranch main
  run git config --global rebase.updateRefs true
fi

if command -v zsh >/dev/null 2>&1 && [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
  echo "Changing the default shell to zsh (you may be prompted for your password)."
  run chsh -s "$(command -v zsh)"
fi

echo
echo "Dotfiles installed. Open a new shell to use them."
if [[ "$(uname -s)" == Darwin ]]; then
  echo "Quit and reopen iTerm2 so it loads the Dotfiles profile."
fi
