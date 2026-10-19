

export XDG_CONFIG_HOME=$HOME/.config
export XDG_PICTURES_DIR=$HOME/Pictures

# Paths

# user scripts (dotfiles' .local/bin, pipx); in .zshenv so non-interactive shells see them too
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.npm-packages/bin

export EDITOR="nvim"
export VISUAL="nvim"
. "$HOME/.cargo/env"
