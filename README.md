# Dotfiles

## Note
Intended for an Arch linux install with hyprland.



## Clipboard manager

- https://github.com/sentriz/cliphist 
- `wl-clipboard`

`SUPER + Z` opens the history in rofi, with image previews from `.config/rofi/cliphist-rofi-img`
(the v0.7.0 contrib script, with thumbnails moved from /tmp to $XDG_RUNTIME_DIR;
the version on master needs a newer cliphist).

Clear history with `cliphist wipe`.

## Image editing

- https://www.pinta-project.com/

## Themes

Use nwg-look to config GTK apps.
https://github.com/nwg-piotr/nwg-look

Theme package: `adw-gtk-theme` (https://github.com/lassekongo83/adw-gtk3), set to `adw-gtk3-dark` in
`hypr/envs.lua` and with nwg-look.

- nwg-look writes `gtk-3.0/settings.ini` and `gtk-4.0/` (its CSS files link into the adw-gtk3-dark theme,
  so GTK 4 apps follow it too); symlink both folders into `~/.config`.

### Qt apps

Packages: `kvantum`, `kvantum-qt5`, `qt5ct`, `qt6ct`, `breeze-icons`.

- Qt apps use the Kvantum style via qt6ct (env set in `hypr/envs.lua`). `Kvantum/`, `qt5ct/` and
  `qt6ct/` set them to KvGnomeDark with breeze-dark icons; symlink them into `~/.config`.
- Qt 5 apps load qt5ct, which also answers to `QT_QPA_PLATFORMTHEME=qt6ct`, and need
  `kvantum-qt5` for the style. qt5ct can't read KDE `.colors` files, so `qt5ct.conf` takes the
  palette from the Kvantum theme instead.

### Thunar

Packages: `thunar`, `tumbler` (thumbnails), `gvfs` (devices, trash), `gvfs-mtp` (Android),
`xdg-user-dirs`.

- Side pane bookmarks live in `~/.config/gtk-3.0/bookmarks`. It holds absolute paths, so it isn't
  tracked; if it's missing, `xdg-user-dirs-gtk-update` (package `xdg-user-dirs-gtk`) creates it with
  the standard XDG user dirs at Hyprland start.
- Dates use the locale's time format; `LC_TIME=en_GB.UTF-8` (set in `hypr/envs.lua`) gives 24-hour
  time and needs `en_GB.UTF-8` uncommented in `/etc/locale.gen` before running `locale-gen`.

## Waybar

- Icons need `otf-font-awesome`
- Text uses `ttf-jetbrains-mono-nerd`


## Key packages
Started by keybinds etc...

- https://github.com/derailed/k9s
- https://github.com/jesseduffield/lazydocker
- https://github.com/junegunn/fzf (Required for shell)
- https://eza.rocks/ (Required for shell aliases)
- https://github.com/sharkdp/bat (Required for the `ff` alias)
- https://starship.rs/ (Shell prompt, config in `.config/starship.toml`)


## Zsh

### Plugins

- zsh-syntax-highlighting
- https://github.com/zsh-users/zsh-autosuggestions
- https://github.com/zsh-users/zsh-history-substring-search (Up/Down search history for what's typed)
