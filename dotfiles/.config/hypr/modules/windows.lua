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

-- Email

hl.window_rule({
    match     = { class = "org.mozilla.Thunderbird" },
    workspace = "6 silent",
    opacity   = "1.0 1.0",         -- string
})

-- Codium

hl.window_rule({
    match     = { class = "codium" },
    workspace = "2 silent",
    opacity   = "1.0 1.0",         -- string
})

-- Spotify
hl.window_rule({
    match     = { class = "Spotify" },
    workspace = "4 silent",
    opacity   = "1.0 1.0",         -- string
})

-- Firefox
hl.window_rule({
    match     = { class = "firefox" },
    workspace = "3 silent",
    opacity   = "1.0 1.0",         -- string
    no_blur   = false,
})

-- Vesktop

hl.window_rule({
    match     = { class = "vesktop" },
    workspace = "7 silent",
    opacity   = "1.0 1.0",         -- string
})

-- =========================================================
-- Layer Rules
-- =========================================================

hl.layer_rule({
    match = {
        namespace = "quickshell",
    },

    blur = true,
    ignore_alpha = 0.5,
})
hl.window_rule({
  match = { class = "^(brave-browser|brave-web.whatsapp.com__-Default|nwg-look|qemu|qemu-system-x86_64|Surfshark|vesktop|firefox|discord|org.mozilla.Thunderbird|org.gnome.Nautilus|mpv|codium|Spotify|org.qbittorrent.qBittorrent)$" },
  tag = "+hyprglass_disabled",
  no_blur = true,
  opacity = "1.0 override 1.0 override 1.0 override",
})