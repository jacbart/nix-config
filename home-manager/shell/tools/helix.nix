{
  config,
  pkgs,
  ...
}:
let
  # helix = inputs.helix.packages.${pkgs.platform}.helix.overrideAttrs (prev: {
  #   patches = (prev.patches or [ ]) ++ [
  #     ./patches/helix/clickable-buffer.patch
  #   ];
  # });
  # helix = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix;
  helix = pkgs.unstable.helix;
  # custom-lsp-ai = pkgs.lsp-ai.overrideAttrs (oldAttrs: {
  #   cargoBuildFlags = oldAttrs.cargoBuildFlags or [ ] ++ [
  #     "--features"
  #     (
  #       if pkgs.stdenv.hostPlatform.isDarwin then
  #         "llama_cpp,metal"
  #       else if pkgs.stdenv.hostPlatform.isLinux then
  #         "llama_cpp"
  #       else
  #         "llama_cpp"
  #     )
  #   ];
  # });
in
{
  # Home settings
  home = {
    packages = with pkgs; [
      # personally most used lsp's for helix
      delve # golang debugger
      delta # A syntax-highlighting pager for git, diff, grep, and blame output
      dockerfile-language-server # dockerfile language server
      gofumpt # go formatter
      gopls # go language server
      jdt-language-server # java lsp
      # llama-cpp # Inference of Meta's LLaMA model (and others) in pure C/C++
      # custom-lsp-ai # code completion LSP for LLM's
      markdown-oxide # markdown language server
      nil # nix language server
      nixd # nix lsp
      nixfmt-rfc-style # nix formatter
      nodePackages.prettier # code formatter
      ruff # python language server/formatter etc
      serpl # find and replace
      shfmt # Bash formatter
      sqls # SQL language server
      steel # Embedded scheme interpreter in Rust
      stylua # lua formatter
      systemd-language-server # Language Server for Systemd unit files
      taplo # TOML language server
      terraform-ls # language server for [ .hcl, .tf, .tfvars, .koi, .jaws ]
      typescript-language-server # Typescript
      vscode-langservers-extracted # [ vscode-css-language-server vscode-eslint-language-server vscode-html-language-server vscode-json-language-server vscode-markdown-language-server ]
      yaml-language-server # YAML language server
      # yazi # file manager
    ];

    file."${config.xdg.configHome}/sqls/config.yml".text = builtins.readFile ./sqls.yaml;
    # file."${config.xdg.configHome}/helix/helix.scm".text = builtins.readFile ./helix/helix.scm;
    # file."${config.xdg.configHome}/helix/init.scm".text = builtins.readFile ./helix/init.scm;

    sessionVariables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };
  programs = {
    helix = {
      enable = true;
      package = helix;
      languages = {
        language-server = {
          sqls = {
            command = "sqls";
          };
          #   lsp-ai = {
          #     command = "lsp-ai";
          #     timeout = 60;
          #     environment = {
          #       "LSP_AI_LOG" = "debug";
          #     };
          #     config = {
          #       memory = {
          #         file_store = { };
          #       };
          #       models = {
          #         model1 = {
          #           type = "llama_cpp";
          #           repository = "Qwen/Qwen3-4B-GGUF";
          #           name = "Qwen3-4B-Q4_K_M.gguf";
          #           n_ctx = 4096;
          #           n_gpu_layers = -1; # Offload all layers to GPU
          #           main_gpu = 0; # Use first GPU
          #           tensor_split = [ ]; # Auto-balance across GPUs (single GPU on M5)
          #         };
          #         model2 = {
          #           type = "llama_cpp";
          #           repository = "unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF";
          #           name = "DeepSeek-R1-0528-Qwen3-8B-Q4_K_M.gguf";
          #           n_ctx = 4096;
          #           n_gpu_layers = -1; # Offload all layers to GPU
          #           main_gpu = 0; # Use first GPU
          #           tensor_split = [ ]; # Auto-balance across GPUs (single GPU on M5)
          #         };
          #       };
          #       completion = {
          #         model = "model1";
          #         parameters = {
          #           fim = {
          #             start = "<fim_prefix>";
          #             middle = "<fim_suffix>";
          #             end = "<fim_middle>";
          #           };
          #           max_context = 4096;
          #           options = {
          #             num_predict = 32;
          #           };
          #         };
          #       };
          #       actions = [
          #         {
          #           action_display_name = "Complete";
          #           model = "model2";
          #           parameters = {
          #             max_context = 4096;
          #             max_tokens = 4096;
          #             system = "You are an AI coding assistant. Your task is to complete code snippets. The user's cursor position is marked by \"<CURSOR>\". Follow these steps:\n\n1. Analyze the code context and the cursor position.\n2. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include thoughts about the cursor position, what needs to be completed, and any necessary formatting.\n3. Determine the appropriate code to complete the current thought, including finishing partial words or lines.\n4. Replace \"<CURSOR>\" with the necessary code, ensuring proper formatting and line breaks.\n5. Wrap your code solution in <answer> tags.\n\nYour response should always include both the reasoning and the answer. Pay special attention to completing partial words or lines before adding new lines of code.";
          #             messages = [
          #               {
          #                 role = "user";
          #                 content = "{CODE}";
          #               }
          #             ];
          #           };
          #         }
          #         {
          #           action_display_name = "Refactor";
          #           model = "model2";
          #           parameters = {
          #             max_context = 4096;
          #             max_tokens = 4096;
          #             system = "You are an AI coding assistant specializing in code refactoring. Your task is to analyze the given code snippet and provide a refactored version. Follow these steps:\n\n1. Analyze the code context and structure.\n2. Identify areas for improvement, such as code efficiency, readability, or adherence to best practices.\n3. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include your analysis of the current code and explain your refactoring decisions.\n4. Rewrite the entire code snippet with your refactoring applied.\n5. Wrap your refactored code solution in <answer> tags.\n\nYour response should always include both the reasoning and the refactored code.";
          #             messages = [
          #               {
          #                 role = "user";
          #                 content = "{SELECTED_TEXT}";
          #               }
          #             ];
          #           };
          #         }
          #       ];
          #       chat = [
          #         {
          #           trigger = "!C";
          #           action_display_name = "Chat";
          #           model = "model2";
          #           parameters = {
          #             max_context = 4096;
          #             max_tokens = 1024;
          #             messages = [
          #               {
          #                 role = "system";
          #                 content = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do your best to answer succinctly and accurately given the code context:\n\n{CONTEXT}";
          #               }
          #             ];
          #           };
          #         }
          #       ];
          #     };
          #   };
          #   gopls = {
          #     command = "gopls";
          #     config = {
          #       gofumpt = true;
          #       local = "goimports";
          #       semanticTokens = true;
          #       staticcheck = true;
          #       verboseOutput = true;
          #       analyses = {
          #         nilness = true;
          #         unusedparams = true;
          #         unusedwrite = true;
          #         useany = true;
          #       };
          #       usePlaceholders = true;
          #       completeUnimported = true;
          #       hints = {
          #         assignVariableType = true;
          #         compositeLiteralFields = true;
          #         compositeLiteralTypes = true;
          #         constantValues = true;
          #         functionTypeParameters = true;
          #         parameterNames = true;
          #         rangeVariableTypes = true;
          #       };
          #       # buildFlags = [ "-tags=stub" ];
          #     };
          #   };

          #   rust-analyzer = {
          #     command = "rust-analyzer";
          #     config.inlayHints = {
          #       bindingModeHints.enable = false;
          #       closingBraceHints.minLines = 10;
          #       closureReturnTypeHints.enable = "with_block";
          #       discriminantHints.enable = "fieldless";
          #       lifetimeElisionHints.enable = "skip_trivial";
          #       typeHints.hideClosureInitialization = false;
          #     };
          #   };
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
            name = "java";
            file-types = [
              "cls"
              "java"
            ];
            auto-format = true;
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
            name = "lua";
            formatter = {
              command = "stylua";
              args = [
                "-"
              ];
            };
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
            name = "python";
            file-types = [
              "py"
              "pyi"
              "pyw"
              "ptl"
              "rpy"
              "cpy"
              "ipy"
              "pyt"
              { glob = ".python_history"; }
              { glob = ".pythonrc"; }
            ];
            formatter = {
              command = "ruff";
              args = [
                "format"
                "-"
              ];
            };
            auto-format = true;
            language-servers = [
              "ruff"
              # "lsp-ai"
            ];
          }
          {
            name = "rust";
            scope = "source.rust";
            roots = [
              "Cargo.toml"
              "Cargo.lock"
            ];
            file-types = [ "rs" ];
            auto-format = true;
            language-servers = [
              "rust-analyzer"
              # "lsp-ai"
            ];
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
            language-servers = [
              "sqls"
              # "lsp-ai"
            ];
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
          {
            name = "yaml";
            file-types = [
              "yaml"
              "yml"
            ];
            auto-format = true;
          }
        ];
      };

      settings = {
        theme = "gruvbox_dark_hard";
        keys.normal = {
          # go back if select too many lines with x
          X = "select_line_above";
          # forward in undo history
          L = ":later";
          # code actions
          ";" = {
            B = ":pipe base64 -w 0";
            D = ":pipe base64 -d";
            c = ":pipe view_cert";
            C = ":pipe base64 -d | view_cert";
            y = ":yank-diagnostic";
            r = ":reload";
            R = [
              ":lsp-stop"
              ":config-reload"
              ":reload-all"
              ":lsp-restart"
            ];
            z = ":pipe zsh";
          };
          # git shortcuts
          G = {
            d = ":! git diff";
            D = ":! git diff --cached";
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
            B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
            i = ":toggle lsp.display-inlay-hints";
            W = ":write-all";
            J = ":insert-output echo \"# $(date '+%%Y-%%m-%%d')\"";
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };
          C-h = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
          C-l = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
          C-j = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
          C-k = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
        };
        keys.insert = {
          C-h = ":! [ -n \"$TMUX\" ] && tmux select-pane -L";
          C-l = ":! [ -n \"$TMUX\" ] && tmux select-pane -R";
          C-j = ":! [ -n \"$TMUX\" ] && tmux select-pane -D";
          C-k = ":! [ -n \"$TMUX\" ] && tmux select-pane -U";
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
          # bufferline = "always";
          rulers = [ 100 ];
          auto-completion = true;
          path-completion = true;
          auto-format = true;
          end-of-line-diagnostics = "hint";
          inline-diagnostics = {
            cursor-line = "warning";
          };
          smart-tab = {
            enable = false;
            supersede-menu = false;
          };
          gutters.layout = [
            "diff"
            "diagnostics"
            "line-numbers"
            "spacer"
          ];
          gutters.line-numbers.min-width = 1;
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
