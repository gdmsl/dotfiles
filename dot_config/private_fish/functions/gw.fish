# Git worktree: create or switch to a branch worktree
# Usage: gw <branch>
function gw --description "Create or switch to a git worktree"
    set -l branch $argv[1]
    if test -z "$branch"
        echo "Usage: gw <branch>"
        return 1
    end

    set -l repo (basename (git rev-parse --show-toplevel 2>/dev/null))
    set -l wt_base "$HOME/projects/git-worktrees/$repo"

    set -l wt_path "$wt_base/$branch"
    if test -d "$wt_path"
        cd "$wt_path"
    else
        git worktree add "$wt_path" -b "$branch" 2>/dev/null
        or git worktree add "$wt_path" "$branch"
        cd "$wt_path"
    end
end
