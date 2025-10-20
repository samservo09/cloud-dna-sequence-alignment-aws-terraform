import subprocess
import os

# --- Configuration ---
INPUT_FILE = "data/all_sequences.fasta"  # MAFFT takes one file with all sequences
OUTPUT_FILE = "results/aligned_sequences.fasta"
MAFFT_EXECUTABLE = "mafft" # Assumes 'mafft' is in the system's PATH

# --- Main Script ---
print(f"Starting alignment for {INPUT_FILE}...")

# Create the results directory if it doesn't exist
os.makedirs("results", exist_ok=True)

# This is the command you would type in your terminal:
# "mafft data/all_sequences.fasta > results/aligned_sequences.fasta"
command = [
    MAFFT_EXECUTABLE,
    INPUT_FILE
]

try:
    # We use subprocess.run() to execute the command
    # stdout=subprocess.PIPE captures the standard output
    # text=True decodes the output as text (UTF-8)
    # check=True will raise an error if MAFFT fails
    result = subprocess.run(command, 
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.PIPE, 
                            text=True, 
                            check=True)

    # Write the captured output (the alignment) to our file
    with open(OUTPUT_FILE, "w") as f:
        f.write(result.stdout)
    
    print(f"Alignment successful! Output saved to {OUTPUT_FILE}")
    if result.stderr:
        print("MAFFT run information:\n", result.stderr)

except FileNotFoundError:
    print(f"Error: '{MAFFT_EXECUTABLE}' not found.")
    print("Please ensure MAFFT is installed and in your system's PATH.")
except subprocess.CalledProcessError as e:
    print("MAFFT failed with an error:")
    print(e.stderr)