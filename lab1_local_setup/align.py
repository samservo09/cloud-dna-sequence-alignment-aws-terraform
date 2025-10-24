import subprocess
import os
import shutil

# --- Configuration ---
# We use os.path.join to build paths that work on any OS
DATA_DIR = "sample_data"
RESULT_DIR = "results"
SEQ1_PATH = os.path.join(DATA_DIR, "seq1.fasta")
SEQ2_PATH = os.path.join(DATA_DIR, "seq2.fasta")
RESULT_PATH = os.path.join(RESULT_DIR, "alignment_output.txt")

# EMBOSS 'needle' command parameters
GAP_OPEN_PENALTY = 10.0
GAP_EXTEND_PENALTY = 0.5

# Find the 'needle' executable from our Conda environment
# shutil.which() is the safest way to find a program in the system's PATH
NEEDLE_EXE = shutil.which("needle")

def main():
    print("--- Starting Lab 1: Local 'needle' Alignment (WSL) ---")

    # --- 1. Check if 'needle' is found ---
    if not NEEDLE_EXE:
        print("\n[ERROR] 'needle' command not found.")
        print("Please ensure your 'dna-env' Conda environment is active.")
        return

    print(f"Found 'needle' executable at: {NEEDLE_EXE}")

    # --- 2. Create the command to run ---
    command = [
        NEEDLE_EXE,
        "-asequence", SEQ1_PATH,
        "-bsequence", SEQ2_PATH,
        "-gapopen", str(GAP_OPEN_PENALTY),
        "-gapextend", str(GAP_EXTEND_PENALTY),
        "-outfile", RESULT_PATH
    ]

    # --- 3. Run the command using subprocess ---
    # Ensure the results directory exists
    os.makedirs(RESULT_DIR, exist_ok=True)

    try:
        print(f"\nRunning command: {' '.join(command)}")

        # This is the core of the script. It runs 'needle' as a child process.
        # check=True will automatically raise an error if 'needle' fails
        subprocess.run(command, capture_output=True, text=True, check=True)

        print("\n--- Alignment Successful! ---")
        print(f"Output saved to: {RESULT_PATH}")

    except FileNotFoundError:
        print(f"\n[ERROR] Could not find FASTA files in '{DATA_DIR}'.")
    except subprocess.CalledProcessError as e:
        # This catches errors from the 'needle' tool itself
        print(f"\n[ERROR] 'needle' failed to run:")
        print(e.stderr)
    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()