# TorVM
A debian VM running Tor.

**This is work in progress... So, don't expect something usable**

## Using

 1. Download desired build
 2. Start VM
 
Default username: *torvm* \
Default password: *torvm*

## Building

You need the following things:
 * qemu-img
 * qemu-nbd
 * debootstrap
 * filesystem utilities for ext4 and swap

Use the `build.sh` script.

*Normally this script runs on a Jenkins CI-server, so it possibly break on a standard system.*