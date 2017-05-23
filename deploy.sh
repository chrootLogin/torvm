#!/bin/bash
set -e
set -x

#curl -T target/torvm-qemu.tar.gz -u${BINTRAY_USERNAME}:${BINTRAY_PASSWORD} https://api.bintray.com/content/rootlogin/TorVM/TorVM-QEMU/${BRANCH_NAME}/TorVM.tar.gz
#curl -T target/torvm-vmware.zip -u${BINTRAY_USERNAME}:${BINTRAY_PASSWORD} https://api.bintray.com/content/rootlogin/TorVM/TorVM-VMware/${BRANCH_NAME}/TorVM.zip

curl --upload-file target/torvm-qemu.tar.gz https://transfer.sh/torvm-qemu.tar.gz
curl --upload-file target/torvm-vmware.zip https://transfer.sh/torvm-vmware.zip

rm -rf target/