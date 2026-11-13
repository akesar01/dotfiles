#!/usr/bin/env bash
# Symlinks this repo's configs into ~/.config. Existing non-symlink dirs are
# moved aside as <name>.bak-<timestamp>, never deleted.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
link() {
  local src="$DOTFILES/$1" dst="$HOME/.config/$1"
  mkdir -p "$HOME/.config"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak-$(date +%Y%m%d-%H%M%S)"
    echo "moved existing $dst aside"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}
link nvim
link wezterm
