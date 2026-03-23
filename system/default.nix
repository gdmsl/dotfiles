# yara - ThinkPad E14 Gen 7
# Role: work laptop (QPerfect) with encrypted personal vault
# Full disk LUKS (company password) + gocryptfs personal vault + external SSD
{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "yara";

  # --- Base system (inlined from homelab base.nix, tailored for laptop) ---

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
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

  users.users.gdmsl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFqoqv6KPpIJGLs15p9AfwJoH4hWm3DGqeIL3PUsYAFK gdmsl-homelab"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # --- Networking ---
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # --- Tailscale (mesh VPN to homelab) ---
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # --- GPU ---
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # --- Laptop power management ---
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # --- Laptop hardware essentials ---
  services.fwupd.enable = true;
  services.upower.enable = true;
  hardware.sensor.iio.enable = true;

  # --- Bluetooth ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Printing ---
  services.printing.enable = true;

  # --- Audio (PipeWire) ---
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Display manager: greetd + tuigreet ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter -"
    "d /home/gdmsl/Personal 0700 gdmsl users -"
  ];

  # --- Compositors ---
  programs.niri.enable = true;
  programs.hyprland.enable = true;

  # --- XDG Desktop Portal ---
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # --- Fonts ---
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
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font" "Maple Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # --- Security / Auth ---
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

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

  # --- System packages ---
  environment.systemPackages = with pkgs; [
    # Core CLI
    neovim
    git
    htop
    tmux
    zellij
    curl
    tailscale
    kitty.terminfo

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
    grim
    slurp

    # Launcher / notifications / bar
    tofi
    mako
    waybar
    libnotify

    # Display management
    kanshi

    # Auto-mount removable media
    udiskie

    # Screen locking / idle
    hyprlock
    hypridle

    # Polkit agent
    polkit_gnome

    # Network / audio GUI
    networkmanagerapplet
    pavucontrol

    # Keyring GUI
    seahorse
    gnome-keyring
  ];

  # Convenience aliases for vault management
  environment.shellAliases = {
    unlock-personal = "gocryptfs ~/.personal-encrypted ~/Personal";
    lock-personal = "fusermount -u ~/Personal";
  };

  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "obsidian"
    "vscode"
    "discord"
  ];

  # --- Nix settings ---
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  # External SSD auto-detection (LUKS encrypted, personal password)
  # TODO: set up after purchasing the SSD (needs UUID)
  # fileSystems."/home/gdmsl/External" = { ... };

  system.stateVersion = "24.11";
}
