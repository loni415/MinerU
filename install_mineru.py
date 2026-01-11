#!/usr/bin/env python3
"""
MinerU Installation Script

This script automates the installation of MinerU with various configuration options.
It supports multiple installation methods and backends based on your system configuration.
"""

import os
import sys
import platform
import subprocess
import shutil
from pathlib import Path


class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_header(text):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'=' * 60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text.center(60)}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'=' * 60}{Colors.ENDC}\n")


def print_success(text):
    print(f"{Colors.OKGREEN}✓ {text}{Colors.ENDC}")


def print_error(text):
    print(f"{Colors.FAIL}✗ {text}{Colors.ENDC}")


def print_warning(text):
    print(f"{Colors.WARNING}⚠ {text}{Colors.ENDC}")


def print_info(text):
    print(f"{Colors.OKCYAN}ℹ {text}{Colors.ENDC}")


def run_command(cmd, check=True, shell=False):
    """Run a shell command and return the result."""
    try:
        if shell:
            result = subprocess.run(cmd, shell=True, check=check, 
                                  capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, check=check, 
                                  capture_output=True, text=True)
        return result
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
        print_error(f"Error: {e.stderr}")
        return None


def check_python_version():
    """Check if Python version meets requirements."""
    print_info("Checking Python version...")
    version = sys.version_info
    
    if version.major == 3 and 10 <= version.minor <= 13:
        print_success(f"Python {version.major}.{version.minor}.{version.micro} is compatible")
        return True
    else:
        print_error(f"Python {version.major}.{version.minor}.{version.micro} is not supported")
        print_error("MinerU requires Python 3.10-3.13")
        return False


def get_system_info():
    """Get system information."""
    system = platform.system()
    machine = platform.machine()
    
    print_info(f"Operating System: {system}")
    print_info(f"Architecture: {machine}")
    
    return system, machine


def check_command_exists(cmd):
    """Check if a command exists in PATH."""
    return shutil.which(cmd) is not None


def upgrade_pip():
    """Upgrade pip to the latest version."""
    print_info("Upgrading pip...")
    result = run_command([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])
    if result and result.returncode == 0:
        print_success("pip upgraded successfully")
        return True
    else:
        print_error("Failed to upgrade pip")
        return False


def install_uv():
    """Install uv package manager."""
    print_info("Installing uv package manager...")
    result = run_command([sys.executable, "-m", "pip", "install", "uv"])
    if result and result.returncode == 0:
        print_success("uv installed successfully")
        return True
    else:
        print_error("Failed to install uv")
        return False


def install_mineru(install_type="all", use_uv=True):
    """Install MinerU package."""
    print_info(f"Installing mineru[{install_type}]...")
    
    if use_uv:
        cmd = [sys.executable, "-m", "uv", "pip", "install", "-U", f"mineru[{install_type}]"]
    else:
        cmd = [sys.executable, "-m", "pip", "install", "-U", f"mineru[{install_type}]"]
    
    result = run_command(cmd)
    if result and result.returncode == 0:
        print_success(f"mineru[{install_type}] installed successfully")
        return True
    else:
        print_error(f"Failed to install mineru[{install_type}]")
        return False


def install_from_source(use_uv=True):
    """Install MinerU from source code."""
    print_info("Installing MinerU from source...")
    
    repo_url = "https://github.com/opendatalab/MinerU.git"
    install_dir = Path.home() / "MinerU"
    
    if install_dir.exists():
        print_warning(f"Directory {install_dir} already exists")
        response = input("Do you want to remove it and clone fresh? (y/n): ").strip().lower()
        if response == 'y':
            shutil.rmtree(install_dir)
        else:
            print_info("Using existing directory")
    
    if not install_dir.exists():
        print_info(f"Cloning repository to {install_dir}...")
        if not check_command_exists("git"):
            print_error("git is not installed. Please install git first.")
            return False
        
        result = run_command(["git", "clone", repo_url, str(install_dir)])
        if not result or result.returncode != 0:
            print_error("Failed to clone repository")
            return False
        print_success("Repository cloned successfully")
    
    original_dir = os.getcwd()
    try:
        os.chdir(install_dir)
        print_info("Installing from source...")
        
        if use_uv:
            cmd = [sys.executable, "-m", "uv", "pip", "install", "-e", ".[all]"]
        else:
            cmd = [sys.executable, "-m", "pip", "install", "-e", ".[all]"]
        
        result = run_command(cmd)
        if result and result.returncode == 0:
            print_success("MinerU installed from source successfully")
            return True
        else:
            print_error("Failed to install from source")
            return False
    finally:
        os.chdir(original_dir)


def verify_installation():
    """Verify MinerU installation."""
    print_info("Verifying installation...")
    
    result = run_command([sys.executable, "-m", "pip", "show", "mineru"])
    if result and result.returncode == 0:
        print_success("MinerU is installed")
        
        for line in result.stdout.split('\n'):
            if line.startswith('Version:'):
                print_info(line)
                break
        return True
    else:
        print_error("MinerU is not installed correctly")
        return False


