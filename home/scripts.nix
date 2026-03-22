{ config, pkgs, ... }:

{
  home.file = {
    ".local/bin/cliphist-pick" = {
      executable = true;
      text = ''
        #!/bin/sh
        cliphist list | tofi --prompt-text "clipboard: " | cliphist decode | wl-copy
      '';
    };

    ".local/bin/cliphist-delete" = {
      executable = true;
      text = ''
        #!/bin/sh
        cliphist list | tofi --prompt-text "delete: " | cliphist delete
      '';
    };

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
