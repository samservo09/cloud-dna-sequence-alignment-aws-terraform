# Windows 10/11 (WSL) Setup Guide

This project (specifically Lab 1) uses a core bioinformatics tool called **EMBOSS needle**. This tool is **built for Linux/macOS** and is not available on Windows.

The standard solution for bioinformaticians on Windows is to use the Windows Subsystem for Linux (WSL). This guide will walk you through setting up a complete Linux environment for this project, all without leaving Windows.


This guide assumes **you have WSL (e.g., Ubuntu) installed from the Microsoft Store**.**

## Overview of Steps
- **Install Miniconda (in WSL)**: We will install the Linux version of Miniconda inside your Ubuntu terminal.
- **Configure Conda**: We'll set up the bioconda channels needed to install scientific tools.
- **Create Environment**: We will create a dna-env with all our tools (emboss, python).
- **Connect VS Code**: We will connect your Windows VS Code to your new Linux environment.

### Step 1: Install Miniconda (Inside WSL)
- Open your WSL/Ubuntu terminal (from your Start Menu).
- Download the latest Linux installer for Miniconda:
```Bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
- Run the installer script:
```Bash
bash Miniconda3-latest-Linux-x86_64.sh
```

#### Follow the on-screen prompts:
- Press ENTER to read the license.
- Keep pressing ENTER (or q) to get to the end.
- Type yes to accept the license terms.
- Press ENTER to accept the default install location (/home/YourName/miniconda3).
- Type yes when it asks, "Do you wish the installer to initialize Miniconda3?".
- Close and re-open your WSL terminal. Your prompt should now show (base) at the beginning.

### Step 2: Configure Conda Channels
This is a one-time setup that tells Conda where to find bioinformatics packages.

- From your WSL terminal (with (base) active), run these four commands one by one:
```Bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

This sets up the **correct channel priority** bioconda (where emboss lives) depends on packages from conda-forge. This setup ensures Conda can find all the dependencies.

### Step 3: Create & Activate Your Project Environment

Now you'll create the isolated env for this project.

- Run the create command:
```Bash
conda create -n dna-env emboss python=3.9 -y
```

This creates a new environment named **dna-env**.

It installs emboss (which includes needle) and python=3.9 into it.

- Activate your new environment:
```Bash
conda activate dna-env
```
Your terminal prompt will change from (base) to (dna-env). Your Linux environment is now 100% ready.

### Step 4: Connect VS Code to WSL

Finally, let's connect your VS Code editor to this new Linux environment.

#### Install the WSL Extension:
- Open your (Windows) VS Code.
- Go to the Extensions tab.
- Search for and install the WSL extension from Microsoft.

#### Connect to WSL:
- Press Ctrl+Shift+P to open the Command Palette.
- Type and select it:
```Bash
WSL: Connect to WSL
```
- VS Code will restart and connect to your Linux environment. The green button in the bottom-left corner will say WSL: Ubuntu.

#### Open Your Project Folder:
- Stay in this WSL-connected window.
- Go to Terminal > New Terminal (or press `Ctrl+``).
- In the new terminal, cd to your project's Linux path. Your Windows C: drive is located at /mnt/c/.

## Replace 'YourName' and 'path/to' with your actual folder path
cd /mnt/c/Users/SamanthaVivienServo/cloud-dna-sequence-alignment-aws-terraform
- Once you are in your project folder, type:

```Bash
code .
```

- A new VS Code window will pop up, correctly opened to your project inside WSL.
- Close your old VS Code window and use this new one.

#### Install the Python Extension (in WSL):
- In your new VS Code window, go to the Extensions tab.
- Search for Python (from Microsoft).
- Click the green button that says "Install in WSL: Ubuntu".

#### Select Your Conda Interpreter:
- Open your lab1_local_setup/align.py file.
- Press Ctrl+Shift+P for the Command Palette.
- Type:
```Bash
Python: Select Interpreter
```

- Choose your 'dna-env': conda environment from the list.
- If it's not in the list:
Choose "Enter interpreter path...".
- A box will pop up. Click "Find...".
- In your WSL terminal, find the path by running: which python
Copy the path (e.g., /home/SamanthaVivienServo/miniconda3/envs/dna-env/bin/python).
- Paste this full path into the VS Code box and press Enter.


## You Are Ready! 
You are now fully set up. To check, open a new terminal in VS Code (Ctrl+\``\)

It should automatically show **(dna-env)`** at the prompt.

You can now run Lab 1 as intended:
```Bash
python lab1_local_setup/align.py
```