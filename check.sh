#!/bin/sh
# Checks that what the configs in this repo expect is installed.
# Usage: ./check.sh [--kitty]
#   --kitty  also start kitty briefly and check which font it actually loads
# Exits non-zero if anything is missing.

failed=0
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✘\033[0m %s\n' "$1"; failed=1; }

# family | styles (comma separated, empty = any) | monospace (yes/no) | package hint | used by
fonts='
Lilex|Regular,Bold,Italic,Bold Italic|yes|ttf-lilex (AUR)|kitty
JetBrainsMono Nerd Font||no|ttf-jetbrains-mono-nerd|waybar
JetBrainsMono Nerd Font Mono||no|ttf-jetbrains-mono-nerd|waybar
Font Awesome 7 Free||no|otf-font-awesome|waybar
Noto Sans|Regular,Light|no|noto-fonts|gtk, hyprlock
'

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

if [ "$1" = --kitty ]; then
  echo kitty
  check_kitty
fi

exit $failed
