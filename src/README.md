# 🧬 DNA Sequence Alignment Lambda Function

This directory contains a serverless DNA sequence alignment service built with AWS Lambda, API Gateway, and S3.

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Web UI    │───▶│ API Gateway │───▶│   Lambda    │
│  (S3 Web)   │    │             │    │  Function   │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
                   ┌─────────────┐            ▼
                   │ S3 Output   │◄───────────────────┐
                   │   Bucket    │                    │
                   └─────────────┘                    │
                                                      ▼
                   ┌─────────────┐            ┌─────────────┐
                   │ S3 Input    │───────────▶│ Biopython   │
                   │   Bucket    │  (trigger) │ Processing  │
                   └─────────────┘            └─────────────┘
```

## ⚡ Features

### **Input Methods:**
1. **File Upload**: Upload FASTA files to S3 (auto-triggers Lambda)
2. **API Direct**: Send sequences directly via HTTP API
3. **Web Interface**: User-friendly HTML interface

### **Alignment Types:**
- **Global Alignment** (Needleman-Wunsch): Compare entire sequences
- **Local Alignment** (Smith-Waterman): Find best local matches

### **Output:**
- JSON results with alignment scores, identity percentages
- Visual alignment display
- Automatic S3 storage of results

## 🚀 Quick Start

### **1. Deploy Infrastructure**
```powershell
# Plan deployment
.\scripts\deploy.ps1 -Action plan

# Deploy to AWS
.\scripts\deploy.ps1 -Action apply
```

### **2. Test the Service**

#### **Option A: Web Interface**
1. Upload `src/web_interface.html` to the web S3 bucket
2. Open the hosted website
3. Use the interface to align sequences

#### **Option B: API Calls**
```bash
# Health check
curl https://your-api-url/health

# Align sequences
curl -X POST https://your-api-url/align \
  -H "Content-Type: application/json" \
  -d '{
    "sequence1": "ATGCGTACGTA",
    "sequence2": "ATGCGTACCTA", 
    "alignment_type": "global"
  }'
```

#### **Option C: S3 Upload**
```bash
# Upload FASTA file (auto-triggers processing)
aws s3 cp your_sequences.fasta s3://your-input-bucket/
```

## 📁 File Structure

```
src/
├── lambda_function.py      # Main Lambda handler
├── requirements.txt        # Python dependencies for layer
└── web_interface.html      # Web UI for testing

terraform/
├── lambda.tf              # Lambda and API Gateway config
├── iam.tf                 # IAM roles and policies
├── variables.tf           # Input variables
└── outputs.tf             # Output values

scripts/
└── deploy.ps1             # Deployment automation
```

## 🧪 Sample API Requests

### **Global Alignment**
```json
{
  "sequence1": "ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC",
  "sequence2": "ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC",
  "alignment_type": "global"
}
```

### **Local Alignment**
```json
{
  "sequence1": "ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC",
  "sequence2": "GATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAAT",
  "alignment_type": "local"
}
```

### **Expected Response**
```json
{
  "status": "success",
  "alignment_type": "global",
  "sequence1": {
    "length": 50,
    "sequence": "ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC"
  },
  "sequence2": {
    "length": 50,
    "sequence": "ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC"
  },
  "alignment": {
    "score": 50.0,
    "identity": 100.0,
    "alignment_display": ["seq1: ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC", "      ||||||||||||||||||||||||||||||||||||||||||||||||", "seq2: ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGC"]
  },
  "timestamp": "2025-10-04T10:30:00.000Z"
}
```

## 🔧 Configuration

### **Environment Variables**
- `INPUT_BUCKET`: S3 bucket for input FASTA files
- `OUTPUT_BUCKET`: S3 bucket for results
- `LOG_LEVEL`: Logging level (INFO, DEBUG, ERROR)

### **Lambda Settings**
- **Runtime**: Python 3.11
- **Memory**: 1024 MB
- **Timeout**: 5 minutes
- **Layer**: Biopython + NumPy

## 🛡️ Security Features

- **IAM Roles**: Least privilege access
- **S3 Encryption**: AES-256 server-side encryption
- **API CORS**: Configurable cross-origin requests
- **VPC**: Optional private subnet deployment
- **CloudWatch**: Comprehensive logging and monitoring

## 💰 Cost Optimization

### **Free Tier Usage:**
- **Lambda**: 1M requests/month + 400,000 GB-seconds
- **API Gateway**: 1M requests/month
- **S3**: 5GB storage + 20,000 GET requests
- **CloudWatch**: Basic monitoring included

### **Estimated Monthly Costs:**
- **Light usage** (< 1000 alignments): **$0-2**
- **Medium usage** (< 10,000 alignments): **$5-15**
- **Heavy usage** (< 100,000 alignments): **$20-50**

## 📊 Monitoring

### **CloudWatch Metrics:**
- Lambda invocations and duration
- API Gateway request count and latency
- S3 bucket operations
- Error rates and failed invocations

### **Logging:**
- Lambda execution logs: `/aws/lambda/dna-alignment-function`
- API Gateway logs: `/aws/apigateway/dna-alignment-api`

## 🚨 Troubleshooting

### **Common Issues:**

**1. Biopython Import Error**
```
Solution: Ensure Lambda layer contains Biopython and NumPy
```

**2. S3 Permission Denied**
```
Solution: Check IAM role has S3 read/write permissions
```

**3. API Gateway CORS Error**
```
Solution: Verify CORS configuration in terraform/lambda.tf
```

**4. Lambda Timeout**
```
Solution: Increase timeout or optimize sequence processing
```

### **Debugging:**
```bash
# Check Lambda logs
aws logs tail /aws/lambda/dna-alignment-function --follow

# Test API endpoint
curl -X GET https://your-api-url/health

# List S3 objects
aws s3 ls s3://your-input-bucket/
```

## 🔄 CI/CD Pipeline

For production deployments, consider:

1. **GitHub Actions** for automated testing
2. **AWS CodePipeline** for deployment automation  
3. **Lambda Versioning** for rollback capability
4. **Blue/Green Deployment** for zero-downtime updates

## 📚 Learning Resources

This project demonstrates:
- **AWS Lambda** serverless computing
- **API Gateway** REST API creation
- **S3** object storage and triggers
- **IAM** security and permissions
- **CloudWatch** monitoring and logging
- **Terraform** infrastructure as code
- **Biopython** bioinformatics in the cloud

Perfect for AWS Solutions Architect Associate (SAA-C03) certification preparation!

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.