{ ... }:
{
  # Default configuration values
  imports = [
    ./system.nix
    ./localization.nix
    ./packages.nix
    ./users.nix
  ];
}
