# SPDX-License-Identifier: MIT
# Author:  Giovanni Santini
# Mail:    giovanni.santini@proton.me
# License: MIT

include make.conf

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
	qemu-system-$(ARCH_QEMU) $(QEMU_FLAGS) 
$(IMG):
	if [ -e $(IMG) ]; then rm $(IMG); fi
	if [ -e $(IMG_MOUNT) ]; then sudo umount $(IMG_MOUNT); fi
	qemu-img create $(IMG) $(IMG_SIZE)
	sudo mkfs.$(FS_TYPE) $(IMG)
	mkdir -p $(IMG_MOUNT)
	sudo mount -o loop $(IMG) $(IMG_MOUNT)
	sudo debootstrap --arch $(ARCH_DEBOOTSTRAP) --include $(PACKAGES) stable $(IMG_MOUNT) https://deb.debian.org/debian
	sudo chroot $(IMG_MOUNT) /bin/bash -c "echo '$(IMG_USER):$(IMG_PASSWD)' | chpasswd"
	sudo umount -R $(IMG_MOUNT)
	rmdir $(IMG_MOUNT)
