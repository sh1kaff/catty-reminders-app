#!/bin/bash
set -e

REPO_DIR="/mnt/c/Users/Sergo/Documents/prog/university/catty-reminders-app"
BRANCH=$1
COMMIT_SHA=$2

echo "Fast Deploying $BRANCH..."

cd "$REPO_DIR"

git fetch origin
git checkout -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"

if [ -n "$COMMIT_SHA" ]; then
    CLEAN_REF=$(echo $COMMIT_SHA | tr -d '\r' | tr -d ' ')
else
    CLEAN_REF=$(git rev-parse HEAD | tr -d '\r' | tr -d ' ')
fi

echo "DEPLOY_REF=$CLEAN_REF" > /tmp/app.env
echo "DEPLOY_REF=$CLEAN_REF" > "$REPO_DIR/.env.deploy"
chmod 644 "$REPO_DIR/.env.deploy"

# pip install -r requirements.txt

echo "Restarting app service..."
sudo systemctl restart app.service
echo "Done! Deploy Ref: $CLEAN_REF"