CHARTS=$(find charts -maxdepth 1 -mindepth 1 -type d)

mkdir -p packages
rm -r packages/*.tgz

echo "Cleaning and preparing"
find . -iname "*.tgz" -type f | grep -v 'packages/' | xargs rm

echo "Liniting  and checking"
scripts/lint.sh

echo "Packaging charts..."
cd packages && helm package ../charts/*

cd ../
echo "Liniting  and checking"
scripts/test.sh

echo "Merging index.yaml"
curl "$ARTIFACTORY_URL/index.yaml" -o packages/index.yaml --fail -sSL -m 5
helm repo index packages --url=$ARTIFACTORY_URL --merge=packages/index.yaml

echo "Copying chart packages and index to docs"
rm -f packages /*.compare
cp packages/* docs/

echo "Now checkin and push charts and docs!"

