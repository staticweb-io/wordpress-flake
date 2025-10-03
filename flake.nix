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
          wordpress_6_4_0 = {
            version = "6.4";
            sha256 = "sha256-1yy+jedKjpPSRTCmgx4Zz05fXDNPmRUTJf2gMIcY8Tc=";
          };
          wordpress_6_4_1 = {
            version = "6.4.1";
            sha256 = "sha256-NF3tvVNUYlKPvtvJZzM7djGflOUT4VUlm4AyHPFzfdw=";
          };
          wordpress_6_4_2 = {
            version = "6.4.2";
            sha256 = "sha256-m4KJELf5zs3gwAQPmAhoPe2rhopZFsYN6OzAv6Wzo6c=";
          };
          wordpress_6_4_3 = {
            version = "6.4.3";
            sha256 = "sha256-PwjHHRlwhEH9q94bPq34NnQv3uhm1kOpjRAu0/ECaYY=";
          };
          wordpress_6_4_4 = {
            version = "6.4.4";
            sha256 = "sha256-aLOO/XgjI3d/+1BpHDT2pGR697oceghjzOId1MjC+wQ=";
          };
          wordpress_6_4_5 = {
            version = "6.4.5";
            sha256 = "sha256-T4fp7uYoc/eo+pCfzSmIY0AbyR2LcDLl6iJHY6kxxso=";
          };
          wordpress_6_4_6 = {
            version = "6.4.6";
            sha256 = "sha256-vUtofIev94qNAOmmG6zCGMdW7jVKhyU5J1Ki3zS/CAg=";
          };
          wordpress_6_4_7 = {
            version = "6.4.7";
            sha256 = "sha256-Zs3ylcnzQbVN0QJklAbs5/FA/XDLnts/rCESpjIstBw=";
          };
          wordpress_6_5_0 = {
            version = "6.5";
            sha256 = "sha256-NCRWKIrhSMC6itw2y/WJUd2LSRtnVWkmVO/b2nEJK58=";
          };
          # 6.5.1 does not exist on wordpress.org
          # https://make.wordpress.org/core/2024/04/09/what-happened-to-wordpress-6-5-1/
          wordpress_6_5_2 = {
            version = "6.5.2";
            sha256 = "sha256-APBO7hO9iuDGOP/IvB0dLAwby0PU7LPFth4IUXNQe9I=";
          };
          wordpress_6_5_3 = {
            version = "6.5.3";
            sha256 = "sha256-UmwP+d71MR0YneVjYHcONCmAUDbQdUpb0RvU3sygymw=";
          };
          wordpress_6_5_4 = {
            version = "6.5.4";
            sha256 = "sha256-HsgnmdN8MxN0F5v3BDFQzxvX2AgC/Ke0+Nz01Fkty7Q=";
          };
          wordpress_6_5_5 = {
            version = "6.5.5";
            sha256 = "sha256-bIRmTqmzIRo1KdhAcJa1GxhVcTEiEaLFPzlNFbzfLcQ=";
          };
          wordpress_6_5_6 = {
            version = "6.5.6";
            sha256 = "sha256-bE4aCeQB09WOpWFnopRZd1wf1z3Z1Rfip2taoUu46pg=";
          };
          wordpress_6_5_7 = {
            version = "6.5.7";
            sha256 = "sha256-mPL4vwnQscUJuGZXdZOJZjqVrjrtJTDLFk3IYTZ38Pk=";
          };
          wordpress_6_6_0 = {
            version = "6.6";
            sha256 = "sha256-pfg4R53RRvkXOnA2NRWz3DSi51LM9txUTeoLND7yWQk=";
          };
          wordpress_6_6_1 = {
            version = "6.6.1";
            sha256 = "sha256-YW6BhlP48okxLrpsJwPgynSHpbdRqyMoXaq9IBd8TlU=";
          };
          wordpress_6_6_2 = {
            version = "6.6.2";
            sha256 = "sha256-JpemjLPc9IP0/OiASSVpjHRmQBs2n8Mt4nB6WcTCB9Y=";
          };
          wordpress_6_6_3 = {
            version = "6.6.3";
            sha256 = "sha256-nsm/osnMCKc+NhRVvxTJmyGpTp2PU21YYX3d8HHOD3c=";
          };
          wordpress_6_6_4 = {
            version = "6.6.4";
            sha256 = "sha256-/E60CprbRRa7P1t4ZHcRfIxpgeSnHrAGlior/6Etayc=";
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
          wordpress_6_7_3 = {
            version = "6.7.3";
            sha256 = "sha256-zWLpZ/NKla1u4CHh2Bu0P7UmFWvnuTUheRq6Bq5NZjU=";
          };
          wordpress_6_7_4 = {
            version = "6.7.4";
            sha256 = "sha256-QvHovW5Z91zORnhv9edngOD6GhiuBF+13v3ep6MDWrM=";
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
