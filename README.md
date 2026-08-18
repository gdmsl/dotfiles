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

A declarative NixOS and Home Manager configuration. Packages, services, shell,
editor, desktop theming — all described in `.nix` files, so rebuilding produces
the same environment every time.

## Hosts and profiles

The flake produces four things:

| Name | What it is | Command |
|---|---|---|
| `yara` | ThinkPad E14, full desktop | `sudo nixos-rebuild switch --flake .#yara` |
| `nomad` | Portable encrypted SSD, boots on any x86_64 machine | `sudo nixos-rebuild switch --flake .#nomad` |
| `gdmsl` | Home Manager only, for machines whose system config you don't own | `home-manager switch --flake .#gdmsl` |
| `gdmsl-tty` | Same, minus everything graphical | `home-manager switch --flake .#gdmsl-tty` |

The two NixOS hosts share `system/default.nix` and all of `home/`; each adds
its own hardware file.

## Everyday commands

```bash
sudo nixos-rebuild switch --flake .#yara   # apply system + user config
sudo nixos-rebuild build  --flake .#yara   # build without applying
nix flake update                           # update every input
nix flake update <input>                   # update just one
nix search nixpkgs <name>                  # find a package
```

Rolling back: pick an older generation from the boot menu, or

```bash
sudo nixos-rebuild switch --rollback
nixos-rebuild list-generations
```

## When something breaks

Nix errors are long but read bottom-up — the last line is usually the real
cause. A few recurring cases:

- **`error: attribute 'foo' missing`** — a package was renamed or removed from
  nixpkgs. `nix search nixpkgs <name>` to find the new name; removals usually
  print a message saying what replaced them.
- **`has an unfree license`** — add the derivation name to the allowlist in
  `system/default.nix`, and to the matching list in `flake.nix`. The name isn't
  always the attribute; `nix eval nixpkgs#foo.name` tells you.
- **`marked as insecure`** — same idea, in `permittedInsecurePackages`. Those
  entries include the version, so a bump breaks them.
- **A user service misbehaving** — `systemctl --user status <name>` then
  `journalctl --user -u <name> -f`.
- **Home Manager didn't apply** — `journalctl -u home-manager-gdmsl.service`.
  Activation runs as one shell script, so one failing step silently skips
  everything after it.
- **Nothing changed after a rebuild** — if the file lives in `raw/` and is
  linked with `.source`, it's copied into the store and needs a rebuild;
  only `mkOutOfStoreSymlink` paths update live.

## Nix in five minutes

Enough of the language to read this repo:

- **Attribute sets** `{ key = value; }` — like a JSON object. Most of Nix is these.
- **Lists** `[ a b c ]` — space-separated, no commas.
- **Functions** `{ pkgs, lib, ... }: { ... }` — one argument, usually an attrset
  destructured like this. The `...` ignores arguments the file doesn't use.
- **let** `let x = 1; in ...` — local bindings.
- **Interpolation** `"${pkgs.git}/bin/git"` — inside strings; with a package this
  expands to its store path.
- **`'' … ''`** — multi-line string. `''${` is how you escape a literal `${`.
- `#` is the only comment syntax.

**Modules.** Both NixOS and Home Manager are configured by modules: files
returning an attrset of options. Every module is merged into one configuration,
which is why config can be split across files — and why two modules setting the
same option conflict unless one uses `lib.mkDefault` (yield) or `lib.mkForce`
(win).

**Flakes.** `flake.nix` declares `inputs` (dependencies) and `outputs` (what
this repo produces). `flake.lock` pins every input to a commit. Flakes only see
git-tracked files, so a new file that isn't `git add`ed will look missing.

**Raw config.** Config formats not worth expressing in Nix live in `raw/` and
are linked into place with `xdg.configFile`. Third-party tools not in nixpkgs
(noctalia, vicinae, anyrun, nvf) come in as flake inputs instead.

## Layout

```
flake.nix                   inputs, and the four outputs above
system/
  default.nix               shared: users, networking, services, fonts, security
  hardware.nix              yara: boot, LUKS, filesystems, swap
  nomad.nix                 portable SSD: GRUB, initrd drivers, hardware opt-outs
  disko-nomad.nix           portable SSD: partitions, LUKS, subvolumes
  aptos.nix                 packaging for a font that isn't in nixpkgs
  ca.pem                    extra trusted CA
home/
  default.nix               entry point: imports, env vars, PATH, dotfiles
  packages.nix              user packages
  tty.nix                   headless profile (imports a subset of the below)
  scripts.nix               scripts installed to ~/.local/bin
  services.nix              systemd user services and timers
  personal-vault.nix        unlock-personal / lock-personal
  xdg.nix                   MIME types, default apps, user directories
  git.nix, firefox.nix, libreoffice.nix
  shell/                    fish (primary), bash, zsh, starship, atuin, direnv
                            _aliases.nix is shared by all three shells
  terminal/                 kitty, tmux, zellij
  editor/                   neovim, via the nvf flake
  desktop/                  niri, hyprland, gtk, portals, noctalia, launchers
  pkgs/                     small local package recipes
raw/                        config files deployed verbatim
templates/                  `nix flake init -t` project templates
third-party/                files that can't be redistributed (see aptos.nix)
```

## Installation

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

git clone https://github.com/gdmsl/dotfiles ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#yara
```

The path matters: `dotfilesPath` in `flake.nix` is `/home/gdmsl/dotfiles`, and
the `mkOutOfStoreSymlink` entries point at it. Clone elsewhere and that value
needs changing too.

## What I use

- **OS** NixOS, flakes
- **Compositors** Niri (scrolling tiling), Hyprland (dynamic tiling)
- **Shell / bar** Noctalia, also handling notifications and clipboard history
- **Terminal** Kitty, FiraCode Nerd Font
- **Shell** Fish, with Bash and Zsh as fallbacks
- **Editor** Neovim via nvf
- **Prompt** Starship
- **Browser** Firefox
- **Files** Yazi in the terminal, Nautilus for a GUI
- **Launcher** Vicinae, Anyrun
- **Theme** Colloid (GTK and icons), One Dark in the terminal and editor
