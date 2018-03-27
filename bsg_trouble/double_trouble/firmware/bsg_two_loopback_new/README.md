### Source dependencies and versioning ###

This project support versioning, which means that uses snapshots (sha-commits)
from other bsg-repositories. The reason why this is required is for preserving
a known state for emulation efforts. The [Makefile] defines the commits being 
used to build this system.

After pulling the required dependencies, a developer may change sources under
the source tree to test new functionality.

### How to build ###

Currently, bb-39 node is the one hosting Xilinx 6-series licenses. Therefore
the steps are:

1. Go to bb-39
2. Run `make`

### How to test ###

1. Go to testing directory
2. Run `make`
