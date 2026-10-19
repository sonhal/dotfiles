

export XDG_CONFIG_HOME=$HOME/.config
export XDG_PICTURES_DIR=$HOME/Pictures

# Paths

# user scripts (dotfiles' .local/bin, pipx); in .zshenv so non-interactive shells see them too
export PATH=$PATH:$HOME/.local/bin

# npm install -g goes to ~/.local (packages in lib/node_modules, commands linked into bin)
export npm_config_prefix=$HOME/.local

export EDITOR="nvim"
export VISUAL="nvim"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
