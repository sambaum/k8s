#!/bin/bash

# Check if we are inside a git repository
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

if [ -z "$REPO_ROOT" ]; then
	echo "This script must be run from inside a git repository."
	exit 1
fi

echo "Repository root detected at: $REPO_ROOT"
# Apply ownership to the whole repository
sudo chown -R sam:sam "$REPO_ROOT"

# Set default ACLs on the whole repo so files created by root inherit sam's access
echo "Setting default ACLs on repository..."
sudo setfacl -R -m u:sam:rwX "$REPO_ROOT"
sudo setfacl -R -d -m u:sam:rwX "$REPO_ROOT"
