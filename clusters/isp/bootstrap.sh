#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../tools/bootstrap-common.sh"

GITHUB_USER=sambaum
REPOSITORY=k8s
BRANCH=master
ENVIRONMENT=isp

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=$BRANCH \
  --path=./clusters/$ENVIRONMENT \
  --personal
