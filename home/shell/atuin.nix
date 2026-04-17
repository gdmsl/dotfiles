# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  atuin.nix — Shell history sync and search                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Atuin replaces the default shell history (Ctrl+R) with a searchable,
# syncable database. It stores commands with context (directory, exit code,
# duration) and can optionally sync across machines.
#
# `enableFishIntegration`, etc., tells Home Manager to add the necessary
# hooks to each shell's init file so Atuin intercepts Ctrl+R.

{ pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      style = "compact";    # compact display (more results visible)
      inline_height = 20;   # number of lines shown in the search overlay
    };
  };
}
