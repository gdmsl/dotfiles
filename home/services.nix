# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  services.nix — systemd user services                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Background daemons that run in your user session rather than as root. Home
# Manager writes them to ~/.config/systemd/user/ and enables them.
#
# The systemd fields used below:
#   PartOf     — stop this when the named target stops
#   After      — don't start until the target is up
#   WantedBy   — start automatically once the target is reached
#   graphical-session.target — active while a compositor is running
#
# `${pkgs.foo}/bin/bar` interpolates the store path, which pins the exact build
# rather than relying on PATH.
#
# Useful when something here misbehaves:
#   systemctl --user status <name>
#   journalctl --user -u <name> -f

{ config, pkgs, lib, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  systemd.user.services = {
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
    # Dims, locks, blanks and suspends on inactivity. Configured in
    # raw/hypr/hypridle.conf.
    #
    # Locking is hypridle + hyprlock rather than noctalia's own, which is
    # disabled in desktop/noctalia.nix. hypridle registers a sleep inhibitor so
    # the screen locks before suspend rather than after waking.
    hypridle = {
      Unit = {
        Description = "Idle manager (dim, lock, DPMS, suspend)";
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

    # ── niri workspace auto-clean ─────────────────────────────────────────
    # niri keeps named workspaces around when they empty; this removes them so
    # they behave like the numbered ones. The script (home/scripts.nix) sits on
    # niri's event stream for as long as the session lasts.
    niri-workspace-autoclean = {
      Unit = {
        Description = "Remove empty named niri workspaces";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "%h/.local/bin/niri-workspace-autoclean";
        # always, not on-failure: when the event stream ends the script exits 0,
        # so on-failure would never restart it.
        Restart = "always";
        RestartSec = 2;
        # The stream can also stall while the process stays alive, which no
        # Restart policy catches. Recycling on a timer bounds how long that can
        # last, and each start re-sweeps existing workspaces anyway.
        RuntimeMaxSec = "15min";
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
        ExecStart = "${inputs.noctalia.packages.${system}.default}/bin/noctalia";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ── Auto-mount removable media ────────────────────────────────────────
    # Mounts USB drives as they appear, under /run/media/$USER. --tray adds an
    # icon for ejecting them.
    #
    # Worth stopping (`systemctl --user stop udiskie`) before partitioning a
    # disk by hand, or it will mount the new filesystems mid-job.
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

    # ── Polkit agent ──────────────────────────────────────────────────────
    # Draws the "enter your password" dialog when something asks for privileges.
    # Without it running, those requests fail silently.
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

    # ── OneDrive sync ─────────────────────────────────────────────────────
    # Short scheduled syncs rather than `onedrive --monitor`. Continuous
    # bidirectional sync rewrites files while editors have them open, which
    # corrupted Logseq pages and churned LibreOffice lock files.
    #
    #   onedrive-sync         — syncs unconditionally. Runs at 04:00, or on
    #                           `systemctl --user start onedrive-sync`.
    #   onedrive-sync-ifidle  — same, but skipped while Logseq or LibreOffice is
    #                           open. Runs at :26 and :56.
    #
    # Both call ~/.local/bin/onedrive-sync, which is also fine to run by hand.
    # Timers activate them, so neither needs a WantedBy.
    onedrive-sync = {
      Unit = {
        Description = "OneDrive one-shot sync (forced)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.local/bin/onedrive-sync";
        TimeoutStartSec = "1h";
      };
    };

    onedrive-sync-ifidle = {
      Unit = {
        Description = "OneDrive one-shot sync (skipped while an editor is open)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        # A non-zero ExecCondition skips the run without marking it failed.
        ExecCondition = "%h/.local/bin/onedrive-sync-guard";
        ExecStart = "%h/.local/bin/onedrive-sync";
        TimeoutStartSec = "1h";
      };
    };

    # ── Podman weekly cleanup ─────────────────────────────────────────────
    # Reclaims space from stopped containers, dangling images, unused networks
    # and build cache. Started by its timer below, hence no WantedBy.
    #
    # Two flags left off on purpose: `--volumes` would delete named volumes
    # nothing currently references, including database data, and `-a` would
    # remove every unused image so the next start re-pulls everything. Pass
    # them by hand when that's what you want.
    podman-prune = {
      Unit = {
        Description = "Weekly Podman cleanup (stopped containers, dangling images, build cache)";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.podman}/bin/podman system prune -f";
      };
    };

    # ── Syncthing vault guard ─────────────────────────────────────────────
    # Watches ~/Personal and stops Syncthing when it's unmounted, so it isn't
    # syncing against a directory that has vanished. BindsTo ties the two units
    # together in both directions.
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

  # ── Timers ──────────────────────────────────────────────────────────────
  # systemd's cron. Each timer starts the service of the same name.
  # `systemctl --user list-timers` shows when they'll next fire.
  systemd.user.timers.podman-prune = {
    Unit.Description = "Weekly Podman cleanup timer";
    Timer = {
      # "weekly" means Monday 00:00. `systemd-analyze calendar <expr>` explains
      # any other expression.
      OnCalendar = "weekly";
      # If the laptop was off when the timer should have fired, run it as
      # soon as possible after boot instead of skipping that week. Crucial
      # for a laptop that's not always on.
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # OneDrive sync every hour at :26 and :56 — this lands in the short breaks of a
  # 25/5 pomodoro rhythm. Runs onedrive-sync-ifidle, which skips itself if a fast
  # editor (Logseq/LibreOffice) is open. NOT Persistent: a slot missed while the
  # machine was off shouldn't stack up and fire mid-work on resume.
  systemd.user.timers.onedrive-sync-ifidle = {
    Unit.Description = "OneDrive sync at :26 and :56 past the hour (idle only)";
    Timer = {
      OnCalendar = "*:26,56";
      Persistent = false;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Forced daily sync at 04:00, ignoring open editors, so there's always at least
  # one full reconciliation per day. Persistent so a night the laptop was off
  # still gets caught up on next boot.
  systemd.user.timers.onedrive-sync = {
    Unit.Description = "Daily forced OneDrive sync (04:00)";
    Timer = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # ── Pueue: personal job queue ───────────────────────────────────────────
  # Pueue is a small daemon (`pueued`) plus a CLI (`pueue`) for queueing
  # shell commands on a single machine — think of it as a private batch
  # scheduler. Common workflow:
  #
  #   pueue add -- long-build.sh --release      # enqueue a job
  #   pueue status                              # see the queue
  #   pueue follow <id>                         # tail a running job's output
  #   pueue log <id>                            # show finished output
  #   pueue parallel <N> [-g <group>]           # how many run at once
  #   pueue group add gpu                       # separate queue for GPU work
  #   pueue add -g gpu -- train.py              # enqueue into the gpu group
  #
  # The home-manager module below installs the `pueue` CLI, drops a config
  # at ~/.config/pueue/pueue.yml, and registers `pueued.service` as a
  # systemd user unit. WantedBy=default.target means the daemon starts at
  # any user login (graphical or pure TTY/SSH), so jobs survive logouts as
  # long as the user session lingers — to make them survive a full logout,
  # enable systemd lingering for this user (`loginctl enable-linger gdmsl`).
  services.pueue = {
    enable = true;
    settings = {
      # Default group runs one job at a time. Bump per-group at runtime
      # with `pueue parallel N` instead of editing this file.
      daemon.default_parallel_tasks = 1;
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
