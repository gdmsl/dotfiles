# Rebuild and update the system

    sudo nixos-rebuild switch --flake ~/dotfiles#yara   # whole system
    home-manager switch --flake ~/dotfiles#gdmsl         # user env only
    nix flake update                                     # bump inputs
    nix flake lock --update-input nixpkgs                # bump one input

New file not picked up by the flake? `git add` it: flakes only see
tracked files.

Roll back: `sudo nixos-rebuild switch --rollback`, or pick an older
generation in the boot menu.
