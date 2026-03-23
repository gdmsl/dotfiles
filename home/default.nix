{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
    ./shell/fish.nix
    ./shell/bash.nix
    ./shell/zsh.nix
    ./shell/starship.nix
    ./shell/atuin.nix
    ./shell/direnv.nix
    ./git.nix
    ./terminal/kitty.nix
    ./terminal/tmux.nix
    ./terminal/zellij.nix
    ./editor/neovim.nix
    ./desktop/hyprland.nix
    ./desktop/niri.nix
    ./desktop/waybar.nix
    ./desktop/mako.nix
    ./desktop/kanshi.nix
    ./services.nix
    ./xdg.nix
    ./scripts.nix
  ];

  home.username = "gdmsl";
  home.homeDirectory = "/home/gdmsl";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Session variables (from environment.d/*.conf)
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    LESS = "-rF";
    MANPAGER = "nvim +Man!";
    MANROFFOPT = "-c";
    GOPATH = "$HOME/Variable/go";
    FZF_DEFAULT_COMMAND = "rg --files --no-ignore-vcs --hidden";
    VCPKG_ROOT = "$HOME/.local/share/vcpkg";
    JULIA_SSH_NO_VERIFY_HOSTS = "git.unistra.fr";
    SAL_DISABLE_OPENCL = "1";
    MOZ_USE_OMTC = "1";
    MOZ_WEBRENDER = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GIT_ASKPASS = "/usr/lib/seahorse/ssh-askpass";
    SSH_ASKPASS = "/usr/lib/seahorse/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  # Additional PATH entries
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.luarocks/bin"
    "$HOME/.cargo/bin"
    "/var/lib/flatpak/exports/bin"
    "$HOME/.npm-packages/bin"
    "$HOME/Variable/go/bin"
  ];

  # Raw config files that cannot be easily nixified
  xdg.configFile = {
    "fontconfig/fonts.conf".source = ../raw/fontconfig/fonts.conf;
    "paru/paru.conf".source = ../raw/paru/paru.conf;
    "Kvantum/kvantum.kvconfig".source = ../raw/Kvantum/kvantum.kvconfig;
    "qt5ct/qt5ct.conf".source = ../raw/qt5ct/qt5ct.conf;
    "qt6ct/qt6ct.conf".source = ../raw/qt6ct/qt6ct.conf;
    "chromium-flags.conf".source = ../raw/chromium-flags.conf;
    "electron-flags.conf".source = ../raw/electron-flags.conf;
    "locale.conf".source = ../raw/locale.conf;
  };

  # Dotfiles in home directory
  home.file = {
    # .profile, .bash_profile managed by programs.bash
    # .zprofile, .zshenv managed by programs.zsh
    ".latexmkrc".source = ../raw/latexmkrc;
    ".screenrc".source = ../raw/screenrc;
    ".ticker.yaml".source = ../raw/ticker.yaml;
    ".dircolors".source = ../raw/dircolors;
    ".makepkg.conf".source = ../raw/makepkg.conf;
  };
}
