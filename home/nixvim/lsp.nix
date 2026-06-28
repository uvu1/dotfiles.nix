{ ... }:

let
  raw = code: { __raw = code; };
in

{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        nil_ls.enable = true;
        ts_ls.enable = true;
        biome.enable = true;
        jsonls.enable = true;
        html.enable = true;
        cssls.enable = true;
        tailwindcss.enable = true;
        pyright.enable = true;
        copilot.enable = true;

        yamlls = {
          enable = true;

          settings = {
            validate = true;
            completion = true;
            hover = true;
            keyOrdering = false;
            schemaStore = {
              enable = false;
              url = "";
            };
            schemas = raw ''
              (function()
                local yaml_schemas = require("schemastore").yaml.schemas()
                yaml_schemas.kubernetes = {
                  "k8s/**/*.yaml",
                  "k8s/**/*.yml",
                  "kubernetes/**/*.yaml",
                  "kubernetes/**/*.yml",
                  "manifests/**/*.yaml",
                  "manifests/**/*.yml",
                  "clusters/**/*.yaml",
                  "clusters/**/*.yml",
                  "applications/**/*.yaml",
                  "applications/**/*.yml",
                  "applicatinsets/**/*.yaml",
                  "applicationsets/**/*.yml",
                }
                return yaml_schemas
              end)()
            '';
          };
        };

        lua_ls = {
          enable = true;

          settings = {
            runtime.version = "LuaJIT";
            diagnostics.globals = [ "vim" ];
            workspace = {
              library = raw ''vim.api.nvim_get_runtime_file("", true)'';
              checkThirdParty = false;
            };
            telemetry.enable = false;
          };
        };

        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          installRustfmt = true;

          settings = {
            cargo.allFeatures = true;
            check.command = "clippy";
          };
        };
      };
    };

    autoGroups = {
      ai_pane_completion.clear = true;
      copilot_inline.clear = true;
    };

    autoCmd = [
      {
        event = "FileType";
        group = "ai_pane_completion";
        pattern = [
          "codecompanion"
          "pane-tabs-ai"
        ];
        callback = raw ''
          function(args)
            vim.b[args.buf].completion = false

            if vim.lsp.inline_completion then
              vim.lsp.inline_completion.enable(false, { bufnr = args.buf })
            end
          end
        '';
      }
      {
        event = "LspAttach";
        group = "copilot_inline";
        callback = raw ''
          function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
              return
            end

            if client.name == "copilot" then
              local ai_filetypes = {
                codecompanion = true,
                ["pane-tabs-ai"] = true,
              }
              vim.lsp.inline_completion.enable(not ai_filetypes[vim.bo[args.buf].filetype], { bufnr = args.buf })
            end
          end
        '';
      }
    ];
  };
}
