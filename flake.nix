{
  description = "Nixos configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    #nixpkgs.url = "github:rien/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    accentor = {
      url = "github:accentor/flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mfauth = {
      url = "github:rien/mfauth/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, agenix, accentor, musnix, mfauth }:
    let
      version-suffix = nixpkgs.rev or (builtins.toString nixpkgs.lastModified);
      pkgsFor = system: import nixpkgs {
        inherit system;
      };
      mkSystem = system: hostname: nixpkgs.lib.nixosSystem {
        extraArgs = {
          util = import ./util.nix;
        };
        inherit system;
        modules = [
          # Secrets management
          agenix.nixosModules.age
          { environment.systemPackages = [ agenix.defaultPackage.${system} ]; }

          # Simple OAuth2 client
          ({
            nixpkgs.overlays = [(self: super: {
              mfauth = mfauth.defaultPackage.${system};
            })];
          })

          # Accentor music server
          accentor.nixosModules.accentor

          musnix.nixosModules.musnix

          # Enable home-manager
          home-manager.nixosModules.home-manager

          # Set global home-manager options
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          })

          # Automatically load custom modules
          (./modules)

          # Expose the currently deployed nixpkgs in /etc/nixpkgs/
          ({ pkgs, ... }: {
            environment.etc."nixpkgs".source = (pkgs.runCommandNoCC "nixpkgs" { } ''
              cp -r ${nixpkgs} $out
              chmod 700 $out
              echo "${version-suffix}" > $out/.version-suffix
            '');
            nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
          })



          # Load the config for out current machine
          (./. + "/machines/${hostname}")
        ];
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = pkgsFor system;
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ nixpkgs-fmt ];
          };
        }) // {
      nixosConfigurations = {
        chaos = mkSystem "x86_64-linux" "chaos";
        space = mkSystem "x86_64-linux" "space";
        living = mkSystem "aarch64-linux" "living";
        entropy = mkSystem "aarch64-linux" "entropy";
      };
    };
}

