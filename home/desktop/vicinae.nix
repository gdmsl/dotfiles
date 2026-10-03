# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  vicinae.nix — Vicinae application launcher                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Application launcher, from its own flake rather than nixpkgs. Runs as a
# daemon so the window opens instantly — see home/services.nix.

{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  # Upstream hardcodes gcc15Stdenv, but numen (its calculator lib) builds with
  # our default stdenv, and linking fails on the libstdc++ mismatch. Build
  # vicinae with the same stdenv. Also used by the daemon in services.nix.
  programs.vicinae.package =
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      gcc15Stdenv = pkgs.stdenv;
    };

  home.packages = [ config.programs.vicinae.package ];
}
