#!/bin/sh
# Checks that the fonts and packages the configs in this repo expect are installed.
# Usage: ./check.sh [--kitty]
#   --kitty  also start kitty briefly and check which font it actually loads
# Exits non-zero if anything is missing.

failed=0
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✘\033[0m %s\n' "$1"; failed=1; }

# family | styles (comma separated, empty = any) | monospace (yes/no) | package hint | used by
fonts='
Lilex|Regular,Bold,Italic,Bold Italic|yes|ttf-lilex (AUR)|kitty, md, monospace
Inter|Regular,Light|no|inter-font|gtk, hyprlock, waybar, rofi, sans-serif
Symbols Nerd Font||no|ttf-nerd-fonts-symbols|waybar icons
Noto Sans||no|noto-fonts|fallback
Noto Sans CJK JP||no|noto-fonts-cjk|waybar mpris, CJK fallback
JoyPixels||no|ttf-joypixels|emoji, starship
DejaVu Sans Mono||no|ttf-dejavu|kitty fallback for starship ➜
'

# command, or absolute path for files | package hint | used by
shell='
zsh|zsh|shell
/usr/share/zsh/plugins/zsh-syntax-highlighting|zsh-syntax-highlighting|.zshrc
/usr/share/zsh/plugins/zsh-autosuggestions|zsh-autosuggestions|.zshrc
/usr/share/zsh/plugins/zsh-history-substring-search|zsh-history-substring-search|.zshrc
starship|starship|prompt
fzf|fzf|.zshrc, ff
zoxide|zoxide|.zshrc
keychain|keychain|ssh-agent
eza|eza|ls, lt
bat|bat|cat, ff
lazygit|lazygit|lg
tmux|tmux|terminal multiplexer
btop|btop|SUPER+T
pandoc|pandoc-cli|md
'

nvim='
nvim|neovim|editor
git|git|plugin manager
make|make|telescope-fzf-native
unzip|unzip|Mason
rg|ripgrep|telescope grep
gcc|gcc|treesitter parsers
tree-sitter|tree-sitter-cli|treesitter parsers
'

desktop='
ly-dm|ly|login greeter
uwsm|uwsm|starts Hyprland
Hyprland|hyprland|window manager
kitty|kitty|terminal
waybar|waybar|bar
swaync|swaync|notifications
hypridle|hypridle|idle
hyprlock|hyprlock|lock screen, waybar power menu
hyprpaper|hyprpaper|wallpaper
/usr/lib/hyprpolkitagent/hyprpolkitagent|hyprpolkitagent|polkit
rofi|rofi|launcher, clipboard, keybinds
cliphist|cliphist|clipboard history
wl-paste|wl-clipboard|clipboard history
hyprshot|hyprshot|screenshots
jq|jq|keybind cheatsheet, waybar routes
notify-send|libnotify|waybar battery alerts
wpctl|wireplumber|volume keys, waybar volume
playerctl|playerctl|media keys
pavucontrol|pavucontrol|waybar volume click
thunar|thunar|file manager
xdg-user-dirs-gtk-update|xdg-user-dirs-gtk|Thunar bookmarks
nwg-look|nwg-look|GTK theme
kvantummanager|kvantum|Qt style
qt5ct|qt5ct|Qt 5 config
qt6ct|qt6ct|Qt 6 config
'

# only checked on machines with a battery
laptop='
powerprofilesctl|power-profiles-daemon|waybar power profile
brightnessctl|brightnessctl|brightness keys
'

check_package() {
  target=$1 pkg=$2 users=$3
  case $target in
    /*) [ -e "$target" ] ;;
    *)  command -v "$target" >/dev/null 2>&1 ;;
  esac && ok "${target##*/} ($users)" || fail "${target##*/} ($users) — install: $pkg"
}

check_packages() {
  echo "$1"
  while IFS='|' read -r target pkg users; do
    [ -n "$target" ] && check_package "$target" "$pkg" "$users"
  done <<EOF
$2
EOF
}

check_font() {
  family=$1 styles=$2 mono=$3 pkg=$4 users=$5
  label="$family ($users)"

  if [ -z "$(fc-list "$family" family)" ]; then
    fail "$label — install: $pkg"
    return
  fi

  # one "style|spacing" line per font file, using each file's primary style name
  installed=$(fc-list "$family" --format '%{style[0]}|%{spacing}\n')
  missing='' notmono=''
  IFS=,
  for style in ${styles:-}; do
    match=$(printf '%s\n' "$installed" | grep -x "$style|.*")
    if [ -z "$match" ]; then
      missing="$missing, $style"
    elif [ "$mono" = yes ] && ! printf '%s\n' "$match" | grep -qx "$style|100"; then
      notmono="$notmono, $style"
    fi
  done
  unset IFS

  if [ -n "$missing" ]; then
    fail "$label — missing styles: ${missing#, } — install: $pkg"
  elif [ -n "$notmono" ]; then
    fail "$label — not detected as monospace, kitty will refuse it: ${notmono#, }"
  else
    ok "$label${styles:+ — $styles}"
  fi
}

# Starts kitty with the repo's config and compares the loaded regular font to font_family.
check_kitty() {
  conf="$(dirname "$(realpath "$0")")/.config/kitty/kitty.conf"
  want=$(sed -n 's/^font_family.*family="\([^"]*\)".*/\1/p' "$conf")
  log=$(timeout 15 kitty --config "$conf" --debug-font-fallback sh -c 'sleep 1' 2>&1)
  file=$(printf '%s\n' "$log" | sed -n 's/.*Normal: [^:]*: \(.*\):[0-9]*$/\1/p' | head -1)
  got=$(fc-query --format '%{family[0]}' "$file" 2>/dev/null)

  if [ -z "$file" ]; then
    fail "kitty did not report its fonts (is it installed, and is a display available?)"
  elif [ "$got" = "$want" ]; then
    ok "kitty loads $want ($file)"
  else
    fail "kitty wants \"$want\" but loaded \"$got\" ($file)"
  fi
}

echo fonts
while IFS='|' read -r family styles mono pkg users; do
  [ -n "$family" ] && check_font "$family" "$styles" "$mono" "$pkg" "$users"
done <<EOF
$fonts
EOF

check_packages shell "$shell"
check_packages nvim "$nvim"
check_packages desktop "$desktop"
if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  check_packages laptop "$laptop"
else
  echo "laptop (skipped, no battery)"
fi

if [ "$1" = --kitty ]; then
  echo kitty
  check_kitty
fi

exit $failed
