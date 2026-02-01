#!/bin/bash
# run_vllm_full.sh - Standalone version with 90% GPU utilization
# Best for general inference when MinerU is NOT running.

sudo docker rm -f vllm-qwen32b 2>/dev/null
echo "Starting vLLM container in STANDALONE mode (90% GPU)..."
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
  --gpu-memory-utilization 0.90 \
  --enforce-eager \
  --quantization awq

echo "vLLM is running at http://localhost:8000"
echo "You can use it with any OpenAI-compatible client."
