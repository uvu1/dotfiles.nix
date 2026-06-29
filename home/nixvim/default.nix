{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  aiAdapterAcp = pkgs.callPackage ../../packages/ai-adapter-acp { };

  luaFiles = [
    "lua/config/keymap/competitive.lua"
    "lua/config/keymap/utils.lua"
    "lua/config/lualine-pane.lua"
    "lua/config/lualine_pane/ai.lua"
    "lua/config/lualine_pane/clock.lua"
    "lua/config/lualine_pane/components.lua"
    "lua/config/lualine_pane/pane.lua"
    "lua/config/lualine_pane/project.lua"
    "lua/config/lualine_pane/runtime.lua"
    "lua/config/lualine_pane/sections.lua"
    "lua/config/lualine_pane/state.lua"
    "lua/config/lualine_pane/util.lua"
    "lua/config/lualine_pane/weather.lua"
    "lua/config/toggleterm.lua"
    "lua/overseer/template/user/just.lua"
  ];
in

{
  imports = [
    ./lsp.nix
    ./completion.nix
    ./plugins.nix
    ./keymaps.nix
  ];

  programs.nixvim = {
    enable = true;

    nixpkgs.source = inputs.nixpkgs.outPath;
    nixpkgs.config.allowUnfree = true;

    luaLoader.enable = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;

      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;

      ignorecase = true;
      smartcase = true;

      termguicolors = true;
      wrap = false;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 300;

      pumblend = 10;
      winblend = 10;

      clipboard = "unnamedplus";

      splitright = true;
      splitbelow = true;
    };

    diagnostic.settings = {
      virtual_text = false;
      virtual_lines = false;
    };

    extraPackages = with pkgs; [
      biome
      clang-tools
      curl
      fd
      git
      jq
      just
      lazygit
      mise
      nodejs
      aiAdapterAcp
      prettier
      ripgrep
      ruff
      rustfmt
      stylua
      tree-sitter
      yamlfmt
      yamllint
    ];

    extraFiles = lib.genAttrs luaFiles (path: {
      source = ./. + "/${path}";
    });

    extraConfigLua = ''
      -- WSL clipboard integration
      if vim.fn.has("wsl") == 1 then
        if vim.fn.executable("wl-copy") == 0 then
          print("wl-copy is not installed, clipboard integration will not work")
        else
          vim.g.clipboard = {
            name = "wl-clipboard(wsl)",
            copy = {
              ["+"] = "wl-copy --foreground --type text/plain",
              ["*"] = "wl-copy --foreground --primary --type text/plain",
            },
            paste = {
              ["+"] = function()
                return vim.fn.systemlist('wl-paste --no-newline|sed -e "s/\r$//"', { "" }, 1)
              end,
              ["*"] = function()
                return vim.fn.systemlist('wl-paste --no-newline --primary|sed -e "s/\r$//"', { "" }, 1)
              end,
            },
            cache_enabled = true,
          }
        end
      end
    '';

    extraConfigLuaPost = ''
      require("config.keymap.competitive")

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() > 0 then
            return
          end

          vim.schedule(function()
            local ok, snacks = pcall(require, "snacks")
            if not ok then
              return
            end

            snacks.explorer.open({
              focus = "list",
              enter = true,
              auto_close = false,
              layout = {
                preset = "sidebar",
                preview = false,
                hidden = { "input" },
              },
            })
          end)
        end,
      })
    '';
  };
}
