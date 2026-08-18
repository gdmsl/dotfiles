# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  zellij.nix — Zellij terminal multiplexer                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Terminal multiplexer, an alternative to tmux. The Home Manager module is
# enabled for the package, but the config comes from raw/zellij/config.kdl.

{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
  };

  xdg.configFile."zellij/config.kdl".source = ../../raw/zellij/config.kdl;
}
