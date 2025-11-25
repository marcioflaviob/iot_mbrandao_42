#!/bin/bash

MANIFEST_FILE="/home/mbrandao/Documents/iot_mbrandao/bonus/manifest.yaml"

if [ ! -f "$MANIFEST_FILE" ]; then
    echo "Error: manifest.yaml not found at $MANIFEST_FILE"
    exit 1
fi

CURRENT_VERSION=$(grep "image: wil42/playground" "$MANIFEST_FILE" | grep -oP 'v[0-9]+')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not detect current version in manifest.yaml"
    exit 1
fi

echo "Current version: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" == "v1" ]; then
    NEW_VERSION="v2"
    sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' "$MANIFEST_FILE"
elif [ "$CURRENT_VERSION" == "v2" ]; then
    NEW_VERSION="v1"
    sed -i 's/wil42\/playground:v2/wil42\/playground:v1/g' "$MANIFEST_FILE"
else
    echo "Error: Unknown version $CURRENT_VERSION"
    exit 1
fi

echo "Changed version from $CURRENT_VERSION to $NEW_VERSION"

cd "$(dirname "$MANIFEST_FILE")/.."
git add bonus/manifest.yaml

if git diff --cached --quiet; then
    echo ""
    echo "No changes to commit"
    exit 0
fi

git commit -m "Update playground app to $NEW_VERSION"
git push

echo ""
echo "==================================="
echo "Version updated and pushed to GitHub!"
echo "New version: $NEW_VERSION"
echo "==================================="