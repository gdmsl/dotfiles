{ pkgs, ... }:

{
  # Kanshi has a HM module but the profile syntax is complex.
  # Deploy raw config for full fidelity.
  services.kanshi = {
    enable = true;
  };

  xdg.configFile."kanshi/config".source = ../../raw/kanshi/config;
}
