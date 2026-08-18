#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# MinerU consolidated accuracy-first pipeline (Chinese academic PDFs)
#
# Flow:
#   1) Run Hybrid-high on all PDFs (primary)
#   2) Heuristically detect suspicious outputs
#   3) Re-run only suspicious PDFs with VLM engine
#   4) Assemble final outputs (hybrid by default, VLM overrides on flagged docs)
#
# Usage:
#   chmod +x mineru_prod_accuracy_pipeline.sh
#   ./mineru_prod_accuracy_pipeline.sh
#
# Optional env overrides:
#   IN_DIR=... OUT_ROOT=... MODEL=... ./mineru_prod_accuracy_pipeline.sh
###############################################################################

# ---- User-style defaults (based on your example paths) ----------------------
IN_DIR="${IN_DIR:-/home/user/dev/mineru2-lf/MinerU/inputs}"
OUT_ROOT="${OUT_ROOT:-/home/user/dev/mineru2-lf/MinerU/output_prod}"
MODEL="${MODEL:-MinerU2.5-Pro-2605-1.2B}"  # change if your installed model name differs

# MinerU language hint based on your example:
# example used: -l ch_server
LANG_HINT="${LANG_HINT:-ch_server}"

# One GPU server: keep explicit for stability
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"

# ---- Derived paths -----------------------------------------------------------
HYBRID_OUT="${OUT_ROOT}/01_hybrid_high"
VLM_OUT="${OUT_ROOT}/02_vlm_rerun"
FINAL_OUT="${OUT_ROOT}/03_final_merged"
WORK_DIR="${OUT_ROOT}/_work"
LOG_DIR="${OUT_ROOT}/_logs"

PDF_LIST="${WORK_DIR}/all_pdfs.txt"
FLAGGED_LIST="${WORK_DIR}/flagged_for_vlm.txt"
RUN_SUMMARY="${LOG_DIR}/run_summary.txt"

mkdir -p "$HYBRID_OUT" "$VLM_OUT" "$FINAL_OUT" "$WORK_DIR" "$LOG_DIR"

echo "=== MinerU Production Run (accuracy-first) ===" | tee "$RUN_SUMMARY"
echo "IN_DIR      : $IN_DIR" | tee -a "$RUN_SUMMARY"
echo "OUT_ROOT    : $OUT_ROOT" | tee -a "$RUN_SUMMARY"
echo "MODEL       : $MODEL" | tee -a "$RUN_SUMMARY"
echo "LANG_HINT   : $LANG_HINT" | tee -a "$RUN_SUMMARY"
echo "GPU         : CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES" | tee -a "$RUN_SUMMARY"
echo "" | tee -a "$RUN_SUMMARY"

# ---- Discover PDFs -----------------------------------------------------------
find "$IN_DIR" -type f \( -iname "*.pdf" \) | sort > "$PDF_LIST"

TOTAL_PDFS=$(wc -l < "$PDF_LIST" | tr -d ' ')
if [[ "$TOTAL_PDFS" -eq 0 ]]; then
  echo "No PDF files found in: $IN_DIR" | tee -a "$RUN_SUMMARY"
  exit 1
fi
echo "Found $TOTAL_PDFS PDF(s)." | tee -a "$RUN_SUMMARY"

# ------------------------------------------------------------------------------
# Helper: run MinerU robustly with two common CLI styles
#  - style A: mineru parse --input ... --output ...
#  - style B: mineru -p ... -o ... -b ... -m ... -l ...
# ------------------------------------------------------------------------------
run_hybrid() {
  local input_pdf="$1"
  local out_dir="$2"

  # Try modern parse style first
  if mineru parse \
      --input "$input_pdf" \
      --output "$out_dir" \
      --backend hybrid \
      --engine hybrid-auto-engine \
      --effort high \
      --lang "$LANG_HINT" \
      --format markdown,json \
      >> "${LOG_DIR}/hybrid.log" 2>&1; then
    return 0
  fi

  # Fallback to short style (aligned with your sample style)
  # NOTE: Your sample uses -b vlm-engine -m ocr -l ch_server.
  # For hybrid attempt, we set backend-style arg to hybrid-engine and keep language hint.
  mineru \
    -p "$input_pdf" \
    -o "$out_dir" \
    -b hybrid-engine \
    -m ocr \
    -l "$LANG_HINT" \
    >> "${LOG_DIR}/hybrid.log" 2>&1
}

run_vlm() {
  local input_pdf="$1"
  local out_dir="$2"

  # Try modern parse style first
  if mineru parse \
      --input "$input_pdf" \
      --output "$out_dir" \
      --backend vlm \
      --engine vlm-vllm-engine \
      --model "$MODEL" \
      --lang "$LANG_HINT" \
      --format markdown,json \
      >> "${LOG_DIR}/vlm.log" 2>&1; then
    return 0
  fi

  # Fallback to style from your example
  mineru \
    -p "$input_pdf" \
    -o "$out_dir" \
    -b vlm-engine \
    -m ocr \
    -l "$LANG_HINT" \
    >> "${LOG_DIR}/vlm.log" 2>&1
}

# ---- Step 1: Hybrid-high pass on all docs -----------------------------------
echo "" | tee -a "$RUN_SUMMARY"
echo "[1/4] Running hybrid-high pass..." | tee -a "$RUN_SUMMARY"

while IFS= read -r pdf; do
  doc_name="$(basename "$pdf" .pdf)"
  doc_out="${HYBRID_OUT}/${doc_name}"
  mkdir -p "$doc_out"

  echo "Hybrid: $pdf" | tee -a "${LOG_DIR}/hybrid_docs.log"
  if ! run_hybrid "$pdf" "$doc_out"; then
    echo "Hybrid FAILED: $pdf" | tee -a "${LOG_DIR}/hybrid_docs.log"
  fi
