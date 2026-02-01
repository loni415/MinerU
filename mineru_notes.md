
# start vllm docker container

# install mineru
uv pip install "mineru[core,vllm]"

# run mineru
cd /home/user/dev/mineru-lf
source mineru-env/bin/activate

export MINERU_VL_MODEL_NAME="Qwen/Qwen2.5-VL-32B-Instruct-AWQ"
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export MINERU_HYBRID_FORCE_PIPELINE_ENABLE=true
# export MINERU_CONFIG_FILE="/home/user/mineru.json" # necessary?
mineru -p <input_path> -o <output_path> -b hybrid-http-client -u http://127.0.0.1:8000 -m ocr -l ch_server

mineru -p "/home/user/dev/mineru-lf/mineru-repo/inputs" -o "/home/user/dev/mineru-lf/mineru-repo/output" -b hybrid-http-client -u http://127.0.0.1:8000 -m ocr -l ch_server


mineru -p "/home/user/dev/mineru-lf/mineru-repo/inputs" -o "/home/user/dev/mineru-lf/mineru-repo/output" -b vlm-http-client -u http://localhost:8000 --lang ch_server
--lang en
