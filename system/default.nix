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

  # User-level services (syncthing vault guard, polkit-gnome-agent, onedrive,
  # vicinae, noctalia-shell, hypridle, cliphist, udiskie) are all managed in
  # home/services.nix. We keep them on the user side because they rely on
  # the user's session/keyring, and grouping them there avoids splitting one
  # service definition across two modules.

  # ── Ollama (local LLM inference) ────────────────────────────────────────
  services.ollama.enable = true;

  # ── Laptop hardware essentials ──────────────────────────────────────────
  services.fwupd.enable = true;       # firmware update daemon
  services.upower.enable = true;      # battery monitoring (consumed by noctalia/quickshell)
  hardware.sensor.iio.enable = true;  # accelerometer / ambient light sensor

  # ── Bluetooth ───────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.blueman.enable = false;  # UI provided by noctalia-shell instead

  # BlueZ daemon settings. These end up in /etc/bluetooth/main.conf.
  hardware.bluetooth.settings = {
    General = {
      # Experimental = battery reporting + newer codec negotiation paths in BlueZ.
      # KernelExperimental enables the kernel-side LE features BlueZ relies on.
      Experimental = true;
      KernelExperimental = true;
    };
    Policy = {
      # When bluetoothd starts (boot or post-resume restart), automatically
      # power on the adapter and reconnect trusted devices. Without this the
      # adapter stays "off" until you toggle it manually in the shell tray.
      AutoEnable = true;
    };
  };

  # Workaround for RTL8852CU Bluetooth USB adapter: disable autosuspend to
  # prevent corrupted frames and mass disconnects.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";
  services.udev.extraRules = ''
    # Realtek RTL8852CU Bluetooth: disable USB autosuspend
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5852", ATTR{power/autosuspend}="-1"
  '';

  # After suspend the Realtek BT USB device re-enumerates and bluetoothd loses
  # the adapter. `powerManagement.resumeCommands` is NixOS's canonical
  # post-resume hook — it ends up in /etc/systemd/system-sleep/, which
  # systemd-suspend.service runs with $1 = "post" right after wake-up.
  # (The previous `systemd.services.bluetooth-resume` unit used
  #  `wantedBy = [ "suspend.target" ]`, which actually fires *before* the
  #  sleep call, not after resume — that's why BT was staying off.)
  powerManagement.resumeCommands = ''
    # In case suspend left a soft-block on the radio.
    ${pkgs.util-linux}/bin/rfkill unblock bluetooth || true
    # SIGKILL first — a clean stop would block on bluetoothd's 90s
    # TimeoutStopSec waiting for the dead HCI handle to reply. Killing
    # outright lets the new instance start immediately.
    ${pkgs.systemd}/bin/systemctl kill -s SIGKILL bluetooth.service || true
    ${pkgs.systemd}/bin/systemctl start bluetooth.service
  '';

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
  # features (file chooser, screen sharing, etc.). The right backend depends
  # on the compositor:
  #   - hyprland → xdg-desktop-portal-hyprland (talks to Hyprland's IPC)
  #   - niri     → xdg-desktop-portal-gnome (Niri has no portal of its own;
  #                gnome's backend is the only one that implements
  #                org.freedesktop.impl.portal.ScreenCast on wlroots-style
  #                compositors, so screen sharing in Firefox/Edge needs it)
  #   - gtk      → general-purpose fallback (file chooser, settings, etc.);
  #                does NOT implement ScreenCast on its own.
  # `config.<desktop>.default` keys off $XDG_CURRENT_DESKTOP, which the niri
  # and hyprland sessions set automatically.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-hyprland
    ];
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "gnome" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
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

      # Rajdhani — pulled from the `google-fonts` collection. The full
      # collection is huge (~1.5GB), so we use `.override { fonts = [...] }`
      # to install only the families we need. Add more names here later if
      # other Google fonts go missing.
      (google-fonts.override { fonts = [ "Rajdhani" ]; })

      # Cascadia Code — Microsoft's open-source monospaced font (the
      # Windows Terminal default). Includes Cascadia Code, Cascadia Mono,
      # and the PL/NF variants with ligatures + powerline glyphs.
      cascadia-code

      # Aptos — Microsoft's default Office font, not in nixpkgs because of
      # its proprietary EULA. Defined in ./aptos.nix; the first rebuild will
      # tell you exactly how to add the zip from third-party/ to /nix/store.
      (pkgs.callPackage ./aptos.nix { })

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

  # ── System packages ─────────────────────────────────────────────────────
  # Packages installed system-wide. We keep this list small on purpose:
  # only tools we'd want available in single-user mode, in a TTY recovery
  # session, or to root. Everything user-facing — browsers, chat apps,
  # GUI/Wayland utilities, dev tooling — lives in home/packages.nix so
  # the same package isn't built into two profiles.
  environment.systemPackages = with pkgs; [
    # Core CLI available in any TTY (including for root)
    neovim
    git
    htop
    tmux
    zellij
    curl

    # Networking (the matching daemons are enabled below)
    tailscale

    # Encrypted vault — referenced from the user's unlock-personal alias
    gocryptfs

    # Terminfo so SSH'ing *into* this box from a kitty terminal Just Works
    kitty.terminfo
  ];

  # ── Unfree packages ─────────────────────────────────────────────────────
  # Nix defaults to only allowing FOSS packages. To install proprietary
  # software you must explicitly allowlist each package by name.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "acli"
    "acli-unwrapped"
    "aptos-fonts"
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
