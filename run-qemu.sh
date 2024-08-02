#! /bin/sh
qemu-system-x86_64 \
    -kernel linux/arch/x86_64/boot/bzImage \
    -hda qemu-image.img \
    -append "root=/dev/sda console=ttyS0" \
    --enable-kvm
