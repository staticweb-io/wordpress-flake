#! @bash@/bin/bash

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] [WPDIR]

Options:
  -s, --src DIR     Path to the source WordPress files (default: @wordpress-source@/share/wordpress)
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
  SRCDIR="@wordpress-source@/share/wordpress"
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
