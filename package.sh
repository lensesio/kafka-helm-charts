#!/usr/bin/env bash
set -o errexit
set -o pipefail

GREEN='\033[0;32m'
ARTIFACTORY_URL=https://landoop.github.io/kafka-helm-charts/

# Fetch packages
git clone -b gh-pages https://github.com/landoop/kafka-helm-charts.git build

echo "Packaging charts..."
# Iterate over all charts are package them
for dir in ${TRAVIS_BUILD_DIR}/charts/lenses; do
    helm dep update $dir
    helm package -d ${TRAVIS_BUILD_DIR}/build $dir
done

# Indexing of charts
if [ -f index.yaml ]; then
    helm repo index --url ${ARTIFACTORY_URL} --merge index.yaml ${TRAVIS_BUILD_DIR}/build
else
    helm repo index --url ${ARTIFACTORY_URL} ${TRAVIS_BUILD_DIR}/build
fi
echo "${GREEN}Success!${NC}"
