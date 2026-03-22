{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      font = "Noto 11";
      background-color = "#222222d0";
      progress-color = "#5f27cdd0";
      icons = true;
      padding = "16";
      width = 450;
      border-color = "#5f27cdd0";
      border-size = 2;
      margin = "8";
      border-radius = 4;
      icon-path = "/usr/share/icons/Yaru/";
      actions = true;
      default-timeout = 3333;
      layer = "overlay";
    };
  };
}
