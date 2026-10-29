# dotfiles

Portable personal shell configuration for macOS and Linux. The repository intentionally excludes work-specific credentials, hosts, cloud profiles, Kubernetes configuration, and company tooling.

## Install

```sh
git clone git@github.com:AndersSpear/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer backs up an existing dotfile before replacing it with a symlink. Backups are named like `.zshrc.backup.20260904120000`.

On macOS it installs Homebrew when needed, then installs Git, fzf, lazygit, direnv, Powerlevel10k, iTerm2, and the Meslo Nerd Font. It also installs the checked-in iTerm2 profile and makes it the default. On Linux it supports apt, dnf, and pacman and installs the portable command-line tools and clipboard support available from that package manager.

Preview the work without changing anything:

```sh
./install.sh --dry-run
```

To link configuration without installing packages:

```sh
./install.sh --skip-packages
```

Machine-, employer-, and secret-specific additions belong in `~/.profile.local` or `~/.zshrc.local`, which are sourced when present but live outside this repository. Do not add `.secrets`, cloud credentials, Kubernetes configs, private package proxies, or company-specific aliases here.
