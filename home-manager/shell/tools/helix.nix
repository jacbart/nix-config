{
  config,
  pkgs,
  ...
}:
{
  # Home settings
  home = {
    packages = with pkgs; [
      # personally most used lsp's for helix
      delve # golang debugger
      dockerfile-language-server-nodejs # dockerfile language server
      gofumpt # go formatter
      gopls # go language server
      # llama-cpp # Inference of Meta's LLaMA model (and others) in pure C/C++
      # lsp-ai # code completion LSP for LLM's
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
      package = pkgs.unstable.helix;
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
          #     models = {
          #       # model1 = {
          #       #   type = "llama_cpp";
          #       #   repository = "Qwen/Qwen3-4B-GGUF";
          #       #   name = "Qwen3-4B-Q4_K_M.gguf";
          #       #   n_ctx = 4096;
          #       # };
          #       # model2 = {
          #       #   type = "llama_cpp";
          #       #   repository = "unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF";
          #       #   name = "DeepSeek-R1-0528-Qwen3-8B-Q4_K_M.gguf";
          #       #   n_ctx = 4096;
          #       # };
          #       model1 = {
          #         type = "ollama";
          #         model = "qwen3:1.7b";
          #       };
          #       model2 = {
          #         type = "ollama";
          #         model = "deepseek-r1:1.5b";
          #       };
          #     };
          #     completion = {
          #       model = "model1";
          #       parameters = {
          #         max_context = 4096;
          #         options = {
          #           num_predict = 32;
          #         };
          #       };
          #     };
          #     actions = [
          #       {
          #         action_display_name = "Complete";
          #         model = "model2";
          #         parameters = {
          #           max_context = 4096;
          #           max_tokens = 4096;
          #           system = "You are an AI coding assistant. Your task is to complete code snippets. The user's cursor position is marked by \"<CURSOR>\". Follow these steps:\n\n1. Analyze the code context and the cursor position.\n2. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include thoughts about the cursor position, what needs to be completed, and any necessary formatting.\n3. Determine the appropriate code to complete the current thought, including finishing partial words or lines.\n4. Replace \"<CURSOR>\" with the necessary code, ensuring proper formatting and line breaks.\n5. Wrap your code solution in <answer> tags.\n\nYour response should always include both the reasoning and the answer. Pay special attention to completing partial words or lines before adding new lines of code.";
          #           messages = [
          #             {
          #               role = "user";
          #               content = "{CODE}";
          #             }
          #           ];
          #         };
          #         # post_process = {
          #         #   extractor = "(?s)<answer>(.*?)</answer>";
          #         # };
          #       }
          #       {
          #         action_display_name = "Refactor";
          #         model = "model2";
          #         parameters = {
          #           max_context = 4096;
          #           max_tokens = 4096;
          #           system = "You are an AI coding assistant specializing in code refactoring. Your task is to analyze the given code snippet and provide a refactored version. Follow these steps:\n\n1. Analyze the code context and structure.\n2. Identify areas for improvement, such as code efficiency, readability, or adherence to best practices.\n3. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include your analysis of the current code and explain your refactoring decisions.\n4. Rewrite the entire code snippet with your refactoring applied.\n5. Wrap your refactored code solution in <answer> tags.\n\nYour response should always include both the reasoning and the refactored code.";
          #         };
          #         messages = [
          #           {
          #             role = "user";
          #             content = "{SELECTED_TEXT}";
          #           }
          #         ];
          #         # post_process = {
          #         #   extractor = "(?s)<answer>(.*?)</answer>";
          #         # };
          #       }
          #     ];
          #     chat = [
          #       {
          #         trigger = "!C";
          #         action_display_name = "Chat";
          #         model = "model2";
          #         parameters = {
          #           max_context = 4096;
          #           max_tokens = 1024;
          #           messages = [
          #             {
          #               role = "system";
          #               content = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do your best to answer succinctly and accurately given the code context:\n\n{CONTEXT}";
          #             }
          #           ];
          #         };
          #       }
          #     ];
          #   };
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
            language-servers = [
              "gopls"
              # "lsp-ai"
            ];
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
          }
          {
            name = "nix";
            auto-format = true;
            file-types = [ "nix" ];
            formatter.command = "nixfmt";
            language-servers = [
              "nil"
              # "lsp-ai"
            ];
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
          }
          {
            name = "lua";
            formatter = {
              command = "stylua";
              args = [
                "-"
              ];
            };
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
          }
          {
            name = "tsx";
            file-types = [
              "tsx"
              "typescript"
            ];
            auto-format = true;
          }
        ];
      };
      settings = {
        theme = "gruvbox_dark_hard";
        keys.normal = {
          A = {
            g = [ ":run-shell-command git diff" ];
          };
          "{" = [
            "goto_prev_paragraph"
            "collapse_selection"
          ];
          "}" = [
            "goto_next_paragraph"
            "collapse_selection"
          ];
          space = {
            B = ":echo %sh{git blame -L %{cursor_line},+1 %s{buffer_name}}";
            i = ":toggle lsp.display-inlay-hints";
            W = ":write";
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
