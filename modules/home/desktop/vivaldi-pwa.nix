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
    };
  };
}
