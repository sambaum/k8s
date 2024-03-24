#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the current working directory
CURRENT_DIR="$(pwd)"

# Check if the script is being run from its own directory
if [ "$SCRIPT_DIR" != "$CURRENT_DIR" ]; then
    echo "Please run this script from its own directory."
    exit 1
fi

sudo chown -R sam:sam .
