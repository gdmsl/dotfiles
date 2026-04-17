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
    cosmic-files
    cosmic-edit
    zathura
    evince
    loupe
    satty
    libreoffice-fresh
    zotero
    hyprpicker
    wf-recorder
    inkscape
    gimp
    darktable

    # GNOME keyring / secrets
    gnome-keyring
    seahorse

    # Languages & toolchains
    julia
    lua
    rustup
    python3
    uv
    gcc
    cmake
    ninja
    gnumake

    # Dev tools
    git-lfs
    gh
    glab

    # Fonts
    maple-mono.NF
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    inter
    carlito
    corefonts
    vista-fonts

    # Theming
    tokyonight-gtk-theme
    tela-circle-icon-theme
    bibata-cursors
    nwg-look
    dconf
    kdePackages.qtstyleplugin-kvantum
    qt6Packages.qt6ct

    # Hyprland extras
    hyprpaper
  ];
}
