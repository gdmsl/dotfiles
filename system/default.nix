# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  system/default.nix — NixOS system configuration for "yara"                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# This file configures the operating system itself: users, networking, audio,
# display manager, system services, fonts, security, and system-level packages.
#
# It's a NixOS module — a function that takes `{ config, pkgs, lib, ... }` and
# returns an attribute set. NixOS merges all modules together to produce one
# final system configuration.
#
# Machine: Lenovo ThinkPad E14 Gen 7 (AMD)
# Role:    work laptop (QPerfect) with encrypted personal vault
# Setup:   full-disk LUKS encryption + gocryptfs personal vault
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix  # hardware-specific config (boot, disks, LUKS)
  ];

  networking.hostName = "yara";

  # ── Locale & timezone ───────────────────────────────────────────────────
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  # Override specific locale categories (date format, paper size, etc.)
  # LC_TIME = en_DK gives ISO 8601 dates (YYYY-MM-DD) which is the sane choice
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };

  # ── User account ────────────────────────────────────────────────────────
  # NixOS manages users declaratively. This creates the "gdmsl" user with
  # the listed groups (wheel = sudo, video = GPU access, input = input devices).
  users.users.gdmsl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFqoqv6KPpIJGLs15p9AfwJoH4hWm3DGqeIL3PUsYAFK gdmsl-homelab"
    ];
    shell = pkgs.fish;  # default login shell
  };

  # Fish must be enabled at the system level for it to work as a login shell
  programs.fish.enable = true;

  # ── Networking ──────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];  # trust all traffic from the VPN
    allowedTCPPorts = [ 22 22000 ];        # SSH + Syncthing
    allowedUDPPorts = [ 21027 ];           # Syncthing discovery
  };

  # SSH server — keys only, no password auth, no root login
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Tailscale (mesh VPN to homelab) ─────────────────────────────────────
  # Tailscale creates a WireGuard-based mesh network between your devices.
  # "checkReversePath = loose" is needed so return packets from Tailscale
  # aren't dropped by the kernel's reverse path filtering.
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";
  systemd.services.tailscaled = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # ── GPU (AMD integrated graphics) ──────────────────────────────────────
  # VA-API and VDPAU provide hardware-accelerated video decode for Firefox,
  # mpv, and other media apps.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # ── Laptop power management ────────────────────────────────────────────
  services.thermald.enable = true;            # prevent thermal throttling
  services.power-profiles-daemon.enable = true; # balance/performance/powersave profiles

  # ── Lid / power button / sleep ──────────────────────────────────────────
  # suspend-then-hibernate: suspends immediately (fast), then hibernates
  # after HibernateDelaySec to save battery if you leave the lid closed.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HandlePowerKey = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    # Upper bound on how long the system may stay in plain suspend before
    # falling through to hibernate. systemd (v253+) will hibernate earlier
    # on its own if the battery-runtime estimator (SuspendEstimationSec,
    # default 1h) predicts the charge will not last until this deadline.
    # So the practical behaviour is: hibernate after 12h of suspend, or
    # sooner if the battery is about to die — whichever comes first.
    HibernateDelaySec = "12h";
  };

  # Syncthing service is managed by Home Manager as a user unit (see services.nix)

  # ── OneDrive (QPerfect file sync) ───────────────────────────────────────
  # A systemd user service that runs OneDrive in monitor mode (watches for
  # changes and syncs continuously). `wantedBy = default.target` means it
  # starts automatically on login.
  systemd.user.services.onedrive = {
    description = "OneDrive sync for QPerfect";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  # ── Ollama (local LLM inference) ────────────────────────────────────────
  services.ollama.enable = true;

  # ── Laptop hardware essentials ──────────────────────────────────────────
  services.fwupd.enable = true;       # firmware update daemon
  services.upower.enable = true;      # battery monitoring (used by waybar, etc.)
  hardware.sensor.iio.enable = true;  # accelerometer / ambient light sensor

  # ── Bluetooth ───────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.blueman.enable = false;  # UI provided by noctalia-shell instead

  # Experimental = battery reporting + newer codec negotiation paths in BlueZ.
  # KernelExperimental enables the kernel-side LE features BlueZ relies on.
  hardware.bluetooth.settings.General = {
    Experimental = true;
    KernelExperimental = true;
  };

  # Workaround for RTL8852CU Bluetooth USB adapter: disable autosuspend to
  # prevent corrupted frames and mass disconnects.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";
  services.udev.extraRules = ''
    # Realtek RTL8852CU Bluetooth: disable USB autosuspend
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5852", ATTR{power/autosuspend}="-1"
  '';

  # After suspend, the Bluetooth USB device re-enumerates badly. This service
  # force-restarts bluetoothd on resume so it picks up the device cleanly.
  systemd.services.bluetooth-resume = {
    description = "Restart Bluetooth after resume";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    path = [ pkgs.util-linux pkgs.bluez ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "bluetooth-resume" ''
        # Kill hung bluetoothd so we don't wait for the dead HCI timeout
        ${pkgs.systemd}/bin/systemctl kill -s SIGKILL bluetooth 2>/dev/null || true
        # Remove the stale hci0 device if it still exists
        hciconfig hci0 down 2>/dev/null || true
        sleep 1
        # Start fresh
        ${pkgs.systemd}/bin/systemctl start bluetooth
      '';
    };
  };

  # ── PKI / trusted certificates ──────────────────────────────────────────
  # Adds a custom CA certificate (e.g., for corporate MITM proxy or internal
  # services). All apps using the system trust store will trust this CA.
  security.pki.certificateFiles = [ ./ca.pem ];

  # ── Printing ────────────────────────────────────────────────────────────
  services.printing.enable = true;  # CUPS print server

  # ── Audio (PipeWire) ────────────────────────────────────────────────────
  # PipeWire replaces PulseAudio and JACK with a single modern audio server.
  # The pulse.enable and alsa.enable options provide backwards compatibility
  # so PulseAudio and ALSA apps still work transparently.
  services.pulseaudio.enable = false;  # disable PulseAudio (PipeWire replaces it)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # for 32-bit apps/games
    pulse.enable = true;       # PulseAudio compatibility layer
  };

  # ── Display manager: greetd + tuigreet ──────────────────────────────────
  # greetd is a minimal login manager. tuigreet provides a TUI (terminal-based)
  # login screen. It remembers your last session (Niri or Hyprland) and starts
  # it after authentication.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };
  # greetd PAM needs gnome-keyring integration to auto-unlock secrets on login
  security.pam.services.greetd.enableGnomeKeyring = true;
  # Ensure these directories exist with the right permissions
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter -"
    "d /home/gdmsl/Personal 0700 gdmsl users -"
  ];

  # ── Compositors (window managers) ───────────────────────────────────────
  # Enable both compositors at the system level. You can choose which one
  # to start from the greetd login screen.
  programs.niri.enable = true;      # scrolling tiling compositor
  programs.hyprland.enable = true;  # dynamic tiling compositor

  # ── XDG Desktop Portal ──────────────────────────────────────────────────
  # Portals provide a standardized API for sandboxed apps to access system
  # features (file chooser, screen sharing, etc.). Each compositor needs its
  # own portal backend + the GTK fallback for general dialogs.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";  # use any available portal
  };

  # ── Fonts ───────────────────────────────────────────────────────────────
  # System-wide fonts available to all users and applications.
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      # TODO: Maple Mono not in nixpkgs — add via overlay if needed
    ];
    # Default font fallback chain — apps that don't specify a font use these
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font" "Maple Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ── Security / Authentication ───────────────────────────────────────────
  # Polkit handles privilege escalation prompts (e.g., "enter password to
  # mount a drive"). gnome-keyring stores passwords and SSH keys securely.
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Polkit agent — shows the graphical "enter password" dialog when an app
  # requests elevated privileges. Runs as a user service tied to the
  # graphical session.
  systemd.user.services.polkit-gnome-agent = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ── System packages ─────────────────────────────────────────────────────
  # Packages installed system-wide (available to all users).
  # `with pkgs;` opens the pkgs namespace so you can write `git` instead of
  # `pkgs.git` — it's just a convenience for shorter lists.
  environment.systemPackages = with pkgs; [
    # Core CLI
    neovim
    git
    htop
    tmux
    zellij
    curl
    tailscale
    kitty.terminfo  # so remote SSH hosts know kitty's terminal capabilities

    # Encrypted vault
    gocryptfs

    # Desktop essentials
    firefox
    kitty

    # Wayland clipboard
    wl-clipboard
    cliphist

    # Screen / media control
    brightnessctl
    playerctl

    # Screenshots
    grim    # grab an image
    slurp   # select a screen region

    # Launcher / notifications / bar
    tofi
    mako
    waybar
    libnotify  # provides notify-send

    # Display management
    kanshi

    # Auto-mount removable media
    udiskie
    gvfs    # virtual filesystem (trash, MTP, etc.)

    # Screen locking / idle
    hyprlock
    hypridle

    # Polkit agent (graphical privilege escalation)
    polkit_gnome

    # Network / audio GUI
    networkmanagerapplet
    pavucontrol

    # Keyring GUI
    seahorse
    gnome-keyring

    # Communication
    discord
    slack
    telegram-desktop
    zoom-us

    # Productivity
    onedrive
    microsoft-edge
    spotify

    # Logseq with workaround for 0.10.15
    #logseq
    (logseq.override { electron = electron_39; })

    # AI / LLM
    claude-code
    gemini-cli
  ];

  # Shell aliases available to all users for managing the encrypted vault.
  # Unlocking mounts the gocryptfs vault and starts Syncthing;
  # locking stops Syncthing and unmounts the vault.
  environment.shellAliases = {
    unlock-personal = "gocryptfs ~/.personal-encrypted ~/Personal && systemctl --user start syncthing && systemctl --user restart gcr-ssh-agent.socket";
    lock-personal = "systemctl --user stop syncthing; fusermount -u ~/Personal";
  };

  # ── Unfree packages ─────────────────────────────────────────────────────
  # Nix defaults to only allowing FOSS packages. To install proprietary
  # software you must explicitly allowlist each package by name.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "claude-code"
    "corefonts"
    "discord"
    "microsoft-edge"
    "logseq"
    "slack"
    "spotify"
    "vista-fonts"
    "zoom"
  ];

  # ── Nix daemon settings ─────────────────────────────────────────────────
  nix = {
    # Automatic garbage collection removes old unused packages weekly
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      # Enable the modern `nix` CLI and flakes (still "experimental" in name,
      # but universally used in practice).
      experimental-features = [ "nix-command" "flakes" ];
      # Deduplicate identical files in the Nix store to save disk space
      auto-optimise-store = true;
    };
  };

  # NixOS state version — tells NixOS which version's defaults to use for
  # backwards compatibility. Bump this when you do a major NixOS upgrade.
  # This does NOT control which packages you get (that's nixpkgs).
  system.stateVersion = "24.11";
}
