-- Autostart. Replaces the old `exec-once = ...` lines.
--
-- Top-level `hl.exec_cmd(...)` would also work and would re-run on every
-- reload (like hyprlang `exec`). Wrapping in `hl.on("hyprland.start", ...)`
-- gives us exec-once semantics: these run when the compositor starts, not
-- on hyprctl reload.

hl.on("hyprland.start", function()
    -- Hand the user session bus / systemd the variables it needs to launch
    -- graphical units (waybar, portals, etc.) into the right Wayland session.
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XAUTHORITY")

    -- gnome-keyring is D-Bus activated, but pkcs11/secrets/ssh need an explicit hint.
    hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")

    -- noctalia-shell, kanshi, hyprpolkitagent, vicinae, cliphist, hypridle,
    -- hyprpaper, udiskie are launched via systemd user units (see
    -- run_once_install-hyprland.sh). nm-applet is started by xdg-autostart.

    -- Auto-applied screen shader (night light, etc.)
    hl.exec_cmd("uwsm app -- hyprshade auto")
    -- Monitor rotation daemon for the 2-in-1 hinge.
    hl.exec_cmd("uwsm app -- iio-hyprland")
    -- Hot-load any plugins managed by hyprpm.
    hl.exec_cmd("uwsm app -- hyprpm reload -n")
end)
