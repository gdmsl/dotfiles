# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  vicinae.nix — Vicinae application launcher                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Vicinae is an application launcher from a third-party flake. It runs as a
# daemon (server mode, started by services.nix) and shows a search UI on demand.
#
# The package comes from the vicinae flake input, not from nixpkgs.
# `pkgs.stdenv.hostPlatform.system` resolves to "x86_64-linux" (our platform).

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  # Install the vicinae binary (from the flake, not nixpkgs)
  home.packages = [
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
