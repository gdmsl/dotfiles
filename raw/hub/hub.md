# Using and extending hub

Open with `hub`, or **Alt-h** in fish to put the picked command on the
prompt. `eval (hub)` runs it instead.

## Moving around

- `1`–`5`, `h`/`l` or Tab switch tabs: Dash, Agents, Commands, Git, Todos.
- `j`/`k` move, `gg`/`G` jump to the first or last row, `^d`/`^u` scroll the
  details.
- `/` filters the current tab; Enter keeps the filter, Esc clears it.
- Space searches every tab and jumps to the hit.
- `?` lists the keys of the current tab.

## Per tab

- **Agents**: Enter jumps to the session's kitty tab, `c` gives a `cd`.
- **Commands**: Enter fills in a cheat's variables, then prints it.
- **Git**: Enter `cd`, `L` lazygit, `o` opens the repo page. Columns: `~`
  changes, `↑` unpushed, `↓` unpulled, `!` open MRs, `#` open issues.
- **Todos**: Enter edits at the line, `t` advances (TODO → DOING → DONE),
  `x` marks done.
- Anywhere: `a` adds a TODO to today's journal, `y` copies, `r` refreshes.

## Extending

- **Cheats**: add a `.cheat` file in `~/dotfiles/raw/cheats/`. navi reads the
  same files. Live, no rebuild.
- **Cards** like this one: a Markdown file in `~/dotfiles/raw/hub/`. Live.
- **Widgets, graphs, project roots, agent dirs**: `home/hub.nix`, then
  rebuild.
- **Private**: `~/Personal/.config/hub/local.toml`, merged over the generated
  config. Services and host aliases go here:

  ```toml
  [services]
  Jellyfin = "https://jellyfin.example"

  [hosts]
  vestara = "git.example.org"
  ```
