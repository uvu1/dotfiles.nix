{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";

      size = 100000;
      save = 100000;

      append = true;
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
      ignoreSpace = true;

      share = false;
    };

    setOptions = [
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "HIST_NO_STORE"
      "INC_APPEND_HISTORY"
    ];

    initContent = ''
      fc -R "$HISTFILE"
    '';

    shellAliases = {
      edit = "nvim";
      code = "nvim";
      vim = "nvim";

      ga = "git add";
      gaa = "git add .";
      gst = "git status";
      gcm = "git commit -m";
      gpl = "git pull";
      gps = "git push";

      k = "kubectl";

      bat = "bat --style=plain --color=always --paging=always";
      fd = "fd --color=always --hidden --exclude .git";
      rg = "rg --color=always";
      ls = "eza --icons --group-directories-first --color=always";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
