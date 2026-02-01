#!/bin/bash
# run_vllm.sh - Optimized memory version (75%)
sudo docker rm -f vllm-qwen32b 2>/dev/null
echo "Starting vLLM container (Qwen2.5-32B at 75% GPU)..."
sudo docker run -d --name vllm-qwen32b \
  --gpus all \
  --restart unless-stopped \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -p 8000:8000 \
  -v /opt/vllm-cache:/root/.cache \
  vllm/vllm-openai:latest \
  --model Qwen/Qwen2.5-32B-Instruct-AWQ \
  --max-model-len 32768 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.75 \
  --enforce-eager \
  --quantization awq
echo "Container started."
