# linux-kernel-module

To build your out-of-tree kernel module on `NixOS` you need to do
the following steps:

```bash
# Create a copy of the kernel source
nix-build '<nixpkgs>' -A linuxPackages_6_1.kernel.dev
# Developement shell
nix-shell '<nixpkgs>' -A linuxPackages.kernel
```

Note that you need to build on the exact kernel version or the module
won't load.

If the exact kernel version that you are using is not in the packet manager,
you need to download that specific version and build it:

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.92.tar.xz
tar -xvf linux*
nix-shell
cd linux*
# Change the settings if needed and save the config
make menuconfig
# Build with the number of avaiable cores
make -j4
```

If you get compile errors, you need to remove `-Werror` from the
linux kernel Makefile.

If you screw up something, you can clean the installation with:
```bash
make distclean
```

You then need to create the module and a make file like so:
```make
obj-m += hello.o 
PWD := $(CURDIR) 
KVERSION = $(shell uname -r)

all: 
	make -C linux/ M=$(PWD) modules 

clean: 
	make -C linux/ M=$(PWD) clean
```

Make sure to use tabs and not spaces. Note that

- `-C` sets the directory of the makefile to execute

- `M` tells the kernel makefile that this directory contains a module

Use `make` to build the module:

```bash
make
```

And load it with `insmod`:

```bash
sudo insmod ./hello.ko
```

Check messages in `dmeg`:

```bash
dmesg
```

List loaded modules:

```bash
lsmod | grep hello
```

Remove it with:

```bash
sudo rmmod -f hello
```

## Booting with qemu

Once you have a compiled kernel, you need a filesystem. You can use busybox,
debootstrap or other alternatives. I'll use debootstrap to get the stable
debian filesystem. You can run the script `create-image.sh:

```bash
create-image.sh
```

Once you have the image, It will need a password to boot. You need to mount
the image, chroot inside it and run `passwd`:

```bash
sudo mount qemu-image.img tmp
sudo chroot tmp /bin/sh
root> export PATH="$PATH:/usr/sbin:/sbin:/bin"
root> passwd
root> exit
sudo umount tmp
```

After all of this, you can finally boot the new kernel with the filesystem:

```bash
qemu-system-x86_64 -kernel linux/arch/x86_64/boot/bzImage -hda qemu-image.img -append "root=/dev/sda rw console=ttyS0" --enable-kvm
```

### Network

To setup networking inside the vm, the easiest think is to install `network-manager`.
You need to chroot inside the mounted image and use apt if you installed debian
or the packet manager of your choice.

```bash
sudo mount qemu-image.img /mnt/linux
sudo chroot /mnt/linux /bin/sh
root> export PATH="$PATH:/usr/sbin:/sbin:/bin"
root> apt install network-manager
root> exit
sudo umount /mnt/linux
```

## Set keyboard

```bash
apt install keyboard-configuration console-setup
```

## Nix

If you want to run a nix shell on the VM, tou need to install nix, then
update It's channgels:
```bash
apt install xz-utils
curl -L https://nixos.org/nix/install > /tmp/install
chmod +x /tmp/install
/tmp/install --daemon
nix-channel --update
nix-shell
```


# Useful commands

Make a defautlt config
```bash
make defconfig
```

# Debugging

Setup linux kernel parameters:
```bash
./scripts/config --set-val CONFIG_DEBUG_INFO  y
./scripts/config --set-val CONFIG_GDB_SCRIPTS y
```
You should also disable "CONFIG_RANDOMIZE_BASE".

Now rebuild the kernel. On quemu, use `-s` and `-S` to listen and wait for gdb.
You shoulw also disable KASLR by adding "nokaslr" to the appened flag int qemu.

You can run gdb like this:
```gdb
cd linux/
echo "add-auto-load-safe-path `pwd`/scripts/gdb/vmlinux-gdb.py" >> ~/.gdbinit
gdb -ex "target remote :1234" ./vmlinux
```

You can find a more comple guide [here](https://www.kernel.org/doc/html/v4.14/dev-tools/gdb-kernel-debugging.html).

Useful gdb:
```
layout asm
```
