# Installation Scripts

MinerU provides automated installation scripts that simplify the setup process across different platforms. These scripts handle all the complexity of checking system requirements, installing dependencies, and configuring MinerU for your specific environment.

## Available Scripts

### Python Script (Cross-Platform)
- **File**: `install_mineru.py`
- **Platforms**: Linux, macOS, Windows
- **Features**: Interactive installation with multiple options

### Bash Script (Unix)
- **File**: `install_mineru.sh`
- **Platforms**: Linux, macOS
- **Features**: Quick automated installation

### PowerShell Script (Windows)
- **File**: `install_mineru.ps1`
- **Platforms**: Windows
- **Features**: Quick automated installation for Windows

## Quick Start

### Linux / macOS

**Interactive Installation (Recommended)**
```bash
python3 install_mineru.py
```

**Quick Installation**
```bash
bash install_mineru.sh
```

**One-Line Installation**
```bash
curl -sSL https://raw.githubusercontent.com/opendatalab/MinerU/master/install_mineru.sh | bash
```

### Windows

**Interactive Installation (Recommended)**
```powershell
python install_mineru.py
```

**Quick Installation**
```powershell
powershell -ExecutionPolicy Bypass -File install_mineru.ps1
```

## Python Script Features

The Python installation script (`install_mineru.py`) provides an interactive menu with three installation options:

### 1. Quick Install (Recommended)
Installs `mineru[all]` which includes:
- All core features (VLM + Pipeline + API + Gradio)
- Platform-specific optimizations:
  - **Linux**: vLLM support
  - **macOS**: MLX support (Apple Silicon)
  - **Windows**: LMDeploy support

### 2. Custom Install
Allows you to select specific backends:
- **core**: All core features without platform-specific accelerators
- **pipeline**: Traditional pipeline backend (good compatibility)
- **vlm**: Vision-Language Model backend (high accuracy)
- **api**: FastAPI server support
- **gradio**: Gradio web UI support
- **mlx/vllm/lmdeploy**: Platform-specific accelerators

### 3. Install from Source
Clones the repository and installs from source code, useful for:
- Development work
- Latest unreleased features
- Contributing to the project

## What the Scripts Do

All installation scripts perform the following steps:

1. **System Check**
   - Verify Python version (3.10-3.13 required, 3.10-3.12 on Windows)
   - Detect operating system and architecture
   - Check macOS version (14.0+ required)
   - Validate Windows Python version compatibility

2. **Dependency Installation**
   - Upgrade pip to the latest version
   - Install uv package manager (recommended)
   - Fall back to pip if uv installation fails

3. **MinerU Installation**
   - Install selected MinerU package
   - Handle installation errors gracefully
   - Provide detailed error messages

4. **Verification**
   - Verify installation success
   - Display installed version
   - Show usage instructions

5. **Usage Guide**
   - Display basic commands
   - Show next steps
   - Provide links to documentation

## Script Output

The scripts provide color-coded output for easy reading:

- ✓ **Green**: Successful operations
- ✗ **Red**: Errors
- ⚠ **Yellow**: Warnings
- ℹ **Cyan**: Information messages

## Troubleshooting

### Python Version Issues

If you see "Python X.X is not supported":

```bash
# Check your Python version
python3 --version

# Use a specific Python version if multiple are installed
python3.11 install_mineru.py
```

### Permission Errors

**Linux/macOS:**
```bash
# Install for current user only
python3 -m pip install --user "mineru[all]"
```

**Windows:**
- Run PowerShell as Administrator
- Or use a virtual environment

### Network Issues

If you experience slow downloads or timeouts:

```bash
# Use a mirror (China users)
pip install -i https://mirrors.aliyun.com/pypi/simple "mineru[all]"

# Or set environment variable
export PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple
python3 install_mineru.py
```

### Script Execution Errors

**macOS Script Blocked:**
```bash
chmod +x install_mineru.sh
bash install_mineru.sh
```

**PowerShell Execution Policy:**
```powershell
# Temporarily allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run directly
powershell -ExecutionPolicy Bypass -File install_mineru.ps1
```

## Virtual Environment (Recommended)

For a clean installation, use a virtual environment:

**Linux/macOS:**
```bash
python3 -m venv mineru-env
source mineru-env/bin/activate
python3 install_mineru.py
```

**Windows:**
```powershell
python -m venv mineru-env
.\mineru-env\Scripts\Activate.ps1
python install_mineru.py
```

## Manual Installation

If the scripts don't work for your system, you can install manually:

```bash
pip install --upgrade pip
pip install uv
uv pip install -U "mineru[all]"
```

See [INSTALL.md](../../../INSTALL.md) for detailed manual installation instructions.

## Next Steps

After installation:

1. **Download Models** (first-time setup)
   ```bash
   mineru-models-download
   ```

2. **Test Installation**
   ```bash
   mineru -p sample.pdf -o output_dir
   ```

3. **Explore Features**
   - Try the API server: `mineru-api`
   - Launch Gradio UI: `mineru-gradio`
   - Read the [Usage Guide](../usage/index.md)

## Getting Help

If you encounter issues:

- Check the [FAQ](../faq/index.md)
- Visit [INSTALL.md](../../../INSTALL.md) for detailed troubleshooting
- Join our [Discord](https://discord.gg/Tdedn9GTXq) community
- Ask questions on [GitHub Issues](https://github.com/opendatalab/MinerU/issues)

## Contributing

Found a bug in the installation scripts or have improvements? Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines.
