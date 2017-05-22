#!/bin/bash

function cleanup {
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

function fail {
  cleanup
  echo ""
  echo "FAILED: $1"
  exit 1
}

trap cleanup EXIT
set -x

echo "Create VM image..."
qemu-img create -f qcow2 torvm.qcow2 2G || fail "Couldn't create image!"

echo "Load NBD module and connect image..."
modprobe nbd max_part=16 || fail "Couldn't load NBD module!"
qemu-nbd -c /dev/nbd0 torvm.qcow2 || fail "Couldn't connect image!"

echo "Create swap and root partition..."
sfdisk /dev/nbd0 -D -uM << EOF || fail "Cannot partition /dev/ndb0"
,512,82,*
;
EOF
sleep 5

echo "Format everything..."
mkswap /dev/nbd0p1
mkfs.ext4 /dev/nbd0p2
mount /dev/nbd0p2 /mnt

echo "Install debian..."
debootstrap --include=less,locales-all,vim,sudo,acpid stable /mnt http://ftp.ch.debian.org/debian

echo "Mount image..."
mount --bind /dev /mnt/dev
mount -t proc none /mnt/proc
mount -t sysfs none /mnt/sys

echo "Configuring system..."
cat <<EOF > /mnt/etc/fstab
/dev/vda1   none        swap    sw                  0   0
/dev/vda2   /           ext4    errors=remount-ro   0   1
none        /dev/shm    tmpfs   defaults,size=400M  0   0
proc        /proc       proc    defaults            0   0
EOF

echo "torvm" > /mnt/etc/hostname

cat <<EOF > /mnt/etc/hosts
127.0.0.1   localhost
127.0.1.1   torvm

# The following lines are desirable for IPv6 capable hosts
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

cat <<EOF > /mnt/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

echo "Chroot inside image and bootstrap..."
LANG=C chroot /mnt /bin/bash -e -x <<'EOF'
export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
  build-essentials \
  linux-image-amd64 \
  grub-pc \
  python-pip

grub-install /dev/nbd0
update-grub

pip install ansible
EOF

echo "Fix grub..."
grub-install /dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos" || fail "Cannot reinstall grub"
sleep 5
