#!/bin/bash
set -e
set -x

function fail {
  rm -rf target/
  echo ""
  echo "FAILED: $1"
  exit 1
}

curl --upload-file target/torvm-qemu.tar.gz https://transfer.sh/torvm-qemu.tar.gz || fail "Couldn't upload qemu image"
curl --upload-file target/torvm-vmware.zip https://transfer.sh/torvm-vmware.zip || fail "Couldn't upload vmware image"

rm -rf target/