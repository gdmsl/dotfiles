# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  home/default.nix — Home Manager entry point                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# All user-level configuration starts here. Home Manager works like NixOS
# modules but for your home directory: dotfiles, user packages, shell config,
# user services.
#
# The arguments every module in here receives:
#   config  — the merged configuration, for referencing other options
#   pkgs    — the package set
#   lib     — helper functions (mkIf, mkForce, …)
#   inputs  — this flake's inputs, passed through from flake.nix
#
# Rebuild after editing anything under home/:
#   sudo nixos-rebuild switch --flake .#yara
#
{ config, pkgs, lib, inputs, ... }:

{
  # ── Imports ─────────────────────────────────────────────────────────────
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
    ./editor/neovide.nix        # Neovide (GPU-accelerated Neovim GUI)
    ./desktop/hyprland.nix      # Hyprland window manager
    ./desktop/niri.nix          # Niri window manager
    ./desktop/portal.nix        # XDG Desktop Portal backends (screen sharing)
    ./desktop/gtk.nix           # GTK theme, icons, cursor
    ./desktop/qt.nix            # Qt theme (qt6ct + Kvantum), matched to GTK
    ./desktop/hyprfm.nix        # hyprfm file manager theme (QML, themed separately)
    ./desktop/kanshi.nix        # Kanshi display profile manager
    ./desktop/noctalia.nix      # Noctalia desktop shell
    ./desktop/vicinae.nix       # Vicinae launcher
    ./desktop/anyrun.nix        # Anyrun launcher
    ./firefox.nix               # Firefox custom desktop entry
    ./element.nix               # Element (Matrix) + the keyring backend flag
    ./libreoffice.nix           # LibreOffice + OnlyOffice + TexMaths equations
    ./prismlauncher.nix         # Minecraft launcher + a Java path that survives rebuilds
    ./services.nix              # systemd user services
    ./xdg.nix                   # XDG MIME types and default apps
    ./scripts.nix               # custom scripts in ~/.local/bin
    ./personal-vault.nix        # unlock-personal / lock-personal (~/Personal)
    ./rbw.nix                   # rbw, CLI client for the Vaultwarden instance
  ];

  # ── Identity ────────────────────────────────────────────────────────────
  home.username = "gdmsl";
  home.homeDirectory = "/home/gdmsl";

  # Same idea as system.stateVersion. Leave it alone.
  home.stateVersion = "24.11";

  # Puts the home-manager command itself on PATH.
  programs.home-manager.enable = true;

  # ── Session variables ───────────────────────────────────────────────────
  # Written to ~/.config/environment.d/, so they reach graphical apps launched
  # by the compositor as well as shells. Changes need a re-login, not just a
  # new terminal.
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
    # SSH_AUTH_SOCK is deliberately absent: gnome-keyring or agent forwarding
    # sets it at runtime, and hardcoding it breaks forwarding over SSH.
  };

  # ── Extra PATH entries ──────────────────────────────────────────────────
  # Added on top of the Nix profile directories.
  home.sessionPath = [
    "$HOME/.local/bin"             # custom scripts (see scripts.nix)
    "$HOME/.luarocks/bin"          # Lua package manager
    "$HOME/.cargo/bin"             # Rust toolchain
    "/var/lib/flatpak/exports/bin" # Flatpak apps
    "$HOME/.npm-packages/bin"      # npm global packages
    "$HOME/Variable/go/bin"        # Go binaries
  ];

  # ── Raw config files ────────────────────────────────────────────────────
  # Config in formats not worth expressing in Nix. Kept verbatim in raw/ and
  # linked into ~/.config. These are store copies, so edits to raw/ need a
  # rebuild to take effect — unlike the mkOutOfStoreSymlink ones further down.
  xdg.configFile = {
    "fontconfig/fonts.conf".source = ../raw/fontconfig/fonts.conf;
    "paru/paru.conf".source = ../raw/paru/paru.conf;
    # Chrome and Edge are Chromium derivatives and read the same flags, each
    # from its own filename, so all three point at one file.
    "chromium-flags.conf".source = ../raw/chromium-flags.conf;
    "chrome-flags.conf".source = ../raw/chromium-flags.conf;
    "microsoft-edge-flags.conf".source = ../raw/chromium-flags.conf;
    "electron-flags.conf".source = ../raw/electron-flags.conf;
    "locale.conf".source = ../raw/locale.conf;
    "onedrive/config".source = ../raw/onedrive/config;
  };

  # ── Dotfiles directly in $HOME ──────────────────────────────────────────
  # Same as xdg.configFile, for things that don't live under ~/.config.
  home.file = {
    # .profile, .bash_profile managed by programs.bash
    # .zprofile, .zshenv managed by programs.zsh
    ".latexmkrc".source = ../raw/latexmkrc;
    ".screenrc".source = ../raw/screenrc;
    ".ticker.yaml".source = ../raw/ticker.yaml;
    ".dircolors".source = ../raw/dircolors;
    ".makepkg.conf".source = ../raw/makepkg.conf;

    # Julia reads these on every launch. Ours load Revise, so edits to a
    # package apply without restarting the REPL.
    ".julia/config/startup.jl".source = ../raw/julia/startup.jl;
    ".julia/config/startup_ijulia.jl".source = ../raw/julia/startup_ijulia.jl;

    # mkOutOfStoreSymlink makes a plain symlink instead of copying into the Nix
    # store, so these apps read and write inside ~/Personal and their data stays
    # encrypted. It also means the target has to exist at that exact path.
    ".local/share/TelegramDesktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Personal/.local/share/TelegramDesktop";
    ".config/discord".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Personal/.config/discord";
  };
}
