{ pkgs, ... }:

{
  # Niri has no Home Manager module -- deploy raw KDL config
  xdg.configFile."niri/config.kdl".source = ../../raw/niri/config.kdl;

  # Niriswitcher config
  xdg.configFile."niriswitcher/config.toml".source = ../../raw/niriswitcher/config.toml;
}
