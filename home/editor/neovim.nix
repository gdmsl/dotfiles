{ pkgs, lib, inputs, ... }:
let
  inherit (lib) mkForce;
in

{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      # ── Aliases ──────────────────────────────────────────────────────
      viAlias = true;
      vimAlias = true;

      # ── Options ──────────────────────────────────────────────────────
      options = {
        shiftwidth = 4;
        tabstop = 4;
        clipboard = "";
      };

      # ── Theme ────────────────────────────────────────────────────────
      theme = {
        enable = true;
        name = "onedark";
        style = "darker";
      };

      # ── LSP ──────────────────────────────────────────────────────────
      lsp.enable = true;

      # ── Treesitter ───────────────────────────────────────────────────
      treesitter = {
        enable = true;
        autotagHtml = true;
      };

      # ── Languages ────────────────────────────────────────────────────
      languages = {
        clang = {
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
            servers = [ "pyright" ];
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
        tex = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        cmake = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        ts = {
          enable = true;
          lsp.enable = true;
          format.enable = true;
        };
        nix = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "nil" ];
          };
          format.enable = true;
        };
        julia = {
          enable = true;
          lsp.enable = true;
        };
      };

      # Julia LSP needs a custom command
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

      # Clangd offset encoding
      lsp.servers.clangd.cmd = mkForce [ "clangd" "--offset-encoding=utf-16" ];

      # ── Formatter ────────────────────────────────────────────────────
      formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.cpp = [ "clang_format" ];
      };

      # ── Completion ───────────────────────────────────────────────────
      autocomplete.blink-cmp.enable = true;

      # ── Fuzzy finder ──────────────────────────────────────────────────
      telescope.enable = true;

      # ── File tree ────────────────────────────────────────────────────
      filetree.neo-tree.enable = true;

      # ── Dashboard ────────────────────────────────────────────────────
      dashboard.alpha.enable = true;

      # ── Session ──────────────────────────────────────────────────────
      session.nvim-session-manager.enable = true;

      # ── UI ───────────────────────────────────────────────────────────
      statusline.lualine.enable = true;
      tabline.nvimBufferline.enable = true;
      ui.noice.enable = true;
      utility.snacks-nvim.enable = true;

      # ── Git ──────────────────────────────────────────────────────────
      git.gitsigns.enable = true;

      # ── Navigation & editing ─────────────────────────────────────────
      utility.motion.flash-nvim.enable = true;
      utility.grug-far-nvim.enable = true;
      binds.whichKey.enable = true;

      # ── Mini ─────────────────────────────────────────────────────────
      mini.ai.enable = true;
      mini.icons.enable = true;
      mini.pairs.enable = true;

      # ── Diagnostics ──────────────────────────────────────────────────
      diagnostics.nvim-lint.enable = true;
      lsp.trouble.enable = true;
      notes.todo-comments.enable = true;

      # ── Yanky ────────────────────────────────────────────────────────
      utility.yanky-nvim = {
        enable = true;
        setupOpts = {
          highlight.timer = 150;
          ring.storage = "sqlite";
        };
      };

      # ── Extra plugins (no built-in module) ───────────────────────────
      extraPlugins = {
        plenary-nvim = { package = pkgs.vimPlugins.plenary-nvim; };
        persistence-nvim = {
          package = pkgs.vimPlugins.persistence-nvim;
          setup = "require('persistence').setup()";
        };
        ts-comments-nvim = {
          package = pkgs.vimPlugins.ts-comments-nvim;
          setup = "require('ts-comments').setup()";
        };
        JuliaFormatter-vim = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "JuliaFormatter-vim";
            version = "unstable";
            src = pkgs.fetchFromGitHub {
              owner = "kdheepak";
              repo = "JuliaFormatter.vim";
              rev = "main";
              hash = "sha256-KcIAFw8Sthaqp2aTTG0MJQTJoO0N4AhS9BNnp9IstfM=";
            };
          };
        };
      };

      # ── Keymaps ──────────────────────────────────────────────────────
      keymaps = [
        # ── Yanky ────────────────────────────────────────────────────
        { mode = [ "n" "x" ]; key = "y";  action = "<Plug>(YankyYank)"; }
        { mode = [ "n" "x" ]; key = "p";  action = "<Plug>(YankyPutAfter)"; }
        { mode = [ "n" "x" ]; key = "P";  action = "<Plug>(YankyPutBefore)"; }
        { mode = [ "n" "x" ]; key = "gp"; action = "<Plug>(YankyGPutAfter)"; }
        { mode = [ "n" "x" ]; key = "gP"; action = "<Plug>(YankyGPutBefore)"; }
        { mode = "n"; key = "<c-n>"; action = "<Plug>(YankyCycleForward)"; }
        { mode = "n"; key = "<c-p>"; action = "<Plug>(YankyCycleBackward)"; }
        { mode = "n"; key = "]p"; action = "<Plug>(YankyPutIndentAfterLinewise)"; }
        { mode = "n"; key = "[p"; action = "<Plug>(YankyPutIndentBeforeLinewise)"; }
        { mode = "n"; key = "]P"; action = "<Plug>(YankyPutIndentAfterLinewise)"; }
        { mode = "n"; key = "[P"; action = "<Plug>(YankyPutIndentBeforeLinewise)"; }
        { mode = "n"; key = ">p"; action = "<Plug>(YankyPutIndentAfterShiftRight)"; }
        { mode = "n"; key = "<p"; action = "<Plug>(YankyPutIndentAfterShiftLeft)"; }
        { mode = "n"; key = ">P"; action = "<Plug>(YankyPutIndentBeforeShiftRight)"; }
        { mode = "n"; key = "<P"; action = "<Plug>(YankyPutIndentBeforeShiftLeft)"; }
        { mode = "n"; key = "=p"; action = "<Plug>(YankyPutAfterFilter)"; }
        { mode = "n"; key = "=P"; action = "<Plug>(YankyPutBeforeFilter)"; }

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
        { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; desc = "Next diagnostic"; }
        { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; desc = "Prev diagnostic"; }
        { mode = "n"; key = "]e"; action = "<cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<cr>"; desc = "Next error"; }
        { mode = "n"; key = "[e"; action = "<cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<cr>"; desc = "Prev error"; }
        { mode = "n"; key = "]w"; action = "<cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.WARN})<cr>"; desc = "Next warning"; }
        { mode = "n"; key = "[w"; action = "<cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.WARN})<cr>"; desc = "Prev warning"; }

        # ── Todo comments ────────────────────────────────────────────
        { mode = "n"; key = "]t"; action = "<cmd>lua require('todo-comments').jump_next()<cr>"; desc = "Next todo comment"; }
        { mode = "n"; key = "[t"; action = "<cmd>lua require('todo-comments').jump_prev()<cr>"; desc = "Previous todo comment"; }

        # ── File tree ────────────────────────────────────────────────
        { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<cr>"; desc = "Explorer"; }
        { mode = "n"; key = "<leader>E"; action = "<cmd>Neotree reveal<cr>"; desc = "Explorer (reveal file)"; }

        # ── Find / Files (<leader>f) ─────────────────────────────────
        { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope find_files<cr>"; desc = "Find files"; }
        { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; desc = "Find files"; }
        { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope git_files<cr>"; desc = "Find files (git)"; }
        { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<cr>"; desc = "Recent files"; }
        { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; desc = "Buffers"; }
        { mode = "n"; key = "<leader>fn"; action = "<cmd>enew<cr>"; desc = "New file"; }

        # ── Search (<leader>s) ───────────────────────────────────────
        { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<cr>"; desc = "Grep"; }
        { mode = "n"; key = "<leader>,"; action = "<cmd>Telescope buffers<cr>"; desc = "Switch buffer"; }
        { mode = "n"; key = "<leader>:"; action = "<cmd>Telescope command_history<cr>"; desc = "Command history"; }
        { mode = "n"; key = "<leader>sg"; action = "<cmd>Telescope live_grep<cr>"; desc = "Grep"; }
        { mode = "n"; key = "<leader>sw"; action = "<cmd>Telescope grep_string<cr>"; desc = "Word under cursor"; }
        { mode = "n"; key = "<leader>sb"; action = "<cmd>Telescope current_buffer_fuzzy_find<cr>"; desc = "Buffer lines"; }
        { mode = "n"; key = "<leader>sd"; action = "<cmd>Telescope diagnostics<cr>"; desc = "Diagnostics"; }
        { mode = "n"; key = "<leader>sh"; action = "<cmd>Telescope help_tags<cr>"; desc = "Help"; }
        { mode = "n"; key = "<leader>sk"; action = "<cmd>Telescope keymaps<cr>"; desc = "Keymaps"; }
        { mode = "n"; key = "<leader>sm"; action = "<cmd>Telescope marks<cr>"; desc = "Marks"; }
        { mode = "n"; key = "<leader>sM"; action = "<cmd>Telescope man_pages<cr>"; desc = "Man pages"; }
        { mode = "n"; key = "<leader>sr"; action = "<cmd>Telescope resume<cr>"; desc = "Resume search"; }
        { mode = "n"; key = "<leader>sc"; action = "<cmd>Telescope command_history<cr>"; desc = "Command history"; }
        { mode = "n"; key = "<leader>sC"; action = "<cmd>Telescope commands<cr>"; desc = "Commands"; }
        { mode = "n"; key = "<leader>s\""; action = "<cmd>Telescope registers<cr>"; desc = "Registers"; }
        { mode = "n"; key = "<leader>ss"; action = "<cmd>Telescope lsp_document_symbols<cr>"; desc = "LSP symbols"; }
        { mode = "n"; key = "<leader>sS"; action = "<cmd>Telescope lsp_workspace_symbols<cr>"; desc = "LSP workspace symbols"; }

        # ── Notifications (<leader>n, <leader>sn) ────────────────────
        { mode = "n"; key = "<leader>n"; action = "<cmd>Noice history<cr>"; desc = "Notification history"; }
        { mode = "n"; key = "<leader>snl"; action = "<cmd>Noice last<cr>"; desc = "Noice last message"; }
        { mode = "n"; key = "<leader>snh"; action = "<cmd>Noice history<cr>"; desc = "Noice history"; }
        { mode = "n"; key = "<leader>sna"; action = "<cmd>Noice all<cr>"; desc = "Noice all"; }
        { mode = "n"; key = "<leader>snd"; action = "<cmd>Noice dismiss<cr>"; desc = "Dismiss all"; }

        # ── Git (<leader>g) ──────────────────────────────────────────
        { mode = "n"; key = "<leader>gg"; action = "<cmd>terminal lazygit<cr>"; desc = "Lazygit"; }
        { mode = "n"; key = "<leader>gl"; action = "<cmd>Telescope git_commits<cr>"; desc = "Git log"; }
        { mode = "n"; key = "<leader>gs"; action = "<cmd>Telescope git_status<cr>"; desc = "Git status"; }
        { mode = "n"; key = "<leader>gb"; action = "<cmd>Telescope git_branches<cr>"; desc = "Git branches"; }

        # ── LSP / Code (<leader>c) ───────────────────────────────────
        { mode = "n"; key = "<leader>cd"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; desc = "Line diagnostics"; }
        { mode = [ "n" "x" ]; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; desc = "Code action"; }
        { mode = "n"; key = "<leader>cr"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; desc = "Rename"; }
        { mode = [ "n" "x" ]; key = "<leader>cf"; action = "<cmd>lua vim.lsp.buf.format({async=true})<cr>"; desc = "Format"; }
        { mode = "n"; key = "<leader>cl"; action = "<cmd>LspInfo<cr>"; desc = "LSP info"; }

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
        { mode = "n"; key = "<leader>w"; action = "<c-w>"; desc = "Windows"; }
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
        { mode = "n"; key = "<leader>un"; action = "<cmd>Noice dismiss<cr>"; desc = "Dismiss notifications"; }

        # ── Quit / Session (<leader>q) ───────────────────────────────
        { mode = "n"; key = "<leader>qq"; action = "<cmd>qa<cr>"; desc = "Quit all"; }
      ];

      # ── Lua config (tmux clipboard) ──────────────────────────────────
      luaConfigPre = ''
        -- tmux clipboard integration
        vim.g.clipboard = {
          name = 'myClipboard',
          copy = {
            ["+"] = {'tmux', 'load-buffer', '-'},
            ["*"] = {'tmux', 'load-buffer', '-'},
          },
          paste = {
            ["+"] = {'tmux', 'save-buffer', '-'},
            ["*"] = {'tmux', 'save-buffer', '-'},
          },
          cache_enabled = true,
        }
      '';
    };
  };
}
