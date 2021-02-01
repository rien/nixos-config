{ pkgs, config, lib, ... }: {
  imports = [
    ./ugent.nix;
    ./media.nix;
  ];
}
