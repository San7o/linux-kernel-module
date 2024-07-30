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

If you screw up something, you can clean the installation with:
```bash
make distclean
```

You then need to create the module and a make file like so:
```make
obj-m += hello.o 
PWD := $(CURDIR) 
KVERSION = 6.1.95

all: 
	make -C kernel/lib/modules/$(KVERSION)/build M=$(PWD) modules 

clean: 
	make -C kernel/lib/modules/$(KVERSION)/build M=$(PWD) clean
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
