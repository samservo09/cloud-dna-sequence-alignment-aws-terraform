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

## SSH Key Permissions Note for Windows/WSL Users 🔑
If you're using WSL (Windows Subsystem for Linux) and get an SSH error like "WARNING: UNPROTECTED PRIVATE KEY FILE!" or "bad permissions" even after running chmod 400 on your .pem key file, it's likely because the key is stored on your Windows C: drive (/mnt/c/...).

The Windows filesystem (NTFS) doesn't always handle Linux permissions correctly when accessed from WSL.

### Solution:

Copy the .pem file into your WSL filesystem. The standard location is your WSL home directory's .ssh folder:

```Bash
# Create the directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy from your Windows path (adjust path as needed)
cp "/mnt/c/path/to/your/key.pem" ~/.ssh/key.pem
```
Set permissions inside WSL:
```Bash

chmod 400 ~/.ssh/key.pem
```

Use the WSL path in your SSH command:

```Bash

ssh -i ~/.ssh/key.pem user@host
```

This ensures the key is on a Linux filesystem where permissions work as expected for SSH. Remember to add *.pem to your .gitignore if the key is in your project folder!

## Note: Installing EMBOSS (needle) on the EC2 Instance
During my initial testing of Lab 2, the align_ec2.py script requires the EMBOSS needle alignment tool to be installed on the EC2 instance.

### The Method Used (Compiling from Source on Amazon Linux 2):

If the standard package managers (yum, even with EPEL enabled) cannot find the emboss package on Amazon Linux 2, the manual installation involves:

1. Installing development tools (gcc, make, etc.) using sudo yum groupinstall -y "Development Tools".
2. Installing necessary library dependencies (like zlib-devel).
3. Downloading the EMBOSS source code (e.g., using wget).
4. Extracting the source code (tar -zxvf ...).
Navigating into the source directory (cd EMBOSS-...).
5. Running the configuration script (./configure), potentially needing flags like --without-x to avoid graphical dependency issues.
6. Compiling the code (make), which can take several minutes.
7. Installing the compiled software (sudo make install).

This process is time-consuming, requires installing extra development tools, involves finding the correct source code URL, and troubleshooting potential configuration/compilation errors (like the X11 issue).

### Recommended Alternative (Using Ubuntu AMI):

***This is already done since I have updated the repository.***

A significantly easier approach is to use a **standard Ubuntu Server LTS AMI** instead of Amazon Linux 2 for the EC2 instance.

Ubuntu's repositories typically have broader support for bioinformatics packages like EMBOSS, making installation a simple, one-line command (apt-get install -y emboss) within the user_data script. This avoids the complexities of manual compilation. Standard Ubuntu AMIs are also generally Free Tier eligible on t2.micro/t3.micro instances.