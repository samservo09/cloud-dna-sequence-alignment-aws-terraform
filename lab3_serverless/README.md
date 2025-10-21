# Lab 3: Serverless Alignment (S3 -> Lambda -> DynamoDB)

This is the fully automated, serverless architecture. We no longer have *any* servers to manage. The entire process is event-driven.

Here's the workflow:
1.  A user uploads a **single** FASTA file (containing two sequences) to an `input/` folder in S3.
2.  The S3 "Object Created" event **automatically triggers** our AWS Lambda function.
3.  The Lambda function runs, parses the FASTA file, and performs the alignment.
4.  The alignment result (metadata like filename and score) is written to a DynamoDB table.

**Key Change:** We cannot easily package the `needle` tool in Lambda. Instead, we swap it for a pure-Python alignment library, **`parasail`**, which achieves the same goal.

## Goal
Build an automated, event-driven alignment pipeline that runs with zero servers and scales automatically.

## Tech Stack
* **Terraform**
* **AWS S3** (with Event Notifications)
* **AWS Lambda** (Our serverless compute)
* **AWS DynamoDB** (Our serverless metadata database)
* **AWS IAM** (For Lambda permissions)
* **Python 3** (with `boto3`, `parasail`, `biopython`)

---

## How to Run

1.  **Prerequisites:**
    * [Terraform](https://www.terraform.io/) installed.
    * [AWS CLI](https://aws.amazon.com/cli/) installed and configured.
    * Python 3 and `pip` (for packaging).

2.  **Package the Lambda Function:**
    Our Lambda function has dependencies (`parasail`, `biopython`). We must create a `.zip` file containing them.
    ```bash
    cd lambda_function
    
    # Install dependencies into this local directory
    pip install -r requirements.txt -t .
    
    # Create the zip file
    zip -r ../lambda_package.zip .
    
    cd ..
    ```
    The Terraform script is configured to find and deploy `lambda_package.zip`.

3.  **Initialize and Deploy:**
    From inside the `lab3_serverless` directory:
    ```bash
    terraform init
    
    # You will be prompted for a unique S3 bucket name
    terraform apply
    ```

4.  **Trigger the Pipeline:**
    * Go to the AWS S3 console and find your new bucket.
    * Create a folder named `input`.
    * **Upload your sample file** (e.g., `compare_pair_001.fasta`) into the `input/` folder.
    * *Note: This lab's Lambda is designed to read **one file** containing **two sequences**.*

5.  **Check the Results:**
    * That's it! The upload automatically triggered the entire pipeline.
    * Go to the **AWS DynamoDB** console.
    * Find the table named `dna-alignment-jobs` and click "Explore items".
    * You should see a new item with your filename and the alignment score.

6.  **CLEAN UP:**
    **This is critical.** Run `terraform destroy` to delete all resources.
    ```bash
    terraform destroy
    ```