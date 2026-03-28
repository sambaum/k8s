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
