
export XDG_CONFIG_HOME=${HOME}/.config/
# Add custom aliases to shell
source ${XDG_CONFIG_HOME}/zsh_aliases

# Created by `pipx` on 2025-05-23 18:53:15
export PATH="$PATH:${HOME}.local/bin"


eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
