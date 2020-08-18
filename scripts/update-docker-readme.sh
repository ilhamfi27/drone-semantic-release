#!/bin/bash

## Forked from https://github.com/jlesage/drone-push-readme

set -e # Exit immediately if a command exits with a non-zero status.

echo "Updating DockerHUB README@${UPDATE_DOCKER_README}"

# Set default value of parameters.
DOCKER_USERNAME="${PLUGIN_DOCKER_USERNAME}"
DOCKER_PASSWORD="${PLUGIN_DOCKER_PASSWORD}"
DOCKER_REPO="${PLUGIN_DOCKER_REPO}"

# Validate parameters.
if [[ -z "$DOCKER_USERNAME" ]]; then
  echo "Docker Hub username not set."
  exit 1
elif [[ -z "$DOCKER_PASSWORD" ]]; then
  echo "Docker Hub password not set."
  exit 1
elif [[ -z "$DOCKER_REPO" ]]; then
  echo "Docker Hub repository not set."
  exit 1
elif [[ ! -f "$UPDATE_DOCKER_README" ]]; then
  echo "README@$UPDATE_DOCKER_README not found."
  exit 1
fi

# Login to Docker Hub.
echo "Logging in to Docker Hub..."
declare -r token=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"username": "'"$DOCKER_USERNAME"'", "password": "'"$DOCKER_PASSWORD"'"}' \
  https://hub.docker.com/v2/users/login/ | jq -r .token)

# Make sure we got the JWT token.
if [[ "${token}" = "null" ]]; then
  echo "Unable to login to Docker Hub."
  exit 1
fi

cd /drone/src

# Push the README.
echo "Pushing $UPDATE_DOCKER_README to $DOCKER_REPO ..."
declare -r code=$(jq -n --arg msg "$(<$UPDATE_DOCKER_README)" \
  '{"registry":"registry-1.docker.io","full_description": $msg }' |
  curl -s -o /dev/null -L -w "%{http_code}" \
    https://hub.docker.com/v2/repositories/"$DOCKER_REPO"/ \
    -d @- -X PATCH \
    -H "Content-Type: application/json" \
    -H "Authorization: JWT ${token}")

# Validate the result.
if [[ "${code}" = "200" ]]; then
  echo "Successfully pushed README to Docker Hub."
elif [[ "${code}" = "404" ]]; then
  echo "Docker Hub repository has not been created yet."
else
  echo "Unable to push README to Docker Hub, response code: %s" "${code}"
  exit 1
fi
