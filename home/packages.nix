# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  packages.nix — User-level packages                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Installed into the user profile rather than system-wide, so they're on your
# $PATH but not root's. System-wide ones are in system/default.nix.
#
# `with pkgs;` lets the list say `eza` instead of `pkgs.eza`.
#
# Finding things:
#   nix search nixpkgs <name>
#   nix eval nixpkgs#<name>.meta.description

{ pkgs, lib, inputs, ... }:

let
  # Built from PyPI; recipe in pkgs/mempalace.nix so home/tty.nix can reuse it.
  mempalace = import ./pkgs/mempalace.nix { inherit pkgs lib; };

  # From its own flake input. `packages.<system>.default` is the attribute a
  # flake exposes for a single main package.
  bimbumbam = inputs.bimbumbam.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Also from a flake input, for the same reason: hyprfm isn't in nixpkgs, but
  # upstream maintains a flake, so there's no derivation to keep up to date here.
  hyprfm = inputs.hyprfm.packages.${pkgs.stdenv.hostPlatform.system}.hyprfm;

  # Pinned to an older nixpkgs (the nixpkgs-logseq input): on current nixpkgs
  # it isn't cached and building from source hangs. Reusing `pkgs.config` keeps
  # the unfree and insecure allowances from applying. This shadows pkgs.logseq
  # for the plain `logseq` in the list below.
  logseq = (import inputs.nixpkgs-logseq {
    inherit (pkgs) config;
    inherit (pkgs.stdenv.hostPlatform) system;   # `pkgs.system` is deprecated
  }).logseq;
in

