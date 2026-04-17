# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  noctalia.nix — Noctalia desktop shell                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Noctalia is a desktop shell (panel, system tray, Bluetooth UI, etc.) that
# comes from a third-party flake. It provides its own Home Manager module
# which we import to get its `programs.noctalia-shell` options.
#
# `inputs.noctalia` is the flake input defined in flake.nix, and
# `homeModules.default` is the Home Manager module it exports.

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      # Noctalia configuration — customize via the GUI or add settings here
    };
  };
}
