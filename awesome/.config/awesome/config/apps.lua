--
-- Default applications and commands
--

local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "nano"

local apps = {
    terminal = terminal,
    editor = editor,
    editor_cmd = terminal .. " -e " .. editor
}

return apps
