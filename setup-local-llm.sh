#!/usr/bin/env bash
#
# setup-local-llm.sh
# One-shot setup for a local coding LLM on a base M5 MacBook Air (16 GB).
# Runs Steps 1-4 of local-llm-plan.md: Ollama + model kit + Open WebUI.
#
# Usage (on your Mac):
#   chmod +x setup-local-llm.sh
#   ./setup-local-llm.sh
#
set -euo pipefail

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m✓\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m!\033[0m %s\n' "$1"; }

# --- Sanity checks ----------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This script is meant to run on macOS. Continuing anyway."
fi

if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found. Install it first from https://brew.sh, then re-run."
  exit 1
fi
ok "Homebrew found."

# --- Step 1: Ollama ---------------------------------------------------------
if command -v ollama >/dev/null 2>&1; then
  ok "Ollama already installed."
else
  info "Installing Ollama..."
  brew install ollama
fi

info "Starting the Ollama service..."
brew services start ollama >/dev/null 2>&1 || ollama serve >/dev/null 2>&1 &
sleep 3
ok "Ollama is running."

# --- Step 2: Pull the model kit --------------------------------------------
# Daily driver, quality option, generalist. ~18 GB total on first download.
MODELS=("qwen2.5-coder:7b" "qwen2.5-coder:14b" "llama3.1:8b")
for m in "${MODELS[@]}"; do
  info "Pulling $m ..."
  ollama pull "$m"
done
ok "Model kit downloaded:"
ollama list

# --- Step 3 (smoke test) is interactive — see plan, do it by hand ----------

# --- Step 4: Open WebUI (native, no Docker) --------------------------------
if ! command -v pipx >/dev/null 2>&1; then
  info "Installing pipx..."
  brew install pipx
  pipx ensurepath
fi

if pipx list 2>/dev/null | grep -q open-webui; then
  ok "Open WebUI already installed."
else
  info "Installing Open WebUI (this pulls a fair bit of Python — be patient)..."
  pipx install open-webui
fi

# --- Done -------------------------------------------------------------------
cat <<'EOF'

────────────────────────────────────────────────────────────
✓ Setup complete.

Next:
  1. Start the web UI:   open-webui serve
  2. Open your browser:  http://localhost:8080
  3. Create a local account (stays on your machine).
  4. Pick a model in the top-left and start your bake-off:
       - qwen2.5-coder:7b   (daily driver)
       - qwen2.5-coder:14b  (when you can spare RAM)
       - llama3.1:8b        (general chat)

Reminders: stay plugged in for long sessions, set context to ~8k,
and `ollama rm <model>` the ones you don't keep.
────────────────────────────────────────────────────────────
EOF
