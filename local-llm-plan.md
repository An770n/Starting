# Running a Local LLM on a Base M5 MacBook Air

Goal: replace (some) paid LLM usage with a model running entirely on your own
machine — no API bills, no data leaving the laptop, works offline.

## Your hardware (the one constraint that matters)

Base M5 MacBook Air (2026):

- Apple M5, 10-core CPU / 8-core GPU, 16-core Neural Engine
- **16 GB unified memory**  ← this is the cap on model size
- 512 GB SSD

Apple Silicon is genuinely good for this: the GPU and CPU share the same 16 GB
of RAM, so the GPU can use almost all of it for a model. The catch is that
macOS itself wants ~4–6 GB, so realistically budget **~9–10 GB for the model**.

> Quick terminology: you're not *training* an LLM (that needs a datacenter).
> You're *running inference* on an existing open-weight model that someone else
> trained. That's the realistic, free goal.

## What fits in 16 GB

Models are distributed in "quantized" sizes — lower precision = smaller file =
less RAM, with a small quality hit. The `Q4` (4-bit) variants are the sweet
spot.

| Model size | ~RAM at Q4 | On your Air | Notes |
|-----------|-----------|-------------|-------|
| 3–4B      | ~2.5 GB   | Effortless, very fast | Great for quick/offline tasks |
| 7–8B      | ~4.5–5 GB | **Sweet spot** | Best quality-for-comfort balance |
| 12–14B    | ~7–9 GB   | Works, a bit tighter | Close a few apps; noticeably slower |
| 20B+      | 12 GB+    | Don't bother | Will swap/crawl on 16 GB |

**Recommended models to start with (all open-weight, free):**

- **Qwen 2.5 7B Instruct** — excellent all-rounder, strong at coding
- **Llama 3.1 8B Instruct** — great general assistant
- **Gemma 2 9B** — strong reasoning/writing
- **Phi-4 (14B)** — punches above its weight, if you want to push the limit

## The plan

### Step 1 — Pick a runner (do the easy one first)

| Tool | What it is | Pick it if |
|------|-----------|-----------|
| **Ollama** | One-command CLI + local API server | ← **Start here.** Simplest. |
| **LM Studio** | Polished GUI, model browser, built-in chat | You want a ChatGPT-like window with no terminal |
| **MLX / mlx-lm** | Apple's own framework, fastest on Apple Silicon | You want max speed and don't mind Python |
| **llama.cpp** | The low-level engine the others build on | You want full control / scripting |

### Step 2 — Install Ollama and run your first model

```bash
# Install (or download the .dmg from ollama.com)
brew install ollama

# Pull and chat with a model — downloads ~4.7 GB the first time
ollama run qwen2.5:7b
```

That's it — you now have a local LLM. Type to chat; `/bye` to exit.

Try a couple and keep the one you like:

```bash
ollama run llama3.1:8b
ollama run gemma2:9b
ollama list          # see what you've downloaded
ollama rm <model>    # free up disk
```

### Step 3 — Use it from apps (the local API)

Ollama exposes an OpenAI-compatible endpoint at `http://localhost:11434`, so
most "bring your own key" tools work by just pointing them there:

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen2.5:7b","messages":[{"role":"user","content":"hi"}]}'
```

Good front-ends that talk to this:
- **Open WebUI** — self-hosted ChatGPT-style UI
- **Raycast / VS Code / Zed** AI extensions — set base URL to `localhost:11434`
- **Continue.dev** — local coding assistant inside your editor

### Step 4 — Tune for comfort

- Quit RAM-hungry apps (Chrome with many tabs) before running 9B+ models.
- Stick to `Q4_K_M` quantization unless you have a reason not to.
- Watch memory pressure in Activity Monitor — if it goes yellow/red, drop to a
  smaller model.
- Keep context windows modest (4k–8k) on 16 GB; huge contexts eat RAM fast.

## Honest expectations

- A local 7–8B model is roughly "good free assistant" tier — great for
  drafting, summarizing, coding help, offline Q&A, and private documents.
- It is **not** GPT-class / Claude-class. For the hardest reasoning or
  long-context work, the frontier cloud models are still clearly better.
- A practical money-saving setup: **local model for 80% of everyday tasks**,
  pay-per-use cloud API only for the hard 20%.

## TL;DR

1. `brew install ollama`
2. `ollama run qwen2.5:7b`
3. Point your editor/chat app at `http://localhost:11434`
4. Stay in the 7–9B range; reach for 14B only when you can spare the RAM.
