{ ... }:

let
  raw = code: { __raw = code; };
  opts = desc: {
    inherit desc;
    silent = true;
    noremap = true;
  };
in

{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options = opts "move to left";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options = opts "move to right";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options = opts "move to upper";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options = opts "move to lower";
    }
    {
      mode = "i";
      key = "<C-c>";
      action = raw ''
        function()
          if vim.lsp.inline_completion then
            return vim.lsp.inline_completion.get()
          end
        end
      '';
    }
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options = opts "Clear search highlights";
    }
    {
      mode = "i";
      key = "<CR>";
      action = raw ''
        function()
          return require("mini.pairs").cr()
        end
      '';
      options = (opts "mini.pairs newline") // {
        expr = true;
        replace_keycodes = true;
      };
    }

    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>AerialToggle!<CR>";
      options = opts "Toggle Aerial";
    }
    {
      mode = "n";
      key = "]]";
      action = "<cmd>AerialNext<CR>";
      options = opts "Go to next symbol";
    }
    {
      mode = "n";
      key = "[[";
      action = "<cmd>AerialPrev<CR>";
      options = opts "Go to previous symbol";
    }

    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = raw ''function() require("flash").jump() end'';
      options = opts "Flash";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action = raw ''function() require("flash").treesitter() end'';
      options = opts "Flash Treesitter";
    }
    {
      mode = "o";
      key = "r";
      action = raw ''function() require("flash").remote() end'';
      options = opts "Remote Flash";
    }
    {
      mode = [
        "o"
        "x"
      ];
      key = "R";
      action = raw ''function() require("flash").treesitter_search() end'';
      options = opts "Treesitter Search";
    }
    {
      mode = "c";
      key = "<c-s>";
      action = raw ''function() require("flash").toggle() end'';
      options = opts "Toggle Flash Search";
    }

    {
      mode = [
        "n"
        "t"
      ];
      key = "<leader>tl";
      action = "<cmd>LazyGit<CR>";
      options = opts "Toggle lazygit";
    }

    {
      mode = "n";
      key = "<leader>rr";
      action = "<cmd>OverseerRun<CR>";
      options = opts "Run task";
    }
    {
      mode = "n";
      key = "<leader>rt";
      action = "<cmd>OverseerToggle<CR>";
      options = opts "Toggle tasks";
    }
    {
      mode = "n";
      key = "<leader>ra";
      action = "<cmd>OverseerQuickAction<CR>";
      options = opts "Task action";
    }
    {
      mode = "n";
      key = "<leader>rl";
      action = "<cmd>OverseerRestartLast<CR>";
      options = opts "Restart last task";
    }
    {
      mode = "n";
      key = "<leader>ri";
      action = "<cmd>OverseerInfo<CR>";
      options = opts "Overseer info";
    }

    {
      mode = "n";
      key = "<M-[>";
      action = raw ''function() require("pane-tabs.pane.editor").prev() end'';
      options = opts "Editor previous pane tab";
    }
    {
      mode = "n";
      key = "<M-]>";
      action = raw ''function() require("pane-tabs.pane.editor").next() end'';
      options = opts "Editor next pane tab";
    }
    {
      mode = "n";
      key = "<leader>a1";
      action = raw ''function() require("pane-tabs.pane.ai").open("copilot") end'';
      options = opts "AI tab1: Copilot";
    }
    {
      mode = "n";
      key = "<leader>a2";
      action = raw ''function() require("pane-tabs.pane.ai").open("codex") end'';
      options = opts "AI tab2: Codex";
    }
    {
      mode = "n";
      key = "<leader>a3";
      action = raw ''function() require("pane-tabs.pane.ai").open("claude") end'';
      options = opts "AI tab3: Claude";
    }
    {
      mode = "n";
      key = "<leader>aa";
      action = raw ''function() require("pane-tabs.pane.ai").toggle() end'';
      options = opts "AI toggle chat pane";
    }
    {
      mode = "n";
      key = "<leader>aq";
      action = raw ''function() require("pane-tabs.pane.ai").close() end'';
      options = opts "AI close chat pane";
    }
    {
      mode = "n";
      key = "<leader>al";
      action = "<cmd>PaneTabsLoadAI<CR>";
      options = opts "AI load session";
    }
    {
      mode = "n";
      key = "<leader>as";
      action = "<cmd>PaneTabsSaveAI<CR>";
      options = opts "AI save session";
    }

    {
      mode = "n";
      key = "<leader>e";
      action = raw ''
        function()
          local snacks = require("snacks")
          local explorers = snacks.picker.get({ source = "explorer" })

          for _, explorer in ipairs(explorers) do
            if explorer and not explorer.closed then
              explorer:focus("list")
              return
            end
          end

          snacks.explorer.open({
            focus = "list",
            auto_close = false,
            layout = {
              preset = "sidebar",
              preview = false,
              hidden = { "input" },
            },
          })
        end
      '';
      options = opts "Focus or open explorer";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = raw ''function() require("snacks").picker.lsp_definitions() end'';
      options = opts "Go to definitions";
    }
    {
      mode = "n";
      key = "<leader>gr";
      action = raw ''function() require("snacks").picker.lsp_references() end'';
      options = opts "Go to references";
    }
    {
      mode = "n";
      key = "<leader>gi";
      action = raw ''function() require("snacks").picker.lsp_implementations() end'';
      options = opts "Go to implementations";
    }
    {
      mode = "n";
      key = "<leader>gy";
      action = raw ''function() require("snacks").picker.lsp_type_definitions() end'';
      options = opts "Go to type definitions";
    }
    {
      mode = "n";
      key = "<leader>grn";
      action = raw ''function() require("snacks").lsp.rename() end'';
      options = opts "Rename symbol";
    }
    {
      mode = "n";
      key = "<leader>gci";
      action = raw ''function() require("snacks").lsp.incoming_calls() end'';
      options = opts "Incoming calls";
    }
    {
      mode = "n";
      key = "<leader>gco";
      action = raw ''function() require("snacks").lsp.outgoing_calls() end'';
      options = opts "Outgoing calls";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = raw ''function() require("snacks").picker.lsp_symbols() end'';
      options = opts "File symbols";
    }
    {
      mode = "n";
      key = "<leader>sS";
      action = raw ''function() require("snacks").picker.lsp_workspace_symbols() end'';
      options = opts "Workspace symbols";
    }
    {
      mode = "n";
      key = "<leader>sf";
      action = raw ''
        function()
          require("snacks").picker.lsp_symbols({
            title = "Functions",
            filter = {
              default = { "Function", "Method", "Constructor" },
            },
          })
        end
      '';
      options = opts "File functions";
    }
    {
      mode = "n";
      key = "<leader>fe";
      action = raw ''function() require("snacks").explorer.open() end'';
      options = opts "Toggle explorer";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = raw ''function() require("snacks").explorer.reveal() end'';
      options = opts "Reveal current file in explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = raw ''function() require("snacks").picker.files() end'';
      options = opts "Find files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = raw ''function() require("snacks").picker.grep() end'';
      options = opts "Grep";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = raw ''function() require("snacks").picker.buffers() end'';
      options = opts "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = raw ''function() require("snacks").picker.recent() end'';
      options = opts "Recent files";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action = raw ''function() require("snacks").picker.diagnostics() end'';
      options = opts "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>fD";
      action = raw ''function() require("snacks").picker.diagnostics_buffer() end'';
      options = opts "Buffer diagnostics";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = raw ''
        function()
          require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
        end
      '';
      options = opts "Find config files";
    }

    {
      mode = [
        "n"
        "t"
      ];
      key = "<leader>tt";
      action = "<cmd>ToggleTerm<CR>";
      options = opts "Toggle terminal";
    }

    {
      mode = "n";
      key = "]f";
      action = raw ''
        function()
          require("nvim-treesitter.textobjects.move").goto_next_start("@function.outer", "textobjects")
        end
      '';
      options = opts "Go to next function start";
    }
    {
      mode = "n";
      key = "[f";
      action = raw ''
        function()
          require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end
      '';
      options = opts "Go to previous function start";
    }
    {
      mode = "n";
      key = "]F";
      action = raw ''
        function()
          require("nvim-treesitter.textobjects.move").goto_next_end("@function.outer", "textobjects")
        end
      '';
      options = opts "Go to next function end";
    }
    {
      mode = "n";
      key = "[F";
      action = raw ''
        function()
          require("nvim-treesitter.textobjects.move").goto_previous_end("@function.outer", "textobjects")
        end
      '';
      options = opts "Go to previous function end";
    }

    {
      mode = "n";
      key = "<leader>ts";
      action = "<cmd>TSJToggle<CR>";
      options = opts "Split/Join code structure";
    }

    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options = opts "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options = opts "Buffer Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle focus=false<CR>";
      options = opts "Symbols (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>cl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=bottom<CR>";
      options = opts "LSP Definitions / References (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xQ";
      action = "<cmd>Trouble qflist toggle<CR>";
      options = opts "Quickfix List (Trouble)";
    }

    {
      mode = "n";
      key = "zR";
      action = raw ''function() require("ufo").openAllFolds() end'';
      options = opts "Close All Folds (Ufo)";
    }
    {
      mode = "n";
      key = "zM";
      action = raw ''function() require("ufo").closeAllFolds() end'';
      options = opts "Open All Folds (Ufo)";
    }
    {
      mode = "n";
      key = "zp";
      action = raw ''function() require("ufo").peekFoldedLinesUnderCursor() end'';
      options = opts "Peek Folded Lines Under Cursor (Ufo)";
    }

    {
      mode = "n";
      key = "<leader>?";
      action = raw ''function() require("which-key").show({ global = false }) end'';
      options = opts "Buffer local Keymaps(which-key)";
    }

    {
      mode = "n";
      key = "<leader>cf";
      action = raw ''
        function()
          require("conform").format({
            async = true,
            lsp_format = "fallback",
          })
        end
      '';
      options = opts "Format buffer";
    }
  ];
}
