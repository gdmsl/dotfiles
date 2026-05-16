-- General window layout & border colors.
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 7,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        no_border_on_floating = false,

        layout = "dwindle",
    },
})
