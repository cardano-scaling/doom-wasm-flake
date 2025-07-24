_: {
  flake.flakeModule = caller:
    let
      inherit (caller.lib)
        mkOption
        types;
      inherit (caller.flake-parts-lib)
        mkPerSystemOption;
    in
    {
      options.perSystem = mkPerSystemOption ({ pkgs, lib, ... }: {
        options.doom = mkOption {
          type = types.attrsOf
            (types.submodule ({ name, config, ... }: {
              options = {
                assets = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                };
                src = mkOption {
                  type = types.path;
                };
                dependencies = mkOption {
                  type = types.attrsOf (types.submodule {
                    options = {
                      url = mkOption {
                        type = types.str;
                      };
                      sha256 = mkOption {
                        type = types.str;
                      };
                    };
                  });
                  default = {
                    ogg = {
                      url = "https://github.com/emscripten-ports/ogg/archive/version_1.zip";
                      sha256 = "sha256:02rpqvxq6bf4zn4jp64hry0q2m6scmkdpwk5qn7zjpq6wsxrkx92";
                    };
                    vorbis = {
                      url = "https://github.com/emscripten-ports/vorbis/archive/version_1.zip";
                      sha256 = "sha256:0zpyd52qf2as3f731bbkx9h2sqkgswwz0x8krc4v2210hr8slz5j";
                    };
                    sdl2 = {
                      url = "https://github.com/libsdl-org/SDL/archive/release-2.24.2.zip";
                      sha256 = "sha256:1nksfcga49xwg26ax15hvk4k0q3slvnahpil69zpb2y24kdxycyw";
                    };
                    sdl2_mixer = {
                      url = "https://github.com/libsdl-org/SDL_mixer/archive/release-2.0.4.zip";
                      sha256 = "sha256:0n64sfp5254rn812b95zfl9pdyrgsfbqk0rz2dnwy9wmg2kxw270";
                    };
                    sdl2_net = {
                      url = "https://github.com/emscripten-ports/SDL2_net/archive/version_2.zip";
                      sha256 = "sha256:1g9m7qmjy56gqbmvqrr7i917qrg8zrs31b5ldvzipybqla7az37w";
                    };
                  };
                };
                port = mkOption {
                  type = types.int;
                  default = 3000;
                };
                outputs = {
                  site = mkOption {
                    type = types.attrs;
                    default =
                      pkgs.buildEmscriptenPackage {
                        name = "doom-wasm";

                        buildInputs = with pkgs; [
                          pkg-config
                          ccls
                          autoconf
                          python3
                          nodejs_20
                          automake
                          gnumake
                          emscripten
                          unar
                          unzip
                        ];

                        inherit (config) src;

                        configurePhase = ''
                          export EM_CACHE=$TMPDIR/.emscriptencache
                          mkdir -p $EM_CACHE/ports
                          pushd $EM_CACHE/ports
                          ${lib.concatStrings (builtins.attrValues (builtins.mapAttrs (name: value: ''
                               mkdir ${name}
                               pushd ${name}
                               echo ${value.url} > .emscripten_url
                               unar ${builtins.fetchurl value}
                               popd
                             '')
                           config.dependencies))}
                           popd
                           emconfigure autoreconf -fiv
                           ac_cv_exeext=".html" emconfigure ./configure --host=none-none-none || cat config.log
                           echo "Checking for config.h..."
                           find . -name config.h || echo "config.h not found!"
                        '';

                        buildPhase = ''
                          emmake make
                        '';

                        installPhase = ''
                          mkdir -p $out
                          ${if (config.assets != null) then "cp ${config.assets}/* -r $out" else ""}
                          cp src/index.html $out
                          cp src/*.js $out
                          cp src/*.wasm $out
                          cp src/*.wasm.map $out
                        '';

                        checkPhase = ":";
                      };

                  };
                  server = mkOption {
                    type = types.path;
                    default = pkgs.writers.writeBashBin name ''
                      ${pkgs.simple-http-server}/bin/simple-http-server --port ${builtins.toString config.port} ${config.outputs.site}
                    '';
                  };
                };
              };
            }));
        };
      });
      config.perSystem = { config, ... }: {
        packages = caller.lib.mapAttrs (_: doom: doom.outputs.server.overrideAttrs (old: old // { inherit (doom.outputs) site; })) config.doom;
      };
    };
}