def show_usage_guide():
    """Show basic usage information."""
    print_header("Usage Guide")
    
    print(f"{Colors.BOLD}Basic Usage:{Colors.ENDC}")
    print("  For GPU-accelerated systems:")
    print(f"    {Colors.OKCYAN}mineru -p <input_path> -o <output_path>{Colors.ENDC}")
    print()
    print("  For CPU-only systems:")
    print(f"    {Colors.OKCYAN}mineru -p <input_path> -o <output_path> -b pipeline{Colors.ENDC}")
    print()
    
    print(f"{Colors.BOLD}Available Commands:{Colors.ENDC}")
    print(f"  {Colors.OKCYAN}mineru{Colors.ENDC}                   - Main CLI for PDF parsing")
    print(f"  {Colors.OKCYAN}mineru-models-download{Colors.ENDC} - Download required models")
    print(f"  {Colors.OKCYAN}mineru-api{Colors.ENDC}             - Start FastAPI server")
    print(f"  {Colors.OKCYAN}mineru-gradio{Colors.ENDC}          - Start Gradio web UI")
    print()
    
    print(f"{Colors.BOLD}Next Steps:{Colors.ENDC}")
    print("  1. Download models (if needed):")
    print(f"     {Colors.OKCYAN}mineru-models-download{Colors.ENDC}")
    print()
    print("  2. Try parsing a PDF:")
    print(f"     {Colors.OKCYAN}mineru -p /path/to/your.pdf -o /output/directory{Colors.ENDC}")
    print()
    print("  3. For more information, visit:")
    print(f"     {Colors.OKCYAN}https://opendatalab.github.io/MinerU/{Colors.ENDC}")
    print()


def get_installation_preference():
    """Get user's installation preference."""
    print_header("MinerU Installation Options")
    
    print(f"{Colors.BOLD}Choose installation method:{Colors.ENDC}")
    print("  1. Quick install (recommended) - Install mineru[all]")
    print("  2. Custom install - Choose specific backends")
    print("  3. Install from source code")
    print("  4. Exit")
    print()
    
    while True:
        choice = input("Enter your choice (1-4): ").strip()
        if choice in ['1', '2', '3', '4']:
            return choice
        print_warning("Invalid choice. Please enter 1, 2, 3, or 4.")


def get_backend_preference(system):
    """Get user's backend preference for custom installation."""
    print_header("Backend Selection")
    
    print(f"{Colors.BOLD}Available backends:{Colors.ENDC}")
    print("  1. core - All core features (vlm + pipeline + api + gradio)")
    print("  2. pipeline - Traditional pipeline backend (good compatibility)")
    print("  3. vlm - Vision-Language Model backend (high accuracy)")
    print("  4. api - FastAPI server support")
    print("  5. gradio - Gradio web UI support")
    
    if system == "Darwin":
        print("  6. mlx - Apple Silicon acceleration (macOS only)")
    elif system == "Linux":
        print("  6. vllm - vLLM acceleration (Linux only)")
    elif system == "Windows":
        print("  6. lmdeploy - LMDeploy acceleration (Windows)")
    
    print()
    print("You can select multiple backends separated by comma (e.g., 2,4,5)")
    print("Or just press Enter for 'all' (recommended)")
    print()
    
    backends_map = {
        '1': 'core',
        '2': 'pipeline',
        '3': 'vlm',
        '4': 'api',
        '5': 'gradio',
        '6': 'mlx' if system == "Darwin" else 'vllm' if system == "Linux" else 'lmdeploy'
    }
    
    while True:
        choice = input("Enter your choice: ").strip()
        
        if not choice:
            return "all"
        
        selected = [c.strip() for c in choice.split(',')]
        backends = []
        
        valid = True
        for sel in selected:
            if sel in backends_map:
                backends.append(backends_map[sel])
            else:
                print_warning(f"Invalid choice: {sel}")
                valid = False
                break
        
        if valid and backends:
            return ','.join(backends)
        
        print_warning("Invalid selection. Please try again.")


def main():
    """Main installation function."""
    print_header("MinerU Installation Script")
    
    print(f"{Colors.BOLD}This script will help you install MinerU.{Colors.ENDC}\n")
    
    # Check Python version
    if not check_python_version():
        print_error("Please install a compatible Python version (3.10-3.13) and try again.")
        sys.exit(1)
    
    # Get system info
    system, machine = get_system_info()
    print()
    
    # Windows Python 3.13 check
    if system == "Windows":
        version = sys.version_info
        if version.minor == 13:
            print_error("Python 3.13 is not supported on Windows due to 'ray' dependency.")
            print_error("Please use Python 3.10-3.12 on Windows.")
            sys.exit(1)
    
    # Get installation preference
    choice = get_installation_preference()
    
    if choice == '4':
        print_info("Installation cancelled by user.")
        sys.exit(0)
    
    # Upgrade pip
    if not upgrade_pip():
        print_warning("Continuing despite pip upgrade failure...")
    
    # Install uv
    use_uv = install_uv()
    if not use_uv:
        print_warning("Continuing with pip instead of uv...")
    
    # Perform installation based on choice
    success = False
    
    if choice == '1':
        # Quick install
        success = install_mineru("all", use_uv)
    
    elif choice == '2':
        # Custom install
        backend = get_backend_preference(system)
        success = install_mineru(backend, use_uv)
    
    elif choice == '3':
        # Install from source
        success = install_from_source(use_uv)
    
    if not success:
        print_error("\nInstallation failed. Please check the error messages above.")
        print_info("For troubleshooting, visit: https://opendatalab.github.io/MinerU/faq/")
        sys.exit(1)
    
    # Verify installation
    print()
    if verify_installation():
        print_success("\n✓ MinerU installation completed successfully!\n")
        show_usage_guide()
    else:
        print_error("\nInstallation verification failed.")
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_error("\n\nInstallation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print_error(f"\n\nUnexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
