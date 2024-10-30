#!/bin/bash

. ../../tools/bootstrap-common.sh

GITHUB_USER=sambaum
REPOSITORY=k8s
BRANCH=test2
ENVIRONMENT=test

flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=$BRANCH \
  --path=./clusters/$ENVIRONMENT \
  --read-write-key \
  --personal
