#!/bin/bash
set -e

if [ "${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}" == "master" ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    DOCKER_BUILD_ARGS="--push"
else
    echo "Building multi-arch build but will not push to Docker Hub ..."
fi

echo "Create buildx builder ..."
docker buildx create --use --name geoip-builder node-amd64
docker buildx create --append --name geoip-builder node-arm64
docker context ls

echo "Building buildx image ..."
docker buildx build \
    --platform linux/amd64,linux/arm64 ${DOCKER_BUILD_ARGS} \
    --build-arg MAXMIND_LICENSE_KEY=${MAXMIND_LICENSE_KEY} \
    -t observabilitystack/geoip-api:latest \
    -t observabilitystack/geoip-api:$(date +%Y-%V) .
docker buildx imagetools inspect observabilitystack/geoip-api:latest