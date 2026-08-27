# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  system/default.nix — System config shared by every host                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# The operating system itself: users, networking, audio, display manager,
# services, fonts, security, system packages.
#
# This is a NixOS module — a function taking `{ config, pkgs, lib, ... }` and
# returning an attribute set of options. NixOS merges every module together
# into one final configuration, which is why settings can be split across files
# and why two modules setting the same option will conflict unless one uses
# `lib.mkDefault` or `lib.mkForce`.
#
# It sets no hostname and imports no per-machine file. The flake pairs it with
# one:
#
#   yara  → this + ./hardware.nix                    (ThinkPad E14, AMD)
#   nomad → this + ./nomad.nix + ./disko-nomad.nix   (portable SSD)
#
# A few things here are specific to the laptop — fingerprint reader, graphics
# tablet, ollama. nomad.nix switches those off with `lib.mkForce` rather than
# them being moved out.
{ config, pkgs, lib, ... }:

{
  # ── Locale & timezone ───────────────────────────────────────────────────
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  # Per-category overrides. en_DK for LC_TIME is the trick for ISO 8601 dates.
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
    # Lets NetworkManager configure Fortinet SSL VPN connections (Unistra).
    # Pulls in openfortivpn as its backend.
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

  # Remote shell that survives roaming and high latency. Installs client and
  # server and opens UDP 60000–61000; the handshake still goes over SSH.
  programs.mosh.enable = true;

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
    # Longest it may stay suspended before hibernating. systemd hibernates
    # sooner if it estimates the battery won't last that long.
    HibernateDelaySec = "12h";
  };

  # Per-user services (syncthing, polkit agent, onedrive, vicinae, noctalia,
  # hypridle, udiskie) live in home/services.nix — they need the user's
  # session and keyring.

  # ── Ollama (local LLM inference) ────────────────────────────────────────
  services.ollama.enable = true;

  # ── Containers ──────────────────────────────────────────────────────────
  # Podman runs containers without a background daemon — nothing is running
  # until you start a container yourself.
  #
  #   dockerCompat    — symlinks `docker` to `podman`, so tools that hardcode
  #                     the docker binary work unchanged.
  #   dns_enabled     — container DNS, so compose services can reach each other
  #                     by name (`postgres:5432`) instead of by IP.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ── nix-ld (running non-Nix binaries) ───────────────────────────────────
  # Pre-built Linux binaries expect a dynamic linker at
  # /lib64/ld-linux-x86-64.so.2, which doesn't exist on NixOS — so downloaded
  # tools, VSCode extensions and language toolchains fail to start. nix-ld puts
  # a shim at that path which hands off to the real linker.
  #
  # If something fails with `cannot open shared object file: libfoo.so.N`, add
  # the package that provides it to the list below and rebuild.
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

  # ── Extra filesystem support ────────────────────────────────────────────
  # The kernel can already mount these; what this adds is the userspace tools
  # (mkfs, fsck, repair) and the drivers in the initrd, in case one of them
  # ever has to be mounted during early boot.
  boot.supportedFilesystems = {
    btrfs = true;
    f2fs = true;
    xfs = true;
    # ntfs pulls in ntfs3g and its mount helper. It belongs here rather than in
    # home packages because udisks2 runs as a system daemon and looks for
    # mount.ntfs-3g on the system path, not in a user profile.
    ntfs = true;
  };

  # ── Disk management GUI ─────────────────────────────────────────────────
  # GNOME Disks (launcher: "Disks"), for partitioning and formatting. It shells
  # out to the mkfs tools above, so it can write any of those filesystems.
  #
  # The app runs as your user and asks the udisks2 daemon to do the privileged
  # work, which raises a polkit prompt — answered by the agent in
  # home/services.nix.
  programs.gnome-disks.enable = true;

  # ── Bluetooth ───────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.blueman.enable = false;  # UI provided by noctalia-shell instead

  # BlueZ daemon settings. These end up in /etc/bluetooth/main.conf.
  hardware.bluetooth.settings = {
    General = {
      # Battery reporting and AAC/aptX codec negotiation.
      Experimental = true;
      # Leave KernelExperimental off. It turns on BlueZ LE Audio, which this
      # adapter and kernel can't fully support — the symptom is
      # `bap_detached: Unable to find bap session` on every shutdown. Only
      # needed for Auracast or LE Audio hearing aids.
      # KernelExperimental = true;
    };
    Policy = {
      # When bluetoothd starts (boot or post-resume restart), automatically
      # power on the adapter and reconnect trusted devices. Without this the
      # adapter stays "off" until you toggle it manually in the shell tray.
      AutoEnable = true;
    };
  };

  # The RTL8852CU Bluetooth adapter corrupts frames and mass-disconnects if it
  # is allowed to autosuspend.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

  # udev reacts to hardware appearing and disappearing. These rules land in
  # /etc/udev/rules.d/99-local.rules.
  services.udev.extraRules = ''
    # Realtek RTL8852CU Bluetooth: disable USB autosuspend
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5852", ATTR{power/autosuspend}="-1"

    # Enable TRIM on the portable SSD (Crucial P3 Plus in a Realtek RTL9210
    # USB enclosure). The kernel defaults this drive to provisioning_mode
    # "full", which reports as no discard support at all and silently disables
    # TRIM. The bridge does handle SCSI UNMAP, so switch it to "unmap".
    #
    # Check with: lsblk -D /dev/sda   (DISC-MAX should be non-zero)
    #
    # ATTRS{} matches on the parent SCSI device, ATTR{} writes on the scsi_disk
    # one. The model is space-padded, so the glob matters — an exact match just
    # never fires. Matching on vendor+model keeps it off every other disk.
    ACTION=="add|change", SUBSYSTEM=="scsi_disk", ATTRS{vendor}=="CT500P3P", ATTRS{model}=="SSD8*", ATTR{provisioning_mode}="unmap"

    # NuPhy keyboards: let the wheel group talk to them, so VIA / Vial work
    # without sudo. ATTRS{} walks up the tree, matching every interface under
    # the device.
    ATTRS{idVendor}=="19f5", MODE="0666", GROUP="wheel"

    # Let the logged-in user reach hidraw devices, which is what VIA in the
    # browser needs. `uaccess` makes logind grant an ACL for the active
    # session; the mode is a fallback for sessions without a seat.
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Bluetooth after resume: the adapter re-enumerates and its firmware
  # sometimes wedges, so restarting bluetoothd alone isn't enough — it binds
  # before hci0 reappears, or binds to an adapter the driver wrongly thinks is
  # alive. Either way it starts but doesn't work.
  #
  # So: kill bluetoothd outright (a graceful stop waits 90s on a dead handle),
  # reload the driver to force clean re-enumeration, clear any rfkill soft
  # block, wait for the adapter, then start it again.
  #
  # resumeCommands runs when the machine wakes up.
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

  # ── Graphics tablet (XP-Pen Star G640S) ─────────────────────────────────
  # OpenTabletDriver reads the tablet's raw HID in userspace and emits a
  # virtual pointer, so it behaves the same on any compositor. Preferred over
  # the kernel driver here because niri can only map a tablet to a whole output
  # and can't rebind its buttons; otd-gui can do both.
  #
  # This one option installs the CLI and GUI, ships the udev rules, runs the
  # daemon with your graphical session, and blacklists the kernel drivers so
  # they don't fight over the device.
  #
  # First time: plug in, run `otd-gui`, set the display and area on the Output
  # tab and buttons on Bindings, then save presets (Presets → Save As) named
  # e.g. "laptop" and "external". Mod+Alt+T switches between them (see the
  # tablet-preset script in home/scripts.nix). `otd detect` checks it's seen.
  hardware.opentabletdriver.enable = true;

  # ── Audio ───────────────────────────────────────────────────────────────
  # PipeWire replaces both PulseAudio and JACK. The compatibility layers below
  # mean apps written for either still work.
  services.pulseaudio.enable = false;  # disable PulseAudio (PipeWire replaces it)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # for 32-bit apps/games
    pulse.enable = true;       # PulseAudio compatibility layer
  };

  # ── Login screen ────────────────────────────────────────────────────────
  # greetd is a minimal login manager; tuigreet is its terminal-based UI. It
  # remembers which session you last used and starts that.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };
  # So logging in also unlocks the keyring.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # hyprlock gets its own PAM stack, password-only. Fingerprint is handled by
  # hyprlock's own fprintd support (raw/hypr/hyprlock.conf), which runs
  # alongside the password field — having PAM do it too means two things
  # competing for the sensor.
  security.pam.services.hyprlock.fprintAuth = false;

  # Directories that must exist, with these owners and modes.
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter -"
    "d /home/gdmsl/Personal 0700 gdmsl users -"
  ];

  # ── Compositors ─────────────────────────────────────────────────────────
  # Both are enabled; pick one at the login screen.
  programs.niri.enable = true;      # scrolling tiling compositor
  programs.hyprland.enable = true;  # dynamic tiling compositor

  # ── Desktop portals ────────────────────────────────────────────────────
  # Portals are how sandboxed apps get at file pickers, screen sharing and so
  # on. Which backend to use depends on the compositor:
  #
  #   hyprland — its own portal, talks to Hyprland's IPC
  #   gnome    — used under niri, which has no portal of its own. It's the only
  #              backend implementing screen sharing on wlroots-style
  #              compositors, so Firefox screen share needs it.
  #   gtk      — fallback for file pickers and settings. No screen sharing.
  #
  # The keys below match $XDG_CURRENT_DESKTOP, which each session sets.
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

      # The google-fonts collection is ~1.5 GB, so pick out just the families
      # needed. Add more names to the list as required.
      (google-fonts.override { fonts = [ "Rajdhani" ]; })

      # Microsoft's monospace font, with ligature and powerline variants.
      cascadia-code

      # Microsoft's Office font. Not in nixpkgs because of its licence, so it's
      # packaged in ./aptos.nix from a zip in third-party/. The first rebuild
      # prints the commands to add that zip to the store.
      (pkgs.callPackage ./aptos.nix { })
    ];
    # What apps get when they don't ask for a specific font.
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font" "Maple Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ── Security ────────────────────────────────────────────────────────────
  # polkit is what raises "enter your password to do X" prompts; the graphical
  # agent that answers them is in home/services.nix. gnome-keyring stores
  # passwords and SSH keys.
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # ── Fingerprint reader (Goodix 27c6:659a) ───────────────────────────────
  # Supported by mainline libfprint, so the daemon is all that's needed.
  #
  # Enroll a finger once with `fprintd-enroll`, check it with `fprintd-verify`.
  #
  # Turning this on also enables fingerprint auth for PAM services — sudo,
  # the login screen and so on — because their fprintAuth option defaults to
  # this one. The prompt is sequential: touch the sensor first, then fall
  # through to the password if it fails. hyprlock is the exception, see above.
  services.fprintd.enable = true;

  # ── System packages ─────────────────────────────────────────────────────
  # Deliberately short: only what's wanted in a TTY recovery session or on
  # root's PATH. Everything user-facing lives in home/packages.nix, so nothing
  # ends up built into two profiles.
  environment.systemPackages = with pkgs; [
    # Core CLI available in any TTY (including for root)
    neovim
    git
    htop
    tmux
    zellij
    curl

    # Hardware diagnostics. Here rather than in the user profile so they're on
    # root's PATH — `sudo lspci -k` and friends need root for full detail.
    lshw              # hardware tree (try: lshw -short)
    pciutils          # provides lspci (PCI device enumeration)
    usbutils          # provides lsusb (USB device enumeration)

    # Networking (the matching daemons are enabled below)
    tailscale

    # Used by unlock-personal, see home/personal-vault.nix
    gocryptfs

    # So SSH'ing in from a kitty terminal gets the right terminfo
    kitty.terminfo

    fuse
  ];

  # ── Unfree packages ─────────────────────────────────────────────────────
  # Nix only builds free software unless a package is named here. The name is
  # the derivation name, which isn't always the attribute you installed —
  # `nix eval nixpkgs#foo.name` tells you what to write.
  #
  # Keep this in sync with the same list in flake.nix, which the standalone
  # home-manager profiles use.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "acli"
    "acli-unwrapped"
    "aptos-fonts"
    "aptos-fonts.zip"  # the requireFile src derivation now inherits the unfree license too
    "claude-code"
    "corefonts"
    "discord"
    "discord-unwrapped"  # discord is a wrapper; the inner drv is evaluated too
    "microsoft-edge"
    "logseq"
    "slack"
    "spotify"
    "ventoy-gtk3"  # the GTK variant renames the derivation from `ventoy`
    "vista-fonts"
    "zoom"
  ];

  # ── Insecure packages ───────────────────────────────────────────────────
  # Nix refuses to build packages flagged as known-vulnerable unless named
  # here. These include the version, so a package bump breaks the entry and
  # the build tells you to update it.
  #
  #   electron — Logseq bundles an end-of-life Electron.
  #   ventoy   — ships prebuilt binaries nixpkgs can't audit (nixpkgs #404663).
  #
  # Also in flake.nix, same reason as the unfree list.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    "ventoy-gtk3-1.1.12"
  ];

  # ── Nix daemon settings ─────────────────────────────────────────────────
  nix = {
    # Delete unreferenced store paths weekly.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      # The modern CLI and flakes. Still called experimental; used everywhere.
      experimental-features = [ "nix-command" "flakes" ];
      # Hard-link identical files in the store.
      auto-optimise-store = true;
    };
  };

  # Which release's defaults to use for stateful things like database layouts.
  # It does not affect package versions. Leave it at the release you installed
  # with unless you've read the release notes on changing it.
  system.stateVersion = "24.11";
}
