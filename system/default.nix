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
  programs.fuse.enable = true; # creates the setuid wrapper so unprivileged users can mount FUSE filesystems

  # ── Networking ──────────────────────────────────────────────────────────
  networking.networkmanager = {
    enable = true;
    # VPN plugins extend NetworkManager so the GUI/CLI can configure VPN
    # connections of that type. fortisslvpn = Fortinet SSL VPN (FortiClient
    # compatible) — used here for the Unistra VPN. The plugin pulls in
    # openfortivpn as its backend daemon automatically.
    plugins = with pkgs; [ networkmanager-fortisslvpn ];
  };
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
  # vicinae, noctalia-shell, hypridle, udiskie) are all managed in
  # home/services.nix. We keep them on the user side because they rely on
  # the user's session/keyring, and grouping them there avoids splitting one
  # service definition across two modules.

  # ── Ollama (local LLM inference) ────────────────────────────────────────
  services.ollama.enable = true;

  # ── Containers (Podman) ─────────────────────────────────────────────────
  # Podman is a daemonless, rootless-capable container engine. Unlike Docker,
  # there is *no* system-wide daemon process running at boot — containers are
  # spawned by your user on demand and exit when you stop them. That's the
  # property we want here: nothing runs unless you explicitly asked for it.
  #
  #   dockerCompat = true
  #     Adds a `docker` -> `podman` symlink and aliases `docker-compose` etc.
  #     so any tool that hardcodes the `docker` binary (build scripts, IDE
  #     dev-container integrations, CI tooling) works transparently.
  #
  #   defaultNetwork.settings.dns_enabled = true
  #     Enables Podman's built-in DNS for container networks, so services in
  #     a compose stack can find each other by name (e.g. `postgres:5432`)
  #     instead of by IP. Required for almost any multi-service compose file.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ── nix-ld (run foreign dynamic binaries) ───────────────────────────────
  # NixOS binaries are patched to find their libraries in /nix/store, so
  # generic Linux binaries (VSCode extensions, language toolchains, AI tools,
  # proprietary blobs) fail to start because their hardcoded interpreter path
  # `/lib64/ld-linux-x86-64.so.2` doesn't exist on NixOS.
  #
  # nix-ld provides exactly that path: a tiny shim that re-execs the real
  # glibc dynamic linker from nixpkgs and exposes the libraries below via
  # LD_LIBRARY_PATH. Any non-Nix binary that's dynamically linked against
  # glibc now Just Works.
  #
  # `libraries` is the set of shared libs made available to those binaries.
  # If a tool errors with `cannot open shared object file: libfoo.so.N`, add
  # the package providing libfoo.so.N here and rebuild.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib  # libstdc++, libgcc_s — needed by almost everything
      zlib              # libz — extremely common
      openssl           # libssl, libcrypto
      curl              # libcurl
      icu               # libicu — Node, .NET, Java tooling
      libxml2
      libxslt
      nss               # network security services (browsers, Electron)
      nspr              # NSS companion runtime
      libGL             # OpenGL stub — graphical tools
    ];
  };

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
      # Experimental = userspace experimental features (battery reporting,
      # AAC/aptX codec negotiation). Safe and useful.
      Experimental = true;
      # KernelExperimental was on, but it activates BlueZ's LE Audio (BAP/CAP)
      # endpoints. Our RTL8852CU + current kernel combo can't fully back those,
      # which produced `bap_detached: Unable to find bap session` on every
      # shutdown. Disabling unless we actually need LE Audio (Auracast, hearing
      # aids, etc.).
      # KernelExperimental = true;
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
  # udev rules. udev is the kernel-side userspace daemon that reacts to
  # hardware events (device added/removed) and applies rules: things like
  # "set permissions on this hidraw node" or "disable autosuspend on this
  # USB device". Anything in `extraRules` lands in /etc/udev/rules.d/99-local.rules.
  services.udev.extraRules = ''
    # Realtek RTL8852CU Bluetooth: disable USB autosuspend
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5852", ATTR{power/autosuspend}="-1"

    # NuPhy keyboards (vendor 0x19f5): give the wheel group RW access on the
    # raw USB device. Needed so VIA / Vial / vial-cli can talk to the keyboard
    # without sudo. ATTRS{} (plural) walks up the device tree, so this matches
    # every interface — usb, hidraw, the input nodes — under a NuPhy device.
    ATTRS{idVendor}=="19f5", MODE="0666", GROUP="wheel"

    # VIA / WebHID: any hidraw node is reachable by the active local user.
    # `TAG+="uaccess"` is the modern way — systemd-logind grants the seat's
    # current user an ACL on the device, scoped to their session. The legacy
    # `udev-acl` tag is the same thing for older ConsoleKit setups; harmless
    # to keep. MODE=0666 is a belt-and-braces fallback for non-seat sessions.
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';

  # After suspend the Realtek RTL8852CU BT USB device re-enumerates AND the
  # adapter firmware sometimes wedges, so just restarting bluetoothd isn't
  # enough — bluetoothd binds before /sys/class/bluetooth/hci0 reappears
  # (or finds an adapter the kernel driver thinks is alive but actually
  # isn't). Both produce a "started but doesn't work" state.
  #
  # The robust sequence is:
  #   1. Kill bluetoothd hard (avoids 90s TimeoutStopSec on dead HCI handle).
  #   2. Reload the btusb kernel driver. This unbinds the stale adapter and
  #      forces a clean re-enumeration with fresh firmware state.
  #   3. Unblock rfkill in case suspend left a soft-block on the radio.
  #   4. Poll /sys/class/bluetooth/hci0 until the adapter appears (or 5s).
  #   5. Start bluetoothd. `AutoEnable=true` powers it on and reconnects
  #      trusted devices.
  #
  # `powerManagement.resumeCommands` is NixOS's canonical post-resume hook:
  # it ends up as the ExecStop of sleep-actions.service, which runs when
  # sleep.target deactivates on wake-up.
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl kill -s SIGKILL bluetooth.service || true

    # Force a clean driver/adapter re-init. -r unloads, modprobe reloads.
    # The btusb option from boot.extraModprobeConfig (enable_autosuspend=0)
    # is re-applied automatically by the kernel's modprobe.d lookup.
    ${pkgs.kmod}/bin/modprobe -r btusb || true
    ${pkgs.kmod}/bin/modprobe btusb || true

    ${pkgs.util-linux}/bin/rfkill unblock bluetooth || true

    # Wait up to 5s for the adapter to enumerate. Without this wait,
    # bluetoothd starts before hci0 exists and silently fails to bind.
    for i in $(seq 1 50); do
      [ -e /sys/class/bluetooth/hci0 ] && break
      sleep 0.1
    done

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

  # hyprlock needs its own PAM service (it looks for /etc/pam.d/hyprlock by
  # default — without this it would fall through to the restrictive "other"
  # stack). We deliberately make it PASSWORD-ONLY: fprintAuth = false keeps
  # pam_fprintd out of this stack. Fingerprint unlocking is instead handled by
  # hyprlock's own native fprintd backend (see raw/hypr/hyprlock.conf), which
  # runs concurrently with the password field. Keeping fingerprint out of PAM
  # here avoids two code paths fighting over the sensor.
  security.pam.services.hyprlock.fprintAuth = false;
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

  # ── Fingerprint reader (Goodix 27c6:659a) ───────────────────────────────
  # fprintd is the D-Bus daemon that drives the sensor through libfprint.
  # This Goodix sensor is "match-on-chip" (the fingerprint template is stored
  # and compared on the sensor itself) and is supported by mainline libfprint,
  # so no out-of-tree driver or vendor blob is needed — just the daemon.
  #
  # One-time setup after the rebuild: enroll a finger with
  #     fprintd-enroll          # follow the prompts, lift+touch repeatedly
  # then sanity-check it with
  #     fprintd-verify
  #
  # Enabling fprintd also turns on PAM fingerprint auth: the NixOS option
  # security.pam.services.<svc>.fprintAuth defaults to services.fprintd.enable,
  # so most PAM-using services (greetd login, sudo, …) get it automatically.
  # NixOS wires in the stock pam_fprintd.so as `auth sufficient`, i.e. the
  # flow is sequential: the service asks you to touch the sensor first, and
  # if that fails or times out it falls through to the password prompt.
  # (hyprlock is the exception — it opts out of PAM fingerprint above and uses
  # its own native fprintd backend so the sensor and password run in parallel.)
  # tuigreet (we ship 0.9.1) understands these non-password PAM prompts since
  # 0.7.0, so the "swipe your finger" message renders correctly at the login
  # screen too — no need to special-case it off.
  #
  # Note: this is NOT the fprintd-grosshack module (the one that prompts for
  # password and fingerprint *at the same time*). That module is known to be
  # unsafe/broken with greetd; the stock sequential pam_fprintd used here is
  # not affected.
  services.fprintd.enable = true;

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

    # Hardware diagnostics — kept system-wide (not in the user profile) so
    # they're on root's PATH too: `sudo lspci -k`, `sudo lshw`, etc. need
    # root to report kernel drivers and full detail, and these are exactly
    # the tools you reach for in a TTY recovery session.
    lshw              # hardware tree (try: lshw -short)
    pciutils          # provides lspci (PCI device enumeration)
    usbutils          # provides lsusb (USB device enumeration)

    # Networking (the matching daemons are enabled below)
    tailscale

    # Encrypted vault — referenced from the user's unlock-personal alias
    gocryptfs

    # Terminfo so SSH'ing *into* this box from a kitty terminal Just Works
    kitty.terminfo

    # Fuse should be installed by default
    fuse
  ];

  # ── Unfree packages ─────────────────────────────────────────────────────
  # Nix defaults to only allowing FOSS packages. To install proprietary
  # software you must explicitly allowlist each package by name.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "acli"
    "acli-unwrapped"
    "aptos-fonts"
    "aptos-fonts.zip"  # the requireFile src derivation now inherits the unfree license too
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

  # ── Insecure packages ───────────────────────────────────────────────────
  # Nix refuses to build packages whose dependencies are past end-of-life
  # (known-vulnerable) unless you explicitly opt in by name+version here.
  # Logseq bundles an old Electron runtime that upstream hasn't updated, so
  # we accept the risk to keep it installable. Revisit when Logseq ships a
  # newer Electron (bump the version string or drop this line).
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
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
