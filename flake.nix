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
        };
        versions = lib.attrsets.mapAttrs (name: data:
          (wordpress.overrideAttrs (oldAttrs: rec {
            version = data.version;
            src = fetchurl {
              url = "https://wordpress.org/wordpress-${version}.tar.gz";
              sha256 = data.sha256;
            };
          }))) version_data;
        latest = versions.wordpress_6_8_1;
        # write a bash script as a binary
        update-wordpress = writeShellApplication {
          name = "update-wordpress";
          runtimeInputs = [ ];

          text = ''
            usage() {
              cat <<EOF
            Usage: $0 [OPTIONS] [WPDIR]

            Options:
              -s, --src DIR     Path to the source WordPress files (default: ${latest}/share/wordpress)
              -h, --help        Show this help message and exit
            EOF
            }

            if ! OPTS=$(getopt -o s:w:h --long src:,wp:,help -n 'parse-options' -- "$@"); then
              usage >&2
              exit 1
            fi

            eval set -- "$OPTS"

            SRCDIR=""
            WPDIR=""

            while true; do
              case "$1" in
                -s|--src)
                  SRCDIR="$2"
                  shift 2
                  ;;
                -h|--help)
                  usage
                  exit 0
                  ;;
                --)
                  shift
                  break
                  ;;
                *)
                  echo "Unknown option: $1" >&2
                  usage >&2
                  exit 1
                  ;;
              esac
            done

            if [ -z "$SRCDIR" ]; then
              SRCDIR="${latest}/share/wordpress"
            fi

            if [ $# -gt 0 ]; then
              WPDIR="$1"
            fi

            if [ -z "$WPDIR" ]; then
              WPDIR="$(pwd)"
            fi

            cd "$WPDIR"

            if [ ! -f "wp-config.php" ] && [ ! -f "wp-config-sample.php" ]; then
              echo "Error: '$WPDIR' does not contain a WordPress installation." >&2
              exit 1
            fi

            echo "Using SRCDIR: $SRCDIR"
            echo "Using WPDIR: $WPDIR"

            TMPDIR=$(mktemp -d)

            cp -r "$SRCDIR"/wp-includes "$SRCDIR"/wp-admin "$SRCDIR"/wp-content "$SRCDIR"/*.* "$TMPDIR"
            chmod ug+w -R "$TMPDIR"

            set -o noclobber
            true > .maintenance
            set +o noclobber
            rm -rf wp-includes wp-admin

            cp -r "$TMPDIR"/* .

            rm .maintenance
          '';
        };
      in {
        devShells.default = mkShell { buildInputs = [ omnix ]; };
        packages = versions // {
          default = latest;
        } // {
          inherit update-wordpress;
        };
      });
}
