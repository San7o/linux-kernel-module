# SPDX-License-Identifier: MIT
# Author:  Giovanni Santini
# Mail:    giovanni.santini@proton.me
# License: MIT

#
# Config
#

obj-m      += hello.o 
PWD        := $(CURDIR) 
KVERSION   ?= $(shell uname -r)
KERNEL_DIR  = linux

ARCH_KERNEL = x86
ARCH_QEMU   = x86_64
IMG         = qemu-image.img   # use create-image.sh to generate an image
IMG_SIZE    = 1g
IMG_MOUNT   = mount-point.dir
PACKAGES    = vim
FS_TYPE     = ext4
ARCH_DEBOOTSTRAP = amd64

#
# Commands
#

all: module

module:
	make -C $(KERNEL_DIR) M=$(PWD) modules 

clean: 
	make -C $(KERNEL_DIR) M=$(PWD) clean

img: $(IMG)

copy: module img
	if [ -e $(IMG_MOUNT) ]; then sudo umount $(IMG_MOUNT); fi
	mkdir -p $(IMG_MOUNT)
	sudo mount -o loop $(IMG) $(IMG_MOUNT)
	sudo cp $(patsubst %.o, %.ko, $(obj-m)) $(IMG_MOUNT)/root
	sudo umount -R $(IMG_MOUNT)
	rmdir $(IMG_MOUNT)

qemu: img
	qemu-system-$(ARCH_QEMU) -kernel $(KERNEL_DIR)/arch/$(ARCH_KERNEL)/boot/bzImage -hda $(IMG) -append "root=/dev/sda console=ttyS0" --enable-kvm


$(IMG):
	if [ -e $(IMG) ]; then rm $(IMG); fi
	if [ -e $(IMG_MOUNT) ]; then sudo umount $(IMG_MOUNT); fi
	qemu-img create $(IMG) $(IMG_SIZE)
	sudo mkfs.$(FS_TYPE) $(IMG)
	mkdir -p $(IMG_MOUNT)
	sudo mount -o loop $(IMG) $(IMG_MOUNT)
	sudo debootstrap --arch $(ARCH_DEBOOTSTRAP) --include $(PACKAGES) stable $(IMG_MOUNT) https://deb.debian.org/debian
	sudo chroot $(IMG_MOUNT) /bin/bash -c "echo 'root:root' | chpasswd"
	sudo umount -R $(IMG_MOUNT)
	rmdir $(IMG_MOUNT)
