# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  waybar.nix — Waybar status bar                                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Waybar is a highly customizable status bar for Wayland compositors. It shows
# workspaces, system tray, clock, battery, network, audio, and more.
#
# The config uses JSONC (JSON with comments) which is hard to express in Nix
# attrsets, so we deploy raw config files for full fidelity. The CSS file
# controls the bar's appearance.

{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    # We override the Nix-generated config with raw files below
    settings = { };
  };

  # Deploy the raw JSONC config and CSS stylesheet
  xdg.configFile."waybar/config".source = ../../raw/waybar/config;
  xdg.configFile."waybar/style.css".source = ../../raw/waybar/style.css;
}
