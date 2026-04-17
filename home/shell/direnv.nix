# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  direnv.nix — Automatic environment loading                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# direnv watches for .envrc files in directories. When you `cd` into one, it
# automatically loads the environment (variables, paths, etc.) and unloads it
# when you leave.
#
# nix-direnv extends this with first-class Nix support: put `use flake` in a
# .envrc and direnv will load the flake's devShell — with caching so it
# doesn't re-evaluate every time you cd in.

{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # enables cached `use flake` / `use nix` in .envrc
  };
}
