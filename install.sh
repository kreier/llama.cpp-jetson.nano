#!/bin/sh

set -eu

echo "I hope this works!"

red="$( (/usr/bin/tput bold || :; /usr/bin/tput setaf 1 || :) 2>&-)"
plain="$( (/usr/bin/tput sgr0 || :) 2>&-)"

status() { echo ">>> $*" >&2; }
error() { echo "${red}ERROR:${plain} $*"; exit 1; }
warning() { echo "${red}WARNING:${plain} $*"; }

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf $TEMP_DIR; }
trap cleanup EXIT

SUDO=
if [ "$(id -u)" -ne 0 ]; then
    # Running as root, no need for sudo
    if ! available sudo; then
        error "This script requires superuser permissions. Please re-run as root."
    fi

    SUDO="sudo"
fi

NEEDS=$(require curl awk grep sed tee xargs)
if [ -n "$NEEDS" ]; then
    status "ERROR: The following tools are required but missing:"
    for NEED in $NEEDS; do
        echo "  - $NEED"
    done
    exit 1
fi

INSTALL_DIR=$(dirname ${/usr/local/bin})
$SUDO mkdir /usr/local/llama.cpp/lib

status "Installing llama.cpp with CUDA support on the Jetson Nano to $INSTALL_DIR"

$SUDO install -o0 -g0 -m755 -d $INSTALL_DIR
$SUDO install -o0 -g0 -m755 -d "/usr/local/llama.cpp/lib"
