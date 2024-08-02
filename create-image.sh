#! /bin/sh

IMG=qemu-image.img
DIR=mount-point.dir

qemu-img create $IMG 1g
mkfs.ext2 $IMG
mkdir $DIR
sudo mount -o loop $IMG $DIR
sudo debootstrap --arch amd64 stable $DIR https://deb.debian.org/debian
sudo umount -R $DIR
rmdir $DIR