#------------------------------------------------------------
# University of California, San Diego - Bespoke Systems Group
#------------------------------------------------------------
# File: Makefile
#
# Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
#------------------------------------------------------------

obj-m := bsg_ml605_pcie.o
bsg_ml605_pcie-objs := bsg_ml605_pcie_char.o bsg_ml605_pcie_module.o bsg_ml605_pcie_hw.o

KVERSION = $(shell uname -r)

default:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean
	-rm -rf Module.symvers Module.markers modules.order
