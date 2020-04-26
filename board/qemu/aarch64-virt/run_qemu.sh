#!/bin/sh

qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 2 \
	-kernel $1/images/Image \
	-append "rootwait root=/dev/vda console=ttyAMA0" \
	-netdev user,id=eth0 -device virtio-net-device,netdev=eth0 \
	-drive file=$1/images/rootfs.ext4,if=none,format=raw,id=hd0 \
	-device virtio-blk-device,drive=hd0
