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
    # Clipboard persistence and history are both owned by noctalia now (its
    # built-in wlr-data-control clipboard manager survives the source app
    # closing and keeps its own history), so no separate wl-clip-persist daemon.

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
    # hypridle triggers actions on inactivity: dim, lock, turn off display,
    # suspend. Configured via hypridle.conf in the Hyprland config dir.
    #
    # Lock/idle run on hypridle + hyprlock, not noctalia's built-in equivalents.
    # noctalia 5.0 does integrate with logind now (session lock, LockedHint,
    # lock-on-suspend), but we currently find it too unstable — so it stays off
    # (lockscreen.enabled = false in desktop/noctalia.nix) and hypridle drives
    # things: it registers a systemd sleep inhibitor so the screen locks *before*
    # suspend, and fires `loginctl lock-session` on idle and before sleep, which
    # hypridle turns into hyprlock (see raw/hypr/hypridle.conf).
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
    # Removes empty *named* niri workspaces so they behave like numbered ones
    # (niri keeps named workspaces around even when empty — see the script for
    # the full rationale). The niri-workspace-autoclean script (home/scripts.nix)
    # is a long-lived reader of niri's event stream. It's niri-specific, but
    # rides graphical-session.target like the rest since niri is the only
    # compositor we run — that target is what makes `niri msg` reachable here,
    # the same way hypridle's niri calls work.
    niri-workspace-autoclean = {
      Unit = {
        Description = "Remove empty named niri workspaces";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "%h/.local/bin/niri-workspace-autoclean";
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
        ExecStart = "${inputs.noctalia.packages.${system}.default}/bin/noctalia";
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

    # ── OneDrive: scheduled one-shot sync (replaces continuous --monitor) ──
    # We deliberately do NOT run `onedrive --monitor`. A live bidirectional
    # syncer rewrites files while editors are mid-write, which corrupted Logseq
    # (constant "in-memory vs saved" conflicts, vanishing pages) and churns
    # LibreOffice lock files. Instead we sync in short one-shot bursts driven by
    # the two timers further below. Both call the same ~/.local/bin/onedrive-sync
    # wrapper (start/finish notify-send + flock); that wrapper is also the manual
    # command you can run any time.
    #
    #   onedrive-sync         — forced sync, no editor check. Driven by the 04:00
    #                           timer and by `systemctl --user start onedrive-sync`.
    #   onedrive-sync-ifidle  — same sync, but ExecCondition skips the run when a
    #                           fast editor (Logseq/LibreOffice) is open. Driven
    #                           by the :26/:56 timer.
    #
    # These are oneshot units triggered by timers, so (like podman-prune) they
    # have no Install.WantedBy of their own. network-online is wanted so a sync
    # doesn't fire before the link is up.
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
        # exit != 0 from the guard → systemd skips this run cleanly (not failed).
        ExecCondition = "%h/.local/bin/onedrive-sync-guard";
        ExecStart = "%h/.local/bin/onedrive-sync";
        TimeoutStartSec = "1h";
      };
    };

    # ── Podman weekly cleanup ─────────────────────────────────────────────
    # Reclaims disk from stopped containers, dangling images, unused networks,
    # and build cache. Fired by the matching timer below (see systemd.user.timers).
    #
    # `Type = "oneshot"` means: run the command, exit, done — no long-lived
    # process. The unit has no Install.WantedBy because it's not started at
    # boot or login; the timer is what activates it.
    #
    # We deliberately do NOT pass `--volumes` or `-a`:
    #   --volumes  would delete named volumes (e.g. your postgres data dir)
    #              if no container currently references them — too dangerous
    #              for an automatic weekly job.
    #   -a         would remove every unused image, forcing a re-pull next
    #              time you start a stack. Save bandwidth, prune manually
    #              when you actually want that.
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

  # ── Systemd user timers ─────────────────────────────────────────────────
  # Timers are systemd's cron replacement. Each timer activates a service of
  # the same name (here: podman-prune.service, defined above).
  systemd.user.timers.podman-prune = {
    Unit.Description = "Weekly Podman cleanup timer";
    Timer = {
      # OnCalendar uses systemd's calendar syntax. "weekly" expands to
      # "Mon *-*-* 00:00:00" — every Monday at midnight local time.
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
