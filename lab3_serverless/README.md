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

## How to Build the Lambda Deployment Package

This is the most critical step for Lab 3. Our Lambda function uses the `parasail` library, which contains C code. This means it **must** be compiled for the Amazon Linux operating system that Lambda runs on.

You must build the `lambda_package.zip` file, which is not included in this repository. Here are two methods to build it correctly.

---

### Option 1: The Local Build (Docker Method)

This is the fastest method **if** your local Docker setup is working correctly. It uses a Docker container to build the package right on your machine.

**Prerequisites:**
* [Docker Desktop](https://www.docker.com/products/docker-desktop/) is installed and running.
* If using WSL, Docker Desktop's "WSL Integration" is enabled.

**Steps:**

1.  **Navigate to the Lab 3 Folder:**
    Open your terminal and `cd` into the `lab3_serverless` directory.
    ```bash
    cd /path/to/your/cloud-dna-sequence-alignment-aws-terraform/lab3_serverless
    ```

2.  **Run the Docker Build Command:**
    This command mounts your `lambda_function` folder into a clean Amazon Linux container, runs `pip install`, and saves the compiled libraries back into your folder.
    ```bash
    docker run --rm --entrypoint="/bin/sh" -v "$(pwd)/lambda_function":/var/task public.ecr.aws/lambda/python:3.9 -c "pip install -r /var/task/requirements.txt -t /var/task/"
    ```
    > **Troubleshooting:** If this command fails or your `lambda_function` folder is still empty after it runs, you may have a Docker-WSL file-sharing bug. In that case, use Option 2.

3.  **Verify and Zip the Package:**
    * Check your `lambda_function` folder. You should now see new folders like `parasail/`, `boto3/`, `numpy/`, etc.
    * `cd` into the folder and zip the contents:
        ```bash
        cd lambda_function
        zip -r ../lambda_package.zip .
        cd ..
        ```

4.  **Proceed to Deploy:**
    You now have `lambda_package.zip` and can proceed to the "Deploy with Terraform" step.

---

### Option 2: The Automated Build (GitHub Actions Method)

This method is the most reliable as it bypasses your local machine entirely. It uses GitHub's servers to build the package for you.

**Prerequisites:**
* Your project is a GitHub repository.
* Your repository contains the following two files:
    1.  `.github/workflows/build-lambda.yml` (the workflow file)
    2.  `lab3_serverless/lambda_function/requirements.txt` (the list of libraries)

**Steps:**

1.  **Push Your Code:**
    Commit and push your `lambda_handler.py`, `requirements.txt`, and the `.github/workflows/build-lambda.yml` file to your GitHub repository.
    ```bash
    git add .
    git commit -m "Add files for Lab 3"
    git push
    ```

2.  **Wait for the Action to Run:**
    Pushing your code automatically triggers the GitHub Action.
    * Go to your GitHub repository in your browser.
    * Click the **"Actions"** tab.
    * Click on the "Build Lambda Package" workflow and wait for it to complete.

3.  **Download the Artifact:**
    * Once the workflow is complete, click on it to open the summary page.
    * At the bottom, you will see an **"Artifact"** named `lambda-package`.
    * Click it to download the `lambda_package.zip` file to your computer (it will likely be in your Windows `Downloads` folder).

4.  **Move the Zip File:**
    Move the downloaded `lambda_package.zip` from your Downloads folder into your **local `lab3_serverless` project directory**.
    * If you are in your WSL terminal, you can use this command (replace `<username>`):
        ```bash
        # Make sure you are in the lab3_serverless directory first
        mv /mnt/c/Users/<your-windows-username>/Downloads/lambda-package.zip .
        ```

5.  **Proceed to Deploy:**
    You now have the correctly built `lambda_package.zip` file and are ready to deploy.

---

### Final Step: Deploy with Terraform

Once you have the `lambda_package.zip` file in your `lab3_serverless` directory (from either Option 1 or 2), you can finally build your infrastructure.

```bash
# Initialize Terraform
terraform init

# Apply the configuration
terraform apply

