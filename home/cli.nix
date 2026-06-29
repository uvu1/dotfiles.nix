{ pkgs, ... }:

let
  aiAdapterAcp = pkgs.callPackage ../packages/ai-adapter-acp { };
in
{
  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    gh
    ghq
    jq
    ripgrep
    kubernetes-helm
    kubectl
    lazygit
    cloudflared
    codex
    claude-code
    aiAdapterAcp
    direnv
    gemini-cli
    just
    jqp
    k9s
    kubectx
    delta
    nix-direnv
    opentofu
    ruff
    stylua
    terraform
    tree-sitter
    vault
    yamlfmt
    yamllint
    yq-go
    biome
  ];
}
