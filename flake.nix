{
  description = "WordPress flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        function: nixpkgs.lib.genAttrs supportedSystems (system: function nixpkgs.legacyPackages.${system});
      ourLib = import ./src/lib.nix;
    in
    {
      devShells = forAllSystems (pkgs: {
        default =
          with pkgs;
          mkShell {
            buildInputs = [
              jq
              jsonfmt
              nix
              omnix
            ];
          };
      });
      lib = ourLib;
      packages = forAllSystems (
        pkgs:
        with pkgs;
        let
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
          latest = versions.wordpress_6_9_1;
          updaters = lib.attrsets.mapAttrs' (
            name: wordpress-source: lib.attrsets.nameValuePair ("update-" + name) (mkWPUpdater wordpress-source)
          ) versions;
        in
        versions
        // {
          default = latest;
        }
        // updaters
        // {
          update-wordpress = mkWPUpdater latest;
        }
      );
    };
}
