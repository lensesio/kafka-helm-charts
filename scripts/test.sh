#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
BLUE='\033[0m;31m'

ARTIFACTORY_URL=https://datamountaineer.github.io/helm-charts/

# We begin by testing if we can reach artifactory
echo -e ""
echo -e "==> ${GREEN}Testing if we can reach the helm repository at ${ARTIFACTORY_URL} ${NC}..."
code=`curl -o /dev/null -I -w "%{http_code}" $ARTIFACTORY_URL -sSL`
if [ $? -eq 0 ]; then
  if [ ! $code -eq 200 ]; then
    echo -e "==> ${RED}ERROR: Unable to read from repository. Received status code: ${BLUE}$code${NC}"
    exit $code
  fi
else
  echo -e "==> ${RED}ERROR: Unable to reach remote repository${NC}"
  exit 1
fi
echo -e "==> ${GREEN}Valid helm repository configured...${NC}"


echo -e ""
echo -e "==> ${GREEN}Testing if charts have been properly versioned...${NC}"
error=0

for path in `find packages -name "*.tgz"`; do
  # strip packages/ from the path name
  package=`echo -e $path | sed 's:packages/::'`
  echo -e $package	

  # download existing artifact (if it exists)
  curl "$ARTIFACTORY_URL/$package" -o packages/$package.compare --fail -sL -m 5

  # if there is no current artifact, or there is no difference between them, we are good
  if [ -a packages/$package.compare ]; then
    echo -e "${GREEN}Comparing packages/$package and packages/$package.compare${NC}"
    if ! cmp -s packages/$package packages/$package.compare; then
      echo -e "==> ${RED}WARNING: You have updated chart $package without bumping the version...${NC}"
      error=1
      exit 1
    else
      echo -e "==> ${GREEN}Properly versioned: $package${NC}"
    fi
  else
    echo -e "==> ${GREEN}Properly versioned: $package${NC}"
  fi
done

if [ $error -eq 1 ]; then
  echo -e ""
  echo -e "==> ${RED}ERROR: There are charts updated without bumping the version!${NC}"
  echo -e ""
  exit 1
else
  echo -e ""
  echo -e "==> ${GREEN}Tests passed!${NC}"
  echo -e ""
fi
