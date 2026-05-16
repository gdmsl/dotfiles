-- Workspaces. See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--
-- The old hyprlang `workspace=1,monitor:eDP-1,default:true` row was generated
-- by nwg-displays. nwg-displays cannot write Lua; if you re-run it later,
-- it'll create a `workspaces.conf` you'll have to transcribe back here.

hl.workspace_rule({ workspace = 1, monitor = "eDP-1", default = true })
