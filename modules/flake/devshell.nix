{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        nativeBuildInputs = with pkgs; [
          home-manager
          git
        ];
      };
    };
}
