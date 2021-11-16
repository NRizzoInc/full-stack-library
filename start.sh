#!/bin/bash
# this script enables user to run the code in this repo using the virtual environment
# CREDIT: Nick Rizzo's Personal Project: https://github.com/NRizzoInc/texting-and-emailing-agent/blob/develop/start.sh

# Get paths to everything
virtualEnvironName="cs3200-venv"
rootDir="$(readlink -fm $0/..)"
virtualEnvironDir="${rootDir}/${virtualEnvironName}"
srcPath="${rootDir}/src"
backendPath="${srcPath}/backend"
executePath="${backendPath}/main.py"
setupScript="${rootDir}/install/setup.sh"

# check OS... (decide how to call python)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # windows
    venvPath="${virtualEnvironDir}/Scripts/python.exe"
else
    # linux
    venvPath="${virtualEnvironDir}/bin/python" # NOTE: don't use ".exe"
fi

# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: start.sh"
    echo "=========================================================================================================="
    echo "Helper utility to start up the Library Database Web Application"
    echo "Starts up the virtual environment via bash and runs without user having to worry about it."
    echo "=========================================================================================================="
    echo "How to use:" 
    echo "  To Start: ./start.sh"
    echo "  To Stop: control+c"
    echo "=========================================================================================================="
    echo "Available Flags:"
    echo "  -h,--help : Prints the command line help message of the native mode that is run"
    echo "              (or this message if no mode specified)"
    echo "=========================================================================================================="
}

# use "$@" to pass on all parameter the same way to python script
ARGS=$@
# parse command line args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # none of these are reachable if mode is provided due to the break within the "mode" flag
        -h | --help )
            print_flags
            exit 0
            ;;
    esac
    shift
done

# check if venv is setup, if not inform user to run install
if [[ -f ${venvPath} ]]; then
    echo "Using virtual environment ${venvPath}"
else
    echo "Virtual environment not setup. Run ${setupScript}"
    exit
fi


echo "Starting Program ${executePath}"
"${venvPath}" "${executePath}" $ARGS
