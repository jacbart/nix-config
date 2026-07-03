{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        nativeBuildInputs = with pkgs; [
          home-manager
          git
        ];
      };

      # Portable per-project Salesforce (Apex/LWC/SOQL) toolchain. Reuses the same
      # custom packages the home module installs on hosts, but as an on-demand
      # shell: `nix develop .#salesforce` (or via the salesforce flake template).
      # Editor wiring (Helix LSP config, grammars, queries) is host-level and lives
      # in modules/home/dev/salesforce; this shell only vends the CLI toolchain.
      devShells.salesforce = pkgs.mkShell {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        packages = [
          self'.packages.sf-cli
          self'.packages.apex-jorje-lsp # provides `apex-lsp`
          self'.packages.lwc-language-server
          self'.packages.prettier-apex
          self'.packages.apex-impls
          pkgs.jdk21 # `sf apex run test`; the LSP wrapper carries its own JDK
          pkgs.nodejs_24 # npm / sfdx-lwc-jest / eslint in the project
          pkgs.git
          # Editor baseline: flake.nix, docs, config files (shared with the templates)
          pkgs.nil # nix LSP
          pkgs.nixfmt # nix formatter
          pkgs.markdown-oxide # markdown LSP
          pkgs.prettier # markdown/json/yaml formatter (distinct bin from prettier-apex)
          pkgs.yaml-language-server # CI (sfdx json handled by prettier)
        ];
        shellHook = ''
          echo "salesforce dev shell — sf, apex-lsp, lwc-language-server, prettier-apex, apex-impls"
        '';
      };
    };
}
