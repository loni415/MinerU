#!/bin/bash
set -e

# Ensure the script is run from the directory where mineru2-env exists
if [ ! -d "mineru2-env" ]; then
    echo "Error: Virtual environment 'mineru2-env' not found in the current directory."
    echo "Please run './install_mineru.sh' first or ensure you are in the correct directory."
    exit 1
fi

echo "Activating virtual environment..."
source mineru2-env/bin/activate

echo "Starting Mineru extraction..."
echo "Backend: vlm-http-client"
echo "Server: http://localhost:8000"
echo "Input: /home/user/dev/mineru2-lf/MinerU/inputs"
echo "Output: /home/user/dev/mineru2-lf/MinerU/output"

# Execute mineru with the specified parameters
# Note: Ensure the vLLM server is running at http://localhost:8000 before executing this script.
mineru -p "/home/user/dev/mineru2-lf/MinerU/inputs" \
       -o "/home/user/dev/mineru2-lf/MinerU/output" \
       -b vlm-http-client \
       -u http://localhost:8000 \
       --lang en \
       > mineru_output.log 2>&1

echo "Extraction finished. Check 'mineru_output.log' for details."
