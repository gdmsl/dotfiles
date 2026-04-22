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

    # Command to generate new versions in git
    ".local/bin/git-mkversion" = {
      executable = true;
      text = ''
        #!/bin/bash

        # Function to display usage
        usage() {
            echo "Usage: $0 [-p remote] [-h] branch version"
            echo "  -p remote   Specify a remote repository to push to."
            echo "  -h          Display this help message."
            exit 1
        }

        # Check if -h was used
        if [[ "$1" == "-h" ]]; then
            usage
        fi

        # Initialize variables
        remote=""
        branch=""
        version=""

        # Parse options
        while getopts "p:h" opt; do
            case $opt in
            p)
                remote=$OPTARG
                ;;
            h)
                usage
                ;;
            \?)
                usage
                ;;
            esac
        done

        # Shift arguments to get branch and version
        shift $((OPTIND - 1))

        # Assign remaining arguments to branch and version
        branch=$1
        version=$2

        # Check if branch and version are provided
        if [ -z "$branch" ] || [ -z "$version" ]; then
            usage
        fi

        # Checkout the specified branch
        if ! git checkout "$branch"; then
            echo "Failed to checkout branch $branch"
            exit 1
        fi

        # Merge --squash devel
        if ! git merge --squash devel; then
            echo "Failed to merge devel into $branch"
            echo "Opening interactive shell for resolution."
            echo "Remember to change version number."
            if ! $SHELL; then
                echo "Something whent wrong with the interactive shell. Exiting."
                exit 1
            fi
        else
            echo "Merge successful"
            echo "Opening interactive shell for changing version number."
            if ! $SHELL; then
                echo "Something whent wrong with the interactive shell. Exiting."
                exit 1
            fi
        fi

        # Commit the changes
        if ! git commit -am "chore(version): $version"; then
            echo "Failed to commit changes"
            exit 1
        fi

        # Tag the version
        if ! git tag "$version"; then
            echo "Failed to tag version $version"
            exit 1
        fi

        # Push changes
        if ! git push; then
            echo "Failed to push changes"
            exit 1
        fi

        # Push tags
        if ! git push --tags; then
            echo "Failed to push tags"
            exit 1
        fi

        # Push to remote if specified
        if [ -n "$remote" ]; then
            if ! git push "$remote" "$branch"; then
                echo "Failed to push branch $branch to remote $remote"
                exit 1
            fi

            if ! git push "$remote" "$version"; then
                echo "Failed to push version $version to remote $remote"
                exit 1
            fi
        fi

        # Checkout devel and merge the branch

        if ! git checkout devel; then
            echo "Failed to checkout branch devel"
            exit 1
        fi

        if ! git merge "$branch"; then
            echo "Merge conflict detected. Opening interactive shell for resolution."
            $SHELL
            echo "After resolving conflicts, continue the script manually:"
            echo "git commit -am 'Merge branch $branch into devel'"
            echo "git log --graph --oneline --all --decorate"
            exit 1
        fi

        # Display the graph of the git repository and branches
        git log --graph --oneline --all --decorate

        echo "Version $version has been successfully created, pushed, and merged back into devel."
      '';
    };
  };
}
