#!/bin/bash

set -e

if [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_USER" ]; then
    echo "Error: DEPLOY_HOST and DEPLOY_USER must be set"
    exit 1
fi

DEPLOY_PORT=${DEPLOY_PORT:-22}
IMAGE_NAME=${IMAGE_NAME,,}
TARGET_DIR="~/catty-app"

echo "Deploying to $DEPLOY_HOST:$DEPLOY_PORT"
echo "Image: $IMAGE_NAME:$RELEASE_HASH"

COMMON_OPTS="-o StrictHostKeyChecking=no"

ssh -p "$DEPLOY_PORT" $COMMON_OPTS "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p $TARGET_DIR"

scp -P "$DEPLOY_PORT" $COMMON_OPTS docker-compose.yaml "$DEPLOY_USER@$DEPLOY_HOST:$TARGET_DIR/docker-compose.yaml"

# 3. Выполняем деплой через docker compose (используем -p маленькую)
ssh -p "$DEPLOY_PORT" $COMMON_OPTS "$DEPLOY_USER@$DEPLOY_HOST" << EOF
    set -e
    
    cd $TARGET_DIR
    
    echo "Logging in to GitHub Container Registry..."
    echo "$DOCKER_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin
    
    export IMAGE_NAME="$IMAGE_NAME"
    export IMAGE_TAG="$RELEASE_HASH"
    
    echo "Pulling new images..."
    docker compose pull
    
    echo "Starting containers..."
    docker compose up -d --remove-orphans
    
    sleep 5
    
    if docker compose ps | grep -q "Up"; then
        echo "Deployment completed successfully"
    else
        echo "ERROR: Application failed to start"
        docker compose logs
        exit 1
    fi
EOF