# MinerU Installation Scripts

This directory contains automated installation scripts for MinerU that simplify the setup process across different platforms.

## Quick Start

### Linux / macOS

**Option 1: Using the Python script (recommended)**
```bash
python3 install_mineru.py
```

**Option 2: Using the bash script**
```bash
bash install_mineru.sh
```

**Option 3: One-line installation**
```bash
curl -sSL https://raw.githubusercontent.com/opendatalab/MinerU/master/install_mineru.sh | bash
```

### Windows

**Option 1: Using the Python script (recommended)**
```powershell
python install_mineru.py
```

**Option 2: Using PowerShell script**
```powershell
powershell -ExecutionPolicy Bypass -File install_mineru.ps1
```

**Option 3: One-line installation (PowerShell)**
```powershell
iwr -useb https://raw.githubusercontent.com/opendatalab/MinerU/master/install_mineru.ps1 | iex
```

## Script Features

All installation scripts provide the following features:

### ✅ Automated Checks
- Python version compatibility (3.10-3.13)
- Operating system detection and validation
- System requirements verification
- Windows Python 3.13 compatibility check

### 🔧 Installation Options

The Python script (`install_mineru.py`) offers three installation modes:

1. **Quick Install** - Installs `mineru[all]` with all features (recommended for most users)
2. **Custom Install** - Select specific backends based on your needs
3. **Source Install** - Clone and install from the GitHub repository

The bash and PowerShell scripts provide a streamlined quick installation experience.

### 📦 What Gets Installed

When using `mineru[all]`, the following components are installed:

- **Core Package**: Base MinerU functionality
- **VLM Backend**: Vision-Language Model support (high accuracy)
- **Pipeline Backend**: Traditional pipeline processing (good compatibility)
- **API Server**: FastAPI server for HTTP endpoints
- **Gradio UI**: Web-based user interface
- **Platform-specific acceleration**:
  - Linux: vLLM support
  - macOS: MLX support (Apple Silicon)
  - Windows: LMDeploy support

### 🎯 Post-Installation

After successful installation, the scripts will:
- Verify the installation
- Display the installed version
- Show usage examples and next steps
- Provide links to documentation

## System Requirements

### Minimum Requirements (CPU-only)
- Python 3.10-3.13 (3.10-3.12 on Windows)
- 16GB RAM (recommended 32GB+)
- 20GB disk space (SSD recommended)

### Recommended Requirements (GPU-accelerated)
- Volta architecture GPU or later
- 6GB+ VRAM (varies by backend)
- 16GB+ RAM (recommended 32GB+)
- 20GB+ disk space (SSD recommended)

### Operating Systems
- **Linux**: Distributions from 2019 or later
- **macOS**: Version 14.0 or later
- **Windows**: Windows 10/11 with Python 3.10-3.12

## Installation Backends

### All (Recommended)
```bash
python3 install_mineru.py
# Choose option 1 for quick install
```
Includes all core features plus platform-specific optimizations.

### Core Only
```bash
pip install "mineru[core]"
```
Includes VLM, Pipeline, API, and Gradio without platform-specific accelerators.

### Pipeline Only (CPU-friendly)
```bash
pip install "mineru[pipeline]"
```
Best for CPU-only systems or limited resources.

### VLM Only
```bash
pip install "mineru[vlm]"
```
Vision-Language Model backend for high-accuracy parsing.

### Custom Combinations
```bash
pip install "mineru[pipeline,api,gradio]"
```
Install only the components you need.

## Troubleshooting

### Python Version Issues

**Problem**: "Python X.X is not supported"

**Solution**: 
- Install Python 3.10-3.13 (Linux/macOS) or 3.10-3.12 (Windows)
- Verify version: `python3 --version`

### Permission Errors

**Linux/macOS**:
```bash
# Don't use sudo with pip
python3 -m pip install --user "mineru[all]"
```

**Windows**:
- Run PowerShell as Administrator
- Or use a virtual environment

### Network Issues

**Problem**: Slow downloads or timeouts

**Solution**:
```bash
# Use a mirror (example for China users)
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple "mineru[all]"
```

### GPU Not Detected

**Problem**: Installation succeeds but GPU is not used

**Solution**:
1. Verify GPU drivers are installed
2. Check CUDA/ROCm installation (NVIDIA/AMD)
3. Install appropriate PyTorch version:
   ```bash
   # For CUDA 11.8
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
   
   # For CUDA 12.1
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
   ```

### Import Errors After Installation

**Problem**: `ModuleNotFoundError` when running mineru

**Solution**:
1. Verify installation: `pip show mineru`
2. Check you're using the correct Python:
   ```bash
   which python3
   python3 -m pip show mineru
   ```
3. Try reinstalling in a virtual environment

## Manual Installation

If the automated scripts don't work for your system, you can install manually:

### Using pip
```bash
# Update pip
pip install --upgrade pip

# Install uv (recommended)
pip install uv

# Install MinerU
uv pip install -U "mineru[all]"
```

### From Source
```bash
# Clone repository
git clone https://github.com/opendatalab/MinerU.git
cd MinerU

# Install
uv pip install -e .[all]
```

## Verification

After installation, verify everything works:

```bash
# Check version
mineru --version

# Download models (first time only)
mineru-models-download

# Test with a sample PDF
mineru -p sample.pdf -o output_dir
```

## Getting Help

- **Documentation**: https://opendatalab.github.io/MinerU/
- **FAQ**: https://opendatalab.github.io/MinerU/faq/
- **Issues**: https://github.com/opendatalab/MinerU/issues
- **Discord**: https://discord.gg/Tdedn9GTXq
- **AI Assistant**: https://deepwiki.com/opendatalab/MinerU

## Advanced Usage

### Virtual Environment (Recommended)

**Linux/macOS**:
```bash
python3 -m venv mineru-env
source mineru-env/bin/activate
python3 install_mineru.py
```

**Windows**:
```powershell
python -m venv mineru-env
.\mineru-env\Scripts\Activate.ps1
python install_mineru.py
```

### Docker Installation

For containerized deployment:
```bash
# Pull pre-built image
docker pull opendatalab/mineru:latest

# Or build from source
cd docker
docker-compose up
```

See [Docker Deployment Guide](https://opendatalab.github.io/MinerU/quick_start/docker_deployment/) for details.

### Development Installation

For contributors:
```bash
git clone https://github.com/opendatalab/MinerU.git
cd MinerU
pip install -e .[all,test]
pytest tests/
```

## Uninstallation

To remove MinerU:
```bash
pip uninstall mineru

# Also remove dependencies if desired
pip uninstall mineru-vl-utils qwen-vl-utils
```

## License

MinerU is licensed under AGPL-3.0. See [LICENSE.md](LICENSE.md) for details.

Note: Some models are based on YOLO (AGPL license). Future versions may use models with more permissive licenses.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [Changelog](https://opendatalab.github.io/MinerU/reference/changelog/) for version history and updates.
