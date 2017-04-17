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

echo "Copying chart packages and index to docs"
cp packages/* docs/

echo "Now checkin and push charts and docs!"

