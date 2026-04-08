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

      # Shared across nixos / home-manager / darwin nix.settings
      nixAllowedUris = [
        "github:"
        "git+https://github.com/"
        "git+https://git.vdx.hu/"
        "git+ssh://github.com/"
      ];

      nixSubstitutersPublic = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      nixTrustedPublicKeysPublic = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
