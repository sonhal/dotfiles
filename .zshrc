
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt autocd extendedglob notify
setopt inc_append_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
unsetopt beep
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey -v '^?' backward-delete-char
# End of lines configured by zsh-newuser-install
KEYTIMEOUT=1 # 10ms wait after Esc in vi mode instead of the default 400ms
[[ -t 0 ]] && stty -ixon   # free Ctrl-S (tmux prefix) from XON/XOFF flow control so it can't freeze the terminal
# The following lines were added by compinstall
zstyle :compinstall filename "${HOME}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Add custom aliases to shell
source ${XDG_CONFIG_HOME}/zsh_aliases

# -----------------------
# Source plugins
# -----------------------
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  . /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
# -----------------------

# fzf search
source <(fzf --zsh) 2> /dev/null

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# ssh-agent via keychain — prompts once per login, reused across shells
if command -v keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --quiet id_ed25519)"
fi
