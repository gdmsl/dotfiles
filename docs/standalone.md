# Home Manager on its own

For machines whose system config you don't control — a work server, a shared box,
anything not running NixOS. Nix is the only requirement.

Two profiles:

| Profile | For | Includes |
|---|---|---|
| `gdmsl` | a machine with a desktop | everything in `home/`, GUI apps included |
| `gdmsl-tty` | SSH-only boxes | shell, Neovim, git, multiplexers, CLI tools |

`gdmsl-tty` deliberately leaves out `packages.nix`, `services.nix`, `scripts.nix`
and everything under `desktop/`, since those pull in GUI dependencies.

## First time

No home-manager installed yet, straight from GitHub:

```bash
nix run github:nix-community/home-manager -- switch \
    --flake github:gdmsl/dotfiles#gdmsl-tty
```

With a local clone, which you'll want if you're editing anything:

```bash
git clone https://github.com/gdmsl/dotfiles ~/dotfiles
home-manager switch --flake ~/dotfiles#gdmsl-tty
```

Swap `#gdmsl-tty` for `#gdmsl` on a desktop machine.

## Updating

```bash
cd ~/dotfiles
nix flake update
home-manager switch --flake .#gdmsl-tty
```

Rolling back:

```bash
home-manager generations
/nix/store/<hash>-home-manager-generation/activate
```

## Things that differ from a NixOS machine

**The username is assumed.** Both profiles set `home.username = "gdmsl"` and
`home.homeDirectory = "/home/gdmsl"`. If the account differs, change those in
`home/tty.nix` or `home/default.nix`.

**Unfree packages** are allowed through the list in `flake.nix`, not the one in
`system/default.nix`. The two are kept in sync deliberately — a package added to
only one will fail on the other path.

**`~/Personal` doesn't exist** unless you make it. The default vault backend is
gocryptfs, so `unlock-personal` expects `~/.personal-encrypted`:

```bash
mkdir -p ~/.personal-encrypted ~/Personal
gocryptfs -init ~/.personal-encrypted
unlock-personal
```

Until it's mounted, the `-personal` AI wrappers refuse to start rather than
writing an unencrypted config into the empty directory.

**Fish isn't your login shell** unless the system config makes it one, which
you probably can't change. Either `chsh -s $(which fish)` if permitted, or start
it from your existing shell's rc file.

**No system-level packages.** Anything in `system/default.nix` isn't here — that
includes gocryptfs, so install it in the profile if you need the vault.
