{ ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      nil_ls.enable = true;
      yamlls.enable = true;
    };
  };
}
