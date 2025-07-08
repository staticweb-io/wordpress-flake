let WPConfigFormat = ./formats/wp-config;
in {
  inherit WPConfigFormat;
  mkWpConfig = { pkgs, lib, name, settings }:
    let
      settingsFormat = (import WPConfigFormat { inherit pkgs lib; }).format { };
    in settingsFormat.generate name settings;
}
