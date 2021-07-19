{
  description = "A modern music server focusing on metadata";
  outputs = { self, nixpkgs }: {
    nixosModules.services.accentor = import ./modules/accentor.nix;
  };
}
