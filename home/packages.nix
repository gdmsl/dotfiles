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

    # TODO: spf (superfile) — check if in nixpkgs
    # TODO: iio-hyprland — check if in nixpkgs (screen rotation)
  ];
}
