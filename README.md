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

## What this is

A **fully declarative** system and user environment configuration for NixOS
with Home Manager. Everything — packages, services, shell config, editor
setup, desktop theming — is defined in `.nix` files. Rebuilding from these
files produces an identical environment every time.

## Nix concepts for beginners

If you're new to Nix, here are the key ideas you'll encounter in this repo:

### The Nix language

Nix is a **pure functional language** used to describe packages and configurations.
The core building blocks are:

- **Attribute sets** `{ key = value; }` — like JSON objects or Python dicts.
  Almost everything in Nix is an attrset.
- **Lists** `[ item1 item2 ]` — ordered collections (no commas needed).
- **Functions** `x: x + 1` — single-argument functions. Multi-argument functions
  use attrset destructuring: `{ pkgs, lib, ... }: { ... }`.
- **Let bindings** `let x = 1; in x + 2` — local variables.
- **String interpolation** `"hello ${name}"` — embed expressions in strings.
- **Multi-line strings** `'' ... ''` — indentation is stripped automatically.
- **Comments** `# line comment` — Nix only has line comments (no block comments).

### Flakes

A **flake** (`flake.nix`) is Nix's unit of reproducibility. It declares:

- **inputs** — dependencies on other flakes (nixpkgs, home-manager, etc.)
- **outputs** — what this flake produces (a NixOS system, a Home Manager config)

The `flake.lock` file pins every input to an exact git commit. This means
your build is reproducible: same inputs → same result.

### Nixpkgs

**nixpkgs** is the massive package repository (~100,000 packages). When you
write `pkgs.firefox`, you're referencing the Firefox package from nixpkgs.
`with pkgs;` opens the namespace so you can just write `firefox`.

### NixOS modules

NixOS is configured through **modules** — functions that take `{ config, pkgs, lib, ... }`
and return an attribute set of options. NixOS merges all modules together into
one final system configuration. This is why you can split config across many files.

Key patterns:
- `services.foo.enable = true;` — enable a systemd service
- `programs.foo.enable = true;` — install and configure a program
- `environment.systemPackages = [ pkgs.git ];` — install system-wide packages

### Home Manager

**Home Manager** does for your user environment what NixOS does for the system.
It manages:
- **Dotfiles** — generates config files from Nix options
- **User packages** — installs programs into your user profile
- **User services** — manages systemd user units
- **Desktop entries** — creates .desktop launcher files

Key patterns:
- `programs.git.enable = true;` — Home Manager writes `~/.config/git/config`
- `home.packages = [ pkgs.ripgrep ];` — install packages for this user only
- `xdg.configFile."foo/config".source = ./myconfig;` — deploy a raw file to `~/.config/foo/config`
- `home.file.".bashrc".text = "...";` — write a file to `~/`

### The "raw config" pattern

Some programs use config formats that are hard to express in Nix (KDL, JSONC,
complex INI). For these, we store the config as-is in the `raw/` directory and
deploy it using `xdg.configFile`:

```nix
# Instead of nixifying the config, just deploy the raw file:
xdg.configFile."niri/config.kdl".source = ../../raw/niri/config.kdl;
```

### Flake inputs as dependencies

Third-party tools (noctalia, vicinae, anyrun, nvf) are pulled in as **flake inputs**.
Their packages and Home Manager modules are accessed via `inputs.foo.packages`
and `inputs.foo.homeManagerModules`. This means you get tools that aren't in
nixpkgs, all pinned to exact versions.

## Repository structure

```
flake.nix                         # Entry point: inputs, outputs, system + HM config
flake.lock                        # Pinned versions of all inputs
system/
  default.nix                     # NixOS system config (users, networking, services)
  hardware.nix                    # Hardware-specific config (boot, disks, LUKS)
  ca.pem                          # Custom CA certificate
home/
  default.nix                     # HM root module (imports all below, env vars, paths)
  packages.nix                    # User packages (CLI tools, apps, fonts, themes)
  git.nix                         # Git config (delta pager, aliases, conditional include)
  services.nix                    # systemd user services (clipboard, idle, syncthing)
  xdg.nix                         # MIME types, default apps, raw config deployment
  scripts.nix                     # Custom scripts in ~/.local/bin
  firefox.nix                     # Firefox Personal profile desktop entry
  shell/
    fish.nix                      # Fish shell (primary: abbrs, functions, plugins)
    bash.nix                      # Bash (fallback)
    zsh.nix                       # Zsh (fallback)
    starship.nix                  # Starship prompt (cross-shell)
    atuin.nix                     # Shell history search/sync
    direnv.nix                    # Auto-load .envrc environments
  editor/
    neovim.nix                    # Neovim (via nvf: LSP, treesitter, keymaps)
  terminal/
    kitty.nix                     # Kitty terminal (One Dark theme, splits)
    tmux.nix                      # tmux multiplexer (nova theme, plugins)
    zellij.nix                    # Zellij multiplexer (raw KDL config)
  desktop/
    hyprland.nix                  # Hyprland WM (deploys raw modular config)
    niri.nix                      # Niri WM (raw KDL config)
    waybar.nix                    # Waybar status bar (raw JSONC + CSS)
    mako.nix                      # Mako notification daemon
    gtk.nix                       # GTK/cursor/icon theming
    kanshi.nix                    # Automatic display profile switching
    noctalia.nix                  # Noctalia desktop shell (from flake)
    vicinae.nix                   # Vicinae launcher (from flake)
    anyrun.nix                    # Anyrun launcher (from flake)
raw/                              # Raw config files (not nixified)
  hypr/                           # Hyprland modular config + scripts
  niri/                           # Niri KDL config
  zellij/                         # Zellij KDL config
  waybar/                         # Waybar config + CSS
  ranger/                         # Ranger file manager
  mpv/                            # MPV media player
  fontconfig/                     # Font configuration
  qt5ct/, qt6ct/, Kvantum/        # Qt theming
  julia/                          # Julia startup scripts
  gdb/                            # GDB debugger config
  fastfetch/                      # System info display
  ...                             # Various other dotfiles
```

