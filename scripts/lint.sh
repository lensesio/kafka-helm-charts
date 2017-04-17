#!/bin/bash
error=0

echo "==> Linting charts..."
for chart in `ls -1 charts`; do
  echo "Linting chart: $chart"
  output=`helm lint charts/$chart 2> /dev/null`
  if [ $? -ne 0 ]; then
    error=1
  fi
  echo "$output" | grep "\\["
done
echo ""

exit $error
