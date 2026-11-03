{
  description = "aneks NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  inputs.seamless-asahi-plymouth = {
  url = "github:luca-schlecker/seamless-asahi-plymouth";
  inputs.nixpkgs.follows = "nixpkgs";
};

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
