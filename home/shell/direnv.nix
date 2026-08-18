# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  direnv.nix — Automatic environment loading                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Loads a directory's .envrc when you cd in and unloads it when you leave.
#
# nix-direnv adds Nix support: `use flake` in an .envrc gets you that flake's
# devShell, cached so it isn't re-evaluated on every cd.
#
# New .envrc files need `direnv allow` once before they'll load.

{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # enables cached `use flake` / `use nix` in .envrc
  };
}
