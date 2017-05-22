#!/bin/bash

set -e
set -x

echo "Create folders"

mkdir -p target/qemu/
mkdir -p target/vmware/TorVM.vmware/

echo "Convert image"
qemu-img convert -f qcow2 -O vmdk torvm.qcow2 target/vmware/TorVM.vmware/TorVM.vmdk
mv torvm.qcow2 target/qemu/TorVM.qcow2

cd target/

echo "Create qemu package"
tar czf torvm-qemu.tar.gz qemu
rm -rf qemu

echo "Create VMware package"
cat << EOF > TorVM.vmware/TorVM.vmx
numvcpus = "1"
memsize = "1024"
scsi0.present = "TRUE"
scsi0.sharedBus = "none"
scsi0.virtualDev = "lsilogic"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "TorVM.vmdk"
EOF
zip -9 -r torvm-vmware.zip vmware
rm -rf vmware