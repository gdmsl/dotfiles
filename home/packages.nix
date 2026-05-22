# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  packages.nix — User-level packages                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Packages listed here are installed into the user's Nix profile (not system-wide).
# They end up on your $PATH and are available only to this user.
#
# `{ pkgs, ... }:` — this module only needs the package set.
# `with pkgs;` inside the list opens the pkgs namespace so you can write `eza`
# instead of `pkgs.eza`. It's purely a convenience for shorter code.
#
# To search for packages: nix search nixpkgs <name>
# To see a package's info: nix eval nixpkgs#<name>.meta.description

{ pkgs, lib, inputs, ... }:

let
  # mempalace (local-first AI memory system) is built from PyPI. The recipe
  # lives in pkgs/mempalace.nix so the headless tty profile can reuse it.
  mempalace = import ./pkgs/mempalace.nix { inherit pkgs lib; };

  # bimbumbam comes from its own flake (declared as an input in flake.nix).
  # Each flake exposes a `packages.<system>.default` for `nix run`-style use,
  # which is what we want here. `pkgs.stdenv.hostPlatform.system` is the
  # current way to ask "what platform string ('x86_64-linux', …) is this
  # pkgs built for?" — it replaces the deprecated `pkgs.system`.
  bimbumbam = inputs.bimbumbam.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  home.packages = with pkgs; [
    # ── Modern CLI replacements ───────────────────────────────────────────
    # These replace older Unix tools with faster, more user-friendly versions.
    eza           # ls replacement (colors, icons, git awareness)
    fd            # find replacement (simpler syntax, respects .gitignore)
    ripgrep       # grep replacement (fast, respects .gitignore)
    bat           # cat replacement (syntax highlighting, line numbers)
    lazygit       # terminal UI for git
    fzf           # general-purpose fuzzy finder
    zoxide        # cd replacement (learns your most-used directories)
    delta         # git diff viewer (syntax highlighting, side-by-side)
    procs         # ps replacement (color output, searchable)
    dust          # du replacement (visual disk usage)
    duf           # df replacement (disk free space, pretty output)
    ncdu          # interactive disk usage analyzer
    grc           # generic colorizer for command output
    hyperfine     # command benchmarking tool
    tokei         # count lines of code by language
    yazi          # terminal file manager (fast, async)
    bottom        # htop alternative (system monitor)
    direnv        # auto-load env vars when entering a directory
    jq            # JSON processor (query, filter, transform)
    glow          # terminal markdown renderer (pager + TUI browser)
    mdcat         # inline markdown for the terminal (images via kitty protocol)
    unzip
    wget
    curl

    # ── Hardware / system info ────────────────────────────────────────────
    # `inxi -Fxxxz` is the modern one-shot hardware report (CPU/GPU/RAM/disks/
    # sensors/network). The lspci/lsusb/lshw classics haven't been replaced —
    # they're still the canonical detail sources, just less pretty.
    inxi              # all-in-one hardware/system report (try: inxi -Fxxxz)
    lshw              # hardware tree (try: lshw -short)
    pciutils          # provides lspci (PCI device enumeration)
    usbutils          # provides lsusb (USB device enumeration)
    hwinfo            # verbose hardware probe (alternative to lshw)
    dmidecode         # BIOS/SMBIOS dump — RAM slots, firmware, board info
    nvtopPackages.amd # live GPU monitor — htop for the Radeon iGPU
    cpufetch          # CPU info with ASCII art (uarch, AVX, cache)

    # ── Wayland / Desktop utilities ───────────────────────────────────────
    wl-clipboard          # clipboard CLI (wl-copy / wl-paste)
    cliphist              # clipboard history manager
    tofi                  # fast Wayland launcher/menu (like dmenu)
    brightnessctl         # backlight control
    playerctl             # MPRIS media player control (play/pause/next)
    grim                  # screenshot tool (whole screen or region)
    slurp                 # screen region selector (used with grim)
    hyprlock              # screen locker for Hyprland
    hypridle              # idle daemon (triggers lock, DPMS, suspend)
    kanshi                # automatic display profile switching
    udiskie               # auto-mount removable drives
    xwayland-satellite    # X11 compatibility for niri (Zoom, Qt5/xcb apps)
    gvfs                  # virtual filesystem (trash, MTP, etc.)
    libnotify             # provides notify-send command
    networkmanagerapplet  # Wi-Fi tray icon
    pavucontrol           # PulseAudio/PipeWire volume control GUI
    polkit_gnome          # graphical polkit auth agent (started in services.nix)
    solaar                # pair/manage Logitech Unifying receivers (non-BT)

    # ── Browser & terminal ────────────────────────────────────────────────
    firefox
    chromium       # FOSS upstream of Chrome (no Google branding/services)
    kitty

    # ── Applications ──────────────────────────────────────────────────────
    bimbumbam        # fullscreen Wayland keyboard-basher (toddler-proof mode)
    fastfetch        # system info display (like neofetch, but fast)
    mpv              # media player
    cosmic-files     # COSMIC file manager
    cosmic-edit      # COSMIC text editor
    zathura          # minimal PDF/ebook viewer (vim keybindings)
    evince           # GNOME PDF viewer
    loupe            # GNOME image viewer
    satty            # screenshot annotation tool
    zotero           # reference manager
    keepassxc        # offline password manager (KDBX database files)
    hyprpicker       # color picker
    wf-recorder            # simple Wayland screen recorder
    gpu-screen-recorder    # hardware-accelerated recorder (used by Noctalia's screen-recorder plugin)
    obs-studio             # full streaming/recording suite (scenes, sources, RTMP)
    inkscape         # vector graphics editor
    gimp             # image editor
    darktable        # photo editing / RAW processing

    # ── Communication / productivity ──────────────────────────────────────
    discord
    slack
    telegram-desktop
    zoom-us
    microsoft-edge
    spotify
    logseq

    # ── AI / LLM ──────────────────────────────────────────────────────────
    claude-code
    gemini-cli

    # ── GNOME keyring / secrets ───────────────────────────────────────────
    gnome-keyring    # password/key storage daemon
    seahorse         # GUI for managing keyring secrets
    # GnuPG provides the `gpg` CLI for encryption, signing, and key management.
    # `pass` is a CLI password manager: each entry is a small gpg-encrypted file
    # under ~/.password-store/, so it depends on gnupg. To use it you'll need a
    # GPG key — generate one with `gpg --full-generate-key`, then initialize the
    # store with `pass init <your-key-id-or-email>`.
    gnupg
    pass

    # ── Languages & toolchains ────────────────────────────────────────────
    # Julia wrapped with extra shared libraries on LD_LIBRARY_PATH so JLL
    # artifacts can dlopen libquadmath/libgfortran/libstdc++ on NixOS.
    # Recipe in pkgs/julia-wrapped.nix (shared with the tty profile).
    (import ./pkgs/julia-wrapped.nix { inherit pkgs; })
    lua
    rustup     # Rust toolchain manager (provides rustc, cargo)
    python3
    uv         # fast Python package manager
    gcc
    cmake
    ninja
    gnumake

    # ── Dev tools ─────────────────────────────────────────────────────────
    git-lfs        # Git Large File Storage
    gh             # GitHub CLI
    glab           # GitLab CLI
    jira-cli-go    # interactive Jira CLI (the `jira` command)
    acli           # Atlassian CLI (Jira/Confluence/Bitbucket)
    mempalace      # local-first AI memory system (defined in let-binding above)
    # Podman itself is enabled in system/default.nix; this is the Python wrapper
    # that reads compose.yaml files and drives podman directly. Lighter than the
    # Go `docker compose` plugin and works fine for typical multi-service stacks.
    podman-compose

    # ── Fonts ─────────────────────────────────────────────────────────────
    # User-level fonts (also see system/default.nix for system-wide fonts).
    maple-mono.NF               # Maple Mono with Nerd Font glyphs
    nerd-fonts.fira-code        # FiraCode with Nerd Font glyphs
    nerd-fonts.symbols-only     # just the icon glyphs (for symbol_map fallback)
    inter                       # clean sans-serif (UI font)
    carlito                     # metric-compatible Calibri replacement
    corefonts                   # Microsoft core fonts (Times, Arial, etc.)
    vista-fonts                 # Consolas, Cambria, etc.

    # ── Theming ───────────────────────────────────────────────────────────
    tokyonight-gtk-theme        # GTK theme
    colloid-icon-theme          # icon theme (active — set in home/desktop/gtk.nix)
    # Parent theme in Colloid-Dark's inheritance chain
    # (Inherits=hicolor,breeze in its index.theme). Without it, COSMIC apps
    # like cosmic-files miss window controls / folder icons and degrade into
    # full-theme scans on every icon lookup — visibly slow.
    kdePackages.breeze-icons
    # Universal-fallback icon set. Not in Colloid's Inherits= chain, but many
    # GTK/Qt apps (e.g. noctalia-shell) request icons from "Adwaita" by name
    # directly when their primary theme misses one.
    adwaita-icon-theme
    # COSMIC apps (cosmic-files, etc.) don't honour the GTK iconTheme setting —
    # they default to looking up the "Cosmic" theme by name. Without this
    # package window controls and folder icons render as blanks.
    cosmic-icons
    bibata-cursors              # cursor theme
    nwg-look                    # GTK theme settings GUI for Wayland
    dconf                       # GNOME settings backend (needed for GTK config)
    kdePackages.qtstyleplugin-kvantum  # Qt theme engine (reads Kvantum themes)
    qt6Packages.qt6ct           # Qt6 configuration tool

    # ── Hyprland extras ───────────────────────────────────────────────────
    hyprpaper     # wallpaper daemon for Hyprland
  ];
}
