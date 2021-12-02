@echo off
::NOTE - This script will only work once the installation of the venv is completed using install.sh

:: Get paths to everything
Set virtualEnvironName=cs3200-venv
Set root_dir=%~dp0

Set executePath="%root_dir%src\backend\main.py
Set virtualEnvironDir="%root_dir%%virtualEnvironName%
Set venvPath=%virtualEnvironDir%\Scripts\python.exe"

echo %venvPath%

echo Starting Program %executePath%"
%venvPath% %executePath%" %*

