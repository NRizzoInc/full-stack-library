#!/bin/bash
# create virtual environment to install desired packages (i.e. flask & extensions)
# Credit: Nick Rizzo's Personal Project: https://github.com/NRizzoInc/texting-and-emailing-agent/blob/develop/install/setup.sh
[[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && isWindows=true || isWindows=false

# if linux, need to check if using correct permissions
if [[ "${isWindows}" = false ]]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root ('sudo')"
        exit
    fi
fi

# CLI Flags
print_flags () {
    echo "========================================================================================================================="
    echo "Usage: setup.sh"
    echo "========================================================================================================================="
    echo "Helper utility to setup everything to use this repo"
    echo "========================================================================================================================="
    echo "How to use:"
    echo "  To Start: ./setup.sh [flags]"
    echo "========================================================================================================================="
    echo "Available Flags (mutually exclusive):"
    echo "    -a | --install-all (default): If used, install everything (recommended for fresh installs)"
    echo "    -p | --python-packages: Update virtual environment with current python packages (this should be done on pulls)"
    echo "    -h | --help: This message"
    echo "========================================================================================================================="
}

# parse command line args
upgradePkgs=true
noneSet=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a | --install-all )
            upgradePkgs=true
            noneSet=false
            break
            ;;
        -p | --python-packages )
            upgradePkgs=true
            noneSet=false
            break
            ;;
        -h | --help )
            print_flags
            exit 0
            ;;
        * )
            echo "... Unrecognized Command: $1"
            print_flags
            exit 1
    esac
    shift
done

if [[ ${noneSet} == true ]]; then
    print_flags
    echo "Please use one of the flags (just use -a if you are unsure)"
    exit
fi


THIS_FILE_DIR="$(readlink -fm $0/..)"
virtualEnvironName="library-venv"
rootDir="$(readlink -fm "${THIS_FILE_DIR}"/..)"
srcDir="$(readlink -fm ${rootDir}/..)"
backendDir="${srcDir}/backend"
installDir="${rootDir}/install"
virtualEnvironDir="${rootDir}/${virtualEnvironName}"
pythonVersion=3.9
pipLocation="" # make global
pythonLocation="" # global (changed based on OS)


# check OS... (decide how to activate virtual environment)
echo "#1 Setting up virtual environment"
if [[ ${isWindows} = true ]]; then
    # windows
    echo "#1.1 Checking Python Version"
    # windows specific way to choose correct version of python... sigh
    currVersionText=$(py -3 --version)
    currVersionMinor=$(echo "$currVersionText" | awk '{print $2}')
    currVersion=$(echo "${currVersionMinor}" | sed -r 's/\.[0-9]$//') # strips away minor version (3.7.2 -> 3.7)

    echo "Using python${currVersion} to build virtual environment"
    if [[ ${pythonVersion} != ${currVersion} ]]; then
        echo "WARNING: Wrong version of python being used. Expects python${pythonVersion}. This might affect results"
    fi

    echo "#1.2 Creating Virtual Environment"
    py -3 -m venv "${virtualEnvironDir}" # actually create the virtual environment
    "${virtualEnvironDir}/Scripts/activate"
    pipLocation="$virtualEnvironDir/Scripts/pip3.exe"

    echo "#1.3 Getting Path to Virtual Environment's Python"
    pythonLocation="${virtualEnvironDir}/Scripts/python.exe"
    echo "-- pythonLocation: ${pythonLocation}"

else
    # linux
    # needed to get specific versions of python
    pythonName=python${pythonVersion}
    echo "#1.1 Adding python ppa"
    add-apt-repository -y ppa:deadsnakes/ppa

    echo "#1.2 Updating..."
    apt update -y

    echo "#1.3 Upgrading..."
    apt upgrade -y
    apt install -y \
        ${pythonName} \
        ${pythonName}-venv

    echo "#1.4 Creating Virtual Environment"
    ${pythonName} -m venv "${virtualEnvironDir}" # actually create the virtual environment
    source "${virtualEnvironDir}/bin/activate"
    pipLocation="${virtualEnvironDir}/bin/pip${pythonVersion}"

    echo "#1.4.1 Getting Path to Virtual Environment's Python"
    pythonLocation="${virtualEnvironDir}/bin/python" # NOTE: don't use ".exe"
    echo "-- pythonLocation: ${pythonLocation}"
fi

if [[ ${upgradePkgs} == true ]]; then
    # update pip to latest
    echo "#2 Upgrading pip to latest"
    "${pythonLocation}" -m pip install --upgrade pip

    # now pip necessary packages
    echo "#3 Installing all packages"
    "${pipLocation}" install -r "${installDir}/requirements.txt"
fi

echo "Please run the start.sh or start.bat files at the top level of the project."
