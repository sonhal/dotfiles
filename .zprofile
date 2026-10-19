# ly starts Hyprland itself (and sources this file); only autostart on a plain tty login.
if [ "$XDG_SESSION_TYPE" = tty ] && uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
