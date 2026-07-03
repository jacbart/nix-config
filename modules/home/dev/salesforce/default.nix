# Salesforce development: Apex/LWC/SOQL/SOSL toolchain + Helix wiring.
# Toggle per host by adding/removing this module in modules/hosts/<host>/home.nix.
{ config, pkgs, ... }:
{
  imports = [ ./options.nix ];
  dev.salesforce.enable = true;

  home.packages = with pkgs; [
    apex-jorje-lsp # Apex LSP (jar + bundled JVM wrapper: `apex-lsp`)
    lwc-language-server
    prettier-apex
    sf-cli
    jdk21 # for `sf apex run test` etc.; the LSP wrapper carries its own JDK
    scripts.apex-impls # rg-based goto-implementation substitute (see comment below)
  ];

  # Nix-built grammars + vendored queries into the user Helix runtime.
  # nixpkgs' hx is wrapped with HELIX_RUNTIME pointing at its bundled runtime,
  # but lookup is per-file and falls through to ~/.config/helix/runtime for
  # anything not bundled (apex/soql/sosl are not — if a future helix release
  # bundles them, its copies take precedence over these).
  home.file = {
    "${config.xdg.configHome}/helix/runtime/grammars/apex.so".source =
      "${pkgs.tree-sitter-sfapex}/apex.so";
    "${config.xdg.configHome}/helix/runtime/grammars/soql.so".source =
      "${pkgs.tree-sitter-sfapex}/soql.so";
    "${config.xdg.configHome}/helix/runtime/grammars/sosl.so".source =
      "${pkgs.tree-sitter-sfapex}/sosl.so";
    # highlights/locals vendored from aheber/tree-sitter-sfapex @ 27a3091 (same
    # rev as the grammar build in modules/pkgs/tree-sitter-sfapex); apex/soql
    # highlights remapped from VS Code semantic-token captures to native Helix
    # theme scopes. apex textobjects/indents are authored in-repo (upstream ships
    # none), adapted from Helix's bundled java queries.
    "${config.xdg.configHome}/helix/runtime/queries/apex/highlights.scm".source =
      ./queries/apex/highlights.scm;
    "${config.xdg.configHome}/helix/runtime/queries/apex/locals.scm".source = ./queries/apex/locals.scm;
    "${config.xdg.configHome}/helix/runtime/queries/apex/textobjects.scm".source =
      ./queries/apex/textobjects.scm;
    "${config.xdg.configHome}/helix/runtime/queries/apex/indents.scm".source =
      ./queries/apex/indents.scm;
    "${config.xdg.configHome}/helix/runtime/queries/soql/highlights.scm".source =
      ./queries/soql/highlights.scm;
    "${config.xdg.configHome}/helix/runtime/queries/sosl/highlights.scm".source =
      ./queries/sosl/highlights.scm;
  };

  # Merges with shell/tools/helix-langs.nix: language-server attrs merge by key,
  # language lists concatenate. Only add NEW language names here — redeclaring an
  # existing one (e.g. javascript) would emit a duplicate [[language]] block.
  programs.helix.languages = {
    language-server = {
      # Salesforce Apex Language Server (JVM stdio LSP).
      #
      # Navigation reality (ServerCapabilities probed from apex-jorje 67.3.0):
      # advertised — definition (gd), references (gr), rename (space+r),
      # documentSymbol (space+s), hover, completion, codeAction, codeLens.
      # NOT advertised — implementation (gi), typeDefinition (gy),
      # workspaceSymbol (space+S), foldingRange. No Apex LSP anywhere supports
      # goto-implementation (Salesforce's new TS server and apex-dev-tools/
      # apex-ls also lack it). Substitutes, both verified:
      #   - `gr` on an interface METHOD lists the implementing methods (jorje's
      #     reference index includes them alongside the declaration).
      #   - `apex-impls <Type>` (scripts.apex-impls) greps implements/extends
      #     declarations for the TYPE level.
      # LSP features need hx opened at an sfdx project root (sfdx-project.json)
      # and the first JVM index to finish (slow start).
      apex-lsp = {
        command = "apex-lsp";
        timeout = 60;
      };
      # Salesforce LWC Language Server (Node stdio LSP). Serves BOTH the .js
      # component class AND the .html template (lightning-*/c-* tag completions,
      # lwc:if / for:each directives) — but only for files under an lwc/<name>/
      # dir inside an sfdx workspace; elsewhere it stays silent. Wired to the
      # javascript and html languages in shell/tools/helix-langs.nix behind the
      # salesforce flag. TypeScript LWC is still flag-gated upstream (not GA).
      # Related DX, per project (not nix-managed): lint rules come from the
      # project's own @salesforce/eslint-config-lwc devDependency (standard sfdx
      # scaffold), tests via sfdx-lwc-jest (`npm run test:unit`), local preview
      # via `sf lightning dev app`.
      lwc-lsp = {
        command = "lwc-language-server";
        args = [ "--stdio" ];
        timeout = 60;
        # Don't start for js/html outside sfdx projects (the server errors with
        # "unknown workspace type" anywhere else).
        required-root-patterns = [ "sfdx-project.json" ];
      };
      # ESLint diagnostics/code-actions for LWC javascript (server binary ships
      # with vscode-langservers-extracted in helix-packages.nix; it resolves the
      # eslint install + config from the project's node_modules, so it no-ops in
      # projects without one).
      eslint = {
        command = "vscode-eslint-language-server";
        args = [ "--stdio" ];
        # Only start where a node project exists to resolve eslint from.
        required-root-patterns = [ "package.json" ];
        config = {
          validate = "on";
          run = "onType";
          quiet = false;
          nodePath = "";
          rulesCustomizations = [ ];
          experimental = { };
          problems.shortenToSingleLine = false;
          codeActionsOnSave = {
            mode = "all";
            "source.fixAll.eslint" = true;
          };
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation.enable = true;
          };
          workingDirectory.mode = "auto";
        };
      };
    };
    language = [
      {
        name = "apex";
        scope = "source.apex";
        file-types = [
          "cls"
          "trigger"
          "apex"
        ];
        roots = [ "sfdx-project.json" ];
        comment-token = "//";
        block-comment-tokens = {
          start = "/*";
          end = "*/";
        };
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        language-servers = [ "apex-lsp" ];
        formatter = {
          command = "prettier-apex";
          args = [
            "--parser=apex"
            "--stdin-filepath"
            "%{buffer_name}"
          ];
        };
        auto-format = true;
      }
      {
        name = "soql";
        scope = "source.soql";
        file-types = [ "soql" ];
        comment-token = "--";
      }
      {
        name = "sosl";
        scope = "source.sosl";
        file-types = [ "sosl" ];
        comment-token = "--";
      }
    ];
  };
}
