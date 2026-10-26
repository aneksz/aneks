local hl = _G.hl

hl.config({
    input = {
        -- Change 0 to false
        emulate_discrete_scroll = false,

        -- Keyboard
        kb_layout = "us",
        kb_options = "compose:ralt",
        numlock_by_default = true,

        -- Keyboard repeat
        repeat_rate = 40,
        repeat_delay = 600,

        -- Mouse sensitivity (Float is fine)
        sensitivity = 0.6,

        -- Global mouse scroll factor
        scroll_factor = 2.7,

        touchpad = {
            -- Ensure these are commented out correctly if not used
            -- natural_scroll = true,
            -- clickfinger_behavior = true,
            scroll_factor = 0.4,
        },
    },
})
