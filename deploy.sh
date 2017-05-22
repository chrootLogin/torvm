#!/bin/bash
set -e
set -x

gzip ./torvm.qcow2
gzip ./torvm.vmdk

curl --upload-file ./torvm.qcow2.bz2 https://transfer.sh/torvm-$BRANCH_NAME.qcow2.gz
curl --upload-file ./torvm.vmdk.bz2 https://transfer.sh/torvm-$BRANCH_NAME.vmdk.gz
