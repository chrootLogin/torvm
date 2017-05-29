#!/bin/bash
set -e
set -x

function fail {
  rm -rf target/
  echo ""
  echo "FAILED: $1"
  exit 1
}

#curl --upload-file target/torvm-qemu.tar.gz https://transfer.sh/torvm-qemu.tar.gz || fail "Couldn't upload qemu image"
#curl --upload-file target/torvm-vmware.zip https://transfer.sh/torvm-vmware.zip || fail "Couldn't upload vmware image"

curl -u ${NEXTCLOUD_USERNAME}:${NEXTCLOUD_PASSWORD} -T target/torvm-qemu.tar.gz "https://cloud.dini-mueter.net/remote.php/dav/files/${NEXTCLOUD_USERNAME}/Releases/TorVM/TorVM-QEMU-${BRANCH_NAME}.zip"
curl -u ${NEXTCLOUD_USERNAME}:${NEXTCLOUD_PASSWORD} -T target/torvm-vmware.zip "https://cloud.dini-mueter.net/remote.php/dav/files/${NEXTCLOUD_USERNAME}/Releases/TorVM/TorVM-VMware-${BRANCH_NAME}.zip"
curl -u ${NEXTCLOUD_USERNAME}:${NEXTCLOUD_PASSWORD} -T target/torvm-vbox.zip "https://cloud.dini-mueter.net/remote.php/dav/files/${NEXTCLOUD_USERNAME}/Releases/TorVM/TorVM-VirtualBox-${BRANCH_NAME}.zip"

rm -rf target/