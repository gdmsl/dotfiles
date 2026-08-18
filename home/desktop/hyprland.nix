# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hyprland.nix — Hyprland window manager configuration                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Hyprland's config is Lua as of 0.55. The entry point is
# ~/.config/hypr/hyprland.lua, which require()s the other modules — Hyprland
# puts ~/.config/hypr on package.path.
#
# The files come from raw/hypr/. Anything in raw/hypr/scripts/ needs its
# executable bit committed to git, or it won't be executable after the copy into
# the store.
#
# hyprpaper is the exception and still uses the older hyprlang format.

{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # Generate `~/.config/hypr/hyprland.lua` instead of the legacy `.conf`.
    configType = "lua";
    # The entry-point Lua file gets appended verbatim into the HM-rendered
    # hyprland.lua. From there it `require()`s everything in conf/.
    extraConfig = builtins.readFile ../../raw/hypr/hyprland.lua;
  };

  xdg.configFile = {
    # Top-level Lua modules referenced directly from hyprland.lua
    "hypr/vars.lua".source = ../../raw/hypr/vars.lua;
    "hypr/monitors.lua".source = ../../raw/hypr/monitors.lua;
    "hypr/workspaces.lua".source = ../../raw/hypr/workspaces.lua;

    # The auxiliary daemons, which still use hyprlang rather than Lua. Locking
    # and idle are hyprlock and hypridle; noctalia provides the bar, clipboard
    # and notifications.
    "hypr/hyprlock.conf".source = ../../raw/hypr/hyprlock.conf;
    "hypr/hypridle.conf".source = ../../raw/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ../../raw/hypr/hyprpaper.conf;
    "hypr/hyprshade.toml".source = ../../raw/hypr/hyprshade.toml;

    # `recursive = true` links each file individually instead of symlinking the
    # whole directory — that means new files show up after a `switch`.
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
