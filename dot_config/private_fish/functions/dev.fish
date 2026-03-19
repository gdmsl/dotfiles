# Focus the "dev" workspace and spawn a terminal if none exists (niri IPC)
function dev --description "Focus dev workspace, spawn terminal if empty"
    niri msg action focus-workspace "dev" 2>/dev/null
    # Check if there's already a window on the dev workspace
    set -l windows (niri msg --json windows 2>/dev/null | jq '[.[] | select(.workspace_name == "dev")] | length')
    if test "$windows" = "0" -o -z "$windows"
        niri msg action spawn -- kitty
    end
end
