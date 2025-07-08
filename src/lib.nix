let WPConfigFormat = ./formats/wp-config;
in {
  inherit WPConfigFormat;
  mkWPConfig = { pkgs, lib, name, settings }:
    let
      settingsFormat = (import WPConfigFormat { inherit pkgs lib; }).format { };
    in settingsFormat.generate name settings;
}
