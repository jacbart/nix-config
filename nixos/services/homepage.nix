{ inputs, pkgs, ... }:
let
    homepage-bookmarks = pkgs.writeTextFile {
    name = "bookmarks.yaml";
    executable = false;
    destination = "/var/lib/private/homepage-dashboard/bookmarks.yaml";
    text = ''
---
# For configuration options and examples, please see:
# https://gethomepage.dev

- Information:
    - Github:
        - abbr: GH
          href: https://github.com/
    - StackOverflow:
        - abbr: SO
          href: https://stackoverflow.com/
    - Chatgpt:
        - abbr: CG
          href: https://app.chatgpt.com/

- Social:
    - Mastodon:
        - abbr: MD
          href: https://infosec.exchange/home

- Entertainment:
    - YouTube:
        - abbr: YT
          href: https://youtube.com/
    - Plex:
        - abbr: PL
          href: https://app.plex.tv/
    '';
  };
in
{
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/homepage-dashboard.nix" ];

  services.homepage-dashboard = {
    enable = true;
    package = pkgs.unstable.homepage-dashboard;
    openFirewall = true;
  };
  
  environment.systemPackages = [ homepage-bookmarks ];
}
