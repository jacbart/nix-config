{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # my personally most used lsp's for helix
      dockerfile-language-server-nodejs # dockerfile language server
      gofumpt # go formatter
      gopls # go language server
      nil # nix language server
      # marksman # markdown language server
      markdown-oxide # markdown language server
      # dprint # code formatter [ markdown ]
      taplo # TOML language server
      terraform-ls # language server for [ .hcl, .tf, .tfvars, .koi, .jaws ]
      yaml-language-server # YAML language server
      typescript-language-server # Typescript
      vscode-langservers-extracted # [ vscode-css-language-server vscode-eslint-language-server vscode-html-language-server vscode-json-language-server vscode-markdown-language-server ]
    ];

    # file.".dprint.json".text = ''
    # {
    #   "markdown": {
    #   },
    #   "plugins": [
    #     "https://plugins.dprint.dev/markdown-0.17.1.wasm",
    #   ]
    # }
    # '';

    sessionVariables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };
  programs = {
    helix = {
      enable = true;
      languages = {
        language-server = {
          gopls = {
            command = "gopls";
            config = {
              "gofumpt" = true;
              "local" = "goimports";
              "semanticTokens" = true;
              "staticcheck" = true;
              "verboseOutput" = true;
              "analyses" = {
                "fieldalignment" = true;
                "nilness" = true;
                unusedparams = true;
                unusedwrite = true;
                useany = true;
              };
              usePlaceholders = true;
              completeUnimported = true;
              hints = {
                "assignVariableType" = true;
                "compositeLiteralFields" = true;
                "compositeLiteralTypes" = true;
                "constantValues" = true;
                "functionTypeParameters" = true;
                "parameterNames" = true;
                "rangeVariableTypes" = true;
              };
            };
          };
        };
        language = [
          {
            name = "go";
            roots = [ "go.work" "go.mod" ];
            auto-format = true;
            comment-token = "//";
            block-comment-tokens = {
              start = "/*";
              end = "*/";
            };
            language-servers = [ "gopls" ];
          }
          {
            name = "hcl";
            file-types = [ "tf" "tfvars" "hcl" "koi" "jaws" ];
            auto-format = true;
          }
          #  {
          #   name = "markdown";
          #   formatter = { command = "dprint"; args = ["fmt" "--stdin" "md"]; };
          #   auto-format = true;
          # }
          {
            name = "yaml";
            file-types = [ "yaml" "yml" ];
            auto-format = true;
          }
          {
            name = "tsx";
            file-types = [ "tsx" "typescript" ];
            auto-format = true;
          }
        ];
      };
      settings = {
        theme = "gruvbox_dark_hard";
        editor = {
          shell = [ "zsh" "-c" ];
          line-number = "absolute";
          mouse = true;
          color-modes = true;
          auto-pairs = true;
          bufferline = "multiple";
          auto-completion = true;
          auto-format = true;
          statusline = {
            left = [ "mode" "spinner" ];
            center = [ "file-name" ];
            right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
            separator = "│";
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker = {
            hidden = false;
            git-ignore = true;
          };
          whitespace.render = {
            space = "none";
            tab = "none";
            newline = "none";
          };
          whitespace.characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
            tabpad = "·";
          };
          lsp.display-messages = true;
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
        };
      };
    };
  };
}
