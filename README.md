# chocolate-doom flake

[flake-parts](https://flake.parts) module to create a [chocolate-doom](https://github.com/chocolate-doom/chocolate-doom) application.

You can enable this and set the options like so:

```
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    chocolate-doom = {
      flake = false;
      url = "github:chocolate-doom/chocolate-doom";
    };
    chocolate-doom-flake.url = "git+https://github.com/cardano-scaling/chocolate-doom-flake";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    imports = [
      inputs.chocolate-doom-flake.flakeModule
    ];

    perSystem = { ... }: {
      doom.default = {
        enable = true;
        src = inputs.chocolate-doom;
        iwad = [
          "${inputs.self}/freedoom.wad"
        ];
      };
    };

}
```
