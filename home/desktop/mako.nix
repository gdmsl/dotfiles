# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  mako.nix — Mako notification daemon                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Mako is a lightweight notification daemon for Wayland. It shows desktop
# notifications (from notify-send, apps, etc.) as popup bubbles.
#
# Home Manager's `services.mako` both configures and runs Mako as a
# systemd user service.

{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      font = "Noto 11";
      background-color = "#222222d0";   # semi-transparent dark background
      progress-color = "#5f27cdd0";     # purple progress bar
      icons = true;
      padding = "16";
      width = 450;
      border-color = "#5f27cdd0";
      border-size = 2;
      margin = "8";
      border-radius = 4;
      icon-path = "/usr/share/icons/Yaru/";
      actions = true;                    # allow clickable actions in notifications
      default-timeout = 3333;            # auto-dismiss after ~3.3 seconds
      layer = "overlay";                 # render above all other windows
    };
  };
}
