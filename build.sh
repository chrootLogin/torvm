#!/bin/bash

function finish {
  echo "Stop all processes..."
  lsof /mnt | awk 'FNR > 1 { print $2 }' | xargs kill
  sleep 10
  echo "Kill all processes..."
  lsof /mnt | awk 'FNR > 1 { print $2 }' | xargs kill -9

  echo "Unmount everything..."
  umount /mnt/sys
  umount /mnt/proc
  umount /mnt/dev
  umount /mnt
  sleep 5

  echo "Disconnect image and unload NBD module..."
  qemu-nbd -d /dev/nbd0
  rmmod nbd
}

trap finish EXIT
set -x

echo "Create VM image..."
qemu-img create -f qcow2 torvm.qcow2 2G || exit 255

echo "Load NBD module and connect image..."
modprobe nbd max_part=16 || exit 255
qemu-nbd -c /dev/nbd0 torvm.qcow2 || exit 255

echo "Create swap and root partition..."
sfdisk /dev/nbd0 -D -uM << EOF
,512,82
;
EOF
sleep 5

echo "Format everything..."
mkswap /dev/nbd0p1
mkfs.ext4 /dev/nbd0p2
mount /dev/nbd0p2 /mnt

echo "Install debian..."
debootstrap --include=less,locales-all,vim,sudo stable /mnt http://ftp.ch.debian.org/debian

echo "Mount image..."
mount --bind /dev /mnt/dev
mount -t proc none /mnt/proc
mount -t sysfs none /mnt/sys

echo "Chroot inside image and bootstrap..."
LANG=C chroot /mnt /bin/bash -e -x <<'EOF'

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essentials \
  linux-image-amd64 \
  grub \
  python-pip

grub-install /dev/nbd0
update-grub

pip install ansible
EOF

echo "Fix grub..."
grub-install /dev/nbd0 --root-directory=/mnt
sleep 5
