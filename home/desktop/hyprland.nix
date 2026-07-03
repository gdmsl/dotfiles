# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hyprland.nix — Hyprland window manager configuration                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Since Hyprland 0.55 / Home Manager 26.05 the config is written in Lua. The
# canonical entry-point is `~/.config/hypr/hyprland.lua`, which `require()`s
# sibling modules (Hyprland adds `~/.config/hypr/` to package.path).
#
# We deploy the raw Lua files from raw/hypr/ as symlinks. The helper scripts
# in raw/hypr/scripts/ are checked in with the executable bit set so Nix
# preserves it through the store import.
#
# Note: hyprpaper still uses hyprlang — it's a separate daemon with its own
# parser and wasn't migrated by 0.55.

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

    # Standalone hyprlang config for hypridle, the idle/sleep manager. Its idle
    # actions — dim, DPMS off, suspend, and firing `loginctl lock-session` —
    # live in hypridle.conf. The lock *screen* is noctalia's: it catches the
    # logind Lock signal and raises its own locker. noctalia also owns the bar,
    # clipboard, and notifications.
    "hypr/hypridle.conf".source = ../../raw/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ../../raw/hypr/hyprpaper.conf;
    "hypr/hyprshade.toml".source = ../../raw/hypr/hyprshade.toml;

    # Modular fragments and helper scripts. `recursive = true` deploys the
    # directory contents one-by-one as symlinks, instead of symlinking the
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
