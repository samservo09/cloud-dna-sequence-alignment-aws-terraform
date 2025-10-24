import subprocess
import os
from pathlib import Path

# --- Configuration ---
SAMPLE_DATA_DIR = "sample_data"
SEQ1_FILE = os.path.join(SAMPLE_DATA_DIR, "seq1.fasta")
SEQ2_FILE = os.path.join(SAMPLE_DATA_DIR, "seq2.fasta")
RESULTS_DIR = "results"
OUTPUT_FILE = os.path.join(RESULTS_DIR, "alignment_output.txt")
NEEDLE_EXECUTABLE = "needle"  # Assumes 'needle' is in the system's PATH

# --- Main Script ---
print("Lab 1: Local DNA Sequence Alignment")
print("=" * 60)

# Create results directory
os.makedirs(RESULTS_DIR, exist_ok=True)

# Step 1: Check if input files exist
print("\nStep 1: Checking input files...")

if not os.path.exists(SEQ1_FILE):
    print(f"Error: {SEQ1_FILE} not found")
    exit(1)
if not os.path.exists(SEQ2_FILE):
    print(f"Error: {SEQ2_FILE} not found")
    exit(1)

print(f"Found {SEQ1_FILE}")
print(f"Found {SEQ2_FILE}")

# Step 2: Run EMBOSS needle alignment
print(f"\nStep 2: Running EMBOSS needle alignment...")

command = [
    NEEDLE_EXECUTABLE,
    "-asequence", SEQ1_FILE,
    "-bsequence", SEQ2_FILE,
    "-gapopen", "10.0",
    "-gapextend", "0.5",
    "-outfile", OUTPUT_FILE,
    "-aformat", "pair"  # Output format: pairwise alignment
]

try:
    # Check if needle is installed
    print("  Checking for EMBOSS needle...")
    check_needle = subprocess.run([NEEDLE_EXECUTABLE, "-version"], 
                                  capture_output=True, 
                                  text=True)
    print(f"  ✓ EMBOSS needle found")
    
    # Run needle alignment
    print(f"  Running alignment...")
    result = subprocess.run(command, 
                           capture_output=True,
                           text=True, 
                           check=True)
    
    print(f"\Alignment successful!")
    print(f"Output saved to {OUTPUT_FILE}")
    
    # Display stderr (needle outputs progress info here)
    if result.stderr:
        print("\nNeedle output:")
        print(result.stderr)
    
    # Display a preview of the results
    print("\n" + "=" * 60)
    print("ALIGNMENT PREVIEW")
    print("=" * 60)
    
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r") as f:
            lines = f.readlines()
            # Show first 30 lines of output
            for line in lines[:30]:
                print(line.rstrip())
            if len(lines) > 30:
                print("\n... (see full alignment in results file)")

except FileNotFoundError:
    print(f"\nError: '{NEEDLE_EXECUTABLE}' not found.")
    print("\nTo install EMBOSS needle:")
    print("  Using Conda:  conda install -c bioconda emboss")
    print("  Using Homebrew (macOS): brew install emboss")
    print("  Using apt (Linux): sudo apt-get install emboss")
    print("\nTo verify installation, run: needle -version")
    exit(1)
    
except subprocess.CalledProcessError as e:
    print("\nMBOSS needle failed with an error:")
    print(e.stderr)
    exit(1)
print("\n" + "=" * 60)
print("All done! Check the results directory for full output.")
print("=" * 60)