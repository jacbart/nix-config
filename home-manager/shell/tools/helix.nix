{ config
, pkgs
, ...
}: {
  home = {
    packages = with pkgs; [
      # my personally most used lsp's for helix
      dockerfile-language-server-nodejs # dockerfile language server
      gofumpt # go formatter
      gopls # go language server
      # helix-gpt # code completion LSP for LLM's in Helix
      # lsp-ai # code completion LSP for LLM's
      # marksman # markdown language server
      markdown-oxide # markdown language server
      nil # nix language server
      nixfmt-rfc-style # nix formatter
      nodePackages.prettier # code formatter
      serpl # find and replace
      shfmt # Bash formatter
      stylua # lua formatter
      sqls # SQL language server
      taplo # TOML language server
      terraform-ls # language server for [ .hcl, .tf, .tfvars, .koi, .jaws ]
      typescript-language-server # Typescript
      vscode-langservers-extracted # [ vscode-css-language-server vscode-eslint-language-server vscode-html-language-server vscode-json-language-server vscode-markdown-language-server ]
      yaml-language-server # YAML language server
    ];

    file."${config.xdg.configHome}/sqls/config.yml".text = builtins.readFile ./sqls.yaml;

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
          sqls = {
            command = "sqls";
          };
          # lsp-ai = {
          #   command = "lsp-ai";
          #   config = {
          #     memory = {
          #       file_store = { };
          #     };
          #     models.model1 = {
          #       type = "ollama";
          #       model = "qwen2.5-coder:1.5b-base";
          #       # chat_endpoint = "https://llm.bbl.systems/api/chat";
          #       # generate_endpoint = "https://llm.bbl.systems/api/generate";
          #       max_requests_per_second = "128";
          #     };
          #     completion = {
          #       model = "model1";
          #       parameters = {
          #         max_tokens = 64;
          #         max_context = 1024;
          #         options = {
          #           num_predict = 32;
          #         };
          #       };
          #     };
          #   };
          # };
          # gpt = {
          #   command = "helix-gpt";
          #   args = [
          #     "--handler"
          #     "ollama"
          #     "--ollamaEndpoint"
          #     "http://100.78.207.83:11434"
          #     "--ollamaModel"
          #     "phi4"
          #     "--logFile"
          #     "/tmp/helix-gpt.log"
          #   ];
          # };
          gopls = {
            command = "gopls";
            config = {
              gofumpt = true;
              local = "goimports";
              semanticTokens = true;
              staticcheck = true;
              verboseOutput = true;
              analyses = {
                # fieldalignment = true;
                nilness = true;
                unusedparams = true;
                unusedwrite = true;
                useany = true;
              };
              usePlaceholders = true;
              completeUnimported = true;
              hints = {
                assignVariableType = true;
                compositeLiteralFields = true;
                compositeLiteralTypes = true;
                constantValues = true;
                functionTypeParameters = true;
                parameterNames = true;
                rangeVariableTypes = true;
              };
              # buildFlags = [ "-tags=ignore" ];
            };
          };
        };
        language = [
          {
            name = "bash";
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            formatter = {
              command = "shfmt";
              args = [
                "-i"
                "2"
              ];
            };
            auto-format = true;
            # language-servers = [ "gpt" ];
          }
          {
            name = "go";
            roots = [
              "go.work"
              "go.mod"
            ];
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
            file-types = [
              "tf"
              "tfvars"
              "hcl"
              "koi"
              "jaws"
              "rest"
            ];
            auto-format = false;
          }
          {
            name = "json";
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "json"
              ];
            };
            # language-servers = [ "gpt" ];
          }
          {
            name = "javascript";
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "javascript"
              ];
            };
            auto-format = true;
            # language-servers = [ "gpt" ];
          }
          {
            name = "nix";
            auto-format = false;
            file-types = [ "nix" ];
            formatter.command = "nixfmt";
            language-servers = [ "nil" ];
          }
          {
            name = "markdown";
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "markdown"
              ];
            };
            auto-format = true;
            # language-servers = [ "lsp-ai" ];
          }
          {
            name = "html";
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "html"
              ];
            };
            # language-servers = [ "gpt" ];
          }
          {
            name = "css";
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "css"
              ];
            };
            # language-servers = [ "gpt" ];
          }
          {
            name = "lua";
            formatter = {
              command = "stylua";
              args = [
                "-"
              ];
            };
            # language-servers = [ "gpt" ];
          }
          {
            name = "sql";
            file-types = [ "sql" ];
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                ""
              ];
            };
            auto-format = false;
            language-servers = [ "sqls" ];
          }
          {
            name = "yaml";
            file-types = [
              "yaml"
              "yml"
            ];
            auto-format = true;
            # language-servers = [ "gpt" ];
          }
          {
            name = "rust";
            file-types = [ "rs" ];
            auto-format = true;
            language-servers = [ "rust-analyzer" ];
          }
          {
            name = "toml";
            formatter = {
              command = "taplo";
              args = [
                "format"
                "-"
              ];
            };
            auto-format = true;
            # language-servers = [ "gpt" ];
          }
          {
            name = "tsx";
            file-types = [
              "tsx"
              "typescript"
            ];
            auto-format = true;
            # language-servers = [ "gpt" ];
          }
        ];
      };
      settings = {
        theme = "gruvbox_dark_hard";
        keys.normal = {
          A = {
            g = [ ":run-shell-command git diff" ];
            # r = [ ":new" ":insert-output serpl" ":buffer-close!" ":redraw" ];
          };
          space = {
            i = ":toggle lsp.display-inlay-hints";
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };
        };
        editor = {
          shell = [
            "zsh"
            "-c"
          ];
          line-number = "absolute";
          mouse = true;
          scroll-lines = 1;
          popup-border = "all";
          color-modes = true;
          auto-pairs = true;
          bufferline = "always";
          auto-completion = true;
          path-completion = true;
          auto-format = true;
          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [ "file-name" ];
            right = [
              "diagnostics"
              "selections"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
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
