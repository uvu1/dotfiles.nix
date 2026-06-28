{ ... }:

{
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "uvu1" ];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    mode = "0755";
    text = ''
      .zen-wrapped
      zen
      zen-beta
    '';
  };
}
