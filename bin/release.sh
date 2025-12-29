#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.3"
    exit 1
fi

VERSION="$1"

# Validate version format (basic semver check)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format x.y.z (e.g., 1.2.3)"
    exit 1
fi

TAG="v$VERSION"

echo "Creating and pushing tag $TAG..."

# Create and push the tag
git tag "$TAG"
git push origin "$TAG"

echo "Tag $TAG pushed successfully!"
echo "GitHub Actions will now:"
echo "  1. Run tests and build"
echo "  2. Update pubspec.yaml version to $VERSION"
echo "  3. Create GitHub release"
echo "  4. Publish to pub.dev"