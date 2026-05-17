# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  home/tty.nix — Headless / SSH-only home-manager profile                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# A trimmed home-manager configuration meant for machines you only ever SSH
# into: no Wayland, no compositor, no GUI apps. Reuses the per-tool modules
# (fish, neovim, zellij, …) so the terminal experience matches yara, but
# skips everything that depends on a display.
#
# Bootstrap on a fresh box (Nix already installed, no global home-manager):
#
#   nix run github:nix-community/home-manager -- switch \
#       --flake github:gdmsl/dotfiles#gdmsl-tty
#
# After the first activation, subsequent runs work the same way; if you keep
# a local checkout of this repo, point --flake at that path instead.

{ config, pkgs, lib, inputs, ... }:

let
  # mempalace is built from PyPI (not in nixpkgs). The recipe lives next to
  # this file so both home/default.nix (yara) and home/tty.nix (headless)
  # consume the exact same derivation.
  mempalace = import ./pkgs/mempalace.nix { inherit pkgs lib; };
in
{
  # ── Imports ─────────────────────────────────────────────────────────────
  # Each per-tool module is self-contained and display-agnostic — safe to
  # pull into a headless profile. We deliberately do NOT import packages.nix,
  # services.nix, scripts.nix, or any home/desktop/* — those carry GUI deps.
  imports = [
    # Shell stack
    ./shell/fish.nix         # primary shell + abbreviations
    ./shell/bash.nix         # POSIX fallback
    ./shell/zsh.nix          # alternate fallback
    ./shell/starship.nix     # cross-shell prompt
    ./shell/atuin.nix        # synced shell history
    ./shell/direnv.nix       # per-directory env loader

    # Editor / VCS / multiplexers
    ./git.nix                # git config, delta, aliases
    ./terminal/tmux.nix      # tmux multiplexer
    ./terminal/zellij.nix    # zellij multiplexer
    ./editor/neovim.nix      # neovim via nvf framework
  ];

  # ── Identity ────────────────────────────────────────────────────────────
  # Override per-host if your work-machine username differs from gdmsl.
  home.username = "gdmsl";
  home.homeDirectory = "/home/gdmsl";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ── Session variables (terminal subset of home/default.nix) ─────────────
  # Skipped vs. yara: BROWSER, TERMINAL, MOZ_*, SAL_DISABLE_OPENCL — those
  # only matter inside a graphical session.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    LESS = "-rF";                    # -r = raw control chars, -F = quit if one screen
    MANPAGER = "nvim +Man!";         # read man pages in Neovim
    MANROFFOPT = "-c";
    GOPATH = "$HOME/Variable/go";
    FZF_DEFAULT_COMMAND = "rg --files --no-ignore-vcs --hidden";
    VCPKG_ROOT = "$HOME/.local/share/vcpkg";
    JULIA_SSH_NO_VERIFY_HOSTS = "git.unistra.fr";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.luarocks/bin"
    "$HOME/.cargo/bin"
    "$HOME/Variable/go/bin"
    "$HOME/.npm-packages/bin"
  ];

  # ── Packages ────────────────────────────────────────────────────────────
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
    bottom        # htop alternative (system monitor)
    direnv        # auto-load env vars when entering a directory
    jq            # JSON processor (query, filter, transform)
    glow          # terminal markdown renderer (pager + TUI browser)
    mdcat         # inline markdown for the terminal
    unzip
    wget
    curl

    # ── Hardware / system info ────────────────────────────────────────────
    # Useful when SSHing into an unfamiliar box. nvtopPackages.amd is omitted
    # — work hardware may be Intel or Nvidia, so the AMD-specific tool has
    # no value here.
    inxi              # all-in-one hardware/system report (try: inxi -Fxxxz)
    lshw              # hardware tree (try: lshw -short)
    pciutils          # provides lspci
    usbutils          # provides lsusb
    hwinfo            # verbose hardware probe
    dmidecode         # BIOS/SMBIOS dump
    cpufetch          # CPU info with ASCII art
    fastfetch         # one-shot system info display

    # ── AI / LLM CLIs ─────────────────────────────────────────────────────
    claude-code
    gemini-cli

    # ── Secrets ───────────────────────────────────────────────────────────
    # `pass` is a CLI password manager backed by gpg-encrypted files. No
    # graphical keyring on a tty box — the GPG agent's TTY pinentry handles
    # passphrases. To use, generate a key with `gpg --full-generate-key`
    # then `pass init <key-id>`.
    gnupg
    pass

    # ── Languages & toolchains ────────────────────────────────────────────
    # Same Julia wrapper as yara — JLL artifacts dlopen FHS paths that don't
    # exist on NixOS, so we wrap LD_LIBRARY_PATH around `julia`. Recipe in
    # pkgs/julia-wrapped.nix.
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
    mempalace      # local-first AI memory system (built in let-binding)
    podman-compose # compose.yaml runner — works only if podman is on the host
  ];

  # ── Scripts ─────────────────────────────────────────────────────────────
  # Body shared with home/scripts.nix so both profiles ship the same script.
  home.file.".local/bin/git-mkversion" = {
    executable = true;
    source = ../raw/scripts/git-mkversion.sh;
  };

  # ── Raw config ──────────────────────────────────────────────────────────
  # .dircolors tunes ls/eza colors via $LS_COLORS. Display-agnostic, so
  # worth carrying. Other raw/* files (qt5ct, kvantum, chromium-flags,
  # fontconfig, locale.conf) are display-only and skipped here.
  home.file.".dircolors".source = ../raw/dircolors;

  # Julia REPL/IJulia startup files — Julia reads ~/.julia/config/startup.jl
  # on every launch and ours auto-loads Revise. Same recipe as the yara
  # profile (home/default.nix); the file lives in raw/julia/.
  home.file.".julia/config/startup.jl".source = ../raw/julia/startup.jl;
  home.file.".julia/config/startup_ijulia.jl".source = ../raw/julia/startup_ijulia.jl;
}
