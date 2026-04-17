# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  zellij.nix — Zellij terminal multiplexer                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Zellij is a modern terminal multiplexer (alternative to tmux) written in
# Rust. Its config uses KDL (KDL Document Language), which is hard to express
# in Nix attrsets, so we deploy the raw config file directly.
#
# The pattern here — enable the HM module but deploy raw config — is common
# when the config format is too complex to nixify.

{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
  };

  # Deploy the raw KDL config to ~/.config/zellij/config.kdl
  xdg.configFile."zellij/config.kdl".source = ../../raw/zellij/config.kdl;
}
