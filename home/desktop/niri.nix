# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  niri.nix — Niri scrolling tiling compositor                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Niri is a scrolling tiling Wayland compositor — windows arrange in an
# infinite horizontal strip that you scroll through (unlike traditional tiling
# where windows share the screen). It uses KDL config format.
#
# No Home Manager module exists for Niri, so we just deploy raw config files.

{ pkgs, ... }:

{
  # Deploy Niri's KDL config to ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".source = ../../raw/niri/config.kdl;

  # Niriswitcher: Alt-Tab style window switcher for Niri
  xdg.configFile."niriswitcher/config.toml".source = ../../raw/niriswitcher/config.toml;
}
