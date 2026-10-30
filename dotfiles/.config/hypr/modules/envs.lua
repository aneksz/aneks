local hl = _G.hl

-- Wayland
hl.env("GDK_BACKEND", "wayland")
hl.env("QS_NO_RELOAD_POPUP", "1")

-- XDG

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1.5")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_ICON_THEME","Papirus")
hl.env("QT_STYLE_OVERRIDE","gtk2")

-- NVIDIA
hl.env("NVD_BACKEND","direct")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Hyprshot
hl.env("HYPRSHOT_DIR", "/home/igor/Pictures/Screenshots")

-- Cursor
hl.env("XCURSOR_SIZE", "30")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")

-- Ensure the cursor theme applies to the Hyprland process specifically
hl.config({
    env = {
        "XCURSOR_SIZE,30",
        "XCURSOR_THEME,Bibata-Modern-Classic",
    }
})
