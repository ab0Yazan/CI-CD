#!/bin/bash

# ---------------------------
# INPUT ARGS
# ---------------------------
IMAGE="$1"               # Format: namespace/repo
TAG="$2"                 # The tag to delete (e.g., a SHA)
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
# GET MANIFEST DIGEST
# ---------------------------
echo "🔍 Getting manifest digest for $IMAGE:$TAG..."
DIGEST=$(curl -s -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  -u "$DOCKER_USERNAME:$DOCKER_PASSWORD" \
  "https://registry.hub.docker.com/v2/$NAMESPACE/$REPO/manifests/$TAG" \
  | grep -i 'Docker-Content-Digest' | awk '{print $2}' | tr -d $'\r')

if [[ -z "$DIGEST" ]]; then
  echo "❌ Failed to retrieve digest for $IMAGE:$TAG. The tag may not exist or the repo might be private without proper access."
  exit 1
fi

echo "📦 Digest found: $DIGEST"

# ---------------------------
# DELETE THE IMAGE TAG
# ---------------------------
echo "🗑️ Deleting $IMAGE:$TAG..."
DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  -u "$DOCKER_USERNAME:$DOCKER_PASSWORD" \
  "https://registry.hub.docker.com/v2/$NAMESPACE/$REPO/manifests/$DIGEST")

if [[ "$DELETE_STATUS" == "202" ]]; then
  echo "✅ Successfully deleted $IMAGE:$TAG"
else
  echo "❌ Failed to delete $IMAGE:$TAG (HTTP $DELETE_STATUS)"
  exit 1
fi
