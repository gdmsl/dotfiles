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
        dir="$HOME/Pictures/Screenshots"
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

    # Delete a clipboard entry — fuzzy-search and remove from history
    ".local/bin/cliphist-delete" = {
      executable = true;
      text = ''
        #!/bin/sh
        cliphist list | tofi --prompt-text "delete: " | cliphist delete
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
  };
}
