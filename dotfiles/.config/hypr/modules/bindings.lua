local hl = _G.hl

-- Variables
local terminal = "kitty --single-instance"
local browser   = "firefox"
local email = "thunderbird"
local editor = "codium"


-- Helper for exec (much cleaner)
local function bind_exec(key, cmd)
    hl.bind(key, hl.dsp.exec_cmd(cmd))
end

-- Application Launchers
bind_exec("SUPER + SPACE", "~/.config/quickshell/bar2/toggle-launcher.sh")
bind_exec("SUPER + RETURN", terminal)
bind_exec("SUPER + F", "nautilus --new-window")
bind_exec("SUPER + B", browser)
bind_exec("SUPER + SHIFT + B", "firefox --private-window")
bind_exec("SUPER + M", "spotify")
bind_exec("SUPER + E", email)
bind_exec("SUPER + SHIFT + V", editor)
bind_exec("SUPER + P", "qs ipc -c ~/.config/quickshell/bar2 call power toggle")

-- Scripts & Utilities
bind_exec("SUPER + S", "~/.config/hypr/scripts/theme-selector.sh")
bind_exec("SUPER + R", "~/.config/hypr/scripts/relaunch.sh")
bind_exec("SUPER + H", "~/.config/hypr/scripts/wall.sh")
bind_exec("SUPER + L", "quickshell -p ~/.config/quickshell/lock/shell.qml")
bind_exec("CONTROL + ALT + DELETE", "~/.config/hypr/scripts/close-all.sh")


hl.bind("SUPER + T", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/bar2 ipc call timer open"))
-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region | satty --filename -"))
hl.bind("CONTROL + ALT + Print", hl.dsp.exec_cmd("hyprshot -m window"))

-- Window Management
hl.bind("SUPER + N", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + W", hl.dsp.window.close())

-- Focus
hl.bind("SUPER + LEFT",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + DOWN",  hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + UP",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }))

-- Workspaces (1-6)
for i = 1, 6 do
    local ws = tostring(i)
    hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = i }))
end

-- Mouse Bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize (keyboard)
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.exec_cmd("resizeactive 10 0"), { repeating = true })
hl.bind("SUPER + SHIFT + LEFT",  hl.dsp.exec_cmd("resizeactive -10 0"), { repeating = true })
hl.bind("SUPER + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind("SUPER + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))

-- Caps Lock


hl.bind("Caps_Lock", hl.dsp.exec_cmd("qs ipc -p /home/igor/.config/quickshell/bar2 call caps_osd toggle"))


-- Volume

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
