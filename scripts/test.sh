#!/bin/bash

ARTIFACTORY_URL=https://datamountaineer.github.io/helm-charts/

# We begin by testing if we can reach artifactory
echo ""
echo "==> Testing if we can reach the helm repository at $ARTIFACTORY_URL..."
code=`curl -o /dev/null -I -w "%{http_code}" $ARTIFACTORY_URL -sSL`
if [ $? -eq 0 ]; then
  if [ ! $code -eq 200 ]; then
    echo "==> ERROR: Unable to read from repository. Received status code: $code"
    exit $code
  fi
else
  echo "ERROR: Unable to reach remote repository"
  exit 1
fi
echo "Valid helm repository configured..."


echo ""
echo "==> Testing if charts have been properly versioned..."
error=0

for path in `find packages -name "*.tgz"`; do
  # strip packages/ from the path name
  package=`echo $path | sed 's:packages/::'`
  echo $package	

  # download existing artifact (if it exists)
  curl "$ARTIFACTORY_URL/$package" -o packages/$package.compare --fail -sL -m 5

  # if there is no current artifact, or there is no difference between them, we are good
  if [ -a packages/$package.compare ]; then
    if ! cmp -s packages/$package packages/$package.compare; then
      echo "ERROR: You have updated chart $package without bumping the version..."
      error=1
    else
      echo "Properly versioned: $package"
    fi
  else
    echo "Properly versioned: $package"
  fi
done

if [ $error -eq 1 ]; then
  echo ""
  echo "==> ERROR: There are charts updated without bumping the version!"
  echo ""
  exit 1
else
  echo ""
  echo "==> Tests passed!"
  echo ""
fi
