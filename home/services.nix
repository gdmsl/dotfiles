{ config, pkgs, ... }:

{
  # Systemd user services converted from run_once_install-niri.sh and run_once_install-hyprland.sh
  # These services were previously enabled imperatively via chezmoi run_once scripts.
  # Now they are declared in Home Manager.

  systemd.user.services = {
    cliphist = {
      Unit = {
        Description = "Clipboard history manager";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # TODO: vicinae is not in nixpkgs -- uncomment once packaged or use overlay
    # vicinae = {
    #   Unit = {
    #     Description = "Vicinae launcher";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     ExecStart = "vicinae";
    #     Restart = "on-failure";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };

    # TODO: niriswitcher is not in nixpkgs -- uncomment once packaged or use overlay
    # niriswitcher = {
    #   Unit = {
    #     Description = "Niriswitcher window switcher";
    #     PartOf = [ "niri.service" ];
    #     After = [ "niri.service" ];
    #   };
    #   Service = {
    #     ExecStart = "niriswitcher";
    #     Restart = "on-failure";
    #   };
    #   Install = {
    #     WantedBy = [ "niri.service" ];
    #   };
    # };

    # TODO: noctalia-shell is not in nixpkgs -- uncomment once packaged
    # noctalia-shell = {
    #   Unit = {
    #     Description = "Noctalia shell";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     ExecStart = "noctalia-shell";
    #     Restart = "on-failure";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
