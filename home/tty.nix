# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  home/tty.nix — Headless / SSH-only home-manager profile                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Trimmed profile for machines you only SSH into: no compositor, no GUI apps.
# It imports the same per-tool modules as the desktop profile, so the shell and
# editor behave identically.
#
# On a fresh box with Nix but no home-manager:
#
#   nix run github:nix-community/home-manager -- switch \
#       --flake github:gdmsl/dotfiles#gdmsl-tty
#
# Point --flake at a local checkout instead if you have one.

{ config, pkgs, lib, inputs, ... }:

let
  # Same derivation home/packages.nix uses, so both profiles get one build.
  mempalace = import ./pkgs/mempalace.nix { inherit pkgs lib; };
in
{
  # ── Imports ─────────────────────────────────────────────────────────────
  # Only display-agnostic modules. packages.nix, services.nix, scripts.nix and
  # everything under desktop/ pull in GUI dependencies, so they stay out.
  imports = [
    # Shell stack
    ./shell/fish.nix         # primary shell + abbreviations
    ./shell/bash.nix         # POSIX fallback
    ./shell/zsh.nix          # alternate fallback
    ./shell/starship.nix     # cross-shell prompt
    ./shell/atuin.nix        # synced shell history
    ./shell/direnv.nix       # per-directory env loader
    ./personal-vault.nix     # unlock-personal / lock-personal (~/Personal)
    ./rbw.nix                # rbw, CLI client for the Vaultwarden instance

    # Editor / VCS / multiplexers
    ./git.nix                # git config, delta, aliases
    ./terminal/tmux.nix      # tmux multiplexer
    ./terminal/zellij.nix    # zellij multiplexer
    ./editor/neovim.nix      # neovim via nvf framework
  ];

  # Override these if the username on that machine differs.
  home.username = "gdmsl";
  home.homeDirectory = "/home/gdmsl";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ── Session variables ───────────────────────────────────────────────────
  # The terminal subset of home/default.nix; the browser and Firefox ones only
  # matter in a graphical session.
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

  # ── rbw ─────────────────────────────────────────────────────────────────
  # rbw.nix picks a Qt dialog for the master password prompt. There is no
  # display on these machines, so ask in the terminal instead.
  programs.rbw.settings.pinentry = pkgs.pinentry-curses;

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
    # For working out what an unfamiliar box actually is. No nvtop here, since
    # the GPU vendor is unknown.
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
    codex             # OpenAI's terminal coding agent (the `codex` command)
    antigravity-cli   # Google's agent CLI (the `agy` command); replaced gemini-cli

    # ── Secrets ───────────────────────────────────────────────────────────
    # No graphical keyring here, so GPG's terminal pinentry asks for
    # passphrases. Setup: `gpg --full-generate-key`, then `pass init <key-id>`.
    gnupg
    pass

    # ── Languages & toolchains ────────────────────────────────────────────
    # Same Julia wrapper as the desktop profile, see pkgs/julia-wrapped.nix.
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
    mempalace      # local-first AI memory system (built in let-binding)
    podman-compose # compose.yaml runner — works only if podman is on the host
  ];

  # ── Scripts ─────────────────────────────────────────────────────────────
  # Shared with home/scripts.nix, so both profiles ship the same one.
  home.file.".local/bin/git-mkversion" = {
    executable = true;
    source = ../raw/scripts/git-mkversion.sh;
  };

  # ── Raw config ──────────────────────────────────────────────────────────
  # ls and eza colours. The rest of raw/ is graphical, so it's skipped.
  home.file.".dircolors".source = ../raw/dircolors;

  # Loads Revise on every REPL start, as in home/default.nix.
  home.file.".julia/config/startup.jl".source = ../raw/julia/startup.jl;
  home.file.".julia/config/startup_ijulia.jl".source = ../raw/julia/startup_ijulia.jl;
}
