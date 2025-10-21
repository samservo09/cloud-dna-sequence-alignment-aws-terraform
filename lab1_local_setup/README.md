# Lab 1: Local Setup

This lab simulates the starting point for "Project GenomePH": running a DNA alignment script on a local lab computer.

The Python script in this directory (`align.py`) does **not** perform the alignment itself. Instead, it acts as a **wrapper** that calls a real, industry-standard bioinformatics tool, **EMBOSS `needle`**, using the `subprocess` module.

## Goal
Run a pairwise DNA alignment entirely on your local machine, mimicking the original, manual process.

## 🛠 Tech Stack
* **Python 3**
* **`subprocess`** (Python module to run command-line tools)
* **EMBOSS `needle`** (The actual command-line alignment tool)

---

## How to Run

1.  **Install EMBOSS:**
    The easiest way is using Conda (or Homebrew on macOS).
    ```bash
    # The recommended is Miniconda
    conda install -c bioconda emboss
    ```
    To verify, type `needle -version` in your terminal.

2.  **Add Sample Data:**
    This directory contains a `sample_data/` folder. Place your two sample FASTA files inside it.
    * `sample_data/seq1.fasta`
    * `sample_data/seq2.fasta`

3.  **Run the Script:**
    From inside the `lab1_local_setup` directory, run the Python wrapper script.
    ```bash
    python align.py
    ```

4.  **Check the Results:**
    The script will call `needle` and save its full output to the `results/` directory as `alignment_output.txt`. You can open this file to see the alignment score and details.