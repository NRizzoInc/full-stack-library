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
    echo "    -s | --deploy-services: Deploy the source code to enable the system service to run (only works on Ubuntu)"
    echo "    -h | --help: This message"
    echo "========================================================================================================================="
}

# parse command line args
installPkgs=false
deployServices=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a | --install-all )
            installPkgs=true
            deployServices=true
            break
            ;;
        -p | --python-packages )
            installPkgs=true
            ;;
        -s | --deploy-services )
            deployServices=true
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
    if [[ ${installPkgs} = true ]]; then
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
    fi
else
    if [[ ${installPkgs} = true ]]; then
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

        # update pip to latest
        echo "#2 Upgrading pip to latest"
        "${pythonLocation}" -m pip install --upgrade pip

        # now pip necessary packages
        echo "#3 Installing all packages"
        "${pipLocation}" install -r "${installDir}/requirements.txt"
    fi
fi

if [[ ${deployServices} = true ]]; then
    if [[ "${isWindows}" = false ]]; then
        echo "============= #4 Deploying Service ============="
        echo "#4.1 Creating user/group for database/service"
        # randomly generate mysql password (required)
        symbols=(":" "+" ";" ".")
        s1=${symbols[ RANDOM % ${#symbols[@]} ]}
        s2=${symbols[ RANDOM % ${#symbols[@]} ]}
        mysql_rand_pwd=$(date +%s | sha256sum | base64 | head -c 32 ; echo)${s1}${s2}
        echo "mysql_rand_pwd = ${mysql_rand_pwd}"
        mysql_user="full-stack-lib"
        useradd "${mysql_user}"
        mysql -e "CREATE USER IF NOT EXISTS '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_rand_pwd}'"
        mysql -e "GRANT ALL PRIVILEGES ON libsystem.* TO '${mysql_user}'@'localhost';"

        echo "#4.2 Exporting Path to Source Code"
        # make environment variable for path global (if already exists -> replace it, but keep backup)
        # https://serverfault.com/a/413408 -- safest way to create & use environment vars with services
        environDir=/etc/systemd/sysconfig
        environFile=${environDir}/full-stack-library-env
        echo "Environment File: ${environFile}"
        mkdir -p ${environDir}
        touch ${environFile}

        # create backup & save new version with updated path
        echo "#4.3 Deploying Service Environment File"
        # remove past lines
        sed -i.bak '/full_stack_lib_root_dir=/d' ${environFile}
        sed -i.bak '/mysql_access=/d' ${environFile}

        # add new current lines
        echo "full_stack_lib_root_dir=${rootDir}" >> ${environFile}
        echo "mysql_access=${mysql_rand_pwd}" >> ${environFile}
        source ${environFile}

        echo "#4.4 Deploying Service File"
        serviceFileName=full-stack-library.service
        sysServiceDir=/etc/systemd/system
        localServiceFileDir="${installDir}${sysServiceDir}"
        localServiceFile="${localServiceFileDir}/${serviceFileName}"
        cp "${localServiceFile}" "${sysServiceDir}/"
        echo "-- Deployed ${localServiceFile} -> ${sysServiceDir}/${serviceFileName}"

        echo "#4.5 Starting Service"
        # stop daemon to allow reload
        systemctl stop ${serviceFileName}
        # refresh service daemons
        systemctl daemon-reload
        systemctl start ${serviceFileName}

        # Make Daemons Persistent for Boot
        echo "#4.6 Making Service Start at Boot"
        systemctl enable ${serviceFileName}

        echo "============= #4 Done Deploying Service ============="
    else # dont deploy service
        echo "Please run the start.sh or start.bat files at the top level of the project."
    fi
fi

