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
    # Interactive clipboard picker — fuzzy-search clipboard history with tofi
    ".local/bin/cliphist-pick" = {
      executable = true;
      text = ''
        #!/bin/sh
        cliphist list | tofi --prompt-text "clipboard: " | cliphist decode | wl-copy
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
  };
}
