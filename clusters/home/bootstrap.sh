#!/bin/bash

. ../../tools/bootstrap-common.sh

GITHUB_USER=sambaum
REPOSITORY=k8s
BRANCH=master
ENVIRONMENT=home

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=$BRANCH \
  --path=./clusters/$ENVIRONMENT \
  --read-write-key \
  --personal
