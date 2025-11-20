#!/usr/bin/env python
"""
=============================================================================
IGNITION GIT SAVE SCRIPT - Python Version (Works on Windows, Linux, Mac)
Version 1.0.0 | Last Updated: November 20, 2025
=============================================================================

WHAT THIS SCRIPT DOES (in plain English):
  Step 1: Looks at what changed in your Ignition data folder
  Step 2: Saves those changes to Git with your message
  Step 3: Writes a note in a log file so you can see what happened

WHERE TO PUT THIS FILE:
  Put it in your main Ignition folder (where you see the "data" folder)
  Example Windows: C:\Program Files\Inductive Automation\Ignition\
  Example Linux:   /usr/local/bin/ignition/
  Example Mac:     /usr/local/ignition/

HOW TO USE IT:
  From Command Line/Terminal:
    python commit-changes.py "What I changed"

  From Ignition (copy this into a script):
    system.util.execute(["python", "commit-changes.py", "What I changed"])

=============================================================================
"""

import sys
import os
import subprocess
from datetime import datetime
from pathlib import Path


def main():
    # ====================
    # STEP 1: Get your message
    # ====================
    # If you didn't provide a message, we'll create one with today's date and time
    if len(sys.argv) > 1:
        message = sys.argv[1]
    else:
        message = f"Auto save {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"

    # Move to the folder where this script lives (Ignition folder)
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)

    # ====================
    # STEP 2: Set up the log file
    # ====================
    # This creates a log file in your data folder to track what happens
    log_file = Path("data") / "git-commits.log"
    
    # Create the log file if it doesn't exist
    if not log_file.exists():
        log_file.parent.mkdir(exist_ok=True)
        with open(log_file, "w") as f:
            f.write("Ignition Git Save Log\n")
            f.write("=====================\n")

    def log(msg):
        """Helper function to write to the log file"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(log_file, "a") as f:
            f.write(f"\n[{timestamp}] {msg}\n")

    # Write what we're about to save
    log(f"Saving: {message}")

    # ====================
    # STEP 3: Check if Git is installed
    # ====================
    try:
        subprocess.run(["git", "--version"], 
                      capture_output=True, 
                      check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        error_msg = "ERROR: Git is not installed. Please install Git first."
        log(error_msg)
        print(error_msg)
        print("Download from: https://git-scm.com/downloads")
        return 1

    # ====================
    # STEP 4: Check if Git is set up in this folder
    # ====================
    if not Path(".git").exists():
        error_msg = "ERROR: Git is not set up yet. Run these commands first:"
        log(error_msg)
        print(error_msg)
        print("  git init")
        print("  git add .")
        print("  git commit -m 'Initial setup'")
        return 1

    # ====================
    # STEP 5: Tell Git to look at the data folder
    # ====================
    try:
        result = subprocess.run(["git", "add", "data/"],
                               capture_output=True,
                               text=True)
        if result.stdout or result.stderr:
            log(result.stdout + result.stderr)
    except Exception as e:
        log(f"ERROR: Could not add files: {e}")
        print(f"ERROR: Could not add files: {e}")
        return 1

    # ====================
    # STEP 6: Check if anything actually changed
    # ====================
    try:
        result = subprocess.run(["git", "diff", "--cached", "--quiet"],
                               capture_output=True)
        if result.returncode == 0:
            msg = "Nothing has changed - nothing to save"
            log(msg)
            print(msg)
            return 0
    except Exception as e:
        log(f"ERROR: Could not check for changes: {e}")
        print(f"ERROR: Could not check for changes: {e}")
        return 1

    # ====================
    # STEP 7: Save the changes to Git
    # ====================
    try:
        result = subprocess.run(["git", "commit", "-m", message],
                               capture_output=True,
                               text=True)
        log(result.stdout + result.stderr)
        
        if result.returncode == 0:
            success_msg = "SUCCESS: Changes saved to Git!"
            log(success_msg)
            print(success_msg)
        else:
            error_msg = "ERROR: Failed to save changes"
            log(error_msg)
            print(error_msg)
            return 1
            
    except Exception as e:
        error_msg = f"ERROR: Failed to save changes: {e}"
        log(error_msg)
        print(error_msg)
        return 1

    # ====================
    # OPTIONAL: Push to GitHub/GitLab
    # ====================
    # If you want to automatically upload to GitHub/GitLab, uncomment these lines:
    # try:
    #     result = subprocess.run(["git", "push"],
    #                            capture_output=True,
    #                            text=True)
    #     log(result.stdout + result.stderr)
    # except Exception as e:
    #     log(f"Push failed: {e}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
