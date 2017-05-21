#!/bin/bash

set -e
set -x

bzip2 ./torvm.qcow2

curl --upload-file ./torvm.qcow2.bz2 https://transfer.sh/torvm-$BRANCH_NAME.qcow2
