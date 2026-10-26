hl.on("hyprland.start", function()
    -- 🌐 Step 1: Force systemd and DBus environments to synchronize thoroughly
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("elephant")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww restore")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hypridle")
   -- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("quickshell -p ~/.config/quickshell/lock/shell.qml")
    hl.exec_cmd("~/.config/hypr/scripts/spotify-notify.sh")

    -- ⏳ Step 2: Handle standard delayed operations safely via explicit shell
    hl.exec_cmd("bash -c 'sleep 1.2 && hyprpm reload -q'")
    hl.exec_cmd("bash -c 'sleep 4 && export QT_QPA_PLATFORMTHEME=qt6ct && qs -p /home/igor/.config/quickshell/bar2'")
  
end)
