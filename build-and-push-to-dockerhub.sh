#!/bin/bash
set -e

if [ "${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}" == "master" ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    DOCKER_BUILD_ARGS="--push"
else
    echo "Building multi-arch build but will not push to Docker Hub ..."
fi

echo "Building buildx image ..."
docker buildx build ${DOCKER_BUILD_ARGS} \
    --progress plain \
    --platform linux/amd64,linux/arm64 \
    --build-arg MAXMIND_LICENSE_KEY=${MAXMIND_LICENSE_KEY} \
    -t observabilitystack/geoip-api:latest \
    -t observabilitystack/geoip-api:$(date +%Y-%V) .
docker buildx imagetools inspect observabilitystack/geoip-api:latest