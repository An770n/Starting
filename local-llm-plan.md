# Final Plan — Local LLM on a Base M5 MacBook Air (Coding Focus)

Goal: run an open-weight coding model entirely on the laptop to cut paid LLM
costs, accessed through a self-hosted ChatGPT-style web UI.

## Decisions (locked)

| Decision | Choice |
|----------|--------|
| Hardware | Base M5 MacBook Air, **16 GB** unified memory (~9–10 GB usable for a model) |
| Use case | **Coding help** |
| Runner / engine | **Ollama** |
| Interface | **Open WebUI** (self-hosted, in the browser) |
| Approach | Download a **small kit (3 models)** and compare, then keep the winner |

## The model kit

All open-weight and free. Pull all three, run the same prompts through each,
keep the one(s) you like.

| # | Model | Ollama tag | ~RAM (Q4) | Role |
|---|-------|-----------|-----------|------|
| 1 | Qwen 2.5 Coder 7B | `qwen2.5-coder:7b` | ~4.7 GB | **Daily driver** — fast, comfortable |
| 2 | Qwen 2.5 Coder 14B | `qwen2.5-coder:14b` | ~9 GB | **Quality** — when you can spare RAM |
| 3 | Llama 3.1 8B | `llama3.1:8b` | ~4.7 GB | **Generalist** — non-code chat, summaries |

The comparison that matters for coding: **#1 vs #2 (speed vs quality)**. #3 is
your fallback for everyday non-code chat.

## Steps

### Step 1 — Install Ollama

```bash
brew install ollama
# or download the .dmg from ollama.com
```

### Step 2 — Pull the kit

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
ollama pull llama3.1:8b
ollama list          # confirm they downloaded
```

### Step 3 — Smoke-test from the terminal

```bash
ollama run qwen2.5-coder:7b
# try a real task, e.g. "write a Python function to debounce a callback"
# /bye to exit, then repeat with the other two
```

### Step 4 — Stand up Open WebUI (the browser interface)

Run it **natively** (no Docker). On a 16 GB machine this matters: Docker
Desktop idles at ~2–4 GB of RAM, which would eat into the headroom your model
needs. The native install avoids that tax.

```bash
# Use a recent Python (3.11+). pipx keeps it isolated and tidy:
brew install pipx
pipx install open-webui

# Start it (Ollama just needs to be running):
open-webui serve
```

Then open **http://localhost:8080**, create a local account (stays on your
machine), and your Ollama models appear in the model picker.

> If you ever want one-command updates and don't mind the RAM cost, the Docker
> image (`ghcr.io/open-webui/open-webui:main`) is the alternative — but native
> is the right call for 16 GB.

### Step 5 — Compare and pick a default

In Open WebUI, ask each model the same 3–4 real coding questions you'd actually
use it for. Judge: correctness, speed, and how it "feels." Set your favourite as
the default; keep the 14B around for harder problems.

### Step 6 — Tune for 16 GB comfort

- Quit RAM-heavy apps (many Chrome tabs) before running the 14B/16B models.
- Watch memory pressure in Activity Monitor — yellow/red means drop to the 7B.
- Keep context windows at 4k–8k; huge contexts eat RAM fast.
- Stick with the default `Q4_K_M` quantization.

## Optional add-on (recommended later, since this is coding)

Wire the same Ollama backend into your editor for inline help:

- **VS Code / Zed + Continue.dev** → set the provider to Ollama, model
  `qwen2.5-coder:7b`. Gives you autocomplete + chat right in the code.

## Honest expectations

- Qwen 2.5 Coder 7B/14B is strong for everyday coding: boilerplate, refactors,
  explanations, tests, debugging help.
- It won't match frontier cloud models on the hardest, long-context problems.
- Practical setup: **local model for ~80% of coding tasks**, cloud API only for
  the hard 20%.

## TL;DR

1. `brew install ollama`
2. `ollama pull qwen2.5-coder:7b && ollama pull qwen2.5-coder:14b && ollama pull llama3.1:8b`
3. `pipx install open-webui && open-webui serve` → open `http://localhost:8080`
4. Compare the three on real tasks, keep the winner (7B daily, 14B for hard stuff)
5. Later: add Continue.dev in your editor for inline coding help
