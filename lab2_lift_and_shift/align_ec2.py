# align_ec2.py

import boto3
import subprocess
import argparse
import os

# --- Configuration ---
# S3 keys for input files (what we will download)
INPUT_SEQ1_KEY = "input/seq1.fasta"
INPUT_SEQ2_KEY = "input/seq2.fasta"

# S3 key for the output file (where we will upload)
OUTPUT_KEY = "output/alignment_output.txt"

# Local filenames (where files will live on the EC2 instance)
LOCAL_SEQ1 = "seq1.fasta"
LOCAL_SEQ2 = "seq2.fasta"
LOCAL_OUTPUT = "alignment_output.txt"
# ---------------------

def download_files(s3_client, bucket_name):
    """Downloads the two FASTA files from S3."""
    print(f"Downloading {INPUT_SEQ1_KEY} from bucket {bucket_name}...")
    s3_client.download_file(bucket_name, INPUT_SEQ1_KEY, LOCAL_SEQ1)
    
    print(f"Downloading {INPUT_SEQ2_KEY} from bucket {bucket_name}...")
    s3_client.download_file(bucket_name, INPUT_SEQ2_KEY, LOCAL_SEQ2)
    print("Download complete.")

def run_needle_alignment():
    """Runs the EMBOSS needle command on the local files."""
    print("Starting EMBOSS needle alignment...")
    
    # This is the command that will be run in the terminal
    # needle -asequence seq1.fasta -bsequence seq2.fasta -outfile alignment_output.txt -gapopen 10 -gapextend 0.5
    command = [
        "needle",
        "-asequence", LOCAL_SEQ1,
        "-bsequence", LOCAL_SEQ2,
        "-outfile", LOCAL_OUTPUT,
        "-gapopen", "10",
        "-gapextend", "0.5"
    ]
    
    try:
        # Run the command
        subprocess.run(command, check=True, capture_output=True, text=True)
        print("Needle alignment successful.")
    except subprocess.CalledProcessError as e:
        print(f"Error running needle: {e}")
        print(f"STDOUT: {e.stdout}")
        print(f"STDERR: {e.stderr}")
        raise
    except FileNotFoundError:
        print("Error: 'needle' command not found.")
        print("Please ensure the EMBOSS package is installed and in the system's PATH.")
        raise

def upload_result(s3_client, bucket_name):
    """Uploads the resulting alignment file back to S3."""
    if not os.path.exists(LOCAL_OUTPUT):
        print(f"Error: Output file '{LOCAL_OUTPUT}' not found. Alignment may have failed.")
        return
        
    print(f"Uploading {LOCAL_OUTPUT} to s3://{bucket_name}/{OUTPUT_KEY}...")
    s3_client.upload_file(LOCAL_OUTPUT, bucket_name, OUTPUT_KEY)
    print("Upload complete.")

def main():
    # Set up argument parser to accept --bucket
    parser = argparse.ArgumentParser(description="Run DNA alignment on EC2 using S3.")
    parser.add_argument(
        "--bucket",
        required=True,
        help="The name of the S3 bucket for input and output."
    )
    args = parser.parse_args()
    
    # Boto3 will automatically use the IAM Role attached to the EC2 instance
    s3_client = boto3.client("s3")
    
    try:
        # Step 1: Download files
        download_files(s3_client, args.bucket)
        
        # Step 2: Run alignment
        run_needle_alignment()
        
        # Step 3: Upload result
        upload_result(s3_client, args.bucket)
        
        print("\n--- All steps completed successfully! ---")
        
    except Exception as e:
        print(f"\n--- An error occurred ---")
        print(str(e))

if __name__ == "__main__":
    main()