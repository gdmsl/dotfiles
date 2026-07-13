# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  scripts.nix — Custom shell scripts in ~/.local/bin                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Small utility scripts deployed to ~/.local/bin (which is on $PATH).
#
# Using `home.file` with `executable = true` and inline `text` is a convenient
# way to manage small scripts. The `text` attribute uses Nix multi-line strings
# (delimited by '' ... '') — note that Nix escapes '' sequences, so `''$` is
# used to write a literal `$` in some contexts.

{ config, pkgs, ... }:

{
  home.file = {
    # Quick screenshot — capture, save to disk, AND copy to the clipboard, with
    # no annotation step (that's what the Satty binds are for). Pass "full" to
    # grab the whole output; with no argument it lets you select a region.
    #   grim   captures the pixels    (region via -g, or the full screen)
    #   wl-copy puts the PNG on the clipboard so you can paste it immediately
    #   notify-send confirms, using the shot itself as the notification icon
    ".local/bin/screenshot-save" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Resolve the Pictures dir from the XDG user-dirs config. It points into
        # the encrypted ~/Personal vault, so if that vault is locked (unmounted)
        # fall back to a plain ~/Pictures rather than writing into the bare
        # mountpoint. The notification below always shows the final path.
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
          # slurp returns the selected geometry; a non-zero exit means the
          # user pressed Escape, so we bail out without writing a file.
          *)    geom=$(slurp) || exit 0
                grim -g "$geom" "$file" ;;
        esac
        wl-copy --type image/png < "$file"
        notify-send -i "$file" "Screenshot saved" "$file"
      '';
    };

    # Searchable cheat-sheet of niri keybindings. Parses the binds {} block of
    # the live niri config and shows "key  →  description" lines in tofi, where
    # you can fuzzy-search them. For each bind it prefers the hotkey-overlay-title
    # (the human label), falling back to the raw action when there's no title.
    # Styling lives in the dedicated tofi/cheatsheet theme (a wide, centred panel
    # in a monospace font so the columns align). The selection is discarded
    # (>/dev/null) — this is a viewer, not a launcher.
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

    # Searchable unicode symbol picker. Lists a curated set of useful blocks
    # (arrows, maths, currency, punctuation, symbols, shapes, box-drawing, …)
    # as "glyph  U+XXXX  OFFICIAL NAME" lines via the `uni` CLI, and shows them
    # in the same wide tofi panel as the keybinding cheat-sheet. Because the
    # official Unicode name is on every line you can fuzzy-search by meaning
    # ("arrow", "euro", "heart") as well as by codepoint. Selecting a row copies
    # just the glyph to the clipboard (wl-copy), ready to paste anywhere.
    #
    # `uni print` query syntax: `block:NAME` / `cat:NAME` (names may be
    # abbreviated). Add or remove blocks below to taste; `uni list blocks`
    # shows every block name.
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

        # tofi echoes the whole chosen line; the glyph is the first field
        # (everything before the first space). Empty means Escape was pressed.
        [ -z "$sel" ] && exit 0
        glyph=$(printf '%s' "$sel" | cut -d' ' -f1)
        printf '%s' "$glyph" | wl-copy
        notify-send "Copied to clipboard" "$sel"
      '';
    };

    # Add all private SSH keys to the SSH agent
    ".local/bin/ssh-add-all.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Add all private keys to the SSH agent
        for key in "$HOME"/.ssh/id_*; do
          case "$key" in
            *.pub) continue ;;
          esac
          ssh-add "$key" 2>/dev/null
        done
      '';
    };

    # Command to generate new versions in git. Body lives in raw/scripts/
    # so it can be shared with the headless tty profile (home/tty.nix).
    ".local/bin/git-mkversion" = {
      executable = true;
      source = ../raw/scripts/git-mkversion.sh;
    };

    # Rename the focused niri workspace. Pops a tofi prompt and feeds whatever
    # you type to `set-workspace-name`. tofi normally forces a choice from its
    # list; --require-match=false makes it return the typed text (the list is
    # empty here, so it's a plain input box). Empty input — Escape, or Enter on
    # an empty box — leaves the name untouched. Names are dynamic and reset when
    # niri restarts; use static `workspace "name"` blocks in config to persist.
    ".local/bin/niri-rename-workspace" = {
      executable = true;
      text = ''
        #!/bin/sh
        name=$(tofi --config "$HOME/.config/tofi/prompt" \
          --prompt-text "rename workspace ❯ " --require-match=false </dev/null)
        [ -n "$name" ] && niri msg action set-workspace-name "$name"
      '';
    };

    # Auto-clean empty *named* niri workspaces so they behave like numbered ones.
    #
    # niri only auto-removes *unnamed* (dynamic) workspaces when they empty;
    # named workspaces are persistent and stick around forever, even empty. That
    # leaves an emptied named workspace in the scroll order — the bar hides it,
    # but `focus-workspace-down`/up still lands on it. This daemon closes that
    # gap: it watches the compositor event stream and, when a named workspace is
    # empty *and* you're not on it, unsets its name. An unnamed empty workspace
    # is dynamic, so niri then drops it on its own.
    #
    # The jq filter picks workspaces that are:
    #   name != null            → don't touch the trailing unnamed scratch ws
    #   active_window_id == null → empty (no windows)
    #   not is_active           → not the visible ws on its monitor
    #   not is_focused          → not the keyboard-focused ws
    # Skipping the active/focused ws means an emptied workspace survives while
    # you're standing on it (so you don't lose the name mid-use) and is cleaned
    # up the moment you leave — WorkspaceActivated fires then and re-runs the
    # check, exactly mirroring how empty numbered workspaces already behave.
    #
    # We only react to the three events that can change emptiness/where you are,
    # deliberately ignoring WindowOpenedOrChanged (it also fires on every window
    # title change, which would be needless churn). Runs as a systemd user
    # service — see home/services.nix.
    #
    # We emit the workspace *name* (not the numeric id): unset-workspace-name
    # takes a REFERENCE, which niri resolves as an index-or-name — passing the
    # internal id just matches nothing and silently no-ops. `read -r name` with a
    # single variable captures the whole line, so names containing spaces survive.
    ".local/bin/niri-workspace-autoclean" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Unset the name of every empty workspace we're not standing on, so niri
        # drops it. Used both once at startup and on every relevant event.
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

        # Reconcile once on (re)start — catches anything emptied while the reader
        # was down (a systemd relaunch, or the periodic RuntimeMaxSec recycle).
        sweep

        # Then react to live events. When the stream ends OR silently stalls, the
        # unit is relaunched (Restart=always + RuntimeMaxSec, see services.nix),
        # which re-runs the startup sweep above — that's what makes this recover
        # instead of wedging forever, as a bare long-lived reader eventually does.
        niri msg -j event-stream \
          | grep --line-buffered -E 'WindowClosed|WorkspacesChanged|WorkspaceActivated' \
          | while read -r _; do
              sweep
            done
      '';
    };

    # Run a one-shot OneDrive sync of ~/QPerfect, with start/finish desktop
    # notifications. THIS IS ALSO THE MANUAL COMMAND: run `onedrive-sync` from a
    # terminal to force a sync any time, regardless of what's open. The systemd
    # timers call it too — the "skip while an editor is open" gate lives in the
    # onedrive-sync-ifidle service (home/services.nix), not here, so invoking the
    # script directly always syncs.
    #
    # We do NOT use OneDrive's continuous --monitor: a live bidirectional syncer
    # thrashes files that editors are actively writing (that's what made Logseq
    # unusable). A short one-shot burst on a schedule keeps the collision window
    # tiny. flock serialises runs so a manual sync and a timer sync can't overlap
    # (the client refuses to run twice at once anyway).
    #
    # Binaries are referenced by full store path because systemd user timers run
    # with a leaner PATH than an interactive shell (onedrive isn't even on the
    # login PATH). D-Bus for notify-send is already in the user-service env.
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

    # Gate for the every-30-min timer: exit non-zero when it's unsafe to sync,
    # which makes systemd skip that run cleanly (ExecCondition semantics: exit 0
    # = proceed, exit 1–254 = skip, not fail). The 4am forced sync and the manual
    # command do NOT use this guard.
    #
    # "Unsafe" means a "fast editor" (an app that writes ~/QPerfect continuously
    # or holds locks) is *actively in use*, where a concurrent OneDrive write
    # risks corruption/conflicts. Crucially, an editor being *open* is not enough
    # — only active editing is risky. So we first check whether the session is
    # idle: hypridle drops ~/.cache/user-idle after ~2.5 min of no input and
    # removes it the instant you touch a key/mouse (see raw/hypr/hypridle.conf).
    # If that marker exists you've stepped away, nothing is being written, and we
    # let the sync through even with Logseq open. Only when you're actively at the
    # machine do the editor checks below apply. Add more matchers as needed.
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
  };
}
