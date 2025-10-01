{
  description = "WordPress flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      with pkgs;
      let
        version_data = {
          wordpress_6_4_5 = {
            version = "6.4.5";
            sha256 = "sha256-T4fp7uYoc/eo+pCfzSmIY0AbyR2LcDLl6iJHY6kxxso=";
          };
          wordpress_6_5_5 = {
            version = "6.5.5";
            sha256 = "sha256-bIRmTqmzIRo1KdhAcJa1GxhVcTEiEaLFPzlNFbzfLcQ=";
          };
          wordpress_6_6_2 = {
            version = "6.6.2";
            sha256 = "sha256-JpemjLPc9IP0/OiASSVpjHRmQBs2n8Mt4nB6WcTCB9Y=";
          };
          wordpress_6_7_0 = {
            version = "6.7";
            sha256 = "sha256-UDcayx3Leen0HHPcORZ+5cmvfod4BLOWB1HKd6j5rqM=";
          };
          wordpress_6_7_1 = {
            version = "6.7.1";
            sha256 = "sha256-M1Kc1jjIRQB+jg0myR1gycFrgiyEnI3urQPQyFGibes=";
          };
          wordpress_6_7_2 = {
            version = "6.7.2";
            sha256 = "sha256-z9nIPPqd2gNRiY6ptz9YmVyBeZSlQkvhh3f4PohqPPY=";
          };
          wordpress_6_8_0 = {
            version = "6.8";
            sha256 = "sha256-99vtxCPds/Lz6Y6RQPFyC/1tSo9Ic8hdouYvageN4Qo=";
          };
          wordpress_6_8_1 = {
            version = "6.8.1";
            sha256 = "sha256-PGVNB5vELE6C/yCmlIxFYpPhBLZ2L/fJ/JSAcbMxAyg=";
          };
          wordpress_6_8_2 = {
            version = "6.8.2";
            sha256 = "sha256-2Fpy45K/6GaBazwuvGpEaZByqlDMOmIPHE7S8TtkXis=";
          };
          wordpress_6_8_3 = {
            version = "6.8.3";
            sha256 = "sha256-kto0yZYOZNElhlLB73PFF/fkasbf0t/HVDbThVr0aww=";
          };
        };
        versions = lib.attrsets.mapAttrs (name: data:
          (import ./src/wordpress.nix {
            inherit (pkgs) lib stdenv fetchurl;
            version = data.version;
            hash = data.sha256;
          })) version_data;
        latest = versions.wordpress_6_8_3;
        gen-update-wordpress = wordpress-source:
          replaceVarsWith {
            dir = "bin";
            isExecutable = true;
            meta.mainProgram = "update-wordpress";
            name = "update-wordpress";
            replacements = {
              inherit bash wordpress-source;
              path = lib.makeBinPath [ coreutils util-linux ];
            };
            src = ./src/update-wordpress.sh;
          };
        updaters = lib.attrsets.mapAttrs' (name: wordpress-source:
          lib.attrsets.nameValuePair ("update-" + name)
          (gen-update-wordpress wordpress-source)) versions;
      in {
        devShells.default = mkShell { buildInputs = [ omnix ]; };
        lib = import ./src/lib.nix;
        packages = versions // {
          default = latest;
        } // updaters // {
          update-wordpress = gen-update-wordpress latest;
        };
      });
}
