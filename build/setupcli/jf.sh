#!/bin/bash

CLI_OS="na"
CLI_UNAME="na"
CLI_MAJOR_VER="v2-jf"
VERSION="[RELEASE]"
# Order is by destination priority.
DESTINATION_PATHS="/usr/local/bin /usr/bin /opt/bin"
SETUP_COMMAND="jf setup"
GREEN_COLOR='\033[0;32m'
REMOVE_COLOR='\033[0m'

print_installation_greeting () {
  echo -e "${GREEN_COLOR}Thank you for installing JFrog CLI! 🐸${REMOVE_COLOR}ֿ"
}

if [ $# -eq 1 ]
then
    SETUP_COMMAND="$SETUP_COMMAND $1"
fi

echo "Downloading the latest version of JFrog CLI..."
if $(echo "${OSTYPE}" | grep -q msys); then
    CLI_OS="windows"
    URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-windows-amd64/jf.exe"
    FILE_NAME="jf.exe"
elif $(echo "${OSTYPE}" | grep -q darwin); then
    CLI_OS="mac"
    if [[ $(uname -m) == 'arm64' ]]; then
      URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-mac-arm64/jf"
    else
      URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-mac-386/jf"
    fi
    FILE_NAME="jf"
else
    CLI_OS="linux"
    MACHINE_TYPE="$(uname -m)"
    case $MACHINE_TYPE in
        i386 | i486 | i586 | i686 | i786 | x86)
            ARCH="386"
            ;;
        amd64 | x86_64 | x64)
            ARCH="amd64"
            ;;
        arm | armv7l)
            ARCH="arm"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        s390x)
            ARCH="s390x"
            ;;
        ppc64)
           ARCH="ppc64"
           ;;
        ppc64le)
           ARCH="ppc64le"
           ;;
        *)
            echo "Unknown machine type: $MACHINE_TYPE"
            exit -1
            ;;
    esac
    URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-${CLI_OS}-${ARCH}/jf"
    FILE_NAME="jf"
fi

curl -XGET "$URL" -L -k -g > $FILE_NAME
chmod u+x $FILE_NAME

# Move executable to a destination in path.
set -- $DESTINATION_PATHS
while [ -n "$1" ]; do
    # Check if destination is in path.
    if echo $PATH|grep "$1" -> /dev/null ; then
        mv $FILE_NAME $1
        if [ "$?" -eq "0" ]
        then
            echo ""
            echo "The $FILE_NAME executable was installed in $1"
            print_installation_greeting
            $SETUP_COMMAND $BASE64_CRED
            exit 0
        else
            echo ""
            echo "We'd like to install the JFrog CLI executable in $1. Please approve this installation by entering your password."
            sudo mv $FILE_NAME $1
            if [ "$?" -eq "0" ]
            then
                echo ""
                echo "The $FILE_NAME executable was installed in $1"
                print_installation_greeting
                $SETUP_COMMAND $BASE64_CRED
                exit 0
            fi
        fi
    fi
    shift
done

echo "could not find supported destination path in \$PATH"
exit 1
