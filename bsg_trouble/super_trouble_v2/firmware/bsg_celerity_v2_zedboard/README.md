### Project ###

Based on bsg_two_coyote_accum from bsg_designs:

* Core @ 50MHz
* IO @ 100MHz

### Source dependencies and versioning ###

This project support versioning, which means that uses snapshots (sha-commits)
from other bsg-repositories. The reason why this is required is for preserving
a known state for emulation efforts. The following [Makefile](https://bitbucket.org/taylor-bsg/bsg_fpga/src/master/project/bsg_zedboard/bsg_two_coyote_accum/Makefile)
defines the commits being used to build this system.

After pulling the required dependencies, a developer may change sources under
the source tree to test new functionality.

### How to build ###

Currently, bb-39 node is the one hosting Xilinx 6-series licenses. Any other
node can build 7-series designs.

1. In bb-91, make -C bsg_zedboard
2. In bb-39, make -C bsg_gateway
3. In bb-91, make -C bsg_asic synth
4. In bb-39, make -C bsg_asic bitstream

### How to test ###

1. Go to testing directory
2. Run `make`

### How to run zedboard ###

1. Copy boot.bin in SDCard and attach to the Zedboard
2. Program gateway and asic on DoubleTrouble
3. Configure the computer to be connected to Zedboard as gateway (192.168.1.1)
4. Connect ethernet cable between computer and Zedboard
5. ssh to zedboard (192.168.1.5), check RISCV for more info
6. Run `fesvr-zynq pk hello`
