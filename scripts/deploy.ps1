# DNA Sequence Alignment Deployment Script
# This script helps deploy the Lambda function and associated infrastructure

param(
    [string]$Action = "plan",
    [string]$Environment = "dev"
)

Write-Host "🧬 DNA Sequence Alignment Deployment Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Set environment variables
$env:AWS_PROFILE = "sam09"
$env:TF_VAR_environment = $Environment

# Navigate to terraform directory
Set-Location $PSScriptRoot\..\terraform

Write-Host "`n📋 Current Configuration:" -ForegroundColor Yellow
Write-Host "- AWS Profile: $env:AWS_PROFILE"
Write-Host "- Environment: $Environment"
Write-Host "- Action: $Action"

# Check prerequisites
Write-Host "`n🔍 Checking Prerequisites..." -ForegroundColor Yellow

# Check AWS CLI
try {
    $awsVersion = aws --version
    Write-Host "✅ AWS CLI: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI." -ForegroundColor Red
    exit 1
}

# Check AWS credentials
try {
    $identity = aws sts get-caller-identity --query "Account" --output text
    Write-Host "✅ AWS Account: $identity" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured. Run 'aws configure'." -ForegroundColor Red
    exit 1
}

# Check Terraform
try {
    $tfVersion = terraform version -json | ConvertFrom-Json
    Write-Host "✅ Terraform: $($tfVersion.terraform_version)" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Please install Terraform." -ForegroundColor Red
    exit 1
}

# Check if we need to create Lambda layer
$layerPath = "..\src\biopython_layer.zip"
if (-not (Test-Path $layerPath)) {
    Write-Host "`n📦 Creating Biopython Lambda Layer..." -ForegroundColor Yellow
    Write-Host "Note: This would normally require building the layer with biopython and numpy."
    Write-Host "For now, we'll create a placeholder. In production, use AWS SAM or docker to build layers."
    
    # Create a minimal placeholder layer
    $tempDir = ".\temp_layer"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Set-Content -Path "$tempDir\placeholder.txt" -Value "Placeholder for Biopython layer"
    
    # Create zip (in production, this would contain actual Python packages)
    Compress-Archive -Path "$tempDir\*" -DestinationPath $layerPath -Force
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "⚠️  Created placeholder layer. Replace with actual Biopython layer before deployment." -ForegroundColor Yellow
}

# Execute Terraform commands based on action
switch ($Action.ToLower()) {
    "init" {
        Write-Host "`n🚀 Initializing Terraform..." -ForegroundColor Yellow
        terraform init
    }
    "plan" {
        Write-Host "`n📋 Planning Terraform deployment..." -ForegroundColor Yellow
        terraform init -upgrade
        terraform plan
    }
    "apply" {
        Write-Host "`n🚀 Applying Terraform configuration..." -ForegroundColor Yellow
        terraform init -upgrade
        terraform plan
        
        $confirmation = Read-Host "`nDo you want to apply these changes? (yes/no)"
        if ($confirmation -eq "yes") {
            terraform apply -auto-approve
            
            # Get outputs
            Write-Host "`n📊 Deployment Outputs:" -ForegroundColor Green
            terraform output usage_instructions
            
            # Save important outputs to file
            $outputs = @{
                api_url = terraform output -raw api_gateway_url
                input_bucket = terraform output -raw input_bucket_name
                output_bucket = terraform output -raw output_bucket_name
                lambda_name = terraform output -raw lambda_function_name
            }
            
            $outputs | ConvertTo-Json | Out-File -FilePath "..\deployment_info.json"
            Write-Host "📄 Deployment info saved to deployment_info.json" -ForegroundColor Green
        }
    }
    "destroy" {
        Write-Host "`n💥 Destroying Terraform infrastructure..." -ForegroundColor Red
        
        $confirmation = Read-Host "Are you sure you want to DESTROY all resources? (yes/no)"
        if ($confirmation -eq "yes") {
            terraform destroy -auto-approve
        }
    }
    "output" {
        Write-Host "`n📊 Current Deployment Outputs:" -ForegroundColor Yellow
        terraform output
    }
    default {
        Write-Host "`n❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: init, plan, apply, destroy, output" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "`n✅ Script completed!" -ForegroundColor Green