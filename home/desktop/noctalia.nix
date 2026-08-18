# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  noctalia.nix — Noctalia desktop shell                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Desktop shell — panel, tray, notifications — from its own flake, which also
# ships the Home Manager module imported below. That module picks the package,
# so there's nothing to set here.
#
# It runs as a user service, see home/services.nix.
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
      # Locking is hyprlock + hypridle, not noctalia's own. noctalia also
      # registers a logind session-lock listener when its lock screen is
      # enabled, and then `loginctl lock-session` reaches noctalia instead of
      # hypridle. Turning it off here is what keeps that path clear.
      #
      # This writes ~/.config/noctalia/config.toml. Since the file is
      # Nix-managed and read-only, the setting survives updates and can't be
      # switched back on from noctalia's own settings UI.
      lockscreen.enabled = false;
    };
  };
}
