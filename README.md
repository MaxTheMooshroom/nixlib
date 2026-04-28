
# Nixlib

This is a personal collection of nix lib functions,
modeled after nixpkgs' lib.

## Quickstart

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixlib.url = "github:MaxTheMooshroom/nixlib";
  };

  outputs = { flake-parts, nixlib, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, mlib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = [ nixlib.flakeModule ];
    });
}
```

