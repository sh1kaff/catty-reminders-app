#!/bin/bash
set -e

REPO_DIR="/mnt/c/Users/Sergo/Documents/prog/university/catty-reminders-app"
BRANCH=$1
COMMIT_SHA=$2

echo "Deploying $BRANCH at $COMMIT_SHA"

cd "$REPO_DIR"

git fetch origin
git checkout -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"

CLEAN_REF=$(echo $COMMIT_SHA | tr -d '\r' | tr -d ' ')
echo "DEPLOY_REF=$CLEAN_REF" > /tmp/app.env

sync 

sudo systemctl restart app.service
echo "Done"