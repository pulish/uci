#!/bin/sh

set -e

UBUNTU_VERSIONS="focal jammy"
TAGS=$(git tag)

echo "INFO: Checking releases for the following ubuntu versions: ${UBUNTU_VERSIONS}"
for UBUNTU_VERSION in ${UBUNTU_VERSIONS}; do
    echo "INFO: Fetching releases for ${UBUNTU_VERSION}"
    RELEASE_REPO="https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/"
    BUILD_LIST=$(curl -s "${RELEASE_REPO}" | grep 'href="release-' | sed 's/.*href="release-\([\.0-9]\{8,10\}\).*/\1/g' | sort -V)

    for BUILD in ${BUILD_LIST}; do
        if ! echo "${BUILD}" | grep -q '^[\.0-9]\{8,10\}$'; then
            echo "ERROR: found invalid build: '${BUILD}' under url ${RELEASE_REPO}"
            exit 1
        fi

        FORMATTED_BUILD="${BUILD}-${UBUNTU_VERSION}"
        if echo "${TAGS}" | grep -q "${FORMATTED_BUILD}"; then
            echo "INFO: build ${FORMATTED_BUILD} already in tag list"
            continue
        fi

        git tag "${FORMATTED_BUILD}"
        git push origin "${FORMATTED_BUILD}"
        echo "INFO: added ${FORMATTED_BUILD} to tag list"
    done
done
