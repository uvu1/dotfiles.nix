{
  config,
  lib,
  pkgs,
  ...
}:

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

    completionInit = ''
      autoload -Uz compinit

      ZSH_COMPDUMP="${config.xdg.cacheHome}/zsh/zcompdump"
      mkdir -p "''${ZSH_COMPDUMP:h}"

      if [[ -r "$ZSH_COMPDUMP" ]]; then
        compinit -C -d "$ZSH_COMPDUMP"
      else
        compinit -d "$ZSH_COMPDUMP"
      fi
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        setopt interactive_comments
      '')

      ''
        fc -R "$HISTFILE"

        ZSH_COMPLETION_CACHE_DIR="${config.xdg.cacheHome}/zsh/completions"
        mkdir -p "$ZSH_COMPLETION_CACHE_DIR"

        function _source_cached_completion() {
          local name="$1"
          local command_path="$commands[$name]"
          local cache_file="$ZSH_COMPLETION_CACHE_DIR/$name.zsh"
          local tmp_file="$cache_file.$$"
          shift

          [[ -r "$cache_file" ]] && source "$cache_file"

          if [[ -n "$command_path" && ( ! -r "$cache_file" || "$command_path" -nt "$cache_file" ) ]]; then
            {
              "$@" >| "$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
              [[ -e "$tmp_file" ]] && rm "$tmp_file"
            } &!
          fi
        }

        _source_cached_completion kubectl kubectl completion zsh
        _source_cached_completion gh gh completion -s zsh

        if (( $+commands[vault] )); then
          autoload -Uz bashcompinit
          bashcompinit
          complete -o nospace -C "$commands[vault]" vault
        fi

        unfunction _source_cached_completion

        function ghq-fzf() {
          local src
          src="$(ghq list | fzf --preview 'bat --color=always --style=header,grid --line-range :80 "$(ghq root)"/{}/README.* 2>/dev/null')"

          if [[ -n "$src" ]]; then
            BUFFER="cd $(ghq root)/$src"
            zle accept-line
          fi

          zle -R -c
        }

        function ghq() {
          if [[ "$1" == "get" ]]; then
            shift
            for arg in "$@"; do
              if [[ "$arg" == "-p" ]]; then
                command ghq get "$@"
                return $?
              fi
            done
            command ghq get -p "$@"
            return $?
          fi

          command ghq "$@"
        }

        function kube_context_fzf() {
          local context
          local fzf_status

          zle -I
          context="$(
            kubectl config get-contexts -o name 2>/dev/null |
              fzf \
                --height=40% \
                --reverse \
                --border \
                --prompt='kube context> ' \
                --preview='kubectl config view --minify --context={} -o jsonpath="{range .contexts[*]}context: {.name}{\"\n\"}cluster: {.context.cluster}{\"\n\"}namespace: {.context.namespace}{\"\n\"}{end}{range .clusters[*]}server: {.cluster.server}{\"\n\"}{end}" 2>/dev/null'
          )"
          fzf_status=$?

          zle reset-prompt
          zle -R
          (( fzf_status == 0 )) || return
          [[ -n "$context" ]] || return

          kubectl config use-context "$context" >/dev/null
          zle reset-prompt
          zle -R
        }

        function kube_context_or_kill_line() {
          if [[ -z "''${BUFFER//[[:space:]]/}" ]]; then
            BUFFER=""
            CURSOR=0
            kube_context_fzf
          else
            BUFFER=""
            CURSOR=0
            zle reset-prompt
          fi
        }

        function kube_bindkeys() {
          bindkey -r $'\C-k'
          bindkey $'\C-k' kube_context_or_kill_line
        }

        zle -N ghq-fzf
        zle -N kube_context_fzf
        zle -N kube_context_or_kill_line

        bindkey '^g' ghq-fzf
        kube_bindkeys
      ''
    ];

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

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = true;

      format = ''
        $os in $directory$username$kubernetes$git_branch$git_status$git_state$python$nodejs$rust$golang$lua$cpp$cmd_duration$time
        $character'';

      os = {
        disabled = false;
        style = "bold green";
        format = "$symbol ";

        symbols = {
          Windows = "";
          Arch = "󰣇";
          Macos = "";
        };
      };

      username = {
        format = "as [$user]($style) ";
        disabled = false;
        show_always = true;
        style_user = "white bold";
        style_root = "red bold";
      };

      directory = {
        style = "blue";
        format = "[$path]($style) ";
      };

      git_branch = {
        format = "[on $branch]($style) ";
        style = "purple";
      };

      git_status = {
        style = "cyan";
        format = "[$all_status$ahead_behind]($style) ";
      };

      git_state = {
        style = "yellow";
        format = "[$state( $progress_current/$progress_total)]($style) ";
      };

      time = {
        disabled = false;
        format = "at [$time]($style)";
        time_format = "%H:%M";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };

      kubernetes = {
        disabled = false;
        detect_folders = [
          "kubernetes"
          "k8s"
        ];
        symbol = " ";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
    defaultOptions = [
      "--height=40%"
      "--reverse"
      "--border"
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
