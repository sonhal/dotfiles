-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Dark mode (GTK theme and icons are picked in nwg-look)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("GTK_USE_PORTAL", "1")

-- 24-hour time (en_US uses AM/PM); needs en_GB.UTF-8 in /etc/locale.gen
hl.env("LC_TIME", "en_GB.UTF-8")

-- Use XCompose file
hl.env("XCOMPOSEFILE", os.getenv("HOME") .. "/.XCompose")

-- Dark mode and fonts for libadwaita/portal apps. nwg-look only sets the UI font (font-name).
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name 'Lilex 11'")
end)
