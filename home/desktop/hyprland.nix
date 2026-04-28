# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hyprland.nix — Hyprland window manager configuration                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Hyprland's config format uses `source=` directives for modularity (similar
# to CSS @import). Rather than nixifying it, we deploy the raw config files
# from raw/hypr/ into ~/.config/hypr/.
#
# The two subtrees `conf/` (modular fragments sourced by hyprland.conf) and
# `scripts/` (helper scripts called from keybindings) are deployed via
# `recursive = true`, which symlinks everything inside in one shot — much
# tidier than listing each file. Scripts in raw/hypr/scripts are checked in
# with the executable bit set so Nix preserves it through the store import.

{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # Read the entry-point config file as the HM-managed hyprland.conf;
    # it `source=`s everything in conf/ which we deploy below.
    extraConfig = builtins.readFile ../../raw/hypr/hyprland.conf;
  };

  xdg.configFile = {
    # Top-level fragments referenced directly from hyprland.conf
    "hypr/monitors.conf".source = ../../raw/hypr/monitors.conf;
    "hypr/workspaces.conf".source = ../../raw/hypr/workspaces.conf;
    "hypr/hyprlock.conf".source = ../../raw/hypr/hyprlock.conf;
    "hypr/hypridle.conf".source = ../../raw/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ../../raw/hypr/hyprpaper.conf;
    "hypr/hyprshade.toml".source = ../../raw/hypr/hyprshade.toml;

    # Modular fragments (animations, keybindings, etc.) and helper scripts.
    # `recursive = true` deploys the directory contents one-by-one as
    # symlinks, instead of symlinking the whole directory — that means new
    # files added later still show up after `home-manager switch`.
    "hypr/conf" = {
      source = ../../raw/hypr/conf;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ../../raw/hypr/scripts;
      recursive = true;
    };
  };
}
