let
  WPConfigFormat = import ./formats/wp-config;
  defaultWPConfigSettings =
    { pkgs, lib }:
    let
      settingsFormat = (WPConfigFormat { inherit pkgs lib; }).format { };
    in
    {
      "$table_prefix" = settingsFormat.lib.mkInline ''
        /**
         * WordPress database table prefix.
         *
         * You can have multiple installations in one database if you give each
         * a unique prefix. Only numbers, letters, and underscores please!
         *
         * At the installation time, database tables are created with the specified prefix.
         * Changing this value after WordPress is installed will make your site think
         * it has not been installed.
         *
         * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
         */
        $table_prefix = 'wp_';
      '';
      ABS_PATH = settingsFormat.lib.mkInline ''
        /** Absolute path to the WordPress directory. */
        if ( ! defined( 'ABSPATH' ) ) {
            define( 'ABSPATH', __DIR__ . '/' );
        }
      '';
      DB_CHARSET = "utf8";
      DB_COLLATE = "";
      WP_DEBUG = false;
    };
in
{
  inherit WPConfigFormat;
  mkWPConfig =
    {
      pkgs,
      lib,
      name,
      settings,
    }:
    let
      defaultSettings = defaultWPConfigSettings { inherit pkgs lib; };
      settingsFormat = (WPConfigFormat { inherit pkgs lib; }).format { };
    in
    settingsFormat.generate name (defaultSettings // settings);
}
