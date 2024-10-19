#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

# Check if the script is run as root
if [ "$EUID" -eq 0 ]
then
    echo "This script should not be run as root. Aborting."
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
    echo -e "${RED} Homebrew should now be installed. Open a new shell and run the script again ${NOCOLOR}"
    exit 1
else
    echo "Homebrew is already installed."
fi

if ! dpkg -s build-essential >/dev/null 2>&1; then
  echo build-essential not yet installed. Installing...
  sudo apt-get update
  sudo apt-get install -y build-essential
fi

brew install gcc 
brew install derailed/k9s/k9s fluxcd/tap/flux sops age

# Check if GITHUB_TOKEN is set
if [ -z "${GITHUB_TOKEN}" ]; then
  echo
  echo "${RED} Please set GITHUB_TOKEN variable (flux token) first using: export GITHUB_TOKEN=*** ${NOCOLOR}"
  exit 1
else
  echo "GITHUB_TOKEN is set, continuing..."
fi

# Check if age key exists
FILE=$(realpath ~/.sops/age.agekey)
if [ ! -f "$FILE" ]; then
  echo "$FILE does not exist. Aborting."
  exit 1
else
  echo "$FILE exist, continuing..."
fi

microk8s config >~/.kube/config

kubectl create namespace flux-system
cat ~/.sops/age.agekey |
  kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey=/dev/stdin
