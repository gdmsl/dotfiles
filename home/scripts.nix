# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  scripts.nix — Custom shell scripts in ~/.local/bin                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Utility scripts written to ~/.local/bin, which is on $PATH.
#
# `home.file` with `executable = true` and inline `text` is the simple way to
# manage a small script. Longer ones live in raw/scripts/ and are pulled in with
# `source` instead.
#
# Two things about Nix's '' … '' strings, which bite when editing these:
# `''${` is how you write a literal `${` (otherwise Nix interpolates it), and
# `${pkgs.foo}/bin/foo` expands to a store path, which is why some commands are
# fully qualified and others rely on PATH.

{ config, pkgs, ... }:

let
  # Used by the -personal wrappers at the bottom of the file.
  #
  # When ~/Personal is locked the path still exists as an empty directory, so a
  # wrapper that ran anyway would write an unencrypted config there — which then
  # disappears behind the real mount next time it's unlocked. Refuse instead.
  requireVault = cmd: ''
    ${pkgs.util-linux}/bin/mountpoint -q "$HOME/Personal" || {
      echo "${cmd}: ~/Personal is locked — run 'unlock-personal' first." >&2
      exit 1
    }
  '';
in
{
  home.file = {
    # Screenshot to a file and the clipboard, with no annotation step (the
    # Satty binds cover that). "full" grabs the whole output; no argument lets
    # you select a region.
    ".local/bin/screenshot-save" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Pictures points inside ~/Personal, so fall back to a plain
        # ~/Pictures when that's locked rather than writing into the empty
        # mountpoint. The notification shows wherever it ended up.
        pics="$HOME/Pictures"
        [ -r "$HOME/.config/user-dirs.dirs" ] && . "$HOME/.config/user-dirs.dirs" && pics="''${XDG_PICTURES_DIR:-$pics}"
        case "$pics" in
          "$HOME/Personal"/*) mountpoint -q "$HOME/Personal" 2>/dev/null || pics="$HOME/Pictures" ;;
        esac
        dir="$pics/Screenshots"
        mkdir -p "$dir"
        file="$dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
        case "$1" in
          full) grim "$file" ;;
          # slurp exits non-zero on Escape, so bail out without writing.
          *)    geom=$(slurp) || exit 0
                grim -g "$geom" "$file" ;;
        esac
        wl-copy --type image/png < "$file"
        notify-send -i "$file" "Screenshot saved" "$file"
      '';
    };

    # Searchable list of niri keybindings, read out of the live niri config and
    # shown in tofi. Prefers each bind's hotkey-overlay-title, falling back to
    # the raw action. The selection is thrown away — this only displays.
    ".local/bin/niri-keys" = {
      executable = true;
      text = ''
        #!/bin/sh
        config="$HOME/.config/niri/config.kdl"
        awk '
          function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }
          /^binds[ \t]*\{/ { inb=1; next }
          inb && /^\}/      { inb=0; next }
          inb {
            l=trim($0)
            if (l ~ /^\/\// || l=="" || l !~ /\{/) next
            key=l; sub(/[ \t{].*/,"",key)
            if (match(l, /hotkey-overlay-title="[^"]*"/)) {
              d=substr(l,RSTART,RLENGTH); sub(/^hotkey-overlay-title="/,"",d); sub(/"$/,"",d)
            } else {
              d=l; sub(/^[^{]*\{/,"",d); sub(/\}[^}]*$/,"",d); gsub(/[\\"]/,"",d)
              d=trim(d); sub(/;$/,"",d); d=trim(d)
            }
            printf "%-26s  →  %s\n", key, d
          }
        ' "$config" | tofi --config "$HOME/.config/tofi/cheatsheet" >/dev/null
      '';
    };

    # Unicode picker. Lists selected blocks as "glyph U+XXXX NAME" so you can
    # search by meaning ("arrow", "euro") as well as codepoint; the choice is
    # copied to the clipboard.
    #
    # Queries are `block:NAME` or `cat:NAME`, abbreviations allowed. Edit the
    # list below to taste — `uni list blocks` shows what's available.
    ".local/bin/unicode-symbols" = {
      executable = true;
      text = ''
        #!/bin/sh
        sel=$(uni print -c -f '%(char)  %(cpoint l:auto)  %(name)' \
          block:arrows \
          block:'supplemental arrows-a' \
          block:'mathematical operators' \
          block:'miscellaneous mathematical symbols-a' \
          cat:'Currency Symbol' \
          block:'letterlike symbols' \
          block:'general punctuation' \
          block:'superscripts and subscripts' \
          block:'miscellaneous symbols' \
          block:'dingbats' \
          block:'geometric shapes' \
          block:'box drawing' \
          block:'block elements' \
          block:'greek and coptic' \
          | tofi --config "$HOME/.config/tofi/cheatsheet" \
                 --prompt-text "symbol ❯ " --placeholder-text "search unicode…")

        # tofi echoes the whole line; the glyph is the first field. Empty
        # output means Escape.
        [ -z "$sel" ] && exit 0
        glyph=$(printf '%s' "$sel" | cut -d' ' -f1)
        printf '%s' "$glyph" | wl-copy
        notify-send "Copied to clipboard" "$sel"
      '';
    };

    # Apply an OpenTabletDriver preset — a saved display mapping plus button
    # bindings. Create them in otd-gui (Presets → Save As); this only applies
    # them.
    #
    #   tablet-preset <name>   apply it
    #   tablet-preset          pick from a menu
    #
    # Bound to Mod+Alt+T. Commands are unqualified here because niri binds
    # inherit the session PATH.
    ".local/bin/tablet-preset" = {
      executable = true;
      text = ''
        #!/bin/sh
        presets="$HOME/.config/OpenTabletDriver/Presets"
        name="$1"

        if [ -z "$name" ]; then
          # One <name>.json per preset. The [ -e ] guard stops the glob being
          # passed through literally when nothing matches.
          list=$(cd "$presets" 2>/dev/null && for f in *.json; do
            [ -e "$f" ] && printf '%s\n' "''${f%.json}"
          done)
          if [ -z "$list" ]; then
            notify-send -a OpenTabletDriver "Tablet preset" \
              "No presets yet — open otd-gui and save one (Presets → Save As)."
            exit 1
          fi
          # Same wide tofi theme as the cheatsheet, with different prompts.
          name=$(printf '%s\n' "$list" | tofi --config "$HOME/.config/tofi/cheatsheet" \
            --prompt-text "tablet preset ❯ " --placeholder-text "pick a preset…")
          [ -n "$name" ] || exit 0   # Escape / empty selection → do nothing
        fi

        if otd applypreset "$name"; then
          notify-send -a OpenTabletDriver "Tablet preset" "Applied: $name"
        else
          notify-send -u critical -a OpenTabletDriver "Tablet preset" \
            "Failed to apply: $name"
        fi
      '';
    };

    # Load every private key in ~/.ssh into the agent.
    ".local/bin/ssh-add-all.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        for key in "$HOME"/.ssh/id_*; do
          case "$key" in
            *.pub) continue ;;
          esac
          ssh-add "$key" 2>/dev/null
        done
      '';
    };

    # Body lives in raw/scripts/ so home/tty.nix can share it.
    ".local/bin/git-mkversion" = {
      executable = true;
      source = ../raw/scripts/git-mkversion.sh;
    };

    # Rename the focused niri workspace via a tofi prompt.
    # --require-match=false turns tofi into a plain input box. Empty input
    # changes nothing. Names set this way are lost when niri restarts — use
    # `workspace "name"` blocks in the niri config for permanent ones.
    ".local/bin/niri-rename-workspace" = {
      executable = true;
      text = ''
        #!/bin/sh
        name=$(tofi --config "$HOME/.config/tofi/prompt" \
          --prompt-text "rename workspace ❯ " --require-match=false </dev/null)
        [ -n "$name" ] && niri msg action set-workspace-name "$name"
      '';
    };

    # Remove empty named niri workspaces, so they behave like numbered ones.
    #
    # niri drops unnamed workspaces when they empty but keeps named ones
    # forever. An emptied named workspace stays in the scroll order — hidden in
    # the bar, but focus-workspace-down still lands on it. This watches the
    # event stream and unsets the name of any named workspace that's empty and
    # not the one you're on; once unnamed, niri removes it itself.
    #
    # The jq filter wants workspaces that are named, have no windows, and are
    # neither visible nor focused. Skipping the focused one means a workspace
    # you've just emptied keeps its name until you leave it, then gets cleaned
    # up when WorkspaceActivated fires.
    #
    # Only three events are worth reacting to. WindowOpenedOrChanged also fires
    # on every title change, which would be constant churn for nothing.
    #
    # It emits the workspace name rather than its id, because
    # unset-workspace-name resolves references by index or name — an internal id
    # matches nothing and silently does nothing. Run as a service, see
    # home/services.nix.
    ".local/bin/niri-workspace-autoclean" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Used once at startup and again on every relevant event.
        sweep() {
          niri msg -j workspaces | jq -r '
            .[]
            | select(.name != null
                     and .active_window_id == null
                     and (.is_active  | not)
                     and (.is_focused | not))
            | .name' \
          | while read -r name; do
              niri msg action unset-workspace-name "$name" || true
            done
        }

        # Sweep once at startup, catching anything emptied while this was down.
        sweep

        # Then follow the stream. The unit restarts if it ends or stalls (see
        # services.nix), and each restart re-runs the sweep above.
        niri msg -j event-stream \
          | grep --line-buffered -E 'WindowClosed|WorkspacesChanged|WorkspaceActivated' \
          | while read -r _; do
              sweep
            done
      '';
    };

    # One-shot OneDrive sync of ~/QPerfect with desktop notifications. Also the
    # manual command: running `onedrive-sync` syncs immediately, whatever is
    # open. The "skip while an editor is running" check is in the
    # onedrive-sync-ifidle unit, not here.
    #
    # flock stops a manual run and a timer run overlapping.
    #
    # Full store paths because systemd timers run with a much smaller PATH than
    # an interactive shell — onedrive isn't on the login PATH at all.
    ".local/bin/onedrive-sync" = {
      executable = true;
      text = ''
        #!/bin/sh
        lock="$HOME/.cache/onedrive-sync.lock"
        exec 9>"$lock"
        if ! ${pkgs.util-linux}/bin/flock -n 9; then
          ${pkgs.libnotify}/bin/notify-send -a OneDrive "OneDrive sync" "Already running — skipped this trigger"
          exit 0
        fi
        ${pkgs.libnotify}/bin/notify-send -a OneDrive "OneDrive sync" "Starting…  (best to pause edits in ~/QPerfect)"
        if ${pkgs.onedrive}/bin/onedrive --sync; then
          ${pkgs.libnotify}/bin/notify-send -a OneDrive "OneDrive sync" "Finished ✓"
        else
          ${pkgs.libnotify}/bin/notify-send -u critical -a OneDrive "OneDrive sync" "Failed ✗ — journalctl --user -u 'onedrive-sync*'"
        fi
      '';
    };

    # Condition for the half-hourly timer: exit non-zero and systemd skips that
    # run without marking it failed. The 04:00 sync and the manual command don't
    # use this.
    #
    # Syncing is unsafe while an app that continuously writes ~/QPerfect is
    # being used — but merely being open isn't a problem, only active editing.
    # So this first asks whether the session is idle: hypridle creates
    # ~/.cache/user-idle after a couple of minutes without input and deletes it
    # the moment you touch anything (raw/hypr/hypridle.conf).
    # If the marker exists you've stepped away, so the sync goes ahead even with
    # Logseq open. The editor checks below only apply when you're at the machine.
    ".local/bin/onedrive-sync-guard" = {
      executable = true;
      text = ''
        #!/bin/sh
        [ -e "$HOME/.cache/user-idle" ] && exit 0   # idle → nobody editing → safe
        ${pkgs.procps}/bin/pgrep -f 'share/logseq/resources/app' >/dev/null && exit 1  # Logseq
        ${pkgs.procps}/bin/pgrep -x soffice.bin                    >/dev/null && exit 1  # LibreOffice
        exit 0
      '';
    };

    # ── Personal-account wrappers for the AI CLIs ─────────────────────────
    # Same binaries as the bare `claude` / `codex` / `gemini`, but with their
    # config inside ~/Personal. Bare command is the work account, `-personal` is
    # the personal one; they share no credentials or history and can run side by
    # side. Each needs its own login once.

    # These two read their config directory from an environment variable, so
    # redirecting them is a one-liner.
    ".local/bin/claude-personal" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${requireVault "claude-personal"}
        export CLAUDE_CONFIG_DIR="$HOME/Personal/.claude"
        mkdir -p "$CLAUDE_CONFIG_DIR"
        exec ${pkgs.claude-code}/bin/claude "$@"
      '';
    };

    ".local/bin/codex-personal" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${requireVault "codex-personal"}
        export CODEX_HOME="$HOME/Personal/.codex"
        mkdir -p "$CODEX_HOME"
        exec ${pkgs.codex}/bin/codex "$@"
      '';
    };

    # Gemini has no such variable — it hardcodes ~/.gemini. Overriding $HOME
    # would also hide the git identity and SSH keys from anything it shells out
    # to, so instead bubblewrap swaps just that one directory: --dev-bind passes
    # the filesystem through unchanged, then --bind puts the vault copy over
    # ~/.gemini.
    #
    # That swap only exists inside this process and its children, so a plain
    # `gemini` elsewhere still sees the real directory.
    ".local/bin/gemini-personal" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${requireVault "gemini-personal"}
        dir="$HOME/Personal/.gemini"
        # bwrap needs both paths to exist before binding one over the other.
        mkdir -p "$dir" "$HOME/.gemini"
        exec ${pkgs.bubblewrap}/bin/bwrap \
          --dev-bind / / \
          --bind "$dir" "$HOME/.gemini" \
          -- ${pkgs.gemini-cli}/bin/gemini "$@"
      '';
    };

    # ── Mounting the portable SSD for maintenance ─────────────────────────
    # Mounts the SSD at /mnt as its own config describes it, so you can
    # `sudo nixos-enter --root /mnt` and repair or rebuild the installation.
    #
    # The udiskie mounts under /run/media are no good for this: they mount the
    # btrfs top level instead of the subvolumes, add nosuid and nodev which
    # break a chroot, and name the containers after their UUIDs.
    #
    # The mounting itself is done by disko, from system/disko-nomad.nix, so
    # these can't disagree with the actual layout.
    ".local/bin/nomad-mount" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # The drive's serial, same as in system/disko-nomad.nix, so this can't
        # resolve to the internal disk.
        DISK=/dev/disk/by-id/ata-CT500P3PSSD8_2401463EF214
        FLAKE="''${FLAKE:-$HOME/dotfiles}"

        if [ ! -e "$DISK" ]; then
          echo "nomad-mount: SSD not attached ($DISK)" >&2
          exit 1
        fi
        if ${pkgs.util-linux}/bin/mountpoint -q /mnt; then
          echo "nomad-mount: /mnt is already a mountpoint — run nomad-umount first." >&2
          exit 1
        fi

        # udiskie would mount the filesystems as disko opens them.
        if systemctl --user is-active --quiet udiskie; then
          echo "==> stopping udiskie (nomad-umount restarts it)"
          systemctl --user stop udiskie
        fi

        # Release anything udisks holds. Only children of $DISK, so this can
        # never close this machine's own encrypted volumes.
        crypt_children() {
          ${pkgs.util-linux}/bin/lsblk -rno NAME,TYPE "$DISK" | ${pkgs.gawk}/bin/awk '$2=="crypt"{print $1}'
        }
        for name in $(crypt_children); do
          dev="/dev/mapper/$name"
          mp=$(${pkgs.util-linux}/bin/findmnt -nlo TARGET "$dev" || true)
          if [ -n "$mp" ]; then
            echo "==> unmounting $mp"
            udisksctl unmount -b "$dev" >/dev/null || sudo ${pkgs.util-linux}/bin/umount "$dev"
          fi
          echo "==> closing $name"
          sudo ${pkgs.cryptsetup}/bin/cryptsetup close "$name"
        done

        echo "==> mounting via disko (asks for the LUKS passphrase)"
        script=$(nix build --no-link --print-out-paths \
          "$FLAKE#nixosConfigurations.nomad.config.system.build.mountScript")
        sudo "$script"

        echo
        ${pkgs.util-linux}/bin/findmnt -R /mnt || true
        echo
        echo "Ready. Enter the installed system with:"
        echo "  sudo nixos-enter --root /mnt"
      '';
    };

    ".local/bin/nomad-umount" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        DISK=/dev/disk/by-id/ata-CT500P3PSSD8_2401463EF214

        if ${pkgs.util-linux}/bin/mountpoint -q /mnt; then
          echo "==> unmounting /mnt recursively"
          sudo ${pkgs.util-linux}/bin/umount -R /mnt
        fi

        # Only containers on the SSD, never this machine's root or swap.
        if [ -e "$DISK" ]; then
          for name in $(${pkgs.util-linux}/bin/lsblk -rno NAME,TYPE "$DISK" \
                          | ${pkgs.gawk}/bin/awk '$2=="crypt"{print $1}'); do
            echo "==> closing $name"
            sudo ${pkgs.cryptsetup}/bin/cryptsetup close "$name"
          done
        fi

        if ! systemctl --user is-active --quiet udiskie; then
          echo "==> restarting udiskie"
          systemctl --user start udiskie
        fi
        echo "Done — safe to unplug."
      '';
    };
  };
}
