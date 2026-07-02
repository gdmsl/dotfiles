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
  };
}
