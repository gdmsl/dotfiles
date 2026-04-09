{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Modern CLI tools
    eza
    fd
    ripgrep
    bat
    lazygit
    fzf
    zoxide
    delta
    procs
    dust
    duf
    ncdu
    grc
    hyperfine
    tokei
    yazi
    bottom
    direnv
    jq
    unzip
    wget
    curl

    # Wayland / Desktop
    wl-clipboard
    cliphist
    tofi
    brightnessctl
    playerctl
    grim
    slurp
    hyprlock
    hypridle
    mako
    kanshi
    udiskie
    waybar
    libnotify
    networkmanagerapplet
    pavucontrol

    # Applications
    fastfetch
    ranger
    mpv
    cosmic-files   # Rust GUI file manager (Mod+Shift+X)
    cosmic-edit    # Rust text editor (COSMIC)
    zathura        # KISS PDF/DjVu/CBR viewer (vim-like)
    evince         # PDF viewer with annotation support
    oculante       # Rust GPU-accelerated image viewer
    satty          # Rust screenshot annotation tool
    libreoffice-fresh # Office suite
    hyprpicker     # Wayland color picker
    wf-recorder    # Wayland screen recorder
    inkscape       # Vector graphics editor (SVG)
    gimp           # Raster image editor
    darktable      # RAW photo editor / workflow

    # GNOME keyring / secrets
    gnome-keyring
    seahorse

    # Neovim LSP servers (for LazyVim)
    lua-language-server
    nil # Nix LSP
    pyright
    rust-analyzer
    nodePackages.typescript-language-server
    clang-tools # clangd + clang-format
    cmake-language-server
    texlab
    bash-language-server
    shfmt
    shellcheck
    stylua

    # Dev tools
    git-lfs
    gh           # GitHub CLI
    glab         # GitLab CLI

    # Fonts
    maple-mono.NF           # Maple Mono Nerd Font (italic support)
    nerd-fonts.fira-code    # FiraCode Nerd Font
    nerd-fonts.symbols-only # Nerd Font symbols
    inter                   # Inter (sans-serif)
    carlito                 # Calibri metric-compatible
    corefonts               # MS core fonts (Arial, Times New Roman, etc.)
    vista-fonts             # MS Vista fonts (Calibri, Cambria, etc.)

    # Theming
    tokyonight-gtk-theme    # GTK + Kvantum Tokyo Night theme
    tela-circle-icon-theme
    bibata-cursors
    nwg-look               # GTK theme GUI
    dconf                   # needed for gsettings
    kdePackages.qtstyleplugin-kvantum
    qt6Packages.qt6ct

    # Hyprland extras
    hyprpaper

    # Niri extras
    # TODO: niriswitcher — check if packaged or add flake input
    # TODO: niri-wselector — check if packaged

    # TODO: superfile — check if in nixpkgs (TUI file manager)
    # TODO: iio-hyprland — check if in nixpkgs (screen rotation)
  ];
}
