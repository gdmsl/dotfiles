# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  home/default.nix — Root Home Manager module                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# This is the entry point for all user-level configuration. Home Manager works
# like NixOS modules but for your home directory: it manages dotfiles, user
# packages, shell config, services, and more — all declaratively.
#
# The function signature `{ config, pkgs, lib, inputs, ... }:` means:
#   config  — the final merged configuration (lets you reference other options)
#   pkgs    — the Nix package set (all available packages)
#   lib     — Nix utility functions (mkIf, mkForce, etc.)
#   inputs  — our flake inputs (passed via extraSpecialArgs in flake.nix)
#   ...     — catch any extra arguments we don't use here
#
# The `imports` list pulls in other .nix files. Each one is a module that
# configures a specific program or concern. Home Manager merges them all
# together — you can split your config across as many files as you like.

{ config, pkgs, lib, inputs, ... }:

{
  # ── Imports ─────────────────────────────────────────────────────────────
  # Each import is a module that configures one aspect of the user environment.
  # The directory structure mirrors the concern: shell/, terminal/, editor/, etc.
  imports = [
    ./packages.nix              # user-level packages (CLI tools, apps, fonts)
    ./shell/fish.nix            # Fish shell (primary)
    ./shell/bash.nix            # Bash (fallback)
    ./shell/zsh.nix             # Zsh (fallback)
    ./shell/starship.nix        # Starship prompt (cross-shell)
    ./shell/atuin.nix           # Atuin shell history sync
    ./shell/direnv.nix          # direnv + nix-direnv
    ./git.nix                   # Git config, delta pager, aliases
    ./terminal/kitty.nix        # Kitty terminal emulator
    ./terminal/tmux.nix         # tmux multiplexer
    ./terminal/zellij.nix       # Zellij multiplexer
    ./editor/neovim.nix         # Neovim (via nvf framework)
    ./desktop/hyprland.nix      # Hyprland window manager
    ./desktop/niri.nix          # Niri window manager
    ./desktop/mako.nix          # Mako notification daemon
    ./desktop/gtk.nix           # GTK theme, icons, cursor
    ./desktop/kanshi.nix        # Kanshi display profile manager
    ./desktop/noctalia.nix      # Noctalia desktop shell
    ./desktop/vicinae.nix       # Vicinae launcher
    ./desktop/anyrun.nix        # Anyrun launcher
    ./firefox.nix               # Firefox custom desktop entry
    ./libreoffice.nix           # LibreOffice + TexMaths LaTeX equation editor
    ./services.nix              # systemd user services
    ./xdg.nix                   # XDG MIME types and default apps
    ./scripts.nix               # custom scripts in ~/.local/bin
  ];

  # ── Identity ────────────────────────────────────────────────────────────
  home.username = "gdmsl";
  home.homeDirectory = "/home/gdmsl";

  # State version for Home Manager — same concept as system.stateVersion.
  # Tells HM which defaults to assume. Don't change unless upgrading.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself as a program
  programs.home-manager.enable = true;

  # ── Session variables ───────────────────────────────────────────────────
  # These are exported as environment variables via ~/.config/environment.d/
  # so they're available to all programs (including graphical ones launched
  # by the compositor, not just shells).
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    LESS = "-rF";                    # -r = raw control chars, -F = quit if one screen
    MANPAGER = "nvim +Man!";         # read man pages in Neovim
    MANROFFOPT = "-c";
    GOPATH = "$HOME/Variable/go";
    FZF_DEFAULT_COMMAND = "rg --files --no-ignore-vcs --hidden";
    VCPKG_ROOT = "$HOME/.local/share/vcpkg";
    JULIA_SSH_NO_VERIFY_HOSTS = "git.unistra.fr";
    SAL_DISABLE_OPENCL = "1";        # LibreOffice: disable buggy OpenCL rendering
    MOZ_USE_OMTC = "1";              # Firefox: off-main-thread compositing
    MOZ_WEBRENDER = "1";             # Firefox: GPU-accelerated rendering
    MOZ_ENABLE_WAYLAND = "1";        # Firefox: native Wayland mode
    # SSH_AUTH_SOCK not set here — let gnome-keyring or SSH agent forwarding
    # set it at runtime. Hardcoding breaks agent forwarding over SSH.
  };

  # ── Additional PATH entries ─────────────────────────────────────────────
  # Directories added to $PATH (in addition to the Nix profile paths).
  home.sessionPath = [
    "$HOME/.local/bin"             # custom scripts (see scripts.nix)
    "$HOME/.luarocks/bin"          # Lua package manager
    "$HOME/.cargo/bin"             # Rust toolchain
    "/var/lib/flatpak/exports/bin" # Flatpak apps
    "$HOME/.npm-packages/bin"      # npm global packages
    "$HOME/Variable/go/bin"        # Go binaries
  ];

  # ── Raw config files ────────────────────────────────────────────────────
  # Some config files use formats that are hard to express in Nix (INI, custom
  # syntax). We store them as-is in raw/ and deploy them to ~/.config/ using
  # xdg.configFile. The `.source` attribute points to the file in this repo.
  xdg.configFile = {
    "fontconfig/fonts.conf".source = ../raw/fontconfig/fonts.conf;
    "paru/paru.conf".source = ../raw/paru/paru.conf;
    "Kvantum/kvantum.kvconfig".source = ../raw/Kvantum/kvantum.kvconfig;
    "qt5ct/qt5ct.conf".source = ../raw/qt5ct/qt5ct.conf;
    "qt6ct/qt6ct.conf".source = ../raw/qt6ct/qt6ct.conf;
    "chromium-flags.conf".source = ../raw/chromium-flags.conf;
    "electron-flags.conf".source = ../raw/electron-flags.conf;
    "locale.conf".source = ../raw/locale.conf;
    "onedrive/config".source = ../raw/onedrive/config;
  };

  # ── Dotfiles in home directory ──────────────────────────────────────────
  # home.file deploys files to ~/. Same idea as xdg.configFile but for files
  # that live directly in $HOME (like .latexmkrc, .screenrc, etc.).
  home.file = {
    # .profile, .bash_profile managed by programs.bash
    # .zprofile, .zshenv managed by programs.zsh
    ".latexmkrc".source = ../raw/latexmkrc;
    ".screenrc".source = ../raw/screenrc;
    ".ticker.yaml".source = ../raw/ticker.yaml;
    ".dircolors".source = ../raw/dircolors;
    ".makepkg.conf".source = ../raw/makepkg.conf;

    # Symlink app data into the encrypted Personal vault.
    # mkOutOfStoreSymlink creates a real symlink (not a Nix store copy), so
    # the apps read/write data directly inside ~/Personal/. This keeps
    # sensitive data within the gocryptfs-encrypted directory.
    ".local/share/TelegramDesktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Personal/.local/share/TelegramDesktop";
    ".config/discord".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Personal/.config/discord";
  };
}
