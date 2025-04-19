#!/bin/bash

# ---------------------------
# INPUT ARGS
# ---------------------------
IMAGE="$1"
TAG="$2"
DOCKER_USERNAME="$3"
DOCKER_PASSWORD="$4"

# ---------------------------
# VALIDATE INPUTS
# ---------------------------
if [[ -z "$IMAGE" || -z "$TAG" || -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" ]]; then
  echo "Usage: $0 <namespace/repo> <tag> <dockerhub_username> <dockerhub_password>"
  exit 1
fi

NAMESPACE=$(echo "$IMAGE" | cut -d'/' -f1)
REPO=$(echo "$IMAGE" | cut -d'/' -f2)

# ---------------------------
# GET AUTH TOKEN
# ---------------------------
echo "🔐 Authenticating with Docker Hub..."
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST \
  -d '{"username": "'"$DOCKER_USERNAME"'", "password": "'"$DOCKER_PASSWORD"'"}' \
  https://hub.docker.com/v2/users/login/ | jq -r .token)

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "❌ Authentication failed. Check credentials."
  exit 1
fi

# ---------------------------
# GET MANIFEST DIGEST
# ---------------------------
echo "🔍 Getting manifest digest for $IMAGE:$TAG..."
echo "https://hub.docker.com/v2/namespaces/$NAMESPACE/repositories/$REPO/tags/$TAG"
DIGEST=$(curl -s -H "Authorization: JWT $TOKEN" \
  -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  https://hub.docker.com/v2/namespaces/$NAMESPACE/repositories/$REPO/tags/$TAG/ \
  | jq -r '.images[0].digest')

if [[ -z "$DIGEST" || "$DIGEST" == "null" ]]; then
  echo "❌ Failed to retrieve digest. Does the tag exist?"
  exit 1
fi

# ---------------------------
# DELETE THE IMAGE TAG
# ---------------------------
echo "🗑️ Deleting tag $TAG from $IMAGE..."
DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  -H "Authorization: JWT $TOKEN" \
  "https://hub.docker.com/v2/repositories/$NAMESPACE/$REPO/manifests/$DIGEST")

if [[ "$DELETE_STATUS" == "202" ]]; then
  echo "✅ Successfully deleted $IMAGE:$TAG"
else
  echo "❌ Failed to delete tag. HTTP status: $DELETE_STATUS"
  exit 1
fi
