# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  libreoffice.nix — LibreOffice + TexMaths (LaTeX equation editor)          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# TexMaths is a LibreOffice extension that lets you embed LaTeX equations as
# SVG/PNG images in Writer/Impress/Calc/Draw documents. It isn't packaged in
# nixpkgs, so we install it ourselves.
#
# How this module works:
#
#   1. `pkgs.fetchurl` downloads the .oxt file (a zip archive) from SourceForge
#      into the Nix store. The `sha256` pins the exact bytes — bumping the
#      version requires recomputing it with `nix-prefetch-url <url>`.
#
#   2. `home.packages` pulls in LibreOffice itself plus the LaTeX runtime that
#      TexMaths shells out to at render time (latex/pdflatex, dvipng/dvisvgm,
#      ghostscript). Without these, the extension installs but produces empty
#      equation images.
#
#   3. `home.activation` runs an imperative script every `home-manager switch`.
#      LibreOffice extensions are registered via `unopkg`, which mutates state
#      under ~/.config/libreoffice — outside Nix's purview. We track the store
#      path of the .oxt we last installed in a small marker file so the script
#      becomes a no-op when nothing changed and re-runs only on version bumps.
#
# Caveats (the trade-offs of step 3):
#   • If you uninstall TexMaths manually via LibreOffice's GUI, the marker
#     still says it's installed — you'd have to delete the marker to force a
#     reinstall on the next switch.
#   • The first switch after a fresh home directory will run a real `unopkg`
#     call, which can take a few seconds because LibreOffice spins up a JVM.

{ config, pkgs, lib, ... }:

let
  # TexMaths release archive (https://extensions.libreoffice.org/en/extensions/show/9215).
  # To bump: change the version, run `nix-prefetch-url <url>` to get the new
  # hash, paste it into `sha256` below.
  texmathsOxt = pkgs.fetchurl {
    url = "https://downloads.sourceforge.net/project/texmaths/0.52.6/TexMaths-0.52.6.oxt";
    sha256 = "1gmrxj7frchccwlb6d72j2ln243309pvymm320hh9akwn4wmam64";
  };

  # Marker file recording which .oxt store path is currently installed. Lives
  # under XDG_STATE_HOME (typically ~/.local/state) — the standard place for
  # tool state that isn't config and isn't cache.
  stateFile = "${config.xdg.stateHome}/texmaths/installed-oxt";
in
{
  home.packages = with pkgs; [
    libreoffice-fresh
    # texliveMedium bundles a LaTeX engine plus the math packages TexMaths
    # commonly uses (amsmath, amssymb, mathtools) and dvipng/dvisvgm for
    # converting DVI output to images. ~750 MB. If you only ever need basic
    # equations, swap to `texliveSmall` to save space.
    texliveMedium
    ghostscript
  ];

  # `lib.hm.dag.entryAfter [ "writeBoundary" ]` queues this step after Home
  # Manager has finished linking dotfiles into place. Anything earlier and the
  # config files unopkg writes might collide with HM's link-or-copy pass.
  home.activation.installTexMaths =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      installed_marker="${stateFile}"
      desired="${texmathsOxt}"

      # Skip if the recorded version already matches what we want to install.
      if [ -e "$installed_marker" ] && [ "$(cat "$installed_marker" 2>/dev/null)" = "$desired" ]; then
        exit 0
      fi

      # `$DRY_RUN_CMD` is empty in normal runs and `:` (the no-op builtin) when
      # you pass `-n` to home-manager. Prefixing real commands with it makes
      # dry-run print/skip them; we only do "real" work in non-dry-run mode so
      # the marker file stays consistent with what unopkg actually did.
      if [ -z "$DRY_RUN_CMD" ]; then
        mkdir -p "$(dirname "$installed_marker")"
        # `-f` force-replaces any existing copy of the same extension; this is
        # what lets us upgrade TexMaths in place when the version changes.
        # `--suppress-license` accepts the GPLv2 prompt non-interactively.
        ${pkgs.libreoffice-fresh}/bin/unopkg add \
          --suppress-license -f "$desired"
        echo "$desired" > "$installed_marker"
      else
        echo "Would install TexMaths from $desired"
      fi
    '';
}
