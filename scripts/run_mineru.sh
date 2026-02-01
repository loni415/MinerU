#!/bin/bash
# run_mineru.sh - Optimized memory version
export MINERU_CONFIG_FILE="/home/user/mineru.json"
VENV_PYTHON="/home/user/dev/mineru-lf/mineru-env/bin/python3"

echo "Running Mineru with local VLM (10% GPU) + remote vLLM aided features..."
# Passing --gpu-memory-utilization 0.1 to override default 0.5
$VENV_PYTHON -c "from mineru.cli import client; import sys; sys.exit(client.main())" \
  -p "/home/user/dev/mineru-lf/mineru-repo/inputs" \
  -o "/home/user/dev/mineru-lf/mineru-repo/output" \
  --lang ch_server \
  --gpu-memory-utilization 0.1
