{ lib, ... }:
{
  _module.args = {
    vars = rec {
      domain = "meep.sh";
      email = "jacbart@gmail.com";
      timezone = "America/Phoenix";
      acmeDnsProvider = "cloudflare";
      lanSubnet = "10.120.0.0/24";
      lanGateway = "10.120.0.1";
      lanDomain = "lan.meep.sh";

      # NixOS hosts opted in to the hardened fail2ban profile: explicit sshd /
      # caddy-status / recidive jails plus a daily-fed scanner blocklist
      # (Shodan/Censys C2, Spamhaus DROP/EDROP, FireHOL L1–L3) dropped at the
      # firewall via ipset. Add a host's networking.hostName here to opt in.
      # The host must also import profileFail2ban (see
      # modules/nixos/service-profiles.nix); sshguard is automatically disabled
      # on these hosts (see modules/nixos/services/openssh.nix).
      hardenedHosts = [
        "oak"
        "maple"
        "mesquite"
      ];

      # Shared across nixos / home-manager / darwin nix.settings
      nixAllowedUris = [
        "github:"
        "git+https://github.com/"
        "git+https://git.vdx.hu/"
        "git+ssh://github.com/"
      ];

      nixSubstitutersPublic = [
        "https://nix-community.cachix.org"
        "https://nix-citizen.cachix.org"
        "https://cache.nixos.org"
      ];

      nixTrustedPublicKeysPublic = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      nixSubstitutersNixOS = [
        "https://nix-cache.${domain}"
      ]
      ++ nixSubstitutersPublic;

      nixTrustedPublicKeysNixOS = [
        "nix-cache.${domain}-1:q58+Lt6h68AmBke4wpJatSrpe1cZvDzVNDTp8qurEbs="
      ]
      ++ nixTrustedPublicKeysPublic;

      serviceCatalog = import ./service-catalog.nix { inherit domain; };
    };
    stateVersion = lib.mkDefault "25.11";
  };
}
