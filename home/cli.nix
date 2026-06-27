{ pkgs, ... }:

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
    just
    delta
    yq-go
  ];
}
