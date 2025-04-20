#!/bin/bash

set -eu

red="$( (/usr/bin/tput bold || :; /usr/bin/tput setaf 1 || :) 2>&-)"
plain="$( (/usr/bin/tput sgr0 || :) 2>&-)"

# Define the library path
LIB_PATH="/usr/local/lib"

# Check if the LD_LIBRARY_PATH line already exists in ~/.bashrc
grep -q "export LD_LIBRARY_PATH=$LIB_PATH:\$LD_LIBRARY_PATH" ~/.bashrc

# If not, append it to ~/.bashrc
if [ $? -ne 0 ]; then
    echo "Adding library path to ~/.bashrc..."
    echo "export LD_LIBRARY_PATH=$LIB_PATH:\$LD_LIBRARY_PATH" >> ~/.bashrc
else
    echo "Library path is already set in ~/.bashrc."
fi

# Reload ~/.bashrc to apply the changes
echo "Reloading ~/.bashrc..."
source ~/.bashrc

echo "Done! The library path has been updated."
