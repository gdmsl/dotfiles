# third-party/

Drop zone for proprietary font archives and other vendor blobs that we
can't redistribute through nixpkgs. The `.zip` / `.tar.*` / `.iso` files
in here are gitignored (see `../.gitignore`) — only this README is
tracked.

The Nix derivations in `../system/` reference these archives by sha256
via `requireFile`, so once a file is added to the local `/nix/store`,
the rebuild can find it without a path lookup. That means:

  - The archive can live anywhere; we just keep them here for tidiness.
  - You only do the `nix-store --add-fixed` dance **once per machine**.
  - If you garbage-collect later, re-run the same command to restore.

## How `requireFile` works in one paragraph

`requireFile` produces a fixed-output derivation whose output path is
determined entirely by `(name, sha256)`. There is no fetch step — Nix
just looks for `/nix/store/<hash>-<name>` and refuses to build if it's
missing, printing a custom error message instead. You bring the file
yourself with `nix-store --add-fixed sha256 <path>`, which copies it
into the store under the right hash. After that, every rebuild
(including across reboots) finds it transparently.

> Note: nix store path basenames may not contain spaces. If your
> download has spaces in the filename, copy it to `/tmp/<clean-name>`
> first and add the copy.

---

## Aptos (Microsoft Office default font)

Used by `system/aptos.nix`.

**Download:**

  - Sign in at <https://learn.microsoft.com/en-us/typography/font-list/aptos>
    with a Microsoft 365 account and click the download link, **or**
  - From a Windows install with M365, copy `C:\Windows\Fonts\Aptos*` and
    `C:\Program Files\Microsoft Office\root\VFS\Fonts\private\Aptos*`
    into a zip.

Save the file to this folder. The expected filename is **`Microsoft
Aptos Fonts.zip`** with sha256
`6528fd120e719a9f985e94214eca6887d1653b88456916a792a630b02e95b025`. If
yours differs, paste the new hash into `system/aptos.nix` and rebuild.

**Install into the store:**

```bash
cp 'third-party/Microsoft Aptos Fonts.zip' /tmp/aptos-fonts.zip
nix-store --add-fixed sha256 /tmp/aptos-fonts.zip
rm /tmp/aptos-fonts.zip
sudo nixos-rebuild switch --flake .#yara
```

---

## Adding more proprietary fonts (Segoe UI etc.)

The same pattern works for any other font Microsoft (or anyone else)
won't let nixpkgs redistribute. The recipe:

1. **Get the archive.** For Segoe UI, the only legal source is your own
   Windows install — copy `C:\Windows\Fonts\segoe*.ttf` into a zip.
2. **Drop it in this folder** with a descriptive name, e.g.
   `Segoe-UI-Fonts.zip`.
3. **Compute the hash:** `sha256sum third-party/Segoe-UI-Fonts.zip`.
4. **Write a derivation** under `system/` modeled on `aptos.nix`. Fill
   in `name`, `sha256`, and the install phase (most font zips are flat
   `.ttf` files; the existing `install -Dm644 -t .../truetype *.ttf`
   line is usually all you need).
5. **Wire it in** by adding `(pkgs.callPackage ./<your-font>.nix { })`
   to `fonts.packages` in `system/default.nix`. Add the package's
   `pname` to the unfree allowlist if you marked it `licenses.unfree`.
6. **One-time store add:**
   ```bash
   cp 'third-party/Segoe-UI-Fonts.zip' /tmp/segoe-ui-fonts.zip
   nix-store --add-fixed sha256 /tmp/segoe-ui-fonts.zip
   rm /tmp/segoe-ui-fonts.zip
   ```
7. **Rebuild.**

### Pointers for common Microsoft fonts

| Font family | Where to find it |
|---|---|
| Segoe UI / Segoe UI Variable | `C:\Windows\Fonts\segoe*` on any Windows 10/11 install |
| Segoe MDL2 / Fluent Icons | `C:\Windows\Fonts\Seg*Icons.ttf` (Win 10+ / Win 11) |
| Sitka, Bahnschrift, Gabriola | `C:\Windows\Fonts\` (ship with Win 10+) |
| Marlett | `C:\Windows\Fonts\marlett.ttf` |
| Office 2007 ClearType (Calibri etc.) | already covered by `vista-fonts` in nixpkgs |
| Web core fonts (Arial, Times…) | already covered by `corefonts` in nixpkgs |
| Cascadia Code | already covered by `cascadia-code` in nixpkgs |
| Selawik (open Segoe UI clone) | not in nixpkgs and not shipped as binaries; build from <https://github.com/microsoft/Selawik> with `fontmake` and drop the .ttfs here |

If a font is *open-source from Microsoft* (Cascadia, Selawik, Aptos
Mono variants in the official zip), nixpkgs usually has it — check
`nix search nixpkgs <name>` before going down the `requireFile` path.
