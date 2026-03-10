#!/bin/bash
set -e

BASE_BRANCH="master"
RESET_BRANCH="test"

# switch to base branch
git checkout $BASE_BRANCH

# update base branch
git pull origin $BASE_BRANCH

# delete local reset branch if it exists
git branch -D $RESET_BRANCH 2>/dev/null || true

# delete remote reset branch if it exists
git push origin --delete $RESET_BRANCH 2>/dev/null || true

# recreate branch from base
git checkout -b $RESET_BRANCH

# push and set upstream
git push -u origin $RESET_BRANCH
