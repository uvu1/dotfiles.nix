{
  config,
  inputs,
  pkgs,
  ...
}:

let
  raw = code: { __raw = code; };

  mkVimPlugin =
    pname: src:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.shortRev or src.rev or src.lastModifiedDate or "unstable";
    };

  customPlugins = {
    kawaii-theme-nvim = mkVimPlugin "kawaii-theme.nvim" inputs.kawaii-theme-nvim;
    pane-tabs-nvim = mkVimPlugin "pane-tabs.nvim" inputs.pane-tabs-nvim;
  };

  treeSitterGrammars = config.programs.nixvim.plugins.treesitter.package.passthru.builtGrammars;

  acpResolver = ''
    local function executable(path)
      return type(path) == "string" and path ~= "" and vim.fn.executable(path) == 1
    end

    local function notify_missing_acp(binary)
      vim.schedule(function()
        vim.notify(binary .. " not found; the ACP adapter is disabled", vim.log.levels.WARN)
      end)
    end

    local function resolve_acp_command(binary)
      local from_path = vim.fn.exepath(binary)

      if executable(from_path) then
        return { from_path }
      end

      notify_missing_acp(binary)
      return nil
    end
  '';

  webFormatters = raw ''
    function(bufnr)
      local function root_has(names)
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == "" then
          return false
        end

        local dir = vim.fs.dirname(path)
        local found = vim.fs.find(names, {
          path = dir,
          upward = true,
          stop = vim.loop.os_homedir(),
        })

        return #found > 0
      end

      local has_prettier = root_has({
        "prettier.config.js",
        "prettier.config.mjs",
        "prettier.config.cjs",
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        ".prettierrc.toml",
      })

      local has_biome = root_has({
        "biome.json",
        "biome.jsonc",
      })

      if has_prettier then
        return { "prettier" }
      end

      if has_biome then
        return { "biome" }
      end

      return { "biome", "prettier", stop_after_first = true }
    end
  '';
in

