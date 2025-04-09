# llama.cpp-jetson.nano

![GitHub Release](https://img.shields.io/github/v/release/kreier/llama.cpp-jetson.nano)
![GitHub License](https://img.shields.io/github/license/kreier/llama.cpp-jetson.nano)

Install a CUDA version of `llama.cpp`, `llama-server` and `llama-bench` on the Jetson Nano, compiled with gcc 8.5. Just type:

``` sh
curl -fsSL https://kreier.github.io/llama.cpp-jetson.nano/install.sh | sh
```

## Description

The script copies the binaries to `/usr/local/bin` and the libraries to `/usr/local/llama.cpp/lib` and adjusts the path in .bashrc

``` sh
#!/bin/sh

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

INSTALL_DIR=$(dirname /usr/local/bin)

status "Installing llama.cpp with CUDA support on the Jetson Nano to $INSTALL_DIR"

$SUDO install -o0 -g0 -m755 -d $INSTALL_DIR
$SUDO install -o0 -g0 -m755 -d "/usr/local/llama.cpp/lib"
```
