# Adapted from
# https://github.com/NixOS/nixpkgs/blob/b43c397f6c213918d6cfe6e3550abfe79b5d1c51/pkgs/servers/web-apps/wordpress/generic.nix

{
  lib,
  version,
  hash,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation rec {
  pname = "wordpress";
  inherit version;

  src = fetchzip {
    url = "https://wordpress.org/${pname}-${version}.tar.gz";
    inherit hash;
  };

  installPhase = ''
    runHook preInstall

    # remove non-essential plugins
    rm -r wp-content/plugins
    mkdir wp-content/plugins
    cat << EOF > wp-content/plugins/index.php
    <?php
    // Silence is golden.
    EOF

    mkdir -p $out/share/wordpress
    cp -r . $out/share/wordpress

    runHook postInstall
  '';
}
