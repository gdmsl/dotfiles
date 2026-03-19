# Git worktree: remove a worktree
# Usage: gwr [path] (defaults to current directory)
function gwr --description "Remove a git worktree"
    set -l wt_path (pwd)
    if test -n "$argv[1]"
        set wt_path $argv[1]
    end

    # Go back to main worktree before removing
    set -l main_wt (git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
    cd "$main_wt"
    git worktree remove "$wt_path"
end
