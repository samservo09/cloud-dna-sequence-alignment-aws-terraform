import subprocess
import os
from pathlib import Path

# --- Configuration ---
SAMPLE_DATA_DIR = "sample_data"
INPUT_FILES = ["seq1.fasta", "seq2.fasta"]
COMBINED_FILE = "data/all_sequences.fasta"
OUTPUT_FILE = "results/aligned_sequences.fasta"
MAFFT_EXECUTABLE = "mafft"  # Assumes 'mafft' is in the system's PATH

# --- Main Script ---
print("Step 1: Combining input sequences...")

# Create necessary directories
os.makedirs("data", exist_ok=True)
os.makedirs("results", exist_ok=True)

# Combine seq1.fasta and seq2.fasta into one file
try:
    with open(COMBINED_FILE, "w") as outfile:
        for filename in INPUT_FILES:
            filepath = os.path.join(SAMPLE_DATA_DIR, filename)
            if not os.path.exists(filepath):
                print(f"Warning: {filepath} not found, skipping...")
                continue
            
            print(f"  Adding {filename}...")
            with open(filepath, "r") as infile:
                outfile.write(infile.read())
                # Add newline between files if needed
                if not infile.read().endswith('\n'):
                    outfile.write('\n')
    
    print(f"✓ Combined sequences saved to {COMBINED_FILE}")
except Exception as e:
    print(f"Error combining files: {e}")
    exit(1)

# Step 2: Run MAFFT alignment
print(f"\nStep 2: Starting alignment with MAFFT...")

command = [
    MAFFT_EXECUTABLE,
    COMBINED_FILE
]

try:
    # Check if MAFFT is installed
    check_mafft = subprocess.run(["mafft", "--version"], 
                                 capture_output=True, 
                                 text=True)
    
    # Run MAFFT alignment
    result = subprocess.run(command, 
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.PIPE, 
                            text=True, 
                            check=True)

    # Write the alignment to output file
    with open(OUTPUT_FILE, "w") as f:
        f.write(result.stdout)
    
    print(f"✓ Alignment successful! Output saved to {OUTPUT_FILE}")
    if result.stderr:
        print("\nMAFFT run information:")
        print(result.stderr)

except FileNotFoundError:
    print(f"\n❌ Error: '{MAFFT_EXECUTABLE}' not found.")
    print("\nTo install MAFFT:")
    print("  Windows: Download from https://mafft.cbrc.jp/alignment/software/windows.html")
    print("  macOS:   brew install mafft")
    print("  Linux:   sudo apt-get install mafft")
    print("\nAlternatively, use the Biopython version (see README)")
    exit(1)
    
except subprocess.CalledProcessError as e:
    print("\n❌ MAFFT failed with an error:")
    print(e.stderr)
    exit(1)

print("\n✓ All done!")