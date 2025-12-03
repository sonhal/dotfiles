if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi

eval "$(keychain --eval id_ed25519)"
