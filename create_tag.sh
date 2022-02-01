#!/bin/sh

set -e

# get latest version link of 8 numeric chars beginning with 20
BUILDS=$(curl -s https://cloud-images.ubuntu.com/focal/ | grep 'href="20' | sed 's/.*href="\([\.0-9]\{8,10\}\).*/\1/g' | sort -V)

TAGS=$(git tag)

for BUILD in ${BUILDS}; do
    if ! echo "$BUILD" | grep -q '^[\.0-9]\{8,10\}$'; then
        echo "ERROR: found invalid build: ${BUILD} under url https://cloud-images.ubuntu.com/focal/"
        exit 1
    fi

    if echo "${TAGS}" | grep -q "${BUILD}"; then
        echo "INFO: build ${BUILD} already in tag list"
        continue
    fi

    git tag "${BUILD}"
    git push origin "${BUILD}"
    echo "INFO: added ${BUILD} to tag list"
done

for TAG in ${TAGS}; do
    if echo "${BUILDS}" | grep -q "${TAG}"; then
        continue
    fi

    git tag -d "${TAG}"
    git push --delete origin "${TAG}"
    echo "INFO: delete ${TAG} from tag list"
done
