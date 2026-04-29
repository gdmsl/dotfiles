# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  services.nix — systemd user services                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# This module defines systemd user services — background daemons that run in
# your user session (not as root). They're tied to the graphical session so
# they start/stop with your desktop.
#
# Home Manager writes these to ~/.config/systemd/user/<name>.service and
# enables them automatically.
#
# Key systemd concepts:
#   Unit.PartOf   — if the target stops, this service stops too
#   Unit.After    — start this service after the target is up
#   Install.WantedBy — auto-start when this target is reached
#   graphical-session.target — active when your compositor is running
#
# `${pkgs.foo}/bin/bar` is Nix string interpolation — it resolves to the
# full Nix store path of the binary, ensuring the correct version is used.

{ config, pkgs, lib, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  systemd.user.services = {
    # ── Clipboard history ─────────────────────────────────────────────────
    # wl-paste watches the Wayland clipboard; cliphist stores each entry.
    # Use `cliphist list` to see history, or the cliphist-pick script.
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

    # ── Vicinae launcher daemon ───────────────────────────────────────────
    # Runs in server mode so the UI appears instantly when triggered.
    vicinae = {
      Unit = {
        Description = "Vicinae launcher daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.vicinae.packages.${system}.default}/bin/vicinae server";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # TODO: niriswitcher is not in nixpkgs — uncomment once packaged or use overlay
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

    # ── Idle manager ──────────────────────────────────────────────────────
    # hypridle triggers actions on inactivity: lock screen, turn off display,
    # suspend. Configured via hypridle.conf in the Hyprland config dir.
    hypridle = {
      Unit = {
        Description = "Idle manager (lock, DPMS, suspend)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── Noctalia desktop shell ────────────────────────────────────────────
    # Panel, system tray, and desktop shell from the noctalia flake.
    noctalia-shell = {
      Unit = {
        Description = "Noctalia desktop shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.noctalia.packages.${system}.default}/bin/noctalia-shell";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── XWayland for niri (xwayland-satellite) ────────────────────────────
    # niri is a pure-Wayland compositor and doesn't bundle XWayland the way
    # Hyprland does. xwayland-satellite is a small daemon that boots an
    # XWayland server on demand and proxies X11 windows back to niri as
    # individual Wayland surfaces. Without it, Qt5/xcb-only apps (Zoom,
    # older proprietary tools) crash at startup with
    #   qt.qpa.xcb: could not connect to display
    #
    # Type=notify: xwayland-satellite calls sd_notify(READY=1) once the
    # X socket is listening, so dependents only start after `:0` is up.
    # The trailing `:0` arg forces a known display number — must match the
    # `DISPLAY` env var exported by niri's environment{} block in config.kdl.
    xwayland-satellite = {
      Unit = {
        Description = "XWayland satellite (X11 compatibility for niri)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── Auto-mount removable media ────────────────────────────────────────
    # udiskie watches for USB drives and auto-mounts them. --tray shows
    # a system tray icon for safe eject.
    udiskie = {
      Unit = {
        Description = "Auto-mount removable media";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.udiskie}/bin/udiskie --tray";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── Polkit graphical agent ────────────────────────────────────────────
    # Shows the "enter password" dialog when an app asks for elevated
    # privileges (mounting drives, modifying system settings, etc.).
    # Tied to graphical-session.target so it follows the compositor.
    polkit-gnome-agent = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── OneDrive (QPerfect file sync) ─────────────────────────────────────
    # Runs the OneDrive client in monitor mode so changes sync continuously.
    # Auto-starts at user login (default.target), independent of the
    # graphical session — sync should work even on a TTY login.
    onedrive = {
      Unit = {
        Description = "OneDrive sync for QPerfect";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # ── Syncthing vault guard ─────────────────────────────────────────────
    # This companion service watches the encrypted ~/Personal mount.
    # When the vault is unmounted (locked), it stops Syncthing to prevent
    # sync errors against a missing directory.
    # BindsTo means: if syncthing dies, this dies too (and vice versa).
    syncthing-vault-guard = {
      Unit = {
        Description = "Stop syncthing when gocryptfs vault is unmounted";
        BindsTo = [ "syncthing.service" ];
        After = [ "syncthing.service" ];
      };
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash -c 'while ${pkgs.util-linux}/bin/mountpoint -q %h/Personal; do sleep 5; done'";
        ExecStopPost = "${pkgs.systemd}/bin/systemctl --user stop syncthing.service";
      };
      Install = {
        WantedBy = [ "syncthing.service" ];
      };
    };
  };

  # ── Syncthing ───────────────────────────────────────────────────────────
  # Syncthing provides continuous file synchronization between devices.
  # Its config lives inside the encrypted vault for security.
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--home=${config.home.homeDirectory}/Personal/.config/syncthing"
    ];
  };

  # Override Syncthing's auto-start: only run when the vault is mounted.
  # ConditionPathIsMountPoint checks that ~/Personal is a mountpoint.
  # WantedBy = mkForce [] removes it from default.target (no auto-start).
  # Instead, it's started manually via the `unlock-personal` alias.
  systemd.user.services.syncthing = {
    Unit.ConditionPathIsMountPoint = "%h/Personal";
    Install.WantedBy = lib.mkForce [ ];
  };
}
