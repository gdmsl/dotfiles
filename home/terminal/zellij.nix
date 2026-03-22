{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
  };

  # Zellij config is KDL which is hard to nixify -- deploy raw
  xdg.configFile."zellij/config.kdl".source = ../../raw/zellij/config.kdl;
}
