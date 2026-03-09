#!/bin/bash
set -e

REPO_DIR="/mnt/c/Users/Sergo/Documents/prog/university/catty-reminders-app"
BRANCH=$1

cd "$REPO_DIR"

git fetch origin
git checkout -B "$BRANCH" "origin/$BRANCH"
git pull origin "$BRANCH"

echo "Running tests..."

source .venv/bin/activate

uvicorn app.main:app --host 127.0.0.1 --port 8181 > /tmp/catty-test.log 2>&1 &
APP_PID=$!

sleep 3

python3 -m pytest -v
RESULT=$?

kill "$APP_PID" || true

echo "Tests finished with code $RESULT"
exit "$RESULT"