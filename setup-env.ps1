# Setup script for DNA Sequence Alignment Project
# Run this script when starting work on the project

Write-Host "Setting up DNA Sequence Alignment Project environment..." -ForegroundColor Green

# Set AWS Profile
$env:AWS_PROFILE = "sam09"
Write-Host "AWS Profile set to: $env:AWS_PROFILE" -ForegroundColor Yellow

# Activate virtual environment if not already active
if (-not $env:VIRTUAL_ENV) {
    if (Test-Path ".\venv\Scripts\Activate.ps1") {
        & ".\venv\Scripts\Activate.ps1"
        Write-Host "Virtual environment activated" -ForegroundColor Yellow
    }
}

# Verify setup
Write-Host "`nCurrent AWS Configuration:" -ForegroundColor Green
aws configure list

Write-Host "`nPython packages:" -ForegroundColor Green
python -c "import biopython, boto3, pandas; print('✅ All required packages are installed')"

Write-Host "`nEnvironment setup complete!" -ForegroundColor Green
Write-Host "You can now run Terraform and Python commands for this project." -ForegroundColor Cyan