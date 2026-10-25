# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  neovim.nix — Neovim editor configuration (via nvf)                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Neovim configured through nvf, a framework for declaring the whole editor in
# Nix rather than writing init.lua. Plugins, LSP servers, keymaps and options are
# all attrsets under `programs.nvf.settings.vim`.
#
# What that buys: plugins and language servers are pinned by flake.lock, there's
# no plugin manager to run, and treesitter parsers are built by Nix — so no
# :TSInstall, and no plugin updates happening behind your back.
#
# The cost is that anything nvf doesn't have an option for needs `extraPlugins`
# or raw Lua via `luaConfigPre` / `luaConfigPost`, both used further down.

{ pkgs, inputs, ... }:

{
  # nvf's own Home Manager module, from the flake input.
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      # `vi` and `vim` both open Neovim.
      viAlias = true;
      vimAlias = true;

      # ── Editor options ───────────────────────────────────────────────
      options = {
        shiftwidth = 4;    # indent width
        tabstop = 4;       # tab display width
        # Make the Wayland clipboard the unnamed register, so plain `y` and `p`
        # share text with every other app — no `"+` prefix needed. Neovim picks
        # the provider itself: with WAYLAND_DISPLAY set it uses wl-copy/wl-paste,
        # so no explicit provider is needed here (see luaConfigPre for the
        # display-less fallback).
        #
        # The trade-off of "unnamedplus": deletes go to the clipboard too, so `d`
        # and `x` overwrite whatever you last copied. If that gets annoying, the
        # usual fix is to route small deletes to the black-hole register:
        #   { mode = ["n" "x"]; key = "x"; action = "\"_x"; }
        clipboard = "unnamedplus";
      };

      # ── Theme ────────────────────────────────────────────────────────
      theme = {
        enable = true;
        name = "onedark";
        style = "darker";
      };

      # ── LSP (Language Server Protocol) ───────────────────────────────
      # LSP provides IDE features: completion, go-to-definition, rename,
      # diagnostics, etc. Each language below enables its own LSP server.
      lsp.enable = true;

      # ── Treesitter ───────────────────────────────────────────────────
      # Treesitter provides syntax-aware highlighting, indentation, and
      # text objects. Parsers are installed via Nix (no :TSInstall needed).
      treesitter = {
        enable = true;
        autotagHtml = true;  # auto-close/rename HTML tags
      };

      # ── Language support ─────────────────────────────────────────────
      # Each language entry enables syntax, LSP, and/or formatting for
      # that language. nvf installs the required LSP servers from nixpkgs.
      languages = {
        clang = {                  # C/C++
          enable = true;
          lsp.enable = true;
        };
        rust = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        python = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "pyright" ];  # type-checking LSP
          };
          format.enable = true;
        };
        lua = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        bash = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        tex = {                    # LaTeX
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        cmake = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        typescript = {             # TypeScript/JavaScript
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        nix = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "nil" ];   # nil is a Nix LSP
          };
          format.enable = true;
        };
        julia = {
          enable = true;
          lsp.enable = true;
        };
      };

      # Julia LSP needs a custom startup command because it runs a Julia
      # script that instantiates the LanguageServer.jl package.
      lsp.servers.julials = {
        cmd = [
          "julia"
          "--project=@nvim-lspconfig"
          "--startup-file=no"
          "--history-file=no"
          "-e"
          ''
            using Pkg
            Pkg.instantiate()
            using LanguageServer
            depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
            project_path = let
                dirname(something(
                    Base.load_path_expand((
                        p = get(ENV, "JULIA_PROJECT", nothing);
                        p === nothing ? nothing : isempty(p) ? nothing : p
                    )),
                    Base.current_project(),
                    get(Base.load_path(), 1, nothing),
                    Base.load_path_expand("@v#.#"),
                ))
            end
            @info "Running language server" VERSION pwd() project_path depot_path
            server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
            server.runlinter = true
            run(server)
          ''
        ];
        filetypes = [ "julia" ];
        root_markers = [ "Project.toml" "JuliaProject.toml" ];
      };

      # Fetch missing flake inputs without asking. nvf sets this under
      # `nil.nix.autoArchive`, but nil reads it from `nix.flake`.
      lsp.servers.nil.settings.nil.nix.flake.autoArchive = true;

      # ── Formatter ────────────────────────────────────────────────────
      # conform-nvim is a lightweight formatter runner. It calls external
      # formatters (clang-format, black, etc.) on save or on demand.
      formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.cpp = [ "clang_format" ];
      };

      # ── Completion ───────────────────────────────────────────────────
      # blink-cmp provides autocompletion (LSP, buffer words, paths, etc.)
      autocomplete.blink-cmp.enable = true;

      # ── Files ────────────────────────────────────────────────────────
      # Oil opens a directory as a buffer: rename, create and delete files by
      # editing lines, then `:w`. `-` opens the parent directory. It also
      # replaces netrw, so `nvim .` lands in oil. For a sidebar tree there is
      # Snacks.explorer on <leader>e.
      utility.oil-nvim.enable = true;

      # ── Dashboard ────────────────────────────────────────────────────
      # Alpha: startup screen with recent files and shortcuts
      dashboard.alpha.enable = true;

      # ── UI ───────────────────────────────────────────────────────────
      statusline.lualine.enable = true;       # status bar at the bottom

      # ui2: Neovim 0.12's built-in message and cmdline UI (experimental).
      # Messages show in a small window in the bottom-right corner and fade
      # out, so there is no hit-enter prompt. `:messages` opens the full
      # history as a normal buffer.
      ui.ui2 = {
        enable = true;
        setupOpts.msg.targets = "msg";
      };

      tabline.nvimBufferline = {
        enable = true;                        # buffer tabs at the top
        # Hide the per-buffer ordinal indicator (the superscript "³·"
        # that was rendered before the file icon). Set to "ordinal",
        # "buffer_id", or "both" to bring it back.
        setupOpts.options.numbers = "none";
      };

      # ── Snacks ───────────────────────────────────────────────────────
      # folke's collection of small plugins. Most modules work on call
      # (Snacks.lazygit(), Snacks.terminal(), Snacks.explorer()); the picker
      # is enabled here too so it also replaces vim.ui.select, which is what
      # code actions and other prompts use. Picker keymaps are under <leader>s
      # and <leader>f below; inside a picker, <a-?> or ? lists its keys.
      utility.snacks-nvim = {
        enable = true;
        setupOpts.picker.enabled = true;
      };

      # ── Git ──────────────────────────────────────────────────────────
      # Gitsigns shows git diff indicators in the sign column
      git.gitsigns.enable = true;

      # ── Navigation & editing ─────────────────────────────────────────
      utility.motion.flash-nvim.enable = true;   # fast cursor motion (like hop/leap)
      utility.grug-far-nvim.enable = true;        # search and replace UI
      binds.whichKey.enable = true;               # popup showing available keybindings

      # ── Mini plugins ─────────────────────────────────────────────────
      # Mini is a collection of small, focused plugins:
      mini.ai.enable = true;      # enhanced text objects (around/inside)
      mini.icons.enable = true;   # icon provider for other plugins
      mini.pairs.enable = true;   # auto-close brackets and quotes
      # Add, delete and replace surrounding brackets, quotes and tags.
      # Flash owns `s`, so the maps use LazyVim's `gs` prefix:
      # `gsaiw"` surrounds a word with quotes, `gsd"` deletes them,
      # `gsr"'` turns them into single quotes.
      mini.surround = {
        enable = true;
        setupOpts.mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };

      # Detects each file's indent style from its contents, so the
      # shiftwidth/tabstop above only apply to new or ambiguous files.
      utility.guess-indent-nvim.enable = true;

      # ── Diagnostics ──────────────────────────────────────────────────
      diagnostics.nvim-lint.enable = true;    # async linting
      lsp.trouble.enable = true;              # diagnostics list panel
      notes.todo-comments.enable = true;      # highlight and list TODO/FIXME comments

      # ── Extra plugins (not available as nvf modules) ─────────────────
      # `extraPlugins` lets you add any Vim plugin from nixpkgs. The
      # `setup` field runs Lua code to configure the plugin.
      extraPlugins = {
        # Saves a session per directory on exit; never auto-loads, so plain
        # `nvim` still lands on the dashboard. Restore with <leader>qs.
        persistence-nvim = {
          package = pkgs.vimPlugins.persistence-nvim;
          setup = "require('persistence').setup()";
        };
        ts-comments-nvim = {
          package = pkgs.vimPlugins.ts-comments-nvim;
          setup = "require('ts-comments').setup()";
        };
        # Julia formatter plugin (not in nixpkgs, so we build it from GitHub)
        JuliaFormatter-vim = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "JuliaFormatter-vim";
            version = "unstable";
            src = pkgs.fetchFromGitHub {
              owner = "kdheepak";
              repo = "JuliaFormatter.vim";
              rev = "2db5c22703fae588dad8ef5d43559a1b235fa312";
              hash = "sha256-KcIAFw8Sthaqp2aTTG0MJQTJoO0N4AhS9BNnp9IstfM=";
            };
          };
        };
      };

      # ── Keymaps ──────────────────────────────────────────────────────
      # Each keymap is an attrset with mode, key, action, and optional desc.
      # Modes: "n" = normal, "i" = insert, "v" = visual, "x" = visual block.
      # <leader> is Space by default.
      keymaps = [
        # ── Window navigation (Ctrl+hjkl) ────────────────────────────
        { mode = "n"; key = "<C-h>"; action = "<C-w>h"; desc = "Go to left window"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w>j"; desc = "Go to lower window"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w>k"; desc = "Go to upper window"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w>l"; desc = "Go to right window"; }

        # ── Window resize ────────────────────────────────────────────
        { mode = "n"; key = "<C-Up>"; action = "<cmd>resize +2<cr>"; desc = "Increase window height"; }
        { mode = "n"; key = "<C-Down>"; action = "<cmd>resize -2<cr>"; desc = "Decrease window height"; }
        { mode = "n"; key = "<C-Left>"; action = "<cmd>vertical resize -2<cr>"; desc = "Decrease window width"; }
        { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<cr>"; desc = "Increase window width"; }

        # ── Move lines (Alt+jk) ─────────────────────────────────────
        { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<cr>=="; desc = "Move line down"; }
        { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<cr>=="; desc = "Move line up"; }
        { mode = "i"; key = "<A-j>"; action = "<esc><cmd>m .+1<cr>==gi"; desc = "Move line down"; }
        { mode = "i"; key = "<A-k>"; action = "<esc><cmd>m .-2<cr>==gi"; desc = "Move line up"; }
        { mode = "v"; key = "<A-j>"; action = ":m '>+1<cr>gv=gv"; desc = "Move selection down"; }
        { mode = "v"; key = "<A-k>"; action = ":m '<-2<cr>gv=gv"; desc = "Move selection up"; }

        # ── Better indenting (keeps selection) ───────────────────────
        { mode = "v"; key = "<"; action = "<gv"; }
        { mode = "v"; key = ">"; action = ">gv"; }

        # ── Save with Ctrl-S ────────────────────────────────────────
        { mode = [ "i" "x" "n" "s" ]; key = "<C-s>"; action = "<cmd>w<cr><esc>"; desc = "Save file"; }

        # ── Buffer navigation ────────────────────────────────────────
        { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<cr>"; desc = "Prev buffer"; }
        { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<cr>"; desc = "Next buffer"; }
        { mode = "n"; key = "[b"; action = "<cmd>BufferLineCyclePrev<cr>"; desc = "Prev buffer"; }
        { mode = "n"; key = "]b"; action = "<cmd>BufferLineCycleNext<cr>"; desc = "Next buffer"; }

        # ── Diagnostics navigation ───────────────────────────────────
        # ]d / [d are Neovim defaults.
        { mode = "n"; key = "]e"; action = "<cmd>lua vim.diagnostic.jump({count=1, float=true, severity=vim.diagnostic.severity.ERROR})<cr>"; desc = "Next error"; }
        { mode = "n"; key = "[e"; action = "<cmd>lua vim.diagnostic.jump({count=-1, float=true, severity=vim.diagnostic.severity.ERROR})<cr>"; desc = "Prev error"; }
        { mode = "n"; key = "]w"; action = "<cmd>lua vim.diagnostic.jump({count=1, float=true, severity=vim.diagnostic.severity.WARN})<cr>"; desc = "Next warning"; }
        { mode = "n"; key = "[w"; action = "<cmd>lua vim.diagnostic.jump({count=-1, float=true, severity=vim.diagnostic.severity.WARN})<cr>"; desc = "Prev warning"; }

        # ── Todo comments ────────────────────────────────────────────
        { mode = "n"; key = "]t"; action = "<cmd>lua require('todo-comments').jump_next()<cr>"; desc = "Next todo comment"; }
        { mode = "n"; key = "[t"; action = "<cmd>lua require('todo-comments').jump_prev()<cr>"; desc = "Previous todo comment"; }

        # ── File tree ────────────────────────────────────────────────
        { mode = "n"; key = "<leader>e"; action = "<cmd>lua Snacks.explorer()<cr>"; desc = "Explorer"; }
        { mode = "n"; key = "-"; action = "<cmd>Oil<cr>"; desc = "Open parent directory"; }

        # ── Find / Files (<leader>f) ─────────────────────────────────
        { mode = "n"; key = "<leader><space>"; action = "<cmd>lua Snacks.picker.files()<cr>"; desc = "Find files"; }
        { mode = "n"; key = "<leader>ff"; action = "<cmd>lua Snacks.picker.files()<cr>"; desc = "Find files"; }
        { mode = "n"; key = "<leader>fg"; action = "<cmd>lua Snacks.picker.git_files()<cr>"; desc = "Find files (git)"; }
        { mode = "n"; key = "<leader>fr"; action = "<cmd>lua Snacks.picker.recent()<cr>"; desc = "Recent files"; }
        { mode = "n"; key = "<leader>fb"; action = "<cmd>lua Snacks.picker.buffers()<cr>"; desc = "Buffers"; }
        { mode = "n"; key = "<leader>fn"; action = "<cmd>enew<cr>"; desc = "New file"; }

        # ── Search (<leader>s) ───────────────────────────────────────
        { mode = "n"; key = "<leader>/"; action = "<cmd>lua Snacks.picker.grep()<cr>"; desc = "Grep"; }
        { mode = "n"; key = "<leader>,"; action = "<cmd>lua Snacks.picker.buffers()<cr>"; desc = "Switch buffer"; }
        { mode = "n"; key = "<leader>:"; action = "<cmd>lua Snacks.picker.command_history()<cr>"; desc = "Command history"; }
        { mode = "n"; key = "<leader>sg"; action = "<cmd>lua Snacks.picker.grep()<cr>"; desc = "Grep"; }
        { mode = "n"; key = "<leader>sw"; action = "<cmd>lua Snacks.picker.grep_word()<cr>"; desc = "Word under cursor"; }
        { mode = "n"; key = "<leader>sb"; action = "<cmd>lua Snacks.picker.lines()<cr>"; desc = "Buffer lines"; }
        { mode = "n"; key = "<leader>sd"; action = "<cmd>lua Snacks.picker.diagnostics()<cr>"; desc = "Diagnostics"; }
        { mode = "n"; key = "<leader>sh"; action = "<cmd>lua Snacks.picker.help()<cr>"; desc = "Help"; }
        { mode = "n"; key = "<leader>sk"; action = "<cmd>lua Snacks.picker.keymaps()<cr>"; desc = "Keymaps"; }
        { mode = "n"; key = "<leader>sm"; action = "<cmd>lua Snacks.picker.marks()<cr>"; desc = "Marks"; }
        { mode = "n"; key = "<leader>sM"; action = "<cmd>lua Snacks.picker.man()<cr>"; desc = "Man pages"; }
        { mode = "n"; key = "<leader>sr"; action = "<cmd>lua Snacks.picker.resume()<cr>"; desc = "Resume search"; }
        { mode = "n"; key = "<leader>sc"; action = "<cmd>lua Snacks.picker.command_history()<cr>"; desc = "Command history"; }
        { mode = "n"; key = "<leader>sC"; action = "<cmd>lua Snacks.picker.commands()<cr>"; desc = "Commands"; }
        { mode = "n"; key = "<leader>s\""; action = "<cmd>lua Snacks.picker.registers()<cr>"; desc = "Registers"; }
        { mode = "n"; key = "<leader>ss"; action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>"; desc = "LSP symbols"; }
        { mode = "n"; key = "<leader>sS"; action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>"; desc = "LSP workspace symbols"; }

        # ── Messages ─────────────────────────────────────────────────
        { mode = "n"; key = "<leader>n"; action = "<cmd>messages<cr>"; desc = "Message history"; }

        # ── Git (<leader>g) ──────────────────────────────────────────
        { mode = "n"; key = "<leader>gg"; action = "<cmd>lua Snacks.lazygit()<cr>"; desc = "Lazygit"; }
        { mode = "n"; key = "<leader>gl"; action = "<cmd>lua Snacks.picker.git_log()<cr>"; desc = "Git log"; }
        { mode = "n"; key = "<leader>gs"; action = "<cmd>lua Snacks.picker.git_status()<cr>"; desc = "Git status"; }
        { mode = "n"; key = "<leader>gb"; action = "<cmd>lua Snacks.picker.git_branches()<cr>"; desc = "Git branches"; }

        # ── LSP / Code (<leader>c) ───────────────────────────────────
        { mode = "n"; key = "<leader>cd"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; desc = "Line diagnostics"; }
        { mode = [ "n" "x" ]; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; desc = "Code action"; }
        { mode = "n"; key = "<leader>cr"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; desc = "Rename"; }
        { mode = [ "n" "x" ]; key = "<leader>cf"; action = "<cmd>lua vim.lsp.buf.format({async=true})<cr>"; desc = "Format"; }
        { mode = "n"; key = "<leader>cl"; action = "<cmd>checkhealth vim.lsp<cr>"; desc = "LSP info"; }

        # ── Diagnostics / Trouble (<leader>x) ────────────────────────
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; desc = "Diagnostics"; }
        { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; desc = "Buffer diagnostics"; }
        { mode = "n"; key = "<leader>xl"; action = "<cmd>Trouble loclist toggle<cr>"; desc = "Location list"; }
        { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble qflist toggle<cr>"; desc = "Quickfix list"; }
        { mode = "n"; key = "<leader>xt"; action = "<cmd>Trouble todo toggle<cr>"; desc = "Todo (Trouble)"; }

        # ── Buffers (<leader>b) ──────────────────────────────────────
        { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<cr>"; desc = "Delete buffer"; }
        { mode = "n"; key = "<leader>bD"; action = "<cmd>bdelete!<cr>"; desc = "Delete buffer (force)"; }
        { mode = "n"; key = "<leader>bo"; action = "<cmd>BufferLineCloseOthers<cr>"; desc = "Delete other buffers"; }
        { mode = "n"; key = "<leader>bp"; action = "<cmd>BufferLineTogglePin<cr>"; desc = "Toggle pin"; }
        { mode = "n"; key = "<leader>bb"; action = "<cmd>e #<cr>"; desc = "Switch to other buffer"; }
        { mode = "n"; key = "<leader>`"; action = "<cmd>e #<cr>"; desc = "Switch to other buffer"; }

        # ── Windows (<leader>w) ──────────────────────────────────────
        { mode = "n"; key = "<leader>wd"; action = "<C-W>c"; desc = "Delete window"; }
        { mode = "n"; key = "<leader>-"; action = "<C-W>s"; desc = "Split below"; }
        { mode = "n"; key = "<leader>|"; action = "<C-W>v"; desc = "Split right"; }

        # ── Tabs (<leader><tab>) ─────────────────────────────────────
        { mode = "n"; key = "<leader><tab><tab>"; action = "<cmd>tabnew<cr>"; desc = "New tab"; }
        { mode = "n"; key = "<leader><tab>d"; action = "<cmd>tabclose<cr>"; desc = "Close tab"; }
        { mode = "n"; key = "<leader><tab>]"; action = "<cmd>tabnext<cr>"; desc = "Next tab"; }
        { mode = "n"; key = "<leader><tab>["; action = "<cmd>tabprevious<cr>"; desc = "Previous tab"; }

        # ── UI toggles (<leader>u) ───────────────────────────────────
        { mode = "n"; key = "<leader>us"; action = "<cmd>set spell!<cr>"; desc = "Toggle spelling"; }
        { mode = "n"; key = "<leader>uw"; action = "<cmd>set wrap!<cr>"; desc = "Toggle wrap"; }
        { mode = "n"; key = "<leader>ul"; action = "<cmd>set number!<cr>"; desc = "Toggle line numbers"; }
        { mode = "n"; key = "<leader>uL"; action = "<cmd>set relativenumber!<cr>"; desc = "Toggle relative numbers"; }
        { mode = "n"; key = "<leader>ud"; action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<cr>"; desc = "Toggle diagnostics"; }
        { mode = "n"; key = "<leader>uh"; action = "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>"; desc = "Toggle inlay hints"; }

        # ── Terminal (LazyVim-style toggle on Ctrl+/) ────────────────
        # Snacks' terminal opens a bottom split; <C-/> toggles it, and
        # while inside the terminal the same chord closes it. Terminals
        # usually send <C-_> for Ctrl+/ too, so bind both for portability.
        { mode = "n"; key = "<C-/>"; action = "<cmd>lua Snacks.terminal(nil, { win = { position = 'bottom', height = 0.35 } })<cr>"; desc = "Terminal"; }
        { mode = "n"; key = "<C-_>"; action = "<cmd>lua Snacks.terminal(nil, { win = { position = 'bottom', height = 0.35 } })<cr>"; desc = "Terminal"; }
        { mode = "t"; key = "<C-/>"; action = "<cmd>close<cr>"; desc = "Hide terminal"; }
        { mode = "t"; key = "<C-_>"; action = "<cmd>close<cr>"; desc = "Hide terminal"; }

        # ── Quit / Session (<leader>q) ───────────────────────────────
        { mode = "n"; key = "<leader>qq"; action = "<cmd>qa<cr>"; desc = "Quit all"; }
        { mode = "n"; key = "<leader>qs"; action = "<cmd>lua require('persistence').load()<cr>"; desc = "Restore session"; }
        { mode = "n"; key = "<leader>ql"; action = "<cmd>lua require('persistence').load({ last = true })<cr>"; desc = "Restore last session"; }
      ];

      # ── Lua config (runs before plugin setup) ────────────────────────
      luaConfigPre = ''
        -- Clipboard fallback for machines with no display server (the
        -- gdmsl-tty profile imports this same file over SSH).
        --
        -- Neovim autodetects wl-copy/wl-paste whenever WAYLAND_DISPLAY is set,
        -- which covers kitty, tmux and Neovide locally. It also has a built-in
        -- OSC 52 fallback that asks the terminal itself to hold the text — but
        -- that one only engages while 'clipboard' is empty, and we set it to
        -- unnamedplus above. Without this branch a remote yank would just warn
        -- "No provider". Selecting osc52 by name keeps `y` working over SSH.
        if vim.env.WAYLAND_DISPLAY == nil and vim.env.DISPLAY == nil then
          vim.g.clipboard = 'osc52'
        end

        -- Neovide-only settings.
        --
        -- Neovide sets `vim.g.neovide` when it attaches, so this whole block is
        -- inert under kitty and one config serves both UIs. These have to be
        -- Neovim variables rather than config.toml entries because Neovide
        -- re-reads them while running — assigning one at any time takes effect
        -- immediately, which is also how you'd toggle them from `:lua`.
        if vim.g.neovide then
          -- Animation lengths, in seconds. 0 disables an animation outright.
          vim.g.neovide_cursor_animation_length = 0.06    -- cursor glide
          vim.g.neovide_scroll_animation_length = 0.3     -- smooth scrolling
          vim.g.neovide_position_animation_length = 0.15  -- window/split moves

          -- Trail drawn behind the cursor as it moves between positions.
          -- Alternatives: "torpedo", "pixiedust", "sonicboom", "ripple",
          -- "wireframe", or "" for no effect.
          vim.g.neovide_cursor_vfx_mode = "railgun"

          vim.g.neovide_hide_mouse_when_typing = true
          vim.g.neovide_remember_window_size = true

          -- Window transparency. 1.0 is fully opaque.
          vim.g.neovide_opacity = 0.95
        end
      '';
    };
  };
}
