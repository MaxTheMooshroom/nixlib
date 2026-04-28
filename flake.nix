{
  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";

    lib = { flake = false; url = ./lib/top-level.nix; };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = [];

      imports = [ flake-parts.flakeModules.flakeModules ];

      flake.lib = import inputs.lib lib;

      flake.flakeModules.default = { lib, ... }: {
        _module.args.mlib = import inputs.lib lib;
      };

      flake.overlays.nixpkgs = final: prev: {
        mlib = import inputs.lib prev.lib;

        callPackageSet = final.lib'.callPackageSetWith final.newScope;
      };
    });
}
