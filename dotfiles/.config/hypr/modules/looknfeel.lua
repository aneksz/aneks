local hl = _G.hl
local colors = _G.colors

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 8,
        border_size = 1,

        col = {
            active_border   = { 
                colors = { colors.accent, colors.accent_alt }, 
                angle = 45 
            },
            inactive_border = colors.bg1,   -- or "rgba(...)" / 0xAARRGGBB
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "scrolling",
    },
    

    decoration = {
        rounding = 16,
        rounding_power = 3,   
        active_opacity   = 0.85,
        inactive_opacity = 0.75,

        dim_inactive = true,
        dim_strength = 0.15,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee121212,
        },

        blur = {
            enabled    = true,
            size       = 13,
            passes     = 2,
            noise      = 0,
            contrast   = 2,
            vibrancy   = 0.35,
            vibrancy_darkness = 0.35,
            brightness = 0.8,
        },
    },

    -- Added to stop Hyprland from stretching wallpaper textures on layer changes
    render = {
        expand_undersized_textures = false,
    },
})
