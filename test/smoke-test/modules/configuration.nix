{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    doom."default" = {
      src = pkgs.stdenv.mkDerivation {
        name = "doom-wasm";
        src = inputs.doom-wasm;
        patches = [ "${inputs.self}/src/patches/01.patch" ];
        installPhase = ''
          mkdir -p $out
          cp -r ./* $out/
        '';
      };

      assets = "${inputs.self}/src/assets";
    };
  };
}
