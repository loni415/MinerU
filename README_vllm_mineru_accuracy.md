# MinerU + vLLM Accuracy-First Setup (RTX 5090, OCR’d PDFs)

This guide summarizes an accuracy-focused configuration for running MinerU with a vLLM backend on a remote Linux server equipped with an RTX 5090. It targets academic PDFs (headers/footers, 2-column layouts, citations/bibliographies) and web PDFs that are mostly already OCR’d, with English and some Simplified Chinese content.

## Goals

- Maximize text extraction accuracy and reading order.
- Minimize header/footer noise and bad line breaks.
- Prefer higher fidelity over speed or cost.

## Recommended MinerU Backend

For layout-heavy academic PDFs, the VLM pipeline generally yields the best reading order and paragraph reconstruction. Use the VLM backend as the default, and only fall back to hybrid/OCR when input is image-only or the VLM fails.

### Accuracy-first CLI example

```bash
mineru \
  -p "/home/user/dev/mineru2-lf/MinerU/inputs" \
  -o "/home/user/dev/mineru2-lf/MinerU/output" \
  -b vlm \
  -m auto \
  -l en \
  --max-page 0
```

**Notes**
- `-b vlm` prioritizes the VLM layout understanding and fixes many line-break artifacts.
- `-m auto` lets MinerU choose the best compatible VLM configuration.
- `-l en` keeps English as the primary language. If Chinese is common, use `-l en,zh`.
- `--max-page 0` means parse all pages.

### When to use hybrid mode

Use hybrid mode when PDFs are not OCR’d or are image scans:

```bash
-b hybrid
```

## vLLM Server (Accuracy-First)

Use full-precision or bfloat16 weights with an fp16 KV cache. Avoid quantization if memory allows, since it can reduce layout and text fidelity.

### Recommended vLLM Docker command

```bash
sudo docker run -d --gpus all --ipc=host --name vllm-qwen2.5-14b \
  -v /home/user/.cache/huggingface:/root/.cache/huggingface \
  -p 8000:8000 \
  vllm/vllm-openai:latest \
  Qwen/Qwen2.5-14B-Instruct \
  --dtype bfloat16 \
  --kv-cache-dtype fp16 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768 \
  --trust-remote-code
```

**Why this setup**
- **bfloat16 weights** improve reasoning and layout consistency over quantized weights.
- **fp16 KV cache** preserves detail in long documents.
- **Long context (32k)** helps with long multi-page PDFs.

If you must quantize, `AWQ` works but may slightly reduce accuracy on complex layouts.

## Fonts and System Packages

Install CJK and core fonts to improve PDF text and layout rendering:

```bash
sudo apt install -y fonts-noto-core fonts-noto-cjk fonts-noto-cjk-extra
```

Optional additions:

```bash
sudo apt install -y fonts-noto-color-emoji fonts-liberation
```

## Environment Recommendations

- Prefer a Python environment with stable library support (Python 3.10–3.12).
- If system Python is 3.13, use `venv`, `conda`, or Docker for MinerU.
- Keep HuggingFace cache mounted to avoid repeated downloads.

## Troubleshooting Tips

- **Header/footer noise**: Use `-b vlm` and avoid OCR pipeline.
- **Broken sentence/line breaks**: VLM parsing typically improves this; ensure long context on vLLM.
- **Chinese text**: Add `-l zh` or `-l en,zh` if Simplified Chinese appears frequently.

## Suggested Defaults (Summary)

- MinerU backend: `-b vlm`
- Model selection: `-m auto`
- Language: `-l en` or `-l en,zh`
- vLLM: `Qwen/Qwen2.5-14B-Instruct`, `--dtype bfloat16`, `--kv-cache-dtype fp16`
- Max context length: `32768`

These settings prioritize accuracy for complex academic PDFs at the expense of speed and GPU memory.
