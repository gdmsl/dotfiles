-- Custom / per-machine binds.

-- Lid switch — fire the helper script when the laptop lid opens/closes.
-- `switch:` is a special keysym recognised by Hyprland's bind parser; the
-- name after the colon comes from libinput. `{ locked = true }` is the
-- Lua-mode equivalent of hyprlang's `bindl=`.
hl.bind(
    "switch:Lid Switch",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/lidswitch.sh"),
    { locked = true }
)
