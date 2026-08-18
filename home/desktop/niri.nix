# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  niri.nix — Niri scrolling tiling compositor                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Scrolling tiling Wayland compositor: windows sit in an endless horizontal
# strip you scroll through, rather than sharing the screen.
#
# There's no Home Manager module for it, so the config is deployed as-is from
# raw/niri/. The compositor itself is enabled in system/default.nix.

{ pkgs, ... }:

{
  # Edit raw/niri/config.kdl, then rebuild.
  xdg.configFile."niri/config.kdl".source = ../../raw/niri/config.kdl;

  # Niriswitcher: Alt-Tab style window switcher for Niri
  xdg.configFile."niriswitcher/config.toml".source = ../../raw/niriswitcher/config.toml;
}
