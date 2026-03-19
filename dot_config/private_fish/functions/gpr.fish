# Git worktree: checkout a PR into a worktree via gh
# Usage: gpr <pr-number>
function gpr --description "Checkout a GitHub PR into a git worktree"
    set -l pr $argv[1]
    if test -z "$pr"
        echo "Usage: gpr <pr-number>"
        return 1
    end

    set -l repo (basename (git rev-parse --show-toplevel 2>/dev/null))
    set -l wt_base "$HOME/projects/git-worktrees/$repo"
    set -l wt_path "$wt_base/pr-$pr"

    if test -d "$wt_path"
        cd "$wt_path"
    else
        set -l branch (gh pr view $pr --json headRefName -q '.headRefName')
        git fetch origin "pull/$pr/head:$branch" 2>/dev/null
        git worktree add "$wt_path" "$branch"
        cd "$wt_path"
    end
end
