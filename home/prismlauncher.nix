# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  prismlauncher.nix — Minecraft launcher, with a Java path that survives      ║
# ║                      rebuilds                                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Prism remembers which JDK to use as a plain absolute path, written into
# ~/.local/share/PrismLauncher/prismlauncher.cfg:
#
#     JavaPath=/nix/store/0a9l8…-openjdk-25.0.4+7/bin/java
#
# On an ordinary distro that path (/usr/lib/jvm/…) is stable for years. Here it
# changes every time nixpkgs bumps the JDK, and the old store path disappears at
# the next `nix-collect-garbage`. Prism re-checks the path at startup, and when
# it no longer resolves it concludes Java is unconfigured and opens the setup
# wizard asking you to pick a version. That is the prompt.
#
# The relevant check is Application::createSetupWizard(), which asks the wizard
# for exactly three reasons: the IgnoreJavaWizard setting is off, *and* either
# the hostname changed since last run or JavaPath no longer resolves.
#
# So this module removes both triggers:
#
#   1. Points JavaPath at a symlink *we* own, so the string saved in the config
#      file stays valid forever while Home Manager re-aims it at the current JDK
#      on every rebuild.
#   2. Sets IgnoreJavaWizard — the same switch as the "Skip Java setup prompt on
#      startup" checkbox under Settings → Java. This also covers the hostname
#      branch, which fires the wizard the first time you launch Prism on a
#      different machine even when Java is perfectly fine.
#
# Choosing a JDK *per instance* is a separate mechanism that already works: the
# nixpkgs wrapper exports PRISMLAUNCHER_JAVA_PATHS with JDK 25, 21, 17 and 8,
# and the AutomaticJavaSwitch setting makes Prism rescan that list at launch and
# re-pin a compatible JDK onto the instance whenever its saved path has gone
# stale. Instances therefore heal themselves after a rebuild; only the global
# default needed help.

{ config, pkgs, lib, ... }:

let
  # The global fallback JDK, used when auto-switching finds nothing compatible
  # for an instance. 21 rather than the newest, because Prism matches the major
  # version *exactly* against the list the Minecraft version profile asks for,
  # and current Minecraft asks for 21 — a 25 fallback would simply never match.
  #
  # This adds nothing to the closure: prismlauncher's wrapper already depends on
  # this same jdk21 derivation, so the symlink points at a store path that is
  # kept alive regardless.
  fallbackJdk = pkgs.jdk21;

  # Path of the symlink, relative to $HOME the way home.file wants it.
  #
  # Deliberately a sibling of Prism's data directory rather than a child of it:
  # Home Manager owns this path and installs a read-only symlink there, which is
  # not a thing to place inside a directory an application manages itself.
  jdkLink = ".local/share/prismlauncher-jdk";

  javaPath = "${config.home.homeDirectory}/${jdkLink}/bin/java";

  prismCfg = "${config.xdg.dataHome}/PrismLauncher/prismlauncher.cfg";
in
{
  home.packages = [ pkgs.prismlauncher ];

  # A derivation as the source makes this one symlink to the store path, rather
  # than a recursive copy of the JDK tree.
  home.file.${jdkLink}.source = fallbackJdk;

  # prismlauncher.cfg is mutable state — Prism rewrites the whole file on exit,
  # including window geometry and the last selected instance. That rules out
  # `home.file`, which would install a read-only symlink Prism cannot save over.
  # Patching individual keys at activation time is how a mostly-mutable config
  # gets a declarative corner.
  #
  # Caveat that comes with that: if Prism is running during a rebuild it will
  # write its in-memory copy back over these keys when you close it. Rebuild
  # with Prism closed, or just restart it afterwards.
  #
  # entryAfter "writeBoundary" runs this once Home Manager has finished linking
  # dotfiles, so the JDK symlink above is already in place.
  home.activation.prismJavaDefaults =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      prism_cfg="${prismCfg}"

      # DRY_RUN_CMD is empty normally and `:` under `home-manager -n`, so only
      # touch the file when it's empty.
      if [ -z "$DRY_RUN_CMD" ]; then
        # First activation on a new machine: Prism hasn't created the file yet.
        # Seeding it means the very first launch already has these settings and
        # never shows the wizard at all.
        if [ ! -e "$prism_cfg" ]; then
          mkdir -p "$(dirname "$prism_cfg")"
          printf '[General]\n' > "$prism_cfg"
        fi

        # Overwrite the key if present, append it under [General] if not.
        # Prefixed name because every activation step is concatenated into one
        # bash script, where a bare `set_key` could collide with another module.
        prism_set_key() {
          if ${pkgs.gnugrep}/bin/grep -q "^$1=" "$prism_cfg"; then
            ${pkgs.gnused}/bin/sed -i "s|^$1=.*|$1=$2|" "$prism_cfg"
          else
            ${pkgs.gnused}/bin/sed -i "/^\[General\]/a $1=$2" "$prism_cfg"
          fi
        }

        # That same concatenation means a failure here would abandon the rest of
        # activation, so neither call is allowed to be fatal.
        prism_set_key JavaPath "${javaPath}" || \
          echo "Prism: could not set JavaPath — continuing activation anyway." >&2
        prism_set_key IgnoreJavaWizard true || \
          echo "Prism: could not set IgnoreJavaWizard — continuing activation anyway." >&2
      else
        echo "Would point Prism's JavaPath at ${javaPath}"
      fi
    '';
}
