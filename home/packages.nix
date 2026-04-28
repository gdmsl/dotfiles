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

{ pkgs, lib, ... }:

let
  # ── mempalace ───────────────────────────────────────────────────────────
  # Local-first AI memory system (https://github.com/mempalace/mempalace).
  # Not in nixpkgs, so we build it ourselves from PyPI. `buildPythonApplication`
  # is the right choice (vs. `buildPythonPackage`) because it produces a
  # wrapped CLI on $PATH without polluting any Python environment with the
  # library — the binary uses its own private interpreter with the deps below.
  mempalace = pkgs.python3Packages.buildPythonApplication rec {
    pname = "mempalace";
    version = "3.3.3";
    pyproject = true;  # tells nix the project uses pyproject.toml + PEP 517

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-ttMVcabQIb7kKOQBmO61xXQohfsXLSSDvbtjoaFFhIc=";
    };

    # hatchling is the build backend declared in mempalace's pyproject.toml
    build-system = [ pkgs.python3Packages.hatchling ];

    # Runtime dependencies. tomli is only needed on Python <3.11, and our
    # pkgs.python3 is newer than that, so we can skip it.
    dependencies = with pkgs.python3Packages; [
      chromadb
      pyyaml
    ];

    # Sanity-check the build by importing the top-level module.
    pythonImportsCheck = [ "mempalace" ];

    meta = {
      description = "Local-first AI memory system with semantic search";
      homepage = "https://github.com/mempalace/mempalace";
      license = lib.licenses.mit;
      mainProgram = "mempalace";
    };
  };
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
    mako                  # notification daemon
    kanshi                # automatic display profile switching
    udiskie               # auto-mount removable drives
    gvfs                  # virtual filesystem (trash, MTP, etc.)
    libnotify             # provides notify-send command
    networkmanagerapplet  # Wi-Fi tray icon
    pavucontrol           # PulseAudio/PipeWire volume control GUI
    polkit_gnome          # graphical polkit auth agent (started in services.nix)
    solaar                # pair/manage Logitech Unifying receivers (non-BT)

    # ── Browser & terminal ────────────────────────────────────────────────
    firefox
    kitty

    # ── Applications ──────────────────────────────────────────────────────
    fastfetch        # system info display (like neofetch, but fast)
    mpv              # media player
    cosmic-files     # COSMIC file manager
    cosmic-edit      # COSMIC text editor
    zathura          # minimal PDF/ebook viewer (vim keybindings)
    evince           # GNOME PDF viewer
    loupe            # GNOME image viewer
    satty            # screenshot annotation tool
    libreoffice-fresh
    zotero           # reference manager
    hyprpicker       # color picker
    wf-recorder      # screen recorder
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
    # Logseq pinned to electron_39 — newer electrons broke 0.10.15 rendering.
    (logseq.override { electron = electron_39; })

    # ── AI / LLM ──────────────────────────────────────────────────────────
    claude-code
    gemini-cli

    # ── GNOME keyring / secrets ───────────────────────────────────────────
    gnome-keyring    # password/key storage daemon
    seahorse         # GUI for managing keyring secrets

    # ── Languages & toolchains ────────────────────────────────────────────
    # Julia wrapped with extra shared libraries on LD_LIBRARY_PATH.
    # Julia's package manager downloads prebuilt binaries (JLL artifacts) that
    # expect FHS-standard library paths. On NixOS those paths don't exist, so
    # dlopen fails (e.g. libquadmath.so.0 not found when loading OpenSpecFun_jll).
    # symlinkJoin + wrapProgram produces a new `julia` on PATH whose every
    # invocation gets these libs appended to LD_LIBRARY_PATH.
    (pkgs.symlinkJoin {
      name = "julia-wrapped";
      paths = [ pkgs.julia ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/julia \
          --suffix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
            pkgs.gcc-unwrapped.lib   # libquadmath, libgfortran, libgcc_s
            pkgs.stdenv.cc.cc.lib    # libstdc++
            pkgs.zlib
            pkgs.glibc
          ]}
      '';
    })
    lua
    rustup     # Rust toolchain manager (provides rustc, cargo)
    python3
    uv         # fast Python package manager
    gcc
    cmake
    ninja
    gnumake

    # ── Dev tools ─────────────────────────────────────────────────────────
    git-lfs       # Git Large File Storage
    gh            # GitHub CLI
    glab          # GitLab CLI
    jira-cli-go   # interactive Jira CLI (the `jira` command)
    acli          # Atlassian CLI (Jira/Confluence/Bitbucket)
    mempalace     # local-first AI memory system (defined in let-binding above)

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
    tela-circle-icon-theme      # icon theme
    bibata-cursors              # cursor theme
    nwg-look                    # GTK theme settings GUI for Wayland
    dconf                       # GNOME settings backend (needed for GTK config)
    kdePackages.qtstyleplugin-kvantum  # Qt theme engine (reads Kvantum themes)
    qt6Packages.qt6ct           # Qt6 configuration tool

    # ── Hyprland extras ───────────────────────────────────────────────────
    hyprpaper     # wallpaper daemon for Hyprland
  ];
}
