{ ... }:

{
  programs.nixvim.plugins.blink-cmp = {
    enable = true;

    setupLspCapabilities = true;

    settings = {
      keymap.preset = "super-tab";

      completion = {
        documentation.auto_show = true;
      };

      signature.enabled = true;
    };
  };
}
