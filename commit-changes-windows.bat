@echo off
REM =============================================================================
REM IGNITION GIT SAVE SCRIPT - Windows Version
REM Version 1.0.0 | Last Updated: November 20, 2025
REM =============================================================================
REM 
REM WHAT THIS SCRIPT DOES (in plain English):
REM   Step 1: Looks at what changed in your Ignition data folder
REM   Step 2: Saves those changes to Git with your message
REM   Step 3: Writes a note in a log file so you can see what happened
REM
REM WHERE TO PUT THIS FILE:
REM   Put it in your main Ignition folder (where you see the "data" folder)
REM   Example: C:\Program Files\Inductive Automation\Ignition\
REM
REM HOW TO USE IT:
REM   From Windows Command Prompt:
REM     commit-changes-windows.bat "What I changed"
REM
REM   From Ignition (copy this into a script):
REM     system.util.execute(["commit-changes-windows.bat", "What I changed"])
REM
REM =============================================================================

setlocal enabledelayedexpansion

REM Move to the Ignition folder (where this script lives)
cd /d "%~dp0"

REM ====================
REM STEP 1: Get your message
REM ====================
REM If you didn't provide a message, we'll create one with today's date and time
if "%~1"=="" (
    for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set MYDATE=%%c-%%a-%%b)
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do (set MYTIME=%%a:%%b)
    set "MESSAGE=Auto save !MYDATE! !MYTIME!"
) else (
    set "MESSAGE=%~1"
)

REM ====================
REM STEP 2: Set up the log file
REM ====================
REM This creates a log file in your data folder to track what happens
set "LOG=data\git-commits.log"
if not exist "%LOG%" (
    echo Ignition Git Save Log > "%LOG%"
    echo ===================== >> "%LOG%"
)

REM Write what we're about to save
echo. >> "%LOG%"
echo [%date% %time%] Saving: %MESSAGE% >> "%LOG%"

REM ====================
REM STEP 3: Check if Git is installed
REM ====================
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not installed. Please install Git first. >> "%LOG%"
    echo ERROR: Git is not installed. Please install Git first.
    echo Download from: https://git-scm.com/download/windows
    exit /b 1
)

REM ====================
REM STEP 4: Check if Git is set up in this folder
REM ====================
if not exist ".git" (
    echo ERROR: Git is not set up yet. Run these commands first: >> "%LOG%"
    echo ERROR: Git is not set up yet. Run these commands first:
    echo   git init
    echo   git add .
    echo   git commit -m "Initial setup"
    exit /b 1
)

REM ====================
REM STEP 5: Tell Git to look at the data folder
REM ====================
git add data/ >> "%LOG%" 2>&1

REM ====================
REM STEP 6: Check if anything actually changed
REM ====================
git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
    echo Nothing has changed - nothing to save >> "%LOG%"
    echo Nothing has changed - nothing to save
    exit /b 0
)

REM ====================
REM STEP 7: Save the changes to Git
REM ====================
git commit -m "%MESSAGE%" >> "%LOG%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to save changes >> "%LOG%"
    echo ERROR: Failed to save changes
    exit /b 1
)

echo SUCCESS: Changes saved to Git! >> "%LOG%"
echo SUCCESS: Changes saved to Git!

REM ====================
REM OPTIONAL: Push to GitHub/GitLab
REM ====================
REM If you want to automatically upload to GitHub/GitLab, remove the "REM" below:
REM git push >> "%LOG%" 2>&1

exit /b 0
