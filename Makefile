obj-m += hello.o 
PWD := $(CURDIR) 
KVERSION = $(shell uname -r)

all: 
	#make -C linux/lib/modules/$(KVERSION)/build M=$(PWD) modules 
	make -C linux M=$(PWD) modules 

clean: 
	#make -C linux/lib/modules/$(KVERSION)/build M=$(PWD) clean
	make -C linux M=$(PWD) clean
