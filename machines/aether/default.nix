{ pkgs, ... }:
{
  imports = [
    ../../modules/home-base.nix
    ../../modules/git.nix
    ../../modules/bash.nix
    ../../modules/neovim.nix
    ../../modules/kitty.nix
    ../../modules/ssh
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # nix-darwin manages the Nix installation itself.
  nix.package = pkgs.lix;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "rien" ];
  };
  nix.linux-builder.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.shells = [ pkgs.bashInteractive ];
  environment.systemPackages = [ pkgs.claude-code ];

  system.primaryUser = "rien";
  users.users.rien.home = "/Users/rien";
  users.users.root.home = "/var/root";

  # nix-darwin's own release counter, unrelated to the NixOS-style
  # "25.11" stateVersion strings used elsewhere in this repo.
  system.stateVersion = 7;

  home-manager.backupFileExtension = "hmbak";
  home-manager.users.rien.home.stateVersion = "25.11";
  home-manager.users.root.home.stateVersion = "25.11";

  custom = {
    git.enable = true;
    bash.enable = true;
    neovim.enable = true;
    kitty.enable = true;
    ssh.enable = true;
  };
}
