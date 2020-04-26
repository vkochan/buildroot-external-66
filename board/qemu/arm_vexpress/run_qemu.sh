#!/bin/sh

qemu-system-arm -M vexpress-a9 -smp 1 -m 256 \
	-kernel $1/images/zImage \
	-dtb $1/images/vexpress-v2p-ca9.dtb \
	-drive file=$1/images/rootfs.ext2,if=sd,format=raw \
	-append "console=ttyAMA0,115200 rootwait root=/dev/mmcblk0" \
	-nographic -net nic,model=lan9118 -net user
