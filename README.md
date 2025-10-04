# Cloud DNA Sequence Alignment with AWS & Terraform

A bioinformatics proof-of-concept performing DNA sequence alignment using Python and Biopython, deployed on AWS infrastructure provisioned with Terraform. This project demonstrates AWS Solutions Architect Associate (SAA-C03) skills including scalable EC2 compute, secure S3 storage, and infrastructure as code for cloud-based biological data analysis.

## 🧬 Project Overview

This project implements a cloud-based DNA sequence alignment pipeline that:
- Processes FASTA/FASTQ files containing DNA sequences
- Performs pairwise and multiple sequence alignments using Biopython
- Stores input data and results in S3 buckets with proper lifecycle management
- Runs compute workloads on scalable EC2 instances
- Provides monitoring and logging through CloudWatch

## Prerequisites

Before starting, ensure you have:
- **AWS Account** with Free Tier access
- **AWS CLI v2.x** installed
- **Terraform v1.12+** installed
- **Python 3.8+** installed
- **Git** for version control

## Quick Start

### 1. Clone and Setup
```bash
git clone git@github-samservo09:samservo09/cloud-dna-sequence-alignment-aws-terraform.git
cd cloud-dna-sequence-alignment-aws-terraform
```

### 2. Environment Setup
```powershell
# Windows PowerShell
.\setup-env.ps1

# Or manually:
$env:AWS_PROFILE = "sam09"  # Replace with your profile
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 3. Configure AWS
```bash
aws configure --profile sam09  # Replace with your preferred profile name
# Enter your AWS Access Key ID, Secret Access Key, and region (e.g., ap-southeast-1)

# Verify configuration
aws sts get-caller-identity --profile sam09
```

### 4. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 5. Run DNA Analysis
```bash
python src/dna_alignment.py
```

## 📁 Project Structure

```
├── README.md                   # This file
├── .gitignore                  # Git ignore rules
├── .env                        # Environment variables (not tracked)
├── setup-env.ps1              # Environment setup script
├── requirements.txt            # Python dependencies
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf             # Output values
│   ├── terraform.tfvars.example # Example variables
│   └── modules/               # Reusable Terraform modules
│       ├── vpc/               # VPC and networking
│       ├── security/          # IAM roles and security groups
│       ├── compute/           # EC2 instances and Auto Scaling
│       ├── storage/           # S3 buckets and policies
│       └── monitoring/        # CloudWatch and SNS
├── src/                       # Python source code
│   ├── dna_alignment.py       # Main application
│   ├── requirements.txt       # Python dependencies
│   └── utils/                 # Utility functions
├── data/                      # Data directory
│   ├── input/                 # Sample DNA sequences
│   └── output/                # Alignment results
└── scripts/                   # Automation scripts
    ├── deploy.sh              # Deployment automation
    └── cleanup.sh             # Resource cleanup
```

## 🔧 Configuration

### Environment Variables
Copy `.env` and customize:
```bash
AWS_PROFILE=sam09
AWS_DEFAULT_REGION=ap-southeast-1
TF_VAR_environment=dev
TF_VAR_project_name=dna-sequence-alignment
```

### Terraform Variables
Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`:
```hcl
environment    = "dev"
project_name   = "dna-alignment"
instance_type  = "t3.micro"  # Free tier eligible
region         = "ap-southeast-1"
```

## 💻 Local Development

### Python Environment
```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\Activate.ps1  # Windows PowerShell

# Install dependencies
pip install -r requirements.txt

# Run tests
python -m pytest tests/

# Run alignment script
python src/dna_alignment.py
```

### Terraform Commands
```bash
cd terraform

# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

## 📊 Monitoring & Logging

The project includes:
- **CloudWatch Dashboards** for infrastructure monitoring
- **CloudWatch Logs** for application logs
- **SNS Notifications** for alerts
- **S3 Access Logging** for data access auditing

Access monitoring:
```bash
aws logs describe-log-groups --profile sam09
aws cloudwatch describe-alarms --profile sam09
```

## Security Features

- **IAM Roles** with least privilege access
- **VPC** with private subnets for compute
- **Security Groups** with minimal required ports
- **S3 Bucket Policies** for data protection
- **Encryption** at rest and in transit

## Cost Management

This project is designed for AWS Free Tier:
- **EC2**: t3.micro instances (750 hours/month free)
- **S3**: 5GB storage free
- **CloudWatch**: Basic monitoring included
- **Data Transfer**: 1GB out per month free

Estimated monthly cost: **$0-5** (within free tier limits)

## Sample Data

The project includes sample DNA sequences for testing:
```
data/input/sample_sequence1.fasta
data/input/sample_sequence2.fasta
```

## Troubleshooting

### Common Issues

**AWS Authentication Error:**
```bash
# Check current profile
aws configure list

# Set profile for session
export AWS_PROFILE=sam09  # Linux/Mac
$env:AWS_PROFILE = "sam09"  # Windows PowerShell
```

**Terraform State Lock:**
```bash
# If state is locked, force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

**Python Module Not Found:**
```bash
# Ensure virtual environment is activated
pip list | grep biopython
pip install -r requirements.txt
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-analysis`
3. Make changes and test thoroughly
4. Commit: `git commit -m "Add new sequence analysis feature"`
5. Push: `git push origin feature/new-analysis`
6. Create a Pull Request

## Learning Resources

This project demonstrates AWS SAA-C03 concepts:
- **Compute**: EC2, Auto Scaling Groups
- **Storage**: S3, EBS
- **Networking**: VPC, Security Groups, Subnets
- **Security**: IAM, Policies, Encryption
- **Monitoring**: CloudWatch, SNS
- **Infrastructure as Code**: Terraform

## Author

**Samantha Servo**
- GitHub: [@samservo09](https://github.com/samservo09)
- Email: samanthaservo09@gmail.com

## Reproducibility Checklist

- [ ] AWS Free Tier account configured
- [ ] AWS CLI installed and configured with profile
- [ ] Terraform CLI installed
- [ ] Python 3.8+ with virtual environment
- [ ] All dependencies installed (`pip install -r requirements.txt`)
- [ ] Environment variables configured (`.env` file)
- [ ] AWS credentials tested (`aws sts get-caller-identity`)
- [ ] Terraform initialized (`terraform init`)
- [ ] Sample data available in `data/input/`
- [ ] Project structure matches documentation

---

**Success Criteria**: After following these instructions, you should be able to deploy the infrastructure, process sample DNA sequences, and view results in your AWS account within 15-20 minutes.
