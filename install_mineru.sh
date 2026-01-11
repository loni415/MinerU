#!/bin/bash

# MinerU Installation Script (Bash)
# This script provides a quick installation method for Linux and macOS users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}${BOLD}============================================================${NC}"
    echo -e "${BLUE}${BOLD}$(printf '%*s' $(((60+${#1})/2)) "$1")${NC}"
    echo -e "${BLUE}${BOLD}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

check_python() {
    print_info "Checking Python installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        return 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
    
    if [[ "$PYTHON_MINOR" -ge 10 && "$PYTHON_MINOR" -le 13 ]]; then
        print_success "Python $PYTHON_VERSION is compatible"
        return 0
    else
        print_error "Python $PYTHON_VERSION is not supported"
        print_error "MinerU requires Python 3.10-3.13"
        return 1
    fi
}

check_system() {
    print_info "Detecting system..."
    OS_TYPE=$(uname -s)
    ARCH=$(uname -m)
    
    print_info "Operating System: $OS_TYPE"
    print_info "Architecture: $ARCH"
    
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        MACOS_VERSION=$(sw_vers -productVersion)
        MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)
        
        if [[ "$MACOS_MAJOR" -lt 14 ]]; then
            print_warning "macOS version $MACOS_VERSION detected"
            print_warning "MinerU requires macOS 14.0 or later"
            return 1
        fi
    fi
    
    return 0
}

upgrade_pip() {
    print_info "Upgrading pip..."
    if python3 -m pip install --upgrade pip; then
        print_success "pip upgraded successfully"
        return 0
    else
        print_error "Failed to upgrade pip"
        return 1
    fi
}

install_uv() {
    print_info "Installing uv package manager..."
    if python3 -m pip install uv; then
        print_success "uv installed successfully"
        return 0
    else
        print_error "Failed to install uv"
        return 1
    fi
}

install_mineru() {
    local install_type="${1:-all}"
    print_info "Installing mineru[$install_type]..."
    
    if python3 -m uv pip install -U "mineru[$install_type]"; then
        print_success "mineru[$install_type] installed successfully"
        return 0
    else
        print_error "Failed to install mineru[$install_type]"
        print_info "Trying with pip instead..."
        if python3 -m pip install -U "mineru[$install_type]"; then
            print_success "mineru[$install_type] installed successfully"
            return 0
        else
            print_error "Installation failed"
            return 1
        fi
    fi
}

verify_installation() {
    print_info "Verifying installation..."
    
    if python3 -m pip show mineru &> /dev/null; then
        VERSION=$(python3 -m pip show mineru | grep Version | cut -d: -f2 | xargs)
        print_success "MinerU is installed"
        print_info "Version: $VERSION"
        return 0
    else
        print_error "MinerU is not installed correctly"
        return 1
    fi
}

show_usage() {
    print_header "Usage Guide"
    
    echo -e "${BOLD}Basic Usage:${NC}"
    echo "  For GPU-accelerated systems:"
    echo -e "    ${CYAN}mineru -p <input_path> -o <output_path>${NC}"
    echo ""
    echo "  For CPU-only systems:"
    echo -e "    ${CYAN}mineru -p <input_path> -o <output_path> -b pipeline${NC}"
    echo ""
    
    echo -e "${BOLD}Available Commands:${NC}"
    echo -e "  ${CYAN}mineru${NC}                   - Main CLI for PDF parsing"
    echo -e "  ${CYAN}mineru-models-download${NC} - Download required models"
    echo -e "  ${CYAN}mineru-api${NC}             - Start FastAPI server"
    echo -e "  ${CYAN}mineru-gradio${NC}          - Start Gradio web UI"
    echo ""
    
    echo -e "${BOLD}Next Steps:${NC}"
    echo "  1. Download models (if needed):"
    echo -e "     ${CYAN}mineru-models-download${NC}"
    echo ""
    echo "  2. Try parsing a PDF:"
    echo -e "     ${CYAN}mineru -p /path/to/your.pdf -o /output/directory${NC}"
    echo ""
    echo "  3. For more information, visit:"
    echo -e "     ${CYAN}https://opendatalab.github.io/MinerU/${NC}"
    echo ""
}

main() {
    print_header "MinerU Installation Script"
    
    echo -e "${BOLD}This script will install MinerU with all features.${NC}\n"
    
    # Check Python
    if ! check_python; then
        print_error "Please install Python 3.10-3.13 and try again."
        exit 1
    fi
    
    # Check system
    if ! check_system; then
        print_error "System requirements not met."
        exit 1
    fi
    
    echo ""
    
    # Upgrade pip
    if ! upgrade_pip; then
        print_warning "Continuing despite pip upgrade failure..."
    fi
    
    # Install uv
    if ! install_uv; then
        print_warning "Continuing with pip instead of uv..."
    fi
    
    # Install MinerU
    if ! install_mineru "all"; then
        print_error "\nInstallation failed. Please check the error messages above."
        print_info "For troubleshooting, visit: https://opendatalab.github.io/MinerU/faq/"
        exit 1
    fi
    
    echo ""
    
    # Verify installation
    if verify_installation; then
        print_success "\n✓ MinerU installation completed successfully!\n"
        show_usage
    else
        print_error "\nInstallation verification failed."
        exit 1
    fi
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}Installation cancelled by user.${NC}"; exit 1' INT

# Run main function
main
