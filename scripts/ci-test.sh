#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

FILES=$(find . -type f -name 'coyote.yml')

for f in $FILES; do 
    echo "----------$f----------"
    echo "----------------------"
    cd $(dirname $f)
    coyote
    cd ../../
    sleep 20;
done