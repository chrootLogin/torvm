#!/bin/bash

function cleanup {
  echo "Stop all processes..."
  lsof /mnt | awk 'FNR > 1 { print $2 }' | xargs -r kill
  sleep 10
  echo "Kill all processes..."
  lsof /mnt | awk 'FNR > 1 { print $2 }' | xargs -r kill -9

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

function getUUID {
  blkid -s UUID -o value $1
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
mkswap /dev/nbd0p1 || fail "Couldn't create swap filesystem"
mkfs.ext4 -L root /dev/nbd0p2 || fail "Couldn't create root filesystem"
mount /dev/nbd0p2 /mnt || fail "Couldn't mount root filesystem"

echo "Install debian..."
debootstrap --include=less,locales-all,vim,sudo,acpid jessie /mnt http://ftp.ch.debian.org/debian || fail "Couldn't create base filesystem"

echo "Mount image..."
mount --bind /dev /mnt/dev || fail "Couldn't mount /dev"
mount -t proc none /mnt/proc || fail "Couldn't mount /proc"
mount -t sysfs none /mnt/sys || fail "Couldn't mount /sys"

echo "Configuring system..."
cat <<EOF > /mnt/etc/fstab || fail "Couldn't create fstab"
UUID=$(getUUID /dev/nbd0p1) none        swap    sw                  0   0
UUID=$(getUUID /dev/nbd0p2) /           ext4    errors=remount-ro   0   1
none                        /dev/shm    tmpfs   defaults,size=400M  0   0
proc                        /proc       proc    defaults            0   0
EOF
cat /mnt/etc/fstab

echo "torvm" > /mnt/etc/hostname || fail "Couldn't set hostname"

cat <<EOF > /mnt/etc/hosts || fail "Couldn't create hosts file"
127.0.0.1   localhost
127.0.1.1   torvm

# The following lines are desirable for IPv6 capable hosts
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

cat <<EOF > /mnt/etc/network/interfaces || fail "Couldn't create interfaces file"
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

echo "Chroot inside image and bootstrap..."
LANG=C chroot /mnt /bin/bash -e -x <<'EOF' || fail "Cannot bootstrap VM!"
export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
  build-essential \
  grub-pc \
  libffi6 \
  libffi-dev \
  libssl1.0.0 \
  libssl-dev \
  libyaml-0-2 \
  libyaml-dev \
  linux-image-amd64 \
  openssl \
  python-dev \
  python-pip \
  python-setuptools

grub-install /dev/nbd0
update-grub

pip install -U cffi
pip install ansible
EOF

cp -R root/* /mnt || fail "Couldn't copy root filesystem"
LANG=C chroot /mnt /bin/bash -e -x <<'EOF' || fail "Ansible failed"
cd /install
ansible-playbook install.yml
EOF

echo "Chroot inside image and cleanup..."
LANG=C chroot /mnt /bin/bash -e -x <<'EOF' || fail "Cannot cleanup VM!"
apt-get remove -y \
  build-essential \
  libffi-dev \
  libssl-dev \
  libyaml-dev \
  python-dev

apt-get clean

rm -rf /install /root/.ansible
EOF

echo "Fix grub.cfg"
#sed -i "s|/dev/nbd0p1|/dev/vda1|g" /mnt/boot/grub/grub.cfg || fail "Couldn't fix grub.cfg"
#sed -i "s|/dev/nbd0p2|/dev/vda2|g" /mnt/boot/grub/grub.cfg || fail "Couldn't fix grub.cfg"
cat /mnt/boot/grub/grub.cfg

echo "Fix grub..."
grub-install /dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos" || fail "Cannot reinstall grub"
sleep 5