done < "$PDF_LIST"

# ---- Step 2: Flag suspicious outputs ----------------------------------------
echo "" | tee -a "$RUN_SUMMARY"
echo "[2/4] Detecting suspicious outputs for VLM re-run..." | tee -a "$RUN_SUMMARY"
: > "$FLAGGED_LIST"

# Heuristics (simple, conservative):
#  - Missing markdown output
#  - Markdown too short (< 1200 bytes)
#  - Presence of replacement chars / common garble markers
#  - Very low Chinese char ratio in Chinese-target docs
#
# Export variables so inline Python script can access them via os.environ
export PDF_LIST HYBRID_OUT FLAGGED_LIST

python3 - <<'PY'
import os, re, sys, json

in_list = os.environ["PDF_LIST"]
hybrid_out = os.environ["HYBRID_OUT"]
flagged = os.environ["FLAGGED_LIST"]

def find_md(root):
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if fn.lower().endswith(".md"):
                return os.path.join(dp, fn)
    return None

def chinese_ratio(text):
    if not text:
        return 0.0
    zh = len(re.findall(r'[\u4e00-\u9fff]', text))
    letters = len(re.findall(r'[A-Za-z\u4e00-\u9fff]', text))
    if letters == 0:
        return 0.0
    return zh / letters

with open(in_list, "r", encoding="utf-8") as f:
    pdfs = [x.strip() for x in f if x.strip()]

flagged_docs = []
for pdf in pdfs:
    name = os.path.splitext(os.path.basename(pdf))[0]
    out_dir = os.path.join(hybrid_out, name)
    md = find_md(out_dir)

    bad = False
    reason = []

    if not md or not os.path.exists(md):
        bad = True
        reason.append("missing_markdown")
    else:
        try:
            txt = open(md, "r", encoding="utf-8", errors="replace").read()
        except Exception:
            txt = ""
            bad = True
            reason.append("unreadable_markdown")

        size = len(txt.encode("utf-8", errors="ignore"))
        if size < 1200:
            bad = True
            reason.append(f"too_short:{size}B")

        # Common garble markers
        if "�" in txt or "□□" in txt:
            bad = True
            reason.append("garbled_chars")

        # For Chinese journals, too little Chinese content can indicate OCR/layout failure
        ratio = chinese_ratio(txt)
        if ratio < 0.10:  # conservative threshold
            bad = True
            reason.append(f"low_zh_ratio:{ratio:.3f}")

    if bad:
        flagged_docs.append((pdf, ",".join(reason)))

with open(flagged, "w", encoding="utf-8") as fw:
    for pdf, _ in flagged_docs:
        fw.write(pdf + "\n")

# Also print reasons to stdout for logs
for pdf, rsn in flagged_docs:
    print(f"FLAGGED\t{pdf}\t{rsn}")

print(f"FLAGGED_COUNT\t{len(flagged_docs)}")
PY

FLAGGED_COUNT=$(wc -l < "$FLAGGED_LIST" | tr -d ' ')
echo "Flagged for VLM rerun: $FLAGGED_COUNT" | tee -a "$RUN_SUMMARY"

# ---- Step 3: VLM rerun for flagged docs -------------------------------------
echo "" | tee -a "$RUN_SUMMARY"
echo "[3/4] Running VLM rerun on flagged docs..." | tee -a "$RUN_SUMMARY"

if [[ "$FLAGGED_COUNT" -gt 0 ]]; then
  while IFS= read -r pdf; do
    doc_name="$(basename "$pdf" .pdf)"
    doc_out="${VLM_OUT}/${doc_name}"
    mkdir -p "$doc_out"

    echo "VLM: $pdf" | tee -a "${LOG_DIR}/vlm_docs.log"
    if ! run_vlm "$pdf" "$doc_out"; then
      echo "VLM FAILED: $pdf" | tee -a "${LOG_DIR}/vlm_docs.log"
    fi
  done < "$FLAGGED_LIST"
else
  echo "No flagged docs; skipping VLM rerun." | tee -a "$RUN_SUMMARY"
fi

# ---- Step 4: Merge final outputs --------------------------------------------
echo "" | tee -a "$RUN_SUMMARY"
echo "[4/4] Merging final outputs (VLM overrides hybrid for flagged docs)..." | tee -a "$RUN_SUMMARY"

# Start with hybrid outputs
rsync -a --delete "$HYBRID_OUT"/ "$FINAL_OUT"/

# Override with VLM outputs for flagged docs (if available)
if [[ "$FLAGGED_COUNT" -gt 0 ]]; then
  while IFS= read -r pdf; do
    doc_name="$(basename "$pdf" .pdf)"
    if [[ -d "${VLM_OUT}/${doc_name}" ]]; then
      rsync -a --delete "${VLM_OUT}/${doc_name}/" "${FINAL_OUT}/${doc_name}/"
    fi
  done < "$FLAGGED_LIST"
fi

echo "" | tee -a "$RUN_SUMMARY"
echo "Done." | tee -a "$RUN_SUMMARY"
echo "Hybrid outputs : $HYBRID_OUT" | tee -a "$RUN_SUMMARY"
echo "VLM reruns     : $VLM_OUT" | tee -a "$RUN_SUMMARY"
echo "Final merged   : $FINAL_OUT" | tee -a "$RUN_SUMMARY"
echo "Logs           : $LOG_DIR" | tee -a "$RUN_SUMMARY"