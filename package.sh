#!/usr/bin/env bash
set -o errexit

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
ARTIFACTORY_URL=https://landoop.github.io/kafka-helm-charts/
CHARTS=$(find charts -maxdepth 1 -mindepth 1 -type d)
HELM_VERSION='v2.5.1'

mkdir -p packages
rm -rf packages/*.tgz

echo "Cleaning and preparing"
find . -iname "*.tgz" -type f | grep -v 'docs/' | xargs rm

echo "Linting and checking"
scripts/lint.sh
RET=$?

# if [[ "${RET}" == 1 ]]; then
#     exit 1
# fi  

echo "Packaging charts..."
cd packages && helm package ../charts/*

cd ../
echo "Checking version compatibility"
scripts/test.sh
RET=0

if [[ "${RET}" == 0 ]]; then 
    #echo "Merging index.yaml"
    #curl "$ARTIFACTORY_URL/index.yaml" -o index.yaml --fail -sSL -m 5
    helm repo index packages --url=$ARTIFACTORY_URL #--merge=index.yaml

    echo "Copying chart packages and index to docs"
    rm -f docs/*.tgz
    rm -f docs/*.yaml
    rm -f packages/*.compare
    cp packages/*.tgz docs/
    cp packages/index.yaml docs/

    echo "${GREEN}Now commit and push charts and docs!${NC}"
else
    echo "${RED}Tests failed, charts not packaged!${NC}"
fi

rm -fr packages
