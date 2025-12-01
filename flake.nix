{
  description = "WordPress flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      with import nixpkgs { inherit system; };
      with pkgs;
      let
        versions = lib.attrsets.mapAttrs (
          name: data:
          (import ./src/wordpress.nix {
            inherit (pkgs) lib stdenv fetchurl;
            version = data.version;
            hash = data.sha256;
          })
        ) (lib.importJSON (self + "/wordpress-versions.json"));
        latest = versions.wordpress_6_8_3;
        gen-update-wordpress =
          wordpress-source:
          replaceVarsWith {
            dir = "bin";
            isExecutable = true;
            meta.mainProgram = "update-wordpress";
            name = "update-wordpress";
            replacements = {
              inherit bash wordpress-source;
              path = lib.makeBinPath [
                coreutils
                util-linux
              ];
            };
            src = ./src/update-wordpress.sh;
          };
        updaters = lib.attrsets.mapAttrs' (
          name: wordpress-source:
          lib.attrsets.nameValuePair ("update-" + name) (gen-update-wordpress wordpress-source)
        ) versions;
      in
      {
        devShells.default = mkShell { buildInputs = [ omnix ]; };
        lib = import ./src/lib.nix;
        packages =
          versions
          // {
            default = latest;
          }
          // updaters
          // {
            update-wordpress = gen-update-wordpress latest;
          };
      }
    );
}
