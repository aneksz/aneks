local hl = _G.hl

-- Environment
hl.env("GDK_SCALE", "2")
hl.env("GDK_DPI_SCALE", "1")

hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@60",
    position = "1080x0",
    scale    = 1.5,
})

hl.monitor({
    output    = "DP-3",
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = 1,
    transform = 3,
})

-- Workspaces (only on main monitor)
for i = 1, 6 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = "DP-1",
        persistent = true,
    })
end

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})