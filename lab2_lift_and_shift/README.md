# Lab 2: AWS Lift & Shift (EC2 + S3)

This lab is the first step into the cloud. We are "lifting and shifting" our local process with minimal changes. We will use Terraform to provision the core infrastructure: an EC2 instance (our new "lab PC") and an S3 bucket (our new "external hard drive").

The Python script (`align_ec2.py`) is almost identical to Lab 1, but with two key additions:
1.  It uses **Boto3** to *download* the input files from S3.
2.  It uses **Boto3** to *upload* the result file back to S3.

The alignment is still performed by the **EMBOSS `needle`** tool, which we will automatically install on the EC2 instance using a `user_data` script.

## Goal
Migrate the local alignment script to a cloud-based EC2 instance and use S3 for persistent storage.

## Tech Stack
* **Terraform** (Infrastructure-as-Code)
* **AWS EC2** (Our virtual server)
* **AWS S3** (Our scalable, durable storage)
* **AWS IAM** (To give EC2 permission to access S3)
* **Python 3** (with `boto3` and `subprocess`)
* **EMBOSS `needle`**

---

## How to Run

1.  **Prerequisites:**
    * [Terraform](https://www.terraform.io/) installed.
    * [AWS CLI](https://aws.amazon.com/cli/) installed and configured (run `aws configure`).

2.  **Initialize Terraform:**
    From inside the `lab2_lift_and_shift` directory:
    ```bash
    terraform init
    ```

3.  **Deploy the Infrastructure:**
    You will need to provide a **globally unique S3 bucket name**.
    ```bash
    # You will be prompted for the bucket name
    terraform apply
    ```
    This will create the S3 bucket, the EC2 instance, and all required IAM roles.

4.  **Upload Your Data:**
    * Go to the AWS S3 console and find the bucket you just created.
    * Create a new folder named `input`.
    * Upload your two sample FASTA files (e.g., `seq1.fasta` and `seq2.fasta`) into this `input/` folder.

5.  **Run the Job:**
    * Terraform will output the `instance_public_ip`. SSH into your new EC2 instance. (You may need to specify your AWS key pair, e.g., `ssh -i "key.pem" ec2-user@YOUR_PUBLIC_IP`).
    * The repository code (or just the script) will need to be on the instance. The `user_data.sh` (as defined in `main.tf`) should ideally clone it.
    * Run the Python script. **You must pass it your bucket name.**
        ```bash
        # The script is pre-configured to find 'seq1.fasta' and 'seq2.fasta'
        python3 align_ec2.py --bucket "your-unique-bucket-name"
        ```

6.  **Check the Results:**
    * Go back to your S3 bucket in the AWS console.
    * You will see a new folder named `output` containing your `alignment_output.txt` file.

7.  **CLEAN UP:**
    **This is critical to avoid costs.** Run `terraform destroy` as soon as you are done.
    ```bash
    terraform destroy
    ```