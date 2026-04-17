# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hyprland.nix — Hyprland window manager configuration                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Hyprland is a dynamic tiling Wayland compositor. Its config uses a custom
# format with `source=` directives for modularity (similar to CSS @import).
#
# Rather than nixifying the entire config, we deploy the raw config files
# from raw/hypr/ into ~/.config/hypr/ using xdg.configFile. This approach
# is common for apps with complex config formats that don't map well to Nix.
#
# The `xdg.configFile.<name>.source` attribute tells Home Manager to create
# a symlink (or copy) from the Nix store to ~/.config/<name>.
# Setting `executable = true` preserves the execute permission (for scripts).

{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # Load the main Hyprland config (which source= includes the modular files)
    extraConfig = builtins.readFile ../../raw/hypr/hyprland.conf;
  };

  # Deploy all Hyprland config files to ~/.config/hypr/
  # The modular structure keeps things organized:
  #   hypr/hyprland.conf       — main entry point (sources everything below)
  #   hypr/conf/*.conf         — modular config files (keybindings, animations, etc.)
  #   hypr/scripts/*.sh        — helper scripts (lid switch, monitor detection, etc.)
  xdg.configFile = {
    # Main config files
    "hypr/hyprland.conf".source = ../../raw/hypr/hyprland.conf;
    "hypr/monitors.conf".source = ../../raw/hypr/monitors.conf;
    "hypr/workspaces.conf".source = ../../raw/hypr/workspaces.conf;
    "hypr/hyprlock.conf".source = ../../raw/hypr/hyprlock.conf;
    "hypr/hypridle.conf".source = ../../raw/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ../../raw/hypr/hyprpaper.conf;
    "hypr/hyprshade.toml".source = ../../raw/hypr/hyprshade.toml;

    # Modular config directory
    "hypr/conf/animations.conf".source = ../../raw/hypr/conf/animations.conf;
    "hypr/conf/autostart.conf".source = ../../raw/hypr/conf/autostart.conf;
    "hypr/conf/cursor.conf".source = ../../raw/hypr/conf/cursor.conf;
    "hypr/conf/custom.conf".source = ../../raw/hypr/conf/custom.conf;
    "hypr/conf/decoration.conf".source = ../../raw/hypr/conf/decoration.conf;
    "hypr/conf/devices.conf".source = ../../raw/hypr/conf/devices.conf;
    "hypr/conf/environment.conf".source = ../../raw/hypr/conf/environment.conf;
    "hypr/conf/gestures.conf".source = ../../raw/hypr/conf/gestures.conf;
    "hypr/conf/group.conf".source = ../../raw/hypr/conf/group.conf;
    "hypr/conf/gtk.conf".source = ../../raw/hypr/conf/gtk.conf;
    "hypr/conf/keybindings.conf".source = ../../raw/hypr/conf/keybindings.conf;
    "hypr/conf/keyboard.conf".source = ../../raw/hypr/conf/keyboard.conf;
    "hypr/conf/layout.conf".source = ../../raw/hypr/conf/layout.conf;
    "hypr/conf/misc.conf".source = ../../raw/hypr/conf/misc.conf;
    "hypr/conf/monitors.conf".source = ../../raw/hypr/conf/monitors.conf;
    "hypr/conf/plugins.conf".source = ../../raw/hypr/conf/plugins.conf;
    "hypr/conf/window.conf".source = ../../raw/hypr/conf/window.conf;
    "hypr/conf/windowrule.conf".source = ../../raw/hypr/conf/windowrule.conf;

    # Helper scripts (need executable permission)
    "hypr/scripts/desktop-portals.sh" = {
      source = ../../raw/hypr/scripts/desktop-portals.sh;
      executable = true;
    };
    "hypr/scripts/lidswitch.sh" = {
      source = ../../raw/hypr/scripts/lidswitch.sh;
      executable = true;
    };
    "hypr/scripts/monitor-config.sh" = {
      source = ../../raw/hypr/scripts/monitor-config.sh;
      executable = true;
    };
    "hypr/scripts/toggle_layout.sh" = {
      source = ../../raw/hypr/scripts/toggle_layout.sh;
      executable = true;
    };
  };
}
