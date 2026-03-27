{
  description = "image-based atomic nix-provisioned systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules.pattern = ./module;

      nixosConfigurations = {
        flag = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.pattern
            ./flag.nix
          ];
        };
      };

      packages.${system} = {
        gen-keyring = pkgs.writeShellScriptBin "gen-keyring" (builtins.readFile ./scripts/gen-keyring);
        sign-release = pkgs.writeShellScriptBin "sign-release" (builtins.readFile ./scripts/sign-release);
      };
    };
}
