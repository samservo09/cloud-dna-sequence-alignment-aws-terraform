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

### 1.  **Prerequisites:**
    * [Terraform](https://www.terraform.io/) installed.
    * [AWS CLI](https://aws.amazon.com/cli/) installed and configured.
    * Python 3 and `pip` (for packaging).

### 2. **Run with Manual Package Build**

Before running `terraform apply`, you must manually build the `lambda_package.zip` file. This file is required by Terraform but is not checked into Git.

These instructions use `venv` (a built-in Python tool) to create a clean, temporary environment. This is the most reliable way to gather all the necessary packages and avoid `conda` or system `pip` conflicts.

#### Step 1: Create and Activate a Temporary Environment

From the `lab3_serverless` directory:

```bash
# Create a new virtual environment in a folder named "temp_env"
python3 -m venv temp_env

# Activate the new environment
# On macOS/Linux:
source temp_env/bin/activate
# On Windows:
.\temp_env\Scripts\activate
```

#### Step 2: Install Dependencies into the Environment
Now, install all the packages listed in requirements.txt into this clean environment.

```Bash
pip install -r lambda_function/requirements.txt
```

#### Step 3: Copy Packages to the lambda_function Folder
This is the key step. We will find where pip installed the packages and copy them all into our lambda_function folder, right next to our script.

A. Find the package path: Run this command to find your site-packages folder and copy the output path:

```Bash
python -c "import site; print(site.getsitepackages()[0])"
```
Example output on macOS: 
```Bash
/Users/yourname/project/lab3_serverless/temp_env/lib/python3.9/site-packages Example output on Windows: C:\Users\yourname\project\lab3_serverless\temp_env\Lib\site-packages
```

B. Copy the files: Use the path you just copied in the command below.

```Bash
# On macOS/Linux:
# (Replace <PATH_YOU_COPIED> with your actual path)
cp -r <PATH_YOU_COPIED>/* lambda_function/

# On Windows:
# (Replace <PATH_YOU_COPIED> with your actual path)
robocopy <PATH_YOU_COPIED> lambda_function /E /S
```

#### Step 4: Deactivate and Clean Up
The packages are copied, so we no longer need the temporary environment.

```Bash
# Deactivate the environment
deactivate

# Delete the temporary environment folder
# On macOS/Linux:
rm -rf temp_env

# On Windows:
rmdir /S /Q temp_env
```

#### Step 5: Create the Zip File
Navigate into the lambda_function folder, which now contains your script and all its dependencies.

```Bash
cd lambda_function
zip -r ../lambda_package.zip .
cd ..
```

### 3.  **Initialize and Deploy:**
    ```Bash
    # From inside the `lab3_serverless` directory:
    terraform init
    
    # You will be prompted for a unique S3 bucket name
    terraform apply
    ```

### 4.  **Trigger the Pipeline:**
    * Go to the AWS S3 console and find your new bucket.
    * Create a folder named `input`.
    * **Upload your sample file** (e.g., `compare_pair_001.fasta`) into the `input/` folder.
    * *Note: This lab's Lambda is designed to read **one file** containing **two sequences**.*

### 5.  **Check the Results:**
    * That's it! The upload automatically triggered the entire pipeline.
    * Go to the **AWS DynamoDB** console.
    * Find the table named `dna-alignment-jobs` and click "Explore items".
    * You should see a new item with your filename and the alignment score.

### 6.  **CLEAN UP:**
    **This is critical.** Run `terraform destroy` to delete all resources.
    ```bash
    terraform destroy
    ```