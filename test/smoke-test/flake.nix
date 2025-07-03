{

  description = "test flake";

  inputs = {
    doom-wasm = {
      url = "github:cloudflare/doom-wasm";
      flake = false;
    };
    get-flake.url = "github:ursi/get-flake";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = inputs: with inputs.flake-parts.lib; mkFlake { inherit inputs; } (inputs.import-tree ./modules);

}
