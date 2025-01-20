#!/bin/sh

# Enable shell script strictness
set -eu

# Enable command tracing
set -x

# Ensure config directory exists
mkdir -p ~/.config

# Link Git config if it doesn't exist
[ ! -e ~/.config/git ] && ln -s "$PWD/config/git" ~/.config/git

# Link Starship config if it doesn't exist
[ ! -e ~/.config/starship.toml ] && ln -s "$PWD/config/starship/starship.toml" ~/.config/starship.toml

# Link Neovim config if it doesn't exist
[ ! -e ~/config/nvim ] && ln -s "$PWD/config/nvim" ~/.config/nvim
