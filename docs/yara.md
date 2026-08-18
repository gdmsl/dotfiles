# yara — the ThinkPad

The main machine: ThinkPad E14 Gen 7 (AMD), full desktop, encrypted root.

Hardware config is in `system/hardware.nix`; everything shared with the portable
SSD is in `system/default.nix`.

## Everyday use

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#yara   # apply system + user config
sudo nixos-rebuild build  --flake ~/dotfiles#yara   # build only, change nothing
```

Updating inputs:

```bash
nix flake update                                   # everything
nix flake update nixpkgs                           # one input
sudo nixos-rebuild switch --flake ~/dotfiles#yara
```

Going back:

```bash
nixos-rebuild list-generations
sudo nixos-rebuild switch --rollback
```

Old generations are also in the boot menu, which is the way out if a rebuild
leaves the machine unable to start.

## The encrypted vault

`~/Personal` is a gocryptfs directory holding documents, pictures and the
personal AI CLI configs. It isn't mounted at login:

```bash
unlock-personal      # mount it and start Syncthing
lock-personal        # stop Syncthing and unmount
```

Quite a few things depend on it being mounted — XDG Documents and Pictures point
inside it, Syncthing won't start without it, and the `-personal` wrappers refuse
to run rather than write an unencrypted config into the empty mountpoint.

The `-personal` commands (`claude-personal`, `codex-personal`,
`gemini-personal`, and a Firefox launcher) use accounts and history kept in the
vault, entirely separate from the plain `claude` / `codex` / `gemini`.

## After a fresh install

Things that need doing once, by hand.

**The Aptos font** isn't redistributable, so Nix can't fetch it. The first
rebuild fails and prints these commands:

```bash
cp 'third-party/Microsoft Aptos Fonts.zip' /tmp/aptos-fonts.zip
nix-store --add-fixed sha256 /tmp/aptos-fonts.zip
rm /tmp/aptos-fonts.zip
```

This is also what happens if garbage collection ever removes it.

**Fingerprint reader:**

```bash
fprintd-enroll       # touch and lift repeatedly
fprintd-verify
```

That covers sudo and the login screen. hyprlock uses its own fingerprint
support, so there the sensor and password field work at the same time.

**Graphics tablet:** plug it in, run `otd-gui`, set the display and area on the
Output tab and the buttons on Bindings, then save presets (Presets → Save As)
named e.g. `laptop` and `external`. `Mod+Alt+T` switches between them. `otd
detect` confirms the tablet is seen.

**Password store:**

```bash
gpg --full-generate-key
pass init <key-id>
```

## Hardware notes

**Bluetooth after suspend** — the adapter re-enumerates and its firmware
sometimes wedges, so waking up reloads the driver and restarts bluetoothd. That's
automatic (`powerManagement.resumeCommands`). If a device still won't connect,
`systemctl restart bluetooth` is the manual version.

Leave `KernelExperimental` off in the BlueZ settings. It enables LE Audio, which
this adapter can't fully support; the symptom is `bap_detached: Unable to find
bap session` at every shutdown.

**Lid and power button** suspend, then hibernate after 12 hours — or sooner if
the battery won't last that long.

**Suspending with the portable SSD attached** is worth avoiding. USB devices
re-enumerate on resume and the encrypted containers won't survive it cleanly.

## When something's wrong

See the troubleshooting section in the top-level README — that covers the
recurring Nix errors, user services and Home Manager activation.

Two specific to this machine:

**A user service isn't running.** Most of them are tied to the graphical
session, so they won't start over plain SSH:

```bash
systemctl --user status noctalia
journalctl --user -u noctalia -f
```

**Theme changes not applying.** Running a GUI theme switcher like `nwg-look`
writes the same files Home Manager manages. The `force` flags in
`home/desktop/gtk.nix` reclaim them on the next rebuild, so just rebuild — but
don't expect that tool's changes to stick.
