{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
          name = "uvu1";
          email = "53385458+uvu1@users.noreply.github.com";
        }

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
      };

      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
