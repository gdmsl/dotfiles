# Git worktree: toggle between main and the latest worktree
function gwm --description "Toggle between main and latest git worktree"
    set -l worktrees (git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')
    set -l main_wt $worktrees[1]
    set -l current (pwd)

    if test "$current" = "$main_wt"
        # Go to the last worktree
        set -l latest $worktrees[-1]
        if test "$latest" != "$main_wt"
            cd "$latest"
        else
            echo "No other worktrees"
        end
    else
        cd "$main_wt"
    end
end
