#!/bin/bash
set -e
echo "Release tags: ${DOCKER_RELEASE_TAGS}"
docker login --username "${DOCKER_USER}" --password "${DOCKER_TOKEN}"
if [ "${CIRCLE_BRANCH}" == "master" ]; then
    for tag in ${DOCKER_RELEASE_TAGS// / } ; do
        docker tag "dgroup/lazylead:${CIRCLE_BRANCH}" "dgroup/lazylead:${tag}"
        docker push "dgroup/lazylead:${tag}"
        echo "dgroup/lazylead:${tag} released"
    done
else
    docker push "dgroup/lazylead:${CIRCLE_BRANCH}"
    echo "dgroup/lazylead:${CIRCLE_BRANCH} released"
fi
echo "Available LL images:"
docker images | grep lazylead