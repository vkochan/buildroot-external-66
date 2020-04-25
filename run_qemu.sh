#!/bin/sh

qemu-system-x86_64 -M pc \
	-kernel $1/images/bzImage \
	-drive file=$1/images/rootfs.ext2,if=virtio,format=raw \
	-append "rootwait root=/dev/vda console=tty1 console=ttyS0" \
	-net nic,model=virtio -net user -nographic
