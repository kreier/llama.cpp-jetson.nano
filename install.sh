#!/bin/bash

set -eu

red="$( (/usr/bin/tput bold || :; /usr/bin/tput setaf 1 || :) 2>&-)"
plain="$( (/usr/bin/tput sgr0 || :) 2>&-)"

status() { echo ">>> $*" >&2; }
error() { echo "${red}ERROR:${plain} $*"; exit 1; }
warning() { echo "${red}WARNING:${plain} $*"; }

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf $TEMP_DIR; }
trap cleanup EXIT

available() { command -v $1 >/dev/null; }
require() {
    local MISSING=''
    for TOOL in $*; do
        if ! available $TOOL; then
            MISSING="$MISSING $TOOL"
        fi
    done

    echo $MISSING
}

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

status "Downloading binaries to temporary directory"

FILES="llama-cli llama-server llama-bench llama-run llama-simple llama-simple-chat libllama.so libggml.so libggml-base.so libggml-cpu.so libggml-cuda.so"

for FILE in $FILES; do
    status "Downloading $FILE"
    curl -fsSL -o "$TEMP_DIR/$FILE" "https://kreier.github.io/llama.cpp-jetson.nano/bin/$FILE"
done

status "Installing llama.cpp with CUDA support on the Jetson Nano to /usr/local/bin"

$SUDO install -o0 -g0 -m755 -d "/usr/local/bin"
$SUDO install -o0 -g0 -m755 -d "/usr/local/lib"

# Copy binaries
BINARIES="llama-cli llama-server llama-bench llama-run llama-simple llama-simple-chat"
for FILE in $BINARIES; do
    $SUDO cp -v "$TEMP_DIR/$FILE" /usr/local/bin/
    $SUDO chmod +x /usr/local/bin/$FILE
done

# Copy libraries
LIBRARIES="libllama.so libggml.so libggml-base.so libggml-cpu.so libggml-cuda.so"
for FILE in $LIBRARIES; do
    $SUDO cp -v "$TEMP_DIR/$FILE" /usr/local/lib/
done

# Define the library path
LIB_PATH="/usr/local/lib"

# Check if the LD_LIBRARY_PATH line already exists in ~/.bashrc - if not, append it to ~/.bashrc
if grep -q "export LD_LIBRARY_PATH=$LIB_PATH:\$LD_LIBRARY_PATH" ~/.bashrc; then
    echo "Library path is already set in ~/.bashrc."
else
    echo "Adding library path to ~/.bashrc..."
    echo "export LD_LIBRARY_PATH=$LIB_PATH:\$LD_LIBRARY_PATH" >> ~/.bashrc
fi

echo "Done! The library path has been updated. Please run 'source ~/.bashrc' to apply the changes."
echo "You can verify the installation by running 'llama-cli --version'."
