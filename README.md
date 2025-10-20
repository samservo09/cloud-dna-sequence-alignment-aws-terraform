# 🧬 Cloud-based DNA Sequence Alignment on AWS

**From a local Lab PC to a scalable, event-driven pipeline on AWS using Terraform.**

This project is a hands-on guide for bioinformaticians, researchers, and cloud engineers. It demonstrates how to evolve a simple, local DNA alignment script into a robust, high-performance, and cost-effective cloud architecture on AWS.

This repository contains all the code and infrastructure-as-code (Terraform) files for the accompanying blog post: **[Your Blog Post Title Here]**

---

## The Scenario

[cite_start]You're a new member of Project GenomPH, a small research group at a state university[cite: 13]. [cite_start]The team's current "system" is... chaotic[cite: 20]:
* [cite_start]A single, borrowed, legacy lab PC[cite: 15].
* [cite_start]Data is stored on various external hard drives[cite: 16].
* [cite_start]A spreadsheet is used to track file names (with no versioning)[cite: 17].
* [cite_start]Every week, someone asks, "Wait, who has the latest copy of the FASTA file?"[cite: 18, 19].

Your goal is to modernize this workflow to be:
1.  [cite_start]**Cost-Optimized** (You're all students!) [cite: 23]
2.  [cite_start]**High-Performing** (No more waiting hours for a script to fail) [cite: 24]
3.  [cite_start]**Resilient** (No more anxiety when you hit "run") [cite: 24]
4.  [cite_start]**Secure** (Protecting your research data) [cite: 24]

---

## Project Structure: The Three Labs

This project evolves through three distinct labs, each in its own directory.

* **`lab1_local_setup/`**
    [cite_start]**Goal:** Simulate the current setup[cite: 7]. We run a Python script locally that uses `subprocess` to call a real bioinformatics tool (**EMBOSS `needle`**) to perform an alignment.
    * [cite_start]**Architecture:** Your PC[cite: 35, 38].

* **`lab2_lift_and_shift/`**
    **Goal:** The first step into the cloud. [cite_start]We "lift and shift" the exact same script to an **EC2 instance** and use an **S3 bucket** for storage[cite: 8, 49].
    * [cite_start]**Architecture:** EC2 runs the Python script, which reads/writes from S3[cite: 85, 86, 87].

* **`lab3_serverless/`**
    **Goal:** Go fully serverless. [cite_start]A file upload to S3 automatically triggers an **AWS Lambda** function, which performs the alignment (using a Python-native library, `parasail`) and saves the results to **DynamoDB**[cite: 10, 103].
    * [cite_start]**Architecture:** `S3 Event` -> `Lambda` -> `DynamoDB`[cite: 114, 115, 118].

* **`lab4_advanced_workflow/`**
    **Goal:** The "real-world" solution. This architecture addresses the limitations of Lab 3 (e.g., Lambda's 15-min timeout) by using **AWS Batch** for heavy computation and **AWS Step Functions** for orchestration.
    * **Architecture:** `S3 Event` -> `Step Function` -> `AWS Batch Job (Container)` -> `S3/DynamoDB`

---

## Tech Stack

* **Orchestration:** Python (Boto3, `subprocess`), AWS Step Functions
* **Infrastructure:** Terraform (Infrastructure-as-Code)
* **AWS Services:**
    * **Compute:** EC2, AWS Lambda, AWS Batch, Fargate
    * **Storage:** S3, DynamoDB
    * **Networking & Security:** VPC, IAM Roles, Security Groups
* **Bioinformatics Tools:**
    * **EMBOSS `needle`** (Lab 1 & 2): The industry-standard CLI tool for global pairwise alignment.
    * **`parasail`** (Lab 3): A fast, pure-Python library for sequence alignment, perfect for Lambda.
    * **`BWA`/`MAFFT`** (Lab 4): Examples of heavy-duty tools packaged in a **Docker container**.

---

## How to Run This Project

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/saas-dna-project.git](https://github.com/your-username/saas-dna-project.git)
    cd saas-dna-project
    ```

2.  **Navigate to a Lab directory:**
    ```bash
    cd lab1_local_setup
    ```

3.  **Follow the instructions in that lab's dedicated `README.md` file.**
    * **Lab 1** will require a local install of `conda` and `emboss`.
    * **Labs 2, 3, and 4** will require you to have [Terraform](https://www.terraform.io/) and [AWS CLI](https://aws.amazon.com/cli/) installed and configured. You will simply run `terraform init` and `terraform apply`.

---

## ⚠️ Disclaimer

[cite_start]This project is a conceptual proof-of-concept designed for learning[cite: 26]. The alignment scripts are simple wrappers. [cite_start]Real-world bioinformatics pipelines are highly complex and use established tools like GATK, BWA, and BLAST, often orchestrated with workflow managers[cite: 27, 28]. This project aims to show how the *cloud architecture* supporting those tools can be built and scaled.