#!/bin/bash

RED='\033[0;31m'
BOLD='\033[1m'
NOCOLOR='\033[0m'

# Exit on any error
set -euo pipefail

# --- Utility functions ---
error() { echo -e "${RED}[ERROR] $*${NOCOLOR}" >&2; }
info()  { echo "[INFO] $*"; }

abort() { error "$1"; exit 1; }

check_root() {
  if [ "$EUID" -eq 0 ]; then
    abort "This script should not be run as root."
  fi
}

check_env() {
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    abort "Please set GITHUB_TOKEN first: export GITHUB_TOKEN=***"
  fi
  info "GITHUB_TOKEN is set, continuing..."
}

check_sops_key() {
  local FILE
  FILE=$(realpath ~/.sops/age.agekey)
  if [ ! -f "$FILE" ]; then
    abort "$FILE does not exist."
  fi
  info "$FILE exists, continuing..."
}

setup_kubeconfig() {
  info "Getting microk8s config..."
  mkdir -p ~/.kube
  microk8s config | tee ~/.kube/config > /dev/null
}

create_flux_system() {
  info "Creating flux-system namespace..."
  kubectl get ns flux-system &>/dev/null || kubectl create ns flux-system
}

create_sops_secret() {
  info "Creating SOPS key in the cluster..."
  local SOPS_KEY
  SOPS_KEY="$HOME/.sops/age.agekey"
  [ ! -f "$SOPS_KEY" ] && abort "SOPS key not found: $SOPS_KEY"
  kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey="$SOPS_KEY" \
    --dry-run=client -o yaml | kubectl apply -f -
}

check_flux() {
  info "Checking flux..."
  flux check --pre
}

main() {
  check_root
  check_env
  check_sops_key
  setup_kubeconfig
  create_flux_system
  create_sops_secret
  check_flux
  info "Bootstrap pre-checks completed successfully."
  echo
  read -p "Press Enter to continue..."
}

main
