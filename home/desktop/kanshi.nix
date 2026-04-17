# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  kanshi.nix — Automatic display profile switching                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Kanshi automatically applies display profiles when monitors are connected
# or disconnected. For example: laptop-only uses the internal display at
# native res, while docked switches to an external monitor layout.
#
# The profile syntax is complex enough that we deploy a raw config file.

{ pkgs, ... }:

{
  services.kanshi = {
    enable = true;  # runs as a systemd user service
  };

  # Deploy the raw kanshi config to ~/.config/kanshi/config
  xdg.configFile."kanshi/config".source = ../../raw/kanshi/config;
}
