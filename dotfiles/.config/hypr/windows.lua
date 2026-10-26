local hl = _G.hl

-- =========================================================
-- Workspace Rules
-- =========================================================
hl.workspace_rule({
    workspace  = "7",
    monitor    = "DP-3",
    layout_opts = { direction = "down" }
})

for i = 1, 6 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = "DP-1",
        persistent = true,
        default    = (i == 1),
    })
end

-- =========================================================
-- Window Rules
-- =========================================================

-- Global Opacity
 hl.window_rule({
    match   = { class = ".*" },
    opacity = "0.9 0.9",         
})

-- Steam
hl.window_rule({
    match     = { class = "^steam$" },
    workspace = "5 silent",
})

hl.window_rule({
    match     = { class = "^steamwebhelper$" },
    workspace = "5 silent",
})

-- Spotify
hl.window_rule({
    match     = { class = "Spotify" },
    workspace = "4 silent",
    opacity   = "1.0 1.0",         -- string
})

-- Brave
hl.window_rule({
    match     = { class = "brave-browser" },
    workspace = "3 silent",
    opacity   = "1.0 1.0",         -- string
    no_blur   = false,
})


-- =========================================================
-- Layer Rules
-- =========================================================

hl.layer_rule({
    match = {
        namespace = "quickshell",
    },

    blur = false,
    ignore_alpha = 1.0,
})
hl.window_rule({
  match = { class = "^(brave-browser|nwg-look|qemu|qemu-system-x86_64|Surfshark|vesktop|firefox|discord|org.mozilla.Thunderbird|org.gnome.Nautilus|mpv|codium|Spotify|org.qbittorrent.qBittorrent)$" },
  tag = "+hyprglass_disabled",
  no_blur = true,
  opacity = "1.0 override 1.0 override 1.0 override",
})