{
  home.packages = with pkgs; [
    # ── Modern CLI replacements ───────────────────────────────────────────
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
    bottom        # htop alternative (system monitor; the command is `btm`)
    btop          # resource monitor with a polished TUI (CPU/mem/net/procs)
    glances       # broad single-screen system overview (also has a web mode)
    direnv        # auto-load env vars when entering a directory
    jq            # JSON processor (query, filter, transform)
    ffmpeg        # audio/video transcoding; also what hyprfm uses for video
                  # thumbnails — upstream leaves it out of its own wrapper on
                  # size grounds and picks whichever is on PATH
    exiftool      # read/write media metadata; backs hyprfm's metadata panel
    glow          # terminal markdown renderer (pager + TUI browser)
    mdcat         # inline markdown for the terminal (images via kitty protocol)
    psmisc        # process utilities — provides killall, pstree, fuser
    unzip
    wget
    curl

    # ── Hardware / system info ────────────────────────────────────────────
    # lspci, lsusb and lshw are in system/default.nix instead, so they're on
    # root's PATH too.
    inxi              # all-in-one hardware/system report (try: inxi -Fxxxz)
    hwinfo            # verbose hardware probe (alternative to lshw)
    dmidecode         # BIOS/SMBIOS dump — RAM slots, firmware, board info
    nvtopPackages.amd # live GPU monitor — htop for the Radeon iGPU
    cpufetch          # CPU info with ASCII art (uarch, AVX, cache)

    # ── Wayland / Desktop utilities ───────────────────────────────────────
    wl-clipboard          # clipboard CLI (wl-copy / wl-paste) — used by screenshot script
    tofi                  # fast Wayland launcher/menu (like dmenu)
    uni                   # unicode database CLI — feeds the symbol picker (unicode-symbols)
    brightnessctl         # backlight control
    playerctl             # MPRIS media player control (play/pause/next)
    grim                  # screenshot tool (whole screen or region)
    slurp                 # screen region selector (used with grim)
    hyprlock              # screen locker (ext-session-lock); launched by hypridle
    hypridle              # idle daemon (sleep inhibitor, fires loginctl lock-session, runs hyprlock)
    kanshi                # automatic display profile switching
    udiskie               # auto-mount removable drives
    xwayland-satellite    # X11 compatibility for niri (Zoom, Qt5/xcb apps)
    gvfs                  # virtual filesystem (trash, MTP, etc.). Ships its own
                          # systemd user unit and D-Bus activation files, so the
                          # daemon comes up without services.gvfs.enable.
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
    hyprfm           # Qt6/QML file manager — the default for directories
    nautilus         # GNOME file manager; kept as the fallback, and what
                     # GTK apps' own "open containing folder" tends to reach for
    gnome-text-editor # GNOME text editor (GTK4/Adwaita)
    file-roller      # GUI archive manager (zip, tar, 7z, … — browse/extract)
    zathura          # minimal PDF/ebook viewer (vim keybindings)
    evince           # GNOME PDF viewer
    xournalpp        # handwritten notes / PDF annotation (stylus-friendly)
    loupe            # GNOME image viewer
    satty            # screenshot annotation tool
    zotero           # reference manager
    keepassxc        # offline password manager (KDBX database files)
    hyprpicker       # color picker
    # Screen recorder. This used to carry `.override { ffmpeg = ffmpeg_7; }`,
    # because wf-recorder 0.6.0 uses AVCodec.sample_fmts, which FFmpeg dropped
    # in 8.0. nixpkgs now takes ffmpeg_8 as a named argument of its own, so the
    # pin is handled upstream — and the override stopped even being expressible,
    # since there is no longer an `ffmpeg` argument to override.
    wf-recorder
    gpu-screen-recorder    # hardware-accelerated recorder (used by Noctalia's screen-recorder plugin)
    obs-studio             # full streaming/recording suite (scenes, sources, RTMP)
    inkscape         # vector graphics editor
    gimp             # image editor
    darktable        # photo editing / RAW processing

    # Multiboot USB creator: write the drive once, then copy ISOs onto it.
    # Run `ventoy-gui` (desktop entry "Ventoy").
    #
    # The -full-gtk variant is the one worth having — plain `ventoy` builds with
    # no GUI and no ext4/NTFS/XFS/LUKS support. Note the derivation is called
    # `ventoy-gtk3`, which is the name that has to appear in the unfree and
    # insecure lists in system/default.nix and flake.nix.
    ventoy-full-gtk

    # ── Communication / productivity ──────────────────────────────────────
    discord
    # Element (Matrix) is in element.nix — it needs a wrapper to find the keyring.
    signal-desktop
    slack
    telegram-desktop
    zoom-us
    microsoft-edge
    spotify
    logseq

    # ── AI / LLM ──────────────────────────────────────────────────────────
    claude-code
    codex            # OpenAI's terminal coding agent (the `codex` command)
    antigravity-cli  # Google's agent CLI (the `agy` command); replaced gemini-cli

    # ── GNOME keyring / secrets ───────────────────────────────────────────
    gnome-keyring    # password/key storage daemon
    seahorse         # GUI for managing keyring secrets
    # GnuPG provides the `gpg` CLI for encryption, signing, and key management.
    # Password manager: one gpg-encrypted file per entry under
    # ~/.password-store. Needs a GPG key — `gpg --full-generate-key`, then
    # `pass init <key-id>`.
    gnupg
    pass

    # ── Languages & toolchains ────────────────────────────────────────────
    # Julia with extra libraries on LD_LIBRARY_PATH, so JLL artifacts can
    # dlopen libgfortran and friends. Recipe in pkgs/julia-wrapped.nix.
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
    kubectl        # Kubernetes cluster CLI; reads ~/.kube/config
    opentofu       # Terraform-compatible IaC tool (the `tofu` command)
    mempalace      # local-first AI memory system (defined in let-binding above)
    # Reads compose.yaml and drives podman. Podman itself is enabled in
    # system/default.nix.
    podman-compose

    # ── Fonts ─────────────────────────────────────────────────────────────
    # System-wide ones are in system/default.nix.
    maple-mono.NF               # Maple Mono with Nerd Font glyphs
    nerd-fonts.fira-code        # FiraCode with Nerd Font glyphs
    nerd-fonts.symbols-only     # just the icon glyphs (for symbol_map fallback)
    inter                       # clean sans-serif (UI font)
    carlito                     # metric-compatible Calibri replacement
    corefonts                   # Microsoft core fonts (Times, Arial, etc.)
    vista-fonts                 # Consolas, Cambria, etc.

    # ── Theming ───────────────────────────────────────────────────────────
    colloid-icon-theme          # icon theme (active — set in home/desktop/gtk.nix)
    # Colloid-Dark inherits from breeze, so without this every icon it doesn't
    # have triggers a full-theme scan.
    kdePackages.breeze-icons
    # Plenty of GTK and Qt apps ask for Adwaita icons by name when their own
    # theme is missing one, even though Colloid doesn't inherit from it.
    adwaita-icon-theme
    bibata-cursors              # cursor theme
    nwg-look                    # GTK theme settings GUI for Wayland
    dconf                       # GNOME settings backend (needed for GTK config)
    kdePackages.qtstyleplugin-kvantum  # Qt theme engine (reads Kvantum themes)
    qt6Packages.qt6ct           # Qt6 configuration tool

    # ── Hyprland extras ───────────────────────────────────────────────────
    hyprpaper     # wallpaper daemon for Hyprland
  ];
}
