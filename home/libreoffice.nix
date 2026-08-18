# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  libreoffice.nix — LibreOffice, OnlyOffice and the TexMaths extension       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# TexMaths embeds LaTeX equations as images in LibreOffice documents. It isn't
# in nixpkgs, so this module fetches the .oxt and installs it.
#
# Extensions are registered with `unopkg`, which writes into
# ~/.config/libreoffice — mutable state Nix doesn't manage. So installing it
# needs an activation script rather than a package, and a marker file records
# which version is installed so the script only does work after a version bump.
#
# Two consequences of that: removing the extension through LibreOffice's own UI
# leaves the marker in place (delete the marker to force a reinstall), and the
# first run on a new home directory takes a few seconds while LibreOffice
# starts a JVM.

{ config, pkgs, lib, ... }:

let
  # https://extensions.libreoffice.org/en/extensions/show/9215
  # To bump: change the version, then `nix-prefetch-url <url>` for the hash.
  texmathsOxt = pkgs.fetchurl {
    url = "https://downloads.sourceforge.net/project/texmaths/0.52.6/TexMaths-0.52.6.oxt";
    sha256 = "1gmrxj7frchccwlb6d72j2ln243309pvymm320hh9akwn4wmam64";
  };

  # Records which .oxt is installed. ~/.local/state is where state that's
  # neither config nor cache belongs.
  stateFile = "${config.xdg.stateHome}/texmaths/installed-oxt";
in
{
  home.packages = with pkgs; [
    libreoffice-fresh
    # Reads and writes .docx/.xlsx/.pptx natively instead of converting via
    # ODF, so layout survives a round trip better. Worth having when a file has
    # to go back to someone on Microsoft Office.
    onlyoffice-desktopeditors
    # LaTeX engine, the usual maths packages, and the DVI-to-image converters
    # TexMaths calls. ~750 MB; texliveSmall is enough for basic equations.
    texliveMedium
    ghostscript
  ];

  # entryAfter "writeBoundary" runs this once Home Manager has finished linking
  # dotfiles, so unopkg's writes can't collide with that.
  home.activation.installTexMaths =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      installed_marker="${stateFile}"
      desired="${texmathsOxt}"

      # Only act when the installed version differs from the wanted one.
      #
      # Every activation step is concatenated into one bash script, so `exit`
      # here would abandon the rest of activation. Same goes for any command
      # that fails — see the guards below.
      if [ ! -e "$installed_marker" ] || [ "$(cat "$installed_marker" 2>/dev/null)" != "$desired" ]; then
        # DRY_RUN_CMD is empty normally and `:` under `home-manager -n`, so
        # only do real work when it's empty — that keeps the marker honest.
        if [ -z "$DRY_RUN_CMD" ]; then
          # unopkg needs /run/user/$UID, which logind only creates once you
          # log in. Activation also runs at boot, before any session exists,
          # and unopkg then fails with "cannot create directory
          # '/run/user/1000'". Left unguarded that failure aborts activation,
          # taking the ~/.config symlinks with it — so skip when the directory
          # isn't there, and treat unopkg failing as non-fatal.
          if [ ! -d "/run/user/$(${pkgs.coreutils}/bin/id -u)" ]; then
            echo "TexMaths: no XDG_RUNTIME_DIR yet (boot-time activation) — deferring."
          else
            mkdir -p "$(dirname "$installed_marker")"
            # -f replaces an existing copy, which is how version bumps apply.
            # --suppress-license accepts the licence prompt without asking.
            if ${pkgs.libreoffice-fresh}/bin/unopkg add \
                 --suppress-license -f "$desired"; then
              echo "$desired" > "$installed_marker"
            else
              # Marker untouched, so the next activation tries again.
              echo "TexMaths: unopkg failed — continuing activation anyway." >&2
            fi
          fi
        else
          echo "Would install TexMaths from $desired"
        fi
      fi
    '';
}
