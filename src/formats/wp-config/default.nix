# Adapted from
# https://github.com/NixOS/nixpkgs/blob/4a0129eb7df9ed01143f723a7616aaad3a3037e2/pkgs/pkgs-lib/formats/php/default.nix

{ pkgs, lib }: {
  format = { }:
    let
      toPHP = value:
        {
          "null" = "null";
          "bool" = if value then "true" else "false";
          "int" = toString value;
          "float" = toString value;
          "string" = string value;
          "set" = attrs value;
          "list" = list value;
        }.${builtins.typeOf value} or (abort
          "should never happen: unknown value type ${builtins.typeOf value}");

      # https://www.php.net/manual/en/language.types.string.php#language.types.string.syntax.single
      escapeSingleQuotedString = lib.escape [ "'" "\\" ];
      string = value: "'${escapeSingleQuotedString value}'";

      listContent = values: lib.concatStringsSep ", " (map toPHP values);
      list = values: "[" + (listContent values) + "]";

      attrsContent = values:
        lib.pipe values [
          (lib.mapAttrsToList (k: v: "${toPHP k} => ${toPHP v}"))
          (lib.concatStringsSep ", ")
        ];
      attrs = set:
        if set ? _phpType then
          specialType set
        else
          "[" + attrsContent set + "]";

      mixedArray = { list, set }:
        if list == [ ] then
          attrs set
        else
          "[${listContent list}, ${attrsContent set}]";

      specialType = { value, _phpType }:
        {
          "mixed_array" = mixedArray value;
          "raw" = value;
        }.${_phpType};

      type = with lib.types;
        nullOr (oneOf [ bool int float str (attrsOf type) (listOf type) ]) // {
          description = "PHP value";
        };
    in {

      inherit type;

      lib = {
        mkMixedArray = list: set: {
          _phpType = "mixed_array";
          value = { inherit list set; };
        };
        mkRaw = raw: {
          _phpType = "raw";
          value = raw;
        };
      };

      generate = name: attrs:
        pkgs.writeTextFile {
          inherit name;
          text = let
            phpHeader = ''
              <?php
              /**
               * The base configuration for WordPress
               *
               * This file is auto-generated.
               *
               * @link https://codex.wordpress.org/Editing_wp-config.php
               *
               * @package WordPress
               */
            '';

            defines = lib.concatStringsSep "\n" (lib.mapAttrsToList
              (key: val: "define(${toPHP key}, ${toPHP val});") attrs);
          in phpHeader + "\n" + defines + "\n";
        };

    };
}
