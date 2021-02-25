{
  description = "Nixos configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsFor0AD.url = "github:charvp/nixpkgs/0ad0.24";
    home-manager = {
      url = "github:rien/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:rien/agenix/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, nixpkgsFor0AD, home-manager, flake-utils, agenix }:
    let
      version-suffix = nixpkgs.rev or (builtins.toString nixpkgs.lastModified);
      pkgsFor = system: import nixpkgs {
        inherit system;
      };
      mkSystem = system: hostname: nixpkgs.lib.nixosSystem {
        extraArgs = { pkgsFor0AD = import nixpkgsFor0AD { inherit system; }; };
        inherit system;
        modules = [
          # Secrets management
          agenix.nixosModules.age
          { environment.systemPackages = [ agenix.defaultPackage.${system} ]; }

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
      };
    };
}

