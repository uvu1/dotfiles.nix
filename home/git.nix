{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    ignores = [
      "**/.claude/settings.local.json"
    ];

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBASQWjEFevq1IhdQ2aft+weTImIFDfrjPKKOBiqL8r";
      format = "ssh";
      signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "uvu1";
        email = "53385458+uvu1@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
      };

      ghq.root = "~/repo";

      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