{
  programs.nixvim = {
    extraPlugins =
      (with pkgs.vimPlugins; [
        SchemaStore-nvim
        nui-nvim
        plenary-nvim
        promise-async
      ])
      ++ (with customPlugins; [
        kawaii-theme-nvim
        pane-tabs-nvim
      ]);

    extraConfigLuaPre = ''
      require("kawaii-theme").setup({
        transparent = true,
      })
      vim.cmd.colorscheme("kawaii-theme")
    '';

    extraConfigLuaPost = ''
      local ai_provider_order = { "copilot" }
      local ai_providers = {
        copilot = {
          name = "Copilot",
          label = " Copilot",
          icon = "",
          adapter = "copilot",
          command = "CodeCompanionChat",
        },
      }

      local function add_acp_provider(binary, key, provider)
        if vim.fn.executable(binary) == 1 then
          ai_providers[key] = provider
          table.insert(ai_provider_order, key)
          return
        end

        vim.schedule(function()
          vim.notify(binary .. " not found; " .. provider.name .. " pane provider is disabled", vim.log.levels.WARN)
        end)
      end

      add_acp_provider("codex-acp", "codex", {
        name = "Codex",
        label = "󰚩 Codex",
        icon = "󰚩",
        adapter = "codex",
        command = "CodeCompanionChat",
      })

      add_acp_provider("claude-agent-acp", "claude", {
        name = "Claude",
        label = "󰛄 Claude",
        icon = "󰛄",
        adapter = "claude_code",
        command = "CodeCompanionChat",
      })

      require("pane-tabs").setup({
        ai = {
          enabled = true,
          width = 52,
          default_provider = "copilot",
          provider_order = ai_provider_order,
          providers = ai_providers,
        },
      })

      require("config.lualine-pane").setup()
    '';

    plugins = {
      aerial = {
        enable = true;
        settings = {
          backends = [
            "lsp"
            "treesitter"
            "markdown"
          ];
          filter_kind = [
            "Class"
            "Constructor"
            "Enum"
            "Function"
            "Interface"
            "Module"
            "Method"
            "Struct"
          ];
          show_guides = true;
          layout = {
            default_direction = "prefer_right";
            max_width = 40;
            min_width = 20;
            placement = "window";
          };
        };
      };

      auto-save = {
        enable = true;
        settings.condition = ''
          function(buf)
            if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
              return false
            end

            local bo = vim.bo[buf]

            if bo.buftype ~= "" or bo.filetype == "codecompanion" or bo.filetype == "pane-tabs-ai" then
              return false
            end

            if not bo.modifiable or bo.readonly then
              return false
            end

            return vim.api.nvim_buf_get_name(buf) ~= ""
          end
        '';
      };

      codecompanion = {
        enable = true;
        settings = {
          interactions.chat.adapter = {
            name = "copilot";
            model = "gpt-4.1";
          };

          adapters.acp = {
            codex = raw ''
              function()
                ${acpResolver}
                local command = resolve_acp_command("codex-acp")
                if not command then
                  return nil
                end

                return require("codecompanion.adapters").extend("codex", {
                  commands = {
                    default = command,
                  },
                  defaults = {
                    auth_method = "chatgpt",
                    session_config_options = {
                      mode = "Full Access",
                      thought_level = "Xhigh",
                    },
                  },
                })
              end
            '';
            claude_code = raw ''
              function()
                ${acpResolver}
                local command = resolve_acp_command("claude-agent-acp")
                if not command then
                  return nil
                end

                return require("codecompanion.adapters").extend("claude_code", {
                  commands = {
                    default = command,
                  },
                })
              end
            '';
          };

          display = {
            chat.window = {
              layout = "vertical";
              position = "right";
              width = 0.38;
              full_height = true;
              border = "rounded";
              opts = {
                number = false;
                relativenumber = false;
                signcolumn = "no";
                wrap = true;
                linebreak = true;
                winfixwidth = true;
              };
            };
            action_palette.opts.show_preset_prompts = false;
          };
        };
      };

      comment = {
        enable = true;
        settings.toggler = {
          line = "<leader>cc";
          block = "<leader>cb";
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            typescript = webFormatters;
            typescriptreact = webFormatters;
            javascript = webFormatters;
            javascriptreact = webFormatters;
            json = webFormatters;
            jsonc = webFormatters;
            css = webFormatters;

            yaml = raw ''{ "prettier", "yamlfmt", stop_after_first = true }'';
            rust = raw ''{ "rustfmt", lsp_format = "fallback" }'';
            python = [ "ruff_format" ];
            cpp = raw ''{ "clang_format", lsp_format = "fallback" }'';
            c = raw ''{ "clang_format", lsp_format = "fallback" }'';
            lua = [ "stylua" ];
          };

          format_on_save = ''
            function(bufnr)
              local ft = vim.bo[bufnr].filetype

              if
                vim.tbl_contains({
                  "codecompanion",
                  "pane-tabs-ai",
                  "snacks_terminal",
                  "terminal",
                  "prompt",
                }, ft)
              then
                return
              end

              local name = vim.api.nvim_buf_get_name(bufnr)
              if name == "" then
                return
              end

              local ok, stat = pcall(vim.uv.fs_stat, name)
              if ok and stat and stat.size > 1024 * 1024 then
                return
              end

              return {
                timeout_ms = 1000,
                lsp_format = "fallback",
              }
            end
          '';
        };
      };

      flash = {
        enable = true;
        settings = { };
      };

      gitsigns.enable = true;
      lazygit.enable = true;

      lint = {
        enable = true;
        lintersByFt = {
          typescript = [ "biomejs" ];
          typescriptreact = [ "biomejs" ];
          javascript = [ "biomejs" ];
          javascriptreact = [ "biomejs" ];
          json = [ "biomejs" ];
          jsonc = [ "biomejs" ];
          css = [ "biomejs" ];
          yaml = [ "yamllint" ];
          python = [ "ruff" ];
        };
        autoCmd = {
          event = [
            "BufWritePost"
            "InsertLeave"
          ];
          callback = raw ''
            function(args)
              local ft = vim.bo[args.buf].filetype

              if
                vim.tbl_contains({
                  "codecompanion",
                  "pane-tabs-ai",
                  "snacks_terminal",
                  "terminal",
                  "prompt",
                }, ft)
              then
                return
              end

              local name = vim.api.nvim_buf_get_name(args.buf)
              if name == "" then
                return
              end

              require("lint").try_lint()
            end
          '';
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = raw ''require("config.lualine-pane").theme()'';
            globalstatus = false;
            always_divide_middle = false;
            component_separators = "";
            section_separators = "";
            refresh = {
              statusline = 250;
              tabline = 1000;
              winbar = 1000;
              refresh_time = 16;
              events = [
                "BufEnter"
                "BufWinEnter"
                "CursorMoved"
                "CursorMovedI"
                "DiagnosticChanged"
                "FileChangedShellPost"
                "FileType"
                "ModeChanged"
                "SessionLoadPost"
                "VimResized"
                "WinClosed"
                "WinEnter"
                "WinNew"
                "WinResized"
              ];
            };
          };
          sections = raw ''require("config.lualine-pane").sections()'';
          inactive_sections = raw ''vim.deepcopy(require("config.lualine-pane").sections())'';
          tabline = { };
          winbar = { };
          inactive_winbar = { };
        };
      };

      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          pairs = { };
          surround = { };
          icons = { };
          bracketed = {
            diagnostic.suffix = "d";
            quickfix.suffix = "q";

            buffer.suffix = "";
            comment.suffix = "";
            conflict.suffix = "";
            indent.suffix = "";
            jump.suffix = "";
            location.suffix = "";
            oldfile.suffix = "";
            treesitter.suffix = "";
            undo.suffix = "";
            window.suffix = "";
            yank.suffix = "";
          };
        };
      };

      noice = {
        enable = true;
        settings = {
          cmdline.view = "cmdline_popup";
          views = {
            cmdline_popup = {
              relative = "editor";
              position = {
                row = "25%";
                col = "50%";
              };
              size = {
                width = 70;
                height = "auto";
              };
              border = {
                style = "rounded";
                padding = [
                  0
                  1
                ];
              };
            };
            cmdline_popupmenu = {
              relative = "editor";
              position = {
                row = "31%";
                col = "50%";
              };
              size = {
                width = 70;
                height = 10;
              };
              border = {
                style = "rounded";
                padding = [
                  0
                  1
                ];
              };
            };
            presets = {
              bottom_search = false;
              command_palette = false;
              long_message_to_split = false;
              lsp_doc_border = false;
            };
          };
        };
      };

      notify.enable = true;

      overseer = {
        enable = true;
        settings = {
          templates = [
            "builtin"
            "user.just"
          ];
          strategy = {
            __unkeyed-1 = "terminal";
            direction = "bottom";
            size = 15;
          };
          task_list = {
            direction = "right";
            min_width = 32;
            max_width = 52;
            default_detail = 1;
          };
          form.border = "rounded";
          confirm.border = "rounded";
          task_win.border = "rounded";
        };
      };

      rainbow-delimiters.enable = true;

      snacks = {
        enable = true;
        settings = {
          bigfile.enabled = true;
          quickfile.enabled = true;

          dashboard = {
            enabled = true;
            width = 60;
            pane_gap = 4;

            preset = {
              header = ''
                ███╗   ██╗██╗   ██╗██╗███╗   ███╗
                ████╗  ██║██║   ██║██║████╗ ████║
                ██╔██╗ ██║██║   ██║██║██╔████╔██║
                ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
                ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
                ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
              '';

              keys = [
                {
                  icon = " ";
                  key = "f";
                  desc = "Find File";
                  action = "<leader>ff";
                }
                {
                  icon = " ";
                  key = "g";
                  desc = "Grep";
                  action = "<leader>fg";
                }
                {
                  icon = " ";
                  key = "e";
                  desc = "Explorer";
                  action = "<leader>e";
                }
                {
                  icon = " ";
                  key = "r";
                  desc = "Recent Files";
                  action = "<leader>fr";
                }
                {
                  icon = " ";
                  key = "c";
                  desc = "Config";
                  action = "<leader>fc";
                }
                {
                  icon = "󰒲 ";
                  key = "l";
                  desc = "Lazy";
                  action = ":Lazy";
                }
                {
                  icon = " ";
                  key = "q";
                  desc = "Quit";
                  action = ":qa";
                }
              ];
            };

            sections = [
              { section = "header"; }
              {
                section = "keys";
                gap = 1;
                padding = 1;
              }
              {
                icon = " ";
                title = "Recent Files";
                section = "recent_files";
                indent = 2;
                padding = [
                  1
                  1
                ];
              }
              {
                icon = " ";
                title = "Projects";
                section = "projects";
                indent = 2;
                padding = [
                  1
                  1
                ];
              }
              { section = "startup"; }
            ];
          };

          explorer = {
            enabled = true;
            replace_netrw = true;
            trash = true;
          };

          picker = {
            enabled = true;
            ui_select = true;
            sources = {
              explorer = {
                hidden = true;
                ignored = true;
                follow_file = true;
                git_status = true;
                diagnostics = true;
                auto_close = false;
                layout = {
                  preset = "sidebar";
                  preview = false;
                  hidden = [ "input" ];
                  layout.width = 0.18;
                };
              };
              files = {
                hidden = true;
                ignored = false;
              };
              grep = {
                hidden = true;
                ignored = false;
              };
            };
          };

          indent.enabled = true;
          scope.enabled = true;
          statuscolumn.enabled = true;
          input.enabled = true;
          notifier.enabled = true;
        };
      };

      tiny-inline-diagnostic = {
        enable = true;
        settings = {
          preset = "modern";
          options.multilines = true;
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          hide_numbers = true;
          shade_terminals = false;
          start_in_insert = true;
          persist_size = false;
          float_opts = {
            relative = "editor";
            border = "single";
            width = raw ''
              function()
                return require("config.toggleterm").term_width()
              end
            '';
            height = raw ''
              function()
                return require("config.toggleterm").term_height()
              end
            '';
            row = raw ''
              function()
                return require("config.toggleterm").term_row()
              end
            '';
            col = raw ''
              function()
                return require("config.toggleterm").term_col()
              end
            '';
            winblend = 0;
            zindex = 50;
            title_pos = "left";
          };
        };
      };

      treesitter = {
        enable = true;
        grammarPackages = with treeSitterGrammars; [
          bash
          c
          cpp
          css
          diff
          dockerfile
          git_config
          git_rebase
          gitcommit
          gitignore
          go
          gomod
          gosum
          hcl
          html
          javascript
          jq
          jsdoc
          json
          just
          lua
          luadoc
          markdown
          markdown_inline
          nix
          python
          query
          regex
          rust
          sql
          terraform
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
          zsh
        ];
        highlight.enable = true;
        indent.enable = true;
      };

      treesitter-context = {
        enable = true;
        settings = {
          max_lines = 3;
          mode = "cursor";
          separator = raw "nil";
        };
      };

      treesitter-textobjects = {
        enable = true;
        settings = {
          select.lookahead = true;
          move.set_jumps = true;
        };
      };

      treesj = {
        enable = true;
        settings.use_default_keymaps = false;
      };

      trouble = {
        enable = true;
        settings = { };
      };

      ts-comments = {
        enable = true;
        settings = { };
      };

      nvim-ufo = {
        enable = true;
        settings.provider_selector = ''
          function(bufnr, filetype, buftype)
            return { "treesitter", "indent" }
          end
        '';
      };

      web-devicons.enable = true;

      which-key = {
        enable = true;
        settings = { };
      };
    };

    opts = {
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };
  };
}
