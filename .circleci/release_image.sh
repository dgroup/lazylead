#!/bin/bash
export docker_release_tags="latest 1 1.0 0.1.1"
docker login --username "${DOCKER_USER}" --password "${DOCKER_TOKEN}"
if [ "${CIRCLE_BRANCH}" == "master" ]; then
    for tag in ${docker_release_tags// / } ; do
        docker tag "dgroup/lazylead:${CIRCLE_BRANCH}" "dgroup/lazylead:${tag}"
        docker push "dgroup/lazylead:${tag}"
        echo "dgroup/lazylead:${tag} released"
    done
else
    docker push "dgroup/lazylead:${CIRCLE_BRANCH}"
    echo "dgroup/lazylead:${CIRCLE_BRANCH} released"
fi