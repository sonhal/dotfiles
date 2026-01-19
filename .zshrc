
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt autocd extendedglob notify
setopt inc_append_history
unsetopt beep
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey -v '^?' backward-delete-char
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '${HOME}/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export XDG_CONFIG_HOME=${HOME}/.config/
# Add custom aliases to shell
source ${XDG_CONFIG_HOME}/zsh_aliases

# Created by `pipx` on 2025-05-23 18:53:15
export PATH="$PATH:${HOME}/.local/bin"

# -----------------------
# Source plugins
# -----------------------
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# -----------------------

# fzf search
source <(fzf --zsh) 2> /dev/null

eval "$(starship init zsh)"
