{ pkgs, lib, ... }:
let
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-with-node";
    paths = [ pkgs.claude-code ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude \
        --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs ]}
    '';
  };
in
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
  environment.systemPackages = [ claude-code pkgs.gh ];

  system.primaryUser = "rien";
  users.users.rien.home = "/Users/rien";
  users.users.root.home = "/var/root";

  # nix-darwin's own release counter, unrelated to the NixOS-style
  # "25.11" stateVersion strings used elsewhere in this repo.
  system.stateVersion = 7;

  home-manager.backupFileExtension = "hmbak";
  home-manager.users.rien.home.stateVersion = "25.11";
  home-manager.users.root.home.stateVersion = "25.11";

  homebrew = {
    enable = true;
    casks = [ "unity-cli" ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };

  custom = {
    git.enable = true;
    bash.enable = true;
    neovim.enable = true;
    kitty.enable = true;
    ssh.enable = true;
  };
}
