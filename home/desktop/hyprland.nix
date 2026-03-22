{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the raw modular config via source directives
    extraConfig = builtins.readFile ../../raw/hypr/hyprland.conf;
  };

  # Deploy all hyprland config files (the modular source= structure)
  xdg.configFile = {
    "hypr/hyprland.conf".source = ../../raw/hypr/hyprland.conf;
    "hypr/monitors.conf".source = ../../raw/hypr/monitors.conf;
    "hypr/workspaces.conf".source = ../../raw/hypr/workspaces.conf;
    "hypr/hyprlock.conf".source = ../../raw/hypr/hyprlock.conf;
    "hypr/hypridle.conf".source = ../../raw/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ../../raw/hypr/hyprpaper.conf;
    "hypr/hyprshade.toml".source = ../../raw/hypr/hyprshade.toml;
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
