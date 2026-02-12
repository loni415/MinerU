#!/bin/bash
set -e

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: 'uv' command not found."
    echo "Please install uv first (e.g., 'pip install uv' or 'curl -LsSf https://astral.sh/uv/install.sh | sh')."
    exit 1
fi

# Create virtual environment with Python 3.12
# We explicitly use Python 3.12 because the system default Python 3.13 is bleeding edge
# and may have compatibility issues with some ML libraries (like vLLM or PyTorch).
echo "Creating virtual environment 'mineru2-env' with Python 3.12..."
uv venv mineru2-env --python 3.12

# Activate the virtual environment
echo "Activating virtual environment..."
source mineru2-env/bin/activate

# Upgrade pip
echo "Upgrading pip..."
uv pip install -U pip

# Install Mineru with requested extras
echo "Installing Mineru dependencies..."
echo "Note: Installing 'mineru[core,vllm]' as requested."
echo "If installation fails (e.g., due to vLLM compilation issues on this specific hardware), "
echo "you can try installing the lighter version for http-client usage:"
echo "  uv pip install \"mineru[core]\""

uv pip install "mineru[core,vllm]"

echo "----------------------------------------------------------------"
echo "Installation complete."
echo "To activate the environment in your shell, run:"
echo "  source mineru2-env/bin/activate"
