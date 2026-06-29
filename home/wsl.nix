{ lib, ... }:

{
  programs.git = {
    signing.signer = lib.mkForce
      "/mnt/c/Users/uvu1/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";

    settings.core.sshCommand =
      "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
  };
}
