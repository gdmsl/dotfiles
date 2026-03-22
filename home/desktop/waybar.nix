{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    # The waybar config uses JSONC (comments) which is hard to express in Nix attrsets.
    # Deploy it as raw files for full fidelity.
    settings = { };
  };

  xdg.configFile."waybar/config".source = ../../raw/waybar/config;
  xdg.configFile."waybar/style.css".source = ../../raw/waybar/style.css;
}
