#!/bin/bash
error=0
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

echo -e "==> ${GREEN}Linting charts..${NC}."
for chart in lenses; do
  echo -e "==> ${GREEN}Linting chart: $chart ${NC}"
  output=`helm lint charts/$chart --debug 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo -e "===> ${RED} Liniting errors for chart $chart ${NC}"
    echo -e "$output" | grep "\\["
    exit 1
  fi
  echo -e "$output" | grep "\\["
done
echo -e "==> ${GREEN} No linting errors${NC}"

exit $error
