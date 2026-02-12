#!/usr/bin/env zsh

# Enable strict mode
set -euo pipefail

# OS and hardware detection
detect_system() {
  local os
  os="$(uname -s)"
  local arch
  arch="$(uname -m)"
  local metal_support=false

  case "$os" in
  Darwin)
    if [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
      echo "Detected: macOS on Apple Silicon"
      metal_support=true
      export LLAMA_METAL=1
      export LLAMA_METAL_NICELLY=1
    else
      echo "Detected: macOS on Intel"
    fi
    ;;
  Linux)
    echo "Detected: Linux system"
    # Check for CUDA
    if command -v nvidia-smi >/dev/null 2>&1; then
      export LLAMA_CUDA=1
      echo "CUDA support enabled"
    fi
    ;;
  *)
    echo "Detected: $os system"
    ;;
  esac

  export METAL_SUPPORT="$metal_support"
}

# Model selection based on task type
select_model() {
  local task_type="$1"
  local model_path="$2"

  case "$task_type" in
  "code-refactor" | "code-generation")
    # Best models for code tasks
    if [[ "$METAL_SUPPORT" == "true" ]]; then
      # Use smaller, faster models for Apple Silicon
      echo "https://huggingface.co/TheBloke/CodeLlama-7B-GGUF/resolve/main/codellama-7b.Q4_K_M.gguf"
    else
      # Use larger models for systems with more VRAM
      echo "https://huggingface.co/TheBloke/DeepSeek-Coder-V2-1.3B-GGUF/resolve/main/deepseek-coder-v2-1.3b.Q5_K_M.gguf"
    fi
    ;;
  "documentation" | "comment")
    # Models optimized for text generation
    echo "https://huggingface.co/TheBloke/Llama-3-8B-GGUF/resolve/main/Llama-3-8B-Q5_K_M.gguf"
    ;;
  *)
    # Default model
    echo "https://huggingface.co/TheBloke/CodeLlama-7B-GGUF/resolve/main/codellama-7b.Q4_K_M.gguf"
    ;;
  esac
}

# Download model if not exists
download_model() {
  local model_url="$1"
  local model_path="$2"

  if [[ ! -f "$model_path" ]]; then
    echo "Downloading model from $model_url..."
    mkdir -p "$(dirname "$model_path")"
    # Use llama-cli if available, otherwise fall back to curl
    if command -v llama-cli >/dev/null 2>&1; then
      llama-cli --hf "$(echo "$model_url" | sed -E 's|.*/([^/]+)/resolve/.*|\1|')" --model "$model_path"
    else
      curl -L "$model_url" -o "$model_path"
    fi
    echo "Model downloaded to $model_path"
  else
    echo "Using existing model at $model_path"
  fi
}

# Configuration
WORKSPACE_DIR="$(pwd)"
MODEL_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/llama-todo"
TEMP_DIR="/tmp/llama-todo"

# Create directories
mkdir -p "$MODEL_DIR" "$TEMP_DIR"

# Detect system and set optimizations
detect_system

# Function to process file with LLM
process_with_llm() {
  local file_path="$1"
  local todo_line="$2"
  local issue="$3"

  # Determine task type from comment
  local task_type="code-refactor"
  if [[ "$todo_line" =~ "doc"|"documentation"|"comment" ]]; then
    task_type="documentation"
  fi

  # Select appropriate model
  local model_url
  model_url=$(select_model "$task_type" "$MODEL_DIR")
  local model_path
  model_path="$MODEL_DIR/$(basename "$model_url" | sed 's/\.Q[0-9]_K_[MSL]\..*//').gguf"

  # Download model if needed
  download_model "$model_url" "$model_path"

  # Create prompt
  local prompt_file="$TEMP_DIR/prompt.txt"
  local context
  context=$(cat "$file_path" | head -n 200)

  cat >"$prompt_file" <<EOF
Update this code to address the TODO/FIXME without including the comment.
Issue: $issue

$context

Updated code:
EOF

  # Call llama.cpp CLI with appropriate parameters
  local output_file="$TEMP_DIR/llm_output.txt"
  llama-cli \
    --model "$model_path" \
    --prompt "$prompt_file" \
    --n-predict 512 \
    --temp 0.7 \
    --repeat-penalty 1.1 \
    --no-display-prompt \
    --no-interactive \
    >"$output_file" || true

  # Extract generated code
  local generated
  generated=$(grep -v "Update this code to address" "$output_file" | grep -v "Issue:" | sed '/^$/d' | head -n 50)

  # Update file
  local line_num
  line_num=$(grep -n "$todo_line" "$file_path" | head -1 | cut -d: -f1)
  if [[ -n "$line_num" && -n "$generated" ]]; then
    {
      head -n $((line_num - 1)) "$file_path"
      echo "$generated"
      tail -n +$((line_num + 1)) "$file_path"
    } >"$file_path.tmp"
    mv "$file_path.tmp" "$file_path"
    echo "Updated $file_path"
  fi
}

# Main monitoring loop
monitor_workspace() {
  echo "Monitoring $WORKSPACE_DIR for TODO/FIXME comments..."

  while true; do
    find "$WORKSPACE_DIR" -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.cpp" -o -name "*.c" -o -name "*.java" | while read -r file; do
      grep -n "TODO\|FIXME" "$file" | grep -v "grep" | while read -r match; do
        local line_num
        line_num=$(echo "$match" | cut -d: -f1)
        local todo_line
        todo_line=$(echo "$match" | cut -d: -f2-)
        local issue
        issue=$(echo "$todo_line" | sed -E 's/.*TODO.?|FIXME.?//i')

        process_with_llm "$file" "$todo_line" "$issue"
      done
    done

    sleep 5
  done
}

# Run the monitor
monitor_workspace
