-- Window decoration: rounding, transparency, blur, shadow.
hl.config({
    decoration = {
        rounding = 5,

        dim_inactive       = false,
        active_opacity     = 1.0,
        inactive_opacity   = 0.9,
        fullscreen_opacity = 1.0,

        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            new_optimizations  = true,
            noise              = 0.01,
            contrast           = 0.9,
            brightness         = 0.8,
        },

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 2,
            color        = "rgba(00000044)",
        },
    },
})
