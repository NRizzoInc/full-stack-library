:: create virtual environment to install desired packages (i.e. flask & extensions)
@echo off

set virtualEnvironName=library-venv
:: get the directory the file is stored in using %~dp0
set installDir=%~dp0

:: Need to do this syntax to get to parent (P) directory
FOR %%P IN ("%installDir%.") DO SET rootDir=%%~dpP
set virtualEnvironDir="%rootDir%%virtualEnvironName%
set pythonVersion=3.9

:: Install the venv

@echo Please use python3.9 when running this script...
::timeout 5 > NUL

@echo #1.1 Removing any existing environments
RMDIR /S /Q %virtualEnvironDir%"

@echo on

@echo #1.2: Creating Virtual Environment
:: This will automatically activate the venv
:: Specify the version (that should've been downloaded based on README instructions)
py -3.9 -m venv %virtualEnvironDir%"

@echo #1.3 Getting Path to Virtual Environment's Python
set pythonLocation=%virtualEnvironDir%\Scripts\python.exe"
@echo -- pythonLocation: %pythonLocation%
set pipLocation=%virtualEnvironDir%\Scripts\pip3.exe"

@echo #2 Upgrading pip to latest
%pythonLocation% -m pip install --upgrade pip

:: Download / Setup the venv with the right modules
@echo #3 Installing all packages
%pipLocation% install -r "%installDir%\requirements.txt"

%virtualEnvironDir%\Scripts\deactivate"

@echo Install & Setup of the virtual environment for this project is done.
@echo Please run the start.sh or start.bat files at the top level of the project.
