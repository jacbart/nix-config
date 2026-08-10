# Shared declarative Vivaldi PWAs for all desktops that ship Vivaldi.
{ ... }:
{
  imports = [ ../apps/vivaldi-pwa.nix ];

  vivaldiPwa = {
    enable = true;
    pwas = {
      # Remote icon (same URL your site serves; fixed-output fetch):
      # "My site" = {
      #   url = "https://your.domain/";
      #   iconUrl = "https://your.domain/apple-touch-icon.png";
      #   iconHash = "sha256-…"; # leave wrong → build prints correct hash
      #   profile = "isolated";
      # };
      # Theme / local path icon:
      # "ChatGPT" = { url = "https://chatgpt.com"; icon = "applications-internet"; };
      "Harmony" = {
        url = "https://chat.taybart.dev/";
        iconUrl = "https://chat.taybart.dev/appicon.png";
        iconHash = "sha256-HoofTS+prGX4jTyOMtXfmjN/qtdtQMpqLa5xzXfTurY=";
        profile = "default";
      };
      # meep.sh services. Icons must be direct 200s (fetchurl follows no
      # redirects; anything behind the SSO wall yields HTML and breaks the
      # build) — bin/files/wiki fall back to a theme icon for that reason.
      "Books" = {
        url = "https://books.meep.sh/";
        iconUrl = "https://books.meep.sh/favicon.ico";
        iconHash = "sha256-m5/vqsZ+/BYAFLuJOfXkDuIZAjwLF8xBbSrdLsLcFbY=";
        profile = "default";
      };
      "Calibre" = {
        url = "https://calibre.meep.sh/";
        iconUrl = "https://calibre.meep.sh/static/favicon.ico";
        iconHash = "sha256-h2noDRq6tWId74g4dncboK2JIJ7QL2tU3pxzwJtocFs=";
        profile = "default";
      };
      "Photos" = {
        url = "https://photos.meep.sh/";
        iconUrl = "https://photos.meep.sh/favicon.ico";
        iconHash = "sha256-EZKR6mzPzP0VswBD8DVwc9/Nzja+5nuv0tPA3YX0R8k=";
        profile = "default";
      };
      "Bin" = {
        url = "https://bin.meep.sh/";
        profile = "default";
      };
      "Files" = {
        url = "https://files.meep.sh/";
        profile = "default";
      };
      "Wiki" = {
        url = "https://wiki.meep.sh/";
        profile = "default";
      };
    };
  };
}
