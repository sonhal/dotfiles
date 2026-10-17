# ly starts Hyprland itself (and sources this file); only autostart on a plain tty login.
if [ "$XDG_SESSION_TYPE" = tty ] && uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi

# only prompt for the key passphrase when there is a terminal to prompt on
if [ -t 0 ]; then
    eval "$(keychain --eval id_ed25519)"
fi
