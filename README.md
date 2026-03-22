dotfiles by GDMSL
=================

```
                                            ##
       ##                        :####      ##     ####
       ##              ##        #####      ##     ####
       ##              ##        ##                  ##
  :###.##   .####.   #######   #######    ####       ##       .####:    :#####.
 :#######  .######.  #######   #######    ####       ##      .######:  ########
 ###  ###  ###  ###    ##        ##         ##       ##      ##:  :##  ##:  .:#
 ##.  .##  ##.  .##    ##        ##         ##       ##      ########  ##### .
 ##    ##  ##    ##    ##        ##         ##       ##      ########  .######:
 ##.  .##  ##.  .##    ##        ##         ##       ##      ##           .: ##
 ###  ###  ###  ###    ##.       ##         ##       ##:     ###.  :#  #:.  :##
 :#######  .######.    #####     ##      ########    #####   .#######  ########
  :###.##   .####.     .####     ##      ########    .####    .#####:  . ####

```

## Home Manager Flake

This repository is managed by [Home Manager](https://github.com/nix-community/home-manager)
as a standalone flake. It declaratively configures the entire user environment.

### Structure

```
flake.nix                 # Main flake entry point
home/
  default.nix             # Root module -- imports everything, session vars, paths
  packages.nix            # User-level packages (CLI tools, LSP servers, desktop apps)
  git.nix                 # programs.git (delta, aliases, LFS, QPerfect conditional)
  services.nix            # systemd user services (cliphist, kanshi, niriswitcher, etc.)
  xdg.nix                 # XDG dirs, mimeApps, raw config file deployment
  scripts.nix             # ~/.local/bin scripts (cliphist-pick, ssh-add-all, etc.)
  shell/
    fish.nix              # programs.fish (abbrs, aliases, functions, plugins)
    bash.nix              # programs.bash (minimal fallback)
    zsh.nix               # programs.zsh (minimal fallback)
    starship.nix          # programs.starship (full prompt config)
    atuin.nix             # programs.atuin (shell history)
    direnv.nix            # programs.direnv + nix-direnv
  editor/
    neovim.nix            # LazyVim via mkOutOfStoreSymlink + LSP servers
  terminal/
    kitty.nix             # programs.kitty (One Dark theme, keybindings)
    tmux.nix              # programs.tmux (plugins, nova theme)
    zellij.nix            # programs.zellij (raw KDL config)
  desktop/
    hyprland.nix          # wayland.windowManager.hyprland + all conf/ files
    niri.nix              # xdg.configFile for niri (KDL config)
    waybar.nix            # programs.waybar (Catppuccin Mocha style)
    mako.nix              # services.mako (notification daemon)
    kanshi.nix            # kanshi output profiles (raw config)
raw/                      # Raw config files that are not nixified
  hypr/                   # Hyprland modular config
  niri/                   # Niri config (KDL)
  nvim/                   # LazyVim (full Lua config)
  zellij/                 # Zellij config (KDL)
  ranger/                 # Ranger file manager config
  mpv/                    # MPV media player config
  ...
```

### Installation

```bash
# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone this repo
git clone https://github.com/gdmsl/dotfiles ~/Code/configs/dotfiles
cd ~/Code/configs/dotfiles

# Apply the configuration
nix run home-manager -- switch --flake .#gdmsl
```

### Updating

```bash
cd ~/Code/configs/dotfiles
nix flake update
home-manager switch --flake .#gdmsl
```

## What I use

**I use [Arch](https://www.archlinux.org), btw** -- with Nix Home Manager for dotfile management.

- **Window managers**: Niri (scrolling tiling) and Hyprland (dynamic tiling)
- **Terminal**: Kitty with FiraCode Nerd Font
- **Shell**: Fish (primary), Bash and Zsh (fallbacks)
- **Editor**: Neovim (LazyVim distribution)
- **Prompt**: Starship
- **Browser**: Firefox
- **File manager**: Yazi / Ranger
- **Media**: MPV
- **Notifications**: Mako
- **Bar**: Waybar (Catppuccin Mocha theme)
- **Launcher**: Vicinae / Anyrun
- **Clipboard**: Cliphist + wl-clipboard
