-- Keyboard / pointer input.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "intl",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        touchpad = {
            natural_scroll      = true,
            clickfinger_behavior = true,
        },

        -- -1.0 .. 1.0, 0 means no modification.
        sensitivity = 0,
    },
})
