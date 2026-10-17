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

- https://www.pinta-project.com/ (AUR)

## Themes

Use nwg-look to config GTK apps.
https://github.com/nwg-piotr/nwg-look

Theme package
- https://aur.archlinux.org/packages/arc-solid-gtk-theme

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

- Side pane bookmarks live in `~/.config/gtk-3.0/bookmarks`.
- Dates use the locale's time format; `LC_TIME=en_GB.UTF-8` (set in `hypr/envs.lua`) gives 24-hour
  time and needs `en_GB.UTF-8` uncommented in `/etc/locale.gen` before running `locale-gen`.

## Waybar

- Icons need `otf-font-awesome`


## Key packages
Started by keybinds etc...

- https://github.com/derailed/k9s
- https://github.com/jesseduffield/lazydocker
- https://github.com/junegunn/fzf (Required for shell)
- https://eza.rocks/ (Required for shell aliases)


## Zsh

### Plugins

- zsh-syntax-highlighting
- https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
- https://github.com/zsh-users/zsh-autosuggestions
- https://github.com/marlonrichert/zsh-autocomplete
