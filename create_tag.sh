#!/bin/sh

set -e

# get latest version link of 8 numeric chars beginning with 20
BUILD=$(curl -s https://cloud-images.ubuntu.com/focal/ | grep 'href="20' | sed 's/.*href="\([0-9]\{8\}\).*/\1/g' | sort -nr | head -n 1)

if echo "$BUILD" | grep -q '^[0-9]\{8\}$'; then
    echo "INFO: use build ${BUILD}"
else
    echo "ERROR: found invalid build: ${BUILD} under url https://cloud-images.ubuntu.com/focal/"
    exit 1
fi

TAGS=$(git tag)
if echo "${TAGS}" | grep -q "${BUILD}"; then
    echo "INFO: build ${BUILD} already in tag list"
    exit 0
fi

git tag "${BUILD}"
git push origin "${BUILD}"
echo "INFO: added ${BUILD} to tag list"
