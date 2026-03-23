{ inputs, pkgs, ... }:

{
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}; [
        applications   # app launcher
        shell          # shell commands
        symbols        # unicode symbols
        translate      # translation
        dictionary     # dictionary lookup
        websearch      # web search
        kidex          # file search
      ];
      width.fraction = 0.3;
      hidePluginInfo = true;
      closeOnClick = true;
    };
  };
}
