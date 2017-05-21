#!/bin/bash

set -e
set -x

echo "Create VM image..."
qemu-img create -f qcow2 debian.qcow2 2G

echo "Load NBD module and connect image..."
modprobe nbd max_part=16
qemu-nbd -c /dev/nbd0 debian.qcow2

echo "Disconnect image and unload NBD module..."
qemu-nbd -d /dev/nbd0
rmmod nbd