## Suggested reading order

If you want to understand how everything fits together, read the source files
in this order. Each file has comments explaining the Nix concepts it uses.

1. **`flake.nix`** — Start here. This is the entry point that defines what
   inputs we depend on and what outputs we produce. It teaches you about
   flakes, inputs/outputs, and how NixOS and Home Manager are wired together.

2. **`system/hardware.nix`** — Hardware facts: boot loader, LUKS encryption,
   filesystems. Shows `nixos-generate-config` output and `lib.mkDefault`.

3. **`system/default.nix`** — The NixOS system config. Covers users,
   networking, services, audio, display manager, fonts, security, and the
   unfree package allowlist. This is where you learn what NixOS modules look
   like and how `services.foo.enable` works.

4. **`home/default.nix`** — The Home Manager entry point. Shows how imports
   work, session variables, PATH, and the two ways to deploy files
   (`xdg.configFile` for ~/.config, `home.file` for ~/). Introduces
   `mkOutOfStoreSymlink`.

5. **`home/packages.nix`** — Simple but important: how `home.packages` and
   `with pkgs;` work. Good place to see the breadth of available packages.

6. **`home/shell/fish.nix`** — The most feature-rich shell config. Shows
   abbreviations, aliases, multi-line functions, plugins, and how Home
   Manager generates shell config. The git worktree functions are practical
   examples of Fish scripting.

7. **`home/shell/direnv.nix`** — Tiny but important: shows how nix-direnv
   integrates Nix development shells with `use flake` in `.envrc` files.

8. **`home/git.nix`** — Git configuration including conditional includes
   (different email for work repos), credential helpers, and the delta
   pager. Shows how Home Manager generates `~/.config/git/config`.

9. **`home/editor/neovim.nix`** — The largest single module. Shows how nvf
   (a third-party flake) configures Neovim entirely in Nix: languages, LSP,
   plugins, keymaps. Demonstrates `extraPlugins` for plugins not in nvf,
   and `luaConfigPre` for raw Lua code.

10. **`home/terminal/kitty.nix`** — A good example of `programs.foo` with
    settings, keybindings, and raw extraConfig for the color theme.

11. **`home/services.nix`** — systemd user services. Shows how to define
    services that start with the graphical session, and the vault-guard
    pattern for conditional service startup.

12. **`home/desktop/gtk.nix`** — Desktop theming across GTK3, GTK4, dconf,
    and Wayland cursor. Shows how multiple systems need to be configured
    for consistent theming on Linux.

13. **`home/desktop/noctalia.nix`** and **`home/desktop/vicinae.nix`** —
    How to import and use Home Manager modules from third-party flake inputs.

14. **`home/desktop/hyprland.nix`** — The "raw config deployment" pattern:
    when a program's config format is too complex to nixify, just deploy
    the files from `raw/` with `xdg.configFile`.

## Installation

```bash
# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone this repo
git clone https://github.com/gdmsl/dotfiles ~/dotfiles
cd ~/dotfiles

# Apply NixOS system + user config (on NixOS)
sudo nixos-rebuild switch --flake .#yara

# Or apply just the user config (on any Linux with Nix)
nix run home-manager -- switch --flake .#gdmsl
```

## Updating

```bash
cd ~/dotfiles
nix flake update                            # update all inputs to latest
sudo nixos-rebuild switch --flake .#yara    # rebuild system + user config
```

## What I use

- **OS**: NixOS (with flakes)
- **Window managers**: Niri (scrolling tiling) and Hyprland (dynamic tiling)
- **Terminal**: Kitty with FiraCode Nerd Font
- **Shell**: Fish (primary), Bash and Zsh (fallbacks)
- **Editor**: Neovim (nvf framework — fully Nix-native)
- **Prompt**: Starship (cross-shell)
- **Browser**: Firefox
- **File manager**: Yazi / Ranger
- **Media**: MPV
- **Notifications**: Mako
- **Bar**: Waybar
- **Launcher**: Vicinae / Anyrun
- **Clipboard**: Cliphist + wl-clipboard
- **Theme**: Tokyo Night (GTK) + One Dark (terminal/editor)
