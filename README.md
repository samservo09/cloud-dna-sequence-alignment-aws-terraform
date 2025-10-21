# 🧬 Cloud-based DNA Sequence Alignment on AWS

**From a local Lab PC to a scalable, event-driven pipeline on AWS using Terraform.**

This project is a hands-on guide for bioinformaticians, researchers, and cloud engineers. It demonstrates how to evolve a simple, local DNA alignment script into a robust, high-performance, and cost-effective cloud architecture on AWS.

This repository contains all the code and infrastructure-as-code (Terraform) files for the accompanying blog post: **From Lab PC to Serverless: DNA Sequence Alignment on AWS**

---

## The Scenario

You're a new member of Project GenomPH, a small research group at a state universityThe team's current "system" is... chaotic:
* Borrowed, legacy lab PC that malfunctions when it senses your anxiety
* A few external hard drives from some of your members
* A spreadsheet software used to track sequence file names (without versioning)
* Every week, someone asks, “Wait, sino may latest copy ng FASTA file?” (Wait, who has the latest copy of the FASTA file?)

Your goal is to modernize this workflow to be:
1.  **Cost-Optimized** (You're all students!)
2.  **High-Performing** (No more waiting hours for a script to fail)
3.  **Resilient** (No more anxiety when you hit "run")
4.  **Secure** (Protecting your research data) 

---

## Project Structure: The Three Labs

This project evolves through three distinct labs, each in its own directory.

* **`lab1_local_setup/`**
    **Goal:** Simulate the current setup. We run a Python script locally that uses `subprocess` to call a real bioinformatics tool (**EMBOSS `needle`**) to perform an alignment.
    **Architecture:** Your PC.

* **`lab2_lift_and_shift/`**
    **Goal:** The first step into the cloud. We "lift and shift" the exact same script to an **EC2 instance** and use an **S3 bucket** for storage.
    **Architecture:** EC2 runs the Python script, which reads/writes from S3.

* **`lab3_serverless/`**
    **Goal:** Go fully serverless. A file upload to S3 automatically triggers an **AWS Lambda** function, which performs the alignment (using a Python-native library, `parasail`) and saves the results to **DynamoDB**.
    **Architecture:** `S3 Event` -> `Lambda` -> `DynamoDB`.

---

## Tech Stack

* **Orchestration:** Python (Boto3, `subprocess`), AWS Step Functions
* **Infrastructure:** Terraform (Infrastructure-as-Code)
* **AWS Services:**
    * **Compute:** EC2, AWS Lambda
    * **Storage:** S3, DynamoDB
    * **Networking & Security:** VPC, IAM Roles, Security Groups
* **Bioinformatics Tools:**
    * **EMBOSS `needle`** (Lab 1 & 2): The industry-standard CLI tool for global pairwise alignment.
    * **`parasail`** (Lab 3): A fast, pure-Python library for sequence alignment, perfect for Lambda.
---

## How to Run This Project

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/samservo09/cloud-dna-sequence-alignment-aws-terraform.git
    cd cloud-dna-sequence-alignment-aws-terraform
    ```

2.  **Navigate to a Lab directory:**
    ```bash
    cd lab1_local_setup
    ```

3.  **Follow the instructions in that lab's dedicated `README.md` file.**
    * **Lab 1** will require a local install of `conda` and `emboss`.
    * **Labs 2, 3** will require you to have [Terraform](https://www.terraform.io/) and [AWS CLI](https://aws.amazon.com/cli/) installed and configured. You will simply run `terraform init` and `terraform apply`.

---

## ⚠️ Disclaimer

This project is a conceptual proof-of-concept designed for learning. The alignment scripts are simple wrappers. Real-world bioinformatics pipelines are highly complex and use established tools like GATK, BWA, and BLAST, often orchestrated with workflow managers. This project aims to show how the *cloud architecture* supporting those tools can be built and scaled.