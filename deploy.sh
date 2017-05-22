#!/bin/bash
set -e
set -x

curl -T torvm.qcow2.gz -u${BINTRAY_USERNAME}:${BINTRAY_PASSWORD} https://api.bintray.com/content/rootlogin/TorVM/TorVM-QEMU/${BRANCH_NAME}/TorVM.qcow2
gzip ./torvm.qcow2
curl --upload-file ./torvm.qcow2.gz https://transfer.sh/torvm-$BRANCH_NAME.qcow2.gz
rm -f torvm.qcow2

curl -T torvm.vmdk -u${BINTRAY_USERNAME}:${BINTRAY_PASSWORD} https://api.bintray.com/content/rootlogin/TorVM/TorVM-VMware/${BRANCH_NAME}/TorVM.vmdk
gzip ./torvm.vmdk
curl --upload-file ./torvm.vmdk.gz https://transfer.sh/torvm-$BRANCH_NAME.vmdk.gz
rm -f torvm.vmdk