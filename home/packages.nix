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

    # TODO: vicinae and anyrun may not be in nixpkgs -- install via overlay or flake input
    # TODO: hyprpaper, hyprshade, hyprpm, iio-hyprland may need separate inputs
    # TODO: noctalia-shell, niriswitcher need separate packaging
  ];
}
