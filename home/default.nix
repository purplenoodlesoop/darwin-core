{ ... }:
{
  imports = [
    ./git.nix
    ./kitty.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ];

  programs.home-manager.enable = true;
}
