# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  anyrun.nix — Anyrun application launcher                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Another Wayland launcher, plugin-based: applications, shell commands,
# symbols, translation, dictionary, web search, file indexing.
#
# Plugins come from the anyrun flake input.

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
