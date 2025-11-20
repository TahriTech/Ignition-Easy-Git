#!/bin/bash
###############################################################################
# IGNITION GIT SAVE SCRIPT - Linux/Mac Version
# Version 1.0.0 | Last Updated: November 20, 2025
###############################################################################
#
# WHAT THIS SCRIPT DOES (in plain English):
#   Step 1: Looks at what changed in your Ignition data folder
#   Step 2: Saves those changes to Git with your message
#   Step 3: Writes a note in a log file so you can see what happened
#
# WHERE TO PUT THIS FILE:
#   Put it in your main Ignition folder (where you see the "data" folder)
#   Example: /usr/local/bin/ignition/
#
# HOW TO USE IT:
#   First time only - make it executable:
#     chmod +x commit-changes-linux-mac.sh
#
#   From Terminal:
#     ./commit-changes-linux-mac.sh "What I changed"
#
#   From Ignition (copy this into a script):
#     system.util.execute(["./commit-changes-linux-mac.sh", "What I changed"])
#
###############################################################################

# Move to the Ignition folder (where this script lives)
cd "$(dirname "$0")" || exit 1

# ====================
# STEP 1: Get your message
# ====================
# If you didn't provide a message, we'll create one with today's date and time
if [ -z "$1" ]; then
    MESSAGE="Auto save $(date '+%Y-%m-%d %H:%M:%S')"
else
    MESSAGE="$1"
fi

# ====================
# STEP 2: Set up the log file
# ====================
# This creates a log file in your data folder to track what happens
LOG="data/git-commits.log"
if [ ! -f "$LOG" ]; then
    echo "Ignition Git Save Log" > "$LOG"
    echo "=====================" >> "$LOG"
fi

# Helper function to write to the log file
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Write what we're about to save
log "Saving: $MESSAGE"

# ====================
# STEP 3: Check if Git is installed
# ====================
if ! command -v git &> /dev/null; then
    log "ERROR: Git is not installed. Please install Git first."
    echo "ERROR: Git is not installed. Please install Git first."
    echo "Install with: sudo apt-get install git (Ubuntu) or brew install git (Mac)"
    exit 1
fi

# ====================
# STEP 4: Check if Git is set up in this folder
# ====================
if [ ! -d ".git" ]; then
    log "ERROR: Git is not set up yet. Run these commands first:"
    echo "ERROR: Git is not set up yet. Run these commands first:"
    echo "  git init"
    echo "  git add ."
    echo "  git commit -m 'Initial setup'"
    exit 1
fi

# ====================
# STEP 5: Tell Git to look at the data folder
# ====================
git add data/ >> "$LOG" 2>&1

# ====================
# STEP 6: Check if anything actually changed
# ====================
if git diff --cached --quiet; then
    log "Nothing has changed - nothing to save"
    echo "Nothing has changed - nothing to save"
    exit 0
fi

# ====================
# STEP 7: Save the changes to Git
# ====================
if git commit -m "$MESSAGE" >> "$LOG" 2>&1; then
    log "SUCCESS: Changes saved to Git!"
    echo "SUCCESS: Changes saved to Git!"
else
    log "ERROR: Failed to save changes"
    echo "ERROR: Failed to save changes"
    exit 1
fi

# ====================
# OPTIONAL: Push to GitHub/GitLab
# ====================
# If you want to automatically upload to GitHub/GitLab, remove the "#" below:
# git push >> "$LOG" 2>&1

exit 0
