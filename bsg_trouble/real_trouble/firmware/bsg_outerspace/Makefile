# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../common/Makefile.include

# bsg_celerity_loopback variables
include Makefile.include

bsg_ip_cores_sha = 40b07e7aaac48293b2c57444b420d8824681fba9
bsg_designs_sha = a69e490dc4e823d74ef9ad43083c46f143b6d3d4

default: bitstreams

$(BSG_TREE_DIR):
	mkdir -p $@

$(BSG_TREE_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)
	git clone $(BSG_IP_CORES_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_ip_cores_sha) $(bsg_ip_cores_sha)

$(BSG_TREE_DIR)/bsg_designs: | $(BSG_TREE_DIR)
	git clone $(BSG_DESIGNS_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_designs_sha) $(bsg_designs_sha)

setup:  $(BSG_TREE_DIR)/bsg_ip_cores \
	$(BSG_TREE_DIR)/bsg_designs

bsg_gateway/out/bsg_gateway_elf.bit: $(setup)
	make -C bsg_gateway

bitstreams: bsg_gateway/out/bsg_gateway_elf.bit

clean:
	-rm -rf $(BSG_TREE_DIR)
