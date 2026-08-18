# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  vicinae.nix — Vicinae application launcher                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Application launcher, from its own flake rather than nixpkgs. Runs as a
# daemon so the window opens instantly — see home/services.nix.

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  home.packages = [
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
