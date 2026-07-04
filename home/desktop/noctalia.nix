# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  noctalia.nix — Noctalia desktop shell                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Noctalia is a desktop shell (panel, system tray, notification daemon, etc.)
# that comes from a third-party flake. It provides its own Home Manager module
# which we import to get its `programs.noctalia` options.
#
# `inputs.noctalia` is the flake input defined in flake.nix, and
# `homeModules.default` is the Home Manager module it exports. That module also
# sets `programs.noctalia.package` for us by default, so we don't pick a package
# here.
#
# Settings
# --------
# `settings` is written to ~/.config/noctalia/config.toml. It accepts a Nix
# attrset (converted to TOML), a raw TOML string, or a path to a .toml file.
# Anything set here can still be changed at runtime from the settings menu.
# See <https://docs.noctalia.dev/v5> for the available keys.

{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      # Keep noctalia's built-in lock screen OFF. noctalia 5.0 gained logind
      # lock integration (session lock, LockedHint, lock-on-suspend), but we
      # currently find it too unstable, so locking stays on hyprlock + hypridle
      # (see home/services.nix and raw/hypr/hypridle.conf). With
      # lockscreen.enabled = false, noctalia does not register the logind
      # session-lock listener, so `loginctl lock-session` reaches hypridle →
      # hyprlock instead of being grabbed by noctalia (which is what happened
      # after the 5.0 update).
      #
      # This is written to ~/.config/noctalia/config.toml (noctalia v5's
      # declarative config). Being Nix-managed and read-only, it survives
      # noctalia updates and settings resets — the "stays disabled" guarantee.
      # The GUI can still toggle other settings; it just can't quietly turn the
      # lock screen back on.
      lockscreen.enabled = false;
    };
  };
}
