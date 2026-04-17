# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  anyrun.nix — Anyrun application launcher                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Anyrun is a Wayland-native launcher (alternative to rofi/wofi). It supports
# plugins for different search modes: applications, shell commands, symbols,
# translations, dictionary lookups, web search, and file indexing (kidex).
#
# The plugins come from the anyrun flake input (not nixpkgs).

{ inputs, pkgs, ... }:

{
  programs.anyrun = {
    enable = true;
    config = {
      # Plugins loaded from the anyrun flake's package set
      plugins = with inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}; [
        applications   # search installed applications
        shell          # run shell commands
        symbols        # search Unicode symbols and emoji
        translate      # translate text
        dictionary     # dictionary lookups
        websearch      # web search (opens in browser)
        kidex          # file search (uses kidex indexer)
      ];
      width.fraction = 0.3;       # 30% of screen width
      hidePluginInfo = true;       # cleaner UI
      closeOnClick = true;         # dismiss when clicking outside
    };
  };
}
