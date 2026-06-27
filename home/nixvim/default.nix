{ ... }:

{
  imports = [
    ./lsp.nix
    ./completion.nix
  ];

  programs.nixvim = {
    enable = true;

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
      signcolumn = "yes";
      updatetime = 250;

      splitright = true;
      splitbelow = true;
    };

    plugins = {
      gitsigns.enable = true;
      lualine.enable = true;
      treesitter.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
    };
  };
}
