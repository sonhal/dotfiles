# Dotfiles

## Note
Intended for an Arch linux install with hyprland.

Run `./check.sh` to see if the fonts and packages the configs expect are installed; `./check.sh --kitty` also
starts kitty briefly to check which font it actually loads.


## Login

Package: `ly` (TUI greeter). Enable it on tty2 (its unit conflicts with `getty@tty2`, so no need
to disable that):

```sh
sudo systemctl enable ly@tty2.service
```

Pick the `Hyprland (uwsm-managed)` session; ly remembers it. `.zprofile` only autostarts Hyprland
on a plain tty login, so the other ttys still work as a fallback.

## Notifications

Package: `swaync`. It runs from its systemd user unit, which uwsm starts with the graphical
session. Enable it once per machine (not stored in the dotfiles):

```sh
systemctl --user enable swaync
```

Don't also start it from Hyprland's autostart: the unit then finds an instance already running,
fails, and shows up as a failed unit in the bar.

Check it's running correctly:

```sh
systemctl --user status swaync    # active (running), started by systemd
systemctl --user --failed         # should not list swaync
notify-send test                  # a popup should appear
```

If the unit failed earlier, clear it with `systemctl --user reset-failed swaync` and restart it.

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

Packages (AUR): `nordic-theme` (GTK theme `Nordic`), `nordzy-icon-theme` (icons `Nordzy-dark`).

- The GTK theme and icons are picked in nwg-look only; `hypr/envs.lua` just sets the dark
  `color-scheme`.
- nwg-look writes `gtk-3.0/settings.ini` and `gtk-4.0/` (its CSS files link into the selected theme,
  so GTK 4 apps follow it too); symlink both folders into `~/.config`.
- Terminal, Rofi, Hyprland, hyprlock and Neovim use the Nord palette with the darker `#242933`
  background.
- `swaync/style.css` imports swaync's default style and only changes its colors; symlink `swaync/`
  into `~/.config`. `btop/btop.conf` is linked as a file into `~/.config/btop/`.

### Qt apps

Packages: `kvantum`, `kvantum-qt5`, `qt5ct`, `qt6ct`, `breeze-icons`.

- Qt apps use the Kvantum style via qt6ct (env set in `hypr/envs.lua`). `Kvantum/`, `qt5ct/` and
  `qt6ct/` set them to the Nordic-Solid Kvantum theme with Nordzy-dark icons; symlink them into
  `~/.config`. Both take their palette from the Kvantum theme.
- `Kvantum/Nordic-Solid/` is copied from https://github.com/EliverLara/Nordic (`kde/kvantum/`); the
  Solid variant skips the translucency and blur that only work under KWin.
- Qt 5 apps load qt5ct, which also answers to `QT_QPA_PLATFORMTHEME=qt6ct`, and need
  `kvantum-qt5` for the style.

### Thunar

Packages: `thunar`, `tumbler` (thumbnails), `gvfs` (devices, trash), `gvfs-mtp` (Android),
`xdg-user-dirs`.

- Side pane bookmarks live in `~/.config/gtk-3.0/bookmarks`. It holds absolute paths, so it isn't
  tracked; if it's missing, `xdg-user-dirs-gtk-update` (package `xdg-user-dirs-gtk`) creates it with
  the standard XDG user dirs at Hyprland start.
- Dates use the locale's time format; `LC_TIME=en_GB.UTF-8` (set in `hypr/envs.lua`) gives 24-hour
  time and needs `en_GB.UTF-8` uncommented in `/etc/locale.gen` before running `locale-gen`.

## Fonts

Packages: `ttf-lilex` (AUR), `inter-font`, `ttf-nerd-fonts-symbols`, `noto-fonts`,
`ttf-joypixels`, `ttf-dejavu`.

- kitty uses plain Lilex, not a Nerd Font: kitty's FAQ advises against patched fonts, and kitty
  ships its own Nerd Font symbols, which `kitty.conf` pins the icon code points to (Nerd Fonts
  v3.5 ranges).
- kitty only accepts fonts fontconfig marks as monospace. Lilex Medium and SemiBold are not (a few
  glyphs have stray widths), so stick to Regular/Bold.
- Waybar text uses Inter with fixed-width digits (`tnum`); icons come from Symbols Nerd Font, so
  they must use Nerd Font code points (Nerd Fonts v3 has the newer Font Awesome icons under
  `nf-fa-*`, not at Font Awesome's own code points).
- UI text uses Inter: GTK (set in nwg-look), hyprlock, rofi, and `fontconfig/fonts.conf` makes it
  the default `sans-serif` for everything else (Qt, browsers). The same file makes Lilex the default
  `monospace`. Symlink `fontconfig/` into `~/.config`. Noto Sans stays installed as the fallback for
  characters Inter lacks.
- `hypr/envs.lua` sets the GNOME document font (Inter) and monospace font (Lilex) with gsettings at
  Hyprland start; nwg-look only sets the main UI font.
- JoyPixels is the colour emoji font, e.g. for starship's default module symbols.
- Lilex lacks the starship prompt symbol `➜`; kitty draws it from DejaVu Sans Mono.


## Key packages
Started by keybinds etc...

- https://github.com/junegunn/fzf (Required for shell)
- https://eza.rocks/ (Required for shell aliases)
- https://github.com/sharkdp/bat (Required for the `ff` alias)
- https://starship.rs/ (Shell prompt, config in `.config/starship.toml`)


## Zsh

### Plugins

- zsh-syntax-highlighting
- https://github.com/zsh-users/zsh-autosuggestions
- https://github.com/zsh-users/zsh-history-substring-search (Up/Down search history for what's typed)

## Tmux

Config in `.config/tmux/`; symlink the folder into `~/.config`. Prefix is `C-s`.

### Sessionizer

`prefix f` (or `t` in the shell) picks a project with fzf and switches to its session, creating
it if needed. It lists the dotfiles repo and the folders in the XDG projects dir; a folder there
without `.git` or a build file is treated as a group and its subfolders are listed too.

The projects dir is per machine (`~/.config/user-dirs.dirs`, not tracked). Point it at wherever
projects live on this machine:

```sh
xdg-user-dirs-update --set PROJECTS ~/Development
xdg-user-dir PROJECTS    # check
```
