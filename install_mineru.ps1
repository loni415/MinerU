# MinerU Installation Script (PowerShell)
# This script provides a quick installation method for Windows users

# Set error action preference
$ErrorActionPreference = "Stop"

# Color functions
function Write-Header {
    param([string]$Text)
    Write-Host "`n============================================================" -ForegroundColor Blue
    Write-Host $Text.PadLeft((60 + $Text.Length) / 2) -ForegroundColor Blue
    Write-Host "============================================================`n" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠ $Text" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ $Text" -ForegroundColor Cyan
}

function Test-PythonVersion {
    Write-Info "Checking Python installation..."
    
    try {
        $pythonVersion = & python --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Python not found"
        }
        
        # Parse version
        if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]
            
            if ($major -eq 3 -and $minor -ge 10 -and $minor -le 12) {
                Write-Success "Python $major.$minor.$patch is compatible"
                return $true
            }
            elseif ($major -eq 3 -and $minor -eq 13) {
                Write-ErrorMsg "Python 3.13 is not supported on Windows"
                Write-ErrorMsg "The 'ray' dependency does not support Python 3.13 on Windows"
                Write-ErrorMsg "Please use Python 3.10-3.12"
                return $false
            }
            else {
                Write-ErrorMsg "Python $major.$minor.$patch is not supported"
                Write-ErrorMsg "MinerU requires Python 3.10-3.12 on Windows"
                return $false
            }
        }
    }
    catch {
        Write-ErrorMsg "Python is not installed or not in PATH"
        Write-ErrorMsg "Please install Python 3.10-3.12 from https://www.python.org/"
        return $false
    }
}

function Test-SystemRequirements {
    Write-Info "Checking system requirements..."
    
    $os = [System.Environment]::OSVersion.VersionString
    Write-Info "Operating System: $os"
    
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    Write-Info "Architecture: $arch"
    
    return $true
}

function Update-Pip {
    Write-Info "Upgrading pip..."
    
    try {
        & python -m pip install --upgrade pip 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "pip upgraded successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to upgrade pip"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Failed to upgrade pip: $_"
        return $false
    }
}

function Install-UV {
    Write-Info "Installing uv package manager..."
    
    try {
        & python -m pip install uv 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "uv installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to install uv"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Failed to install uv: $_"
        return $false
    }
}

function Install-MinerU {
    param(
        [string]$InstallType = "all",
        [bool]$UseUV = $true
    )
    
    Write-Info "Installing mineru[$InstallType]..."
    
    try {
        if ($UseUV) {
            & python -m uv pip install -U "mineru[$InstallType]"
        }
        else {
            & python -m pip install -U "mineru[$InstallType]"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "mineru[$InstallType] installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to install mineru[$InstallType]"
            
            if ($UseUV) {
                Write-Info "Trying with pip instead..."
                & python -m pip install -U "mineru[$InstallType]"
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "mineru[$InstallType] installed successfully"
                    return $true
                }
            }
            
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Installation failed: $_"
        return $false
    }
}

function Test-Installation {
    Write-Info "Verifying installation..."
    
    try {
        $output = & python -m pip show mineru 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "MinerU is installed"
            
            $versionLine = $output | Select-String -Pattern "^Version:" | Select-Object -First 1
            if ($versionLine) {
                Write-Info $versionLine.ToString().Trim()
            }
            
            return $true
        }
        else {
            Write-ErrorMsg "MinerU is not installed correctly"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "MinerU is not installed correctly"
        return $false
    }
}

function Show-UsageGuide {
    Write-Header "Usage Guide"
    
    Write-Host "Basic Usage:" -ForegroundColor White
    Write-Host "  For GPU-accelerated systems:"
    Write-Host "    mineru -p <input_path> -o <output_path>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  For CPU-only systems:"
    Write-Host "    mineru -p <input_path> -o <output_path> -b pipeline" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Available Commands:" -ForegroundColor White
    Write-Host "  mineru                   - Main CLI for PDF parsing" -ForegroundColor Cyan
    Write-Host "  mineru-models-download   - Download required models" -ForegroundColor Cyan
    Write-Host "  mineru-api               - Start FastAPI server" -ForegroundColor Cyan
    Write-Host "  mineru-gradio            - Start Gradio web UI" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor White
    Write-Host "  1. Download models (if needed):"
    Write-Host "     mineru-models-download" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Try parsing a PDF:"
    Write-Host "     mineru -p C:\path\to\your.pdf -o C:\output\directory" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. For more information, visit:"
    Write-Host "     https://opendatalab.github.io/MinerU/" -ForegroundColor Cyan
    Write-Host ""
}

function Main {
    Write-Header "MinerU Installation Script"
    
    Write-Host "This script will install MinerU with all features.`n" -ForegroundColor White
    
    # Check Python version
    if (-not (Test-PythonVersion)) {
        Write-ErrorMsg "Please install Python 3.10-3.12 and try again."
        exit 1
    }
    
    # Check system requirements
    if (-not (Test-SystemRequirements)) {
        Write-ErrorMsg "System requirements not met."
        exit 1
    }
    
    Write-Host ""
    
    # Upgrade pip
    if (-not (Update-Pip)) {
        Write-Warning "Continuing despite pip upgrade failure..."
    }
    
    # Install uv
    $useUV = Install-UV
    if (-not $useUV) {
        Write-Warning "Continuing with pip instead of uv..."
    }
    
    # Install MinerU
    if (-not (Install-MinerU -InstallType "all" -UseUV $useUV)) {
        Write-ErrorMsg "`nInstallation failed. Please check the error messages above."
        Write-Info "For troubleshooting, visit: https://opendatalab.github.io/MinerU/faq/"
        exit 1
    }
    
    Write-Host ""
    
    # Verify installation
    if (Test-Installation) {
        Write-Success "`n✓ MinerU installation completed successfully!`n"
        Show-UsageGuide
    }
    else {
        Write-ErrorMsg "`nInstallation verification failed."
        exit 1
    }
}

# Handle Ctrl+C
trap {
    Write-Host "`n" -NoNewline
    Write-ErrorMsg "Installation cancelled by user."
    exit 1
}

# Run main function
try {
    Main
}
catch {
    Write-ErrorMsg "`nUnexpected error: $_"
    Write-Host $_.ScriptStackTrace
    exit 1
}
