{ inputs, pkgs, ... }:

{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  # Vicinae launcher — the package is provided by the flake
  home.packages = [
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
