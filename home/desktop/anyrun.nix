{ inputs, pkgs, ... }:

{
  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}; [
        applications
        shell
        symbols
        translate
        dictionary
        websearch
        kidex
      ];
      width.fraction = 0.3;
      hidePluginInfo = true;
      closeOnClick = true;
    };
  };
}
