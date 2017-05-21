#!/bin/bash

set -x

echo "Create VM image..."
qemu-img create -f qcow2 debian.qcow2 2G || exit 255

echo "Load NBD module and connect image..."
modprobe nbd max_part=16 || exit 255
qemu-nbd -c /dev/nbd0 debian.qcow2 || exit 255

echo "Create swap and root partition..."
sfdisk /dev/nbd0 -D -uM << EOF
,512,82
;
EOF
sleep 5

echo "Format everything..."
mkswap /dev/nbd0p1
mkfs.ext3 /dev/nbd0p2
mount /dev/nbd0p2 /mnt/

echo "Install debian..."
debootstrap --include=less,locales-all,vim,sudo stable /mnt http://ftp.ch.debian.org/debian

echo "Mount /dev into image..."
mount --bind /dev/ /mnt/dev

echo "Chroot inside image and bootstrap..."
LANG=C chroot /mnt /bin/bash -e -x <<'EOF'
mount -t proc none /proc
mount -t sysfs none /sys

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  linux-image-amd64 \
  grub

grub-install /dev/nbd0
update-grub

umount /proc/ /sys/ /dev/
EOF

echo "Fix grub..."
grub-install /dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos"

echo "Disconnect image and unload NBD module..."
qemu-nbd -d /dev/nbd0
rmmod nbd
