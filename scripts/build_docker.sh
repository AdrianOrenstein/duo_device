#!/bin/bash

# Install yq if it's not already installed
if ! command -v yq &> /dev/null
then
    echo "yq could not be found, goto https://github.com/mikefarah/yq#install"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo probably run "brew install yq"
    fi

    exit 1
fi

# Parse the values from the combined config.yaml file
USERNAME=$(yq e '.common.USERNAME' config.yaml)
IMAGE_NAME=$(yq e ".common.IMAGE_NAME" config.yaml)
TAG=$(yq e ".common.TAG" config.yaml)

FULL_IMAGE_NAME="$USERNAME/$IMAGE_NAME:$TAG"
echo "Building image $FULL_IMAGE_NAME"

# Ensure buildx is installed
docker buildx install 

PLATFORMS=$(yq e ".common.PLATFORMS" config.yaml)

# Check if multi-platform build is needed
if [ "$1" == "--push" ]; then
    echo "Building and pushing for platforms: $PLATFORMS"
    docker buildx build -t $FULL_IMAGE_NAME \
        --platform="$PLATFORMS" \
        -f dockerfiles/Dockerfile . \
        --push
else
    echo "Building locally for the current platform"
    docker buildx build -t $FULL_IMAGE_NAME \
        -f dockerfiles/Dockerfile . \
        --load
fi

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo "Done"