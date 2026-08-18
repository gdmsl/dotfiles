# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  kanshi.nix — Automatic display profile switching                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Applies a display layout when monitors come and go — internal panel alone,
# versus a docked arrangement with an external screen.
#
# Profiles are in raw/kanshi/config.

{ pkgs, ... }:

{
  services.kanshi = {
    enable = true;  # runs as a systemd user service
  };

  xdg.configFile."kanshi/config".source = ../../raw/kanshi/config;
}
