# doom-wasm flake

[flake-parts](https://flake.parts) module to create a [doom-wasm](https://github.com/cloudflare/doom-wasm) application.

You can enable this and set the options like so:

```
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    doom-wasm = {
      flake = false;
      url = "github:cloudflare/doom-wasm";
    };
    doom-wasm-flake.url = "git+https://github.com/cardano-scaling/doom-wasm-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    imports = [
      inputs.doom-wasm-flake.flakeModule
    ];

    perSystem = { ... }: {
      doom.default = {
        enable = true;
        src = inputs.doom-wasm;
        assets = "${self}/assets";
      };
    };

}
```
