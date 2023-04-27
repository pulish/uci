#!/bin/bash

set -e

UBUNTU_VERSIONS="focal jammy"
FORMATTED_BUILD_LIST=()
TAGS=$(git tag)

echo "INFO: Checking releases for the following ubuntu versions: ${UBUNTU_VERSION[*]}"
for UBUNTU_VERSION in ${UBUNTU_VERSIONS}; do
    echo "INFO: Fetching releases for ${UBUNTU_VERSION}"
    RELEASE_REPO="https://cloud-images.ubuntu.com/releases/$UBUNTU_VERSION/"
    BUILD_LIST=$(curl -s "$RELEASE_REPO" | grep 'href="release-' | sed 's/.*href="release-\([\.0-9]\{8,10\}\).*/\1/g' | sort -V)

    for BUILD in ${BUILD_LIST}; do
        if ! [[ $BUILD =~ ^[\.0-9]{8,10}$ ]]; then
            echo "ERROR: found invalid build: '${BUILD}' under url ${RELEASE_REPO}"
            exit 1
        fi

        FORMATTED_BUILD="$BUILD-$UBUNTU_VERSION"
        FORMATTED_BUILD_LIST+=("$FORMATTED_BUILD")
        if [[ $(echo "$TAGS" | grep -c "$FORMATTED_BUILD") -gt 0 ]]; then
            echo "INFO: build ${FORMATTED_BUILD} already in tag list"
            continue
        fi

        git tag $FORMATTED_BUILD
        echo "INFO: added ${FORMATTED_BUILD} to tag list"
    done
done

git push origin --tags

for TAG in $TAGS; do
    if [[ $(IFS=$'\n'; echo "${FORMATTED_BUILD_LIST[*]}" | grep -c "^$TAG$") -eq 0 ]]; then
        git tag -d "${TAG}"
        git push --delete origin "${TAG}"
        echo "INFO: deleted ${TAG} from tag list"
    fi
done

