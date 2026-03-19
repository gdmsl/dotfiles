# Git worktree: fuzzy-pick a worktree with fzf
function gwl --description "Fuzzy-pick a git worktree"
    set -l wt (git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | fzf --height=40% --reverse)
    if test -n "$wt"
        cd "$wt"
    end
end
