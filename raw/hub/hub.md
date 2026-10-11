# Using and extending hub

Open with `hub` or Alt-h in fish. Tab switches Overview / Search.

Overview (←→ or h/l between panels, ↑↓ or j/k to move):
- Agents: enter cd's into the session's directory.
- Todos: enter edits at the line, space advances
  (TODO → DOING → DONE, LATER → NOW → DONE), x marks done,
  a adds a TODO to today's journal (tab picks the graph).
- Projects: enter cd, g lazygit, o opens the repo page.
  ~ changes, ↑ unpushed, ↓ unpulled, ! open MRs, # open issues.

Search: type to filter, enter puts the command on the prompt,
^d/^u scroll the preview, esc clears then goes back.

Everywhere: ^r refreshes all, q or ^c quits.

Extending, in `home/hub.nix` (rebuild after): graphs, projectRoots,
claudeDirs, codexHomes, gitlabHosts, and widgets (shell commands; first
stdout line = summary, rest = details, exit != 0 = red).

Private, in `~/Personal/.config/hub/local.toml` (live, no rebuild): same
layout as `~/.config/hub/config.toml` and merged over it. Services go here:

    [services]
    Jellyfin = "https://jellyfin.example"

Up means any HTTP answer below 500.

Cards: drop a Markdown file in `~/dotfiles/raw/hub/`. Live, no rebuild.
