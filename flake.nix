{
  description = "WordPress flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        ourLib = import ./src/lib.nix;
        mkWPUpdater =
          wordpress-source:
          (ourLib.mkWPUpdater {
            inherit
              lib
              pkgs
              replaceVarsWith
              wordpress-source
              ;
          });
        versions = lib.attrsets.mapAttrs (
          name: data:
          (import ./src/wordpress.nix {
            inherit (pkgs) lib stdenv fetchzip;
            version = data.version;
            hash = data.hash;
          })
        ) (lib.importJSON (self + "/wordpress-versions.json"));
        latest = versions.wordpress_6_9_0;
        updaters = lib.attrsets.mapAttrs' (
          name: wordpress-source: lib.attrsets.nameValuePair ("update-" + name) (mkWPUpdater wordpress-source)
        ) versions;
      in
      {
        devShells.default = mkShell {
          buildInputs = [
            jq
            jsonfmt
            nix
            omnix
          ];
        };
        lib = ourLib;
        packages =
          versions
          // {
            default = latest;
          }
          // updaters
          // {
            update-wordpress = mkWPUpdater latest;
          };
      }
    );
}
