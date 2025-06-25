{
  description = "WordPress flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      with pkgs;
      let
        versions = {
          wordpress_6_7_0 = (wordpress.overrideAttrs (oldAttrs: rec {
            version = "6.7";
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = "sha256-UDcayx3Leen0HHPcORZ+5cmvfod4BLOWB1HKd6j5rqM=";
            };
          }));
          wordpress_6_7_1 = (wordpress.overrideAttrs (oldAttrs: rec {
            version = "6.7.1";
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = "sha256-M1Kc1jjIRQB+jg0myR1gycFrgiyEnI3urQPQyFGibes=";
            };
          }));
          wordpress_6_7_2 = (wordpress.overrideAttrs (oldAttrs: rec {
            version = "6.7.2";
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = "sha256-z9nIPPqd2gNRiY6ptz9YmVyBeZSlQkvhh3f4PohqPPY=";
            };
          }));
          wordpress_6_8_0 = (wordpress.overrideAttrs (oldAttrs: rec {
            version = "6.8";
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = "sha256-99vtxCPds/Lz6Y6RQPFyC/1tSo9Ic8hdouYvageN4Qo=";
            };
          }));
          wordpress_6_8_1 = (wordpress.overrideAttrs (oldAttrs: rec {
            version = "6.8.1";
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = "sha256-PGVNB5vELE6C/yCmlIxFYpPhBLZ2L/fJ/JSAcbMxAyg=";
            };
          }));
        };
      in {
        devShells.default = mkShell { buildInputs = [ omnix ]; };
        packages = versions // { default = versions.wordpress_6_8_1; };
      });
}
