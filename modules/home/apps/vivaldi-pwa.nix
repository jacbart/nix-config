# Declarative Vivaldi app windows: Chromium-compatible --app= plus optional profile isolation.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vivaldiPwa;

  sanitize = s: lib.strings.sanitizeDerivationName (lib.strings.toLower s);

  normalizeIcon = icon: if builtins.isPath icon then toString icon else icon;

  resolveIcon =
    app:
    if app.iconUrl != null then
      toString (
        pkgs.fetchurl {
          url = app.iconUrl;
          hash = app.iconHash;
        }
      )
    else
      normalizeIcon app.icon;

  getProfile =
    {
      appId,
      profile,
      profileDirectory,
    }:
    let
      homeDir = config.home.homeDirectory;
      kind =
        if profile == null || profile == "isolated" then
          "isolated"
        else if profile == "default" then
          "default"
        else
          "named";

      userDataDir =
        if kind == "isolated" then
          "${homeDir}/.config/vivaldi-pwas/${appId}"
        else if kind == "default" then
          "${homeDir}/.config/vivaldi"
        else
          "${homeDir}/.config/vivaldi-profiles/${sanitize profile}";

      finalProfileDirectory = if profileDirectory != null then profileDirectory else "Default";
    in
    {
      inherit kind userDataDir;
      profileDirectory = finalProfileDirectory;
    };

  mkPwa =
    name: app:
    assert (app.iconUrl == null) == (app.iconHash == null);
    let
      safeName = sanitize name;
      appId = "vivaldi.pwa.${safeName}";
      launcherName = "vivaldi-pwa-${safeName}";
      pwaProfile = getProfile {
        inherit appId;
        profile = app.profile;
        profileDirectory = app.profileDirectory;
      };
      vivaldi = cfg.package;
      iconPath = resolveIcon app;
      wrapper = pkgs.writeShellScriptBin launcherName ''
        set -euo pipefail
        exec ${lib.escapeShellArg "${vivaldi}/bin/vivaldi"} \
          --user-data-dir=${lib.escapeShellArg pwaProfile.userDataDir} \
          --profile-directory=${lib.escapeShellArg pwaProfile.profileDirectory} \
          --class=${lib.escapeShellArg appId} \
          --app=${lib.escapeShellArg app.url} \
          "$@"
      '';
      categoriesStr = lib.concatStringsSep ";" app.categories;
    in
    {
      inherit wrapper launcherName appId;
      desktopText = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${name}
        Exec=${wrapper}/bin/${launcherName} %U
        Icon=${iconPath}
        Terminal=false
        Categories=${categoriesStr}
        StartupWMClass=${appId}
      '';
    };
in
{
  options.vivaldiPwa = {
    enable = lib.mkEnableOption "declarative Vivaldi PWAs (desktop entries + launchers)";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Vivaldi package used for PWAs.";
      default = pkgs.unstable.vivaldi;
    };

    pwas = lib.mkOption {
      description = ''
        PWA definitions keyed by display name.

        profile:
        - null or "isolated": separate user-data-dir under ~/.config/vivaldi-pwas/<id>
        - "default": share main Vivaldi profile (~/.config/vivaldi)
        - other string: named profile under ~/.config/vivaldi-profiles/<name>
      '';
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                description = "Start URL for --app=.";
              };
              icon = lib.mkOption {
                type = lib.types.either lib.types.path lib.types.str;
                default = "applications-internet";
                description = ''
                  Icon theme name or local path. Ignored when iconUrl is set (use fetchurl for remote icons).
                '';
              };
              iconUrl = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                example = "https://example.com/apple-touch-icon.png";
                description = ''
                  If set, icon is fetched at build time with fetchurl (fixed-output).
                  Set iconHash to the SRI hash; omit iconUrl/iconHash to use icon instead.
                '';
              };
              iconHash = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "SRI hash for iconUrl (required when iconUrl is set).";
              };
              categories = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "Network"
                  "WebBrowser"
                ];
              };
              profile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Profile strategy: isolated (default), default, or named instance.";
              };
              profileDirectory = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Chromium profile folder name (usually Default).";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable (
    let
      pwaDefs = lib.mapAttrs mkPwa cfg.pwas;
    in
    {
      home.packages = lib.attrValues (lib.mapAttrs (_: v: v.wrapper) pwaDefs);

      xdg.dataFile = lib.mapAttrs' (
        _: v: lib.nameValuePair "applications/${v.launcherName}.desktop" { text = v.desktopText; }
      ) pwaDefs;
    }
  );
}
