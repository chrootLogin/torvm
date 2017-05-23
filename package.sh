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
cat << EOF > vmware/TorVM.vmware/TorVM.vmx
config.version = "8"
virtualHW.version = "7"

displayName = "TorVM"
guestOS = "other26xlinux-64"

numvcpus = "2"
memsize = "1024"

vmci0.present = "TRUE"

floppy0.present = "FALSE"

scsi0.present = "TRUE"
scsi0.sharedBus = "none"
scsi0.virtualDev = "lsilogic"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "TorVM.vmdk"
scsi0:0.deviceType = "scsi-hardDisk"

ide1:0.present = "FALSE"

pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"

ethernet0.pciSlotNumber = "32"
ethernet0.present = "TRUE"
ethernet0.virtualDev = "e1000"
ethernet0.networkName = "Inside"
ethernet0.generatedAddressOffset = "0"
EOF
zip -r torvm-vmware.zip vmware
rm -rf vmware
