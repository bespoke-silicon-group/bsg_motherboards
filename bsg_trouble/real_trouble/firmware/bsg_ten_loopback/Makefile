# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../common/Makefile.include

# bsg_celerity_loopback variables
include Makefile.include

bsg_ip_cores_sha = 40b07e7aaac48293b2c57444b420d8824681fba9
bsg_designs_sha = a69e490dc4e823d74ef9ad43083c46f143b6d3d4
bsg_rocket_sha = c8238b944840a0cf3740866761659027bc4de6aa
bsg_packaging_sha = 135c1e3e172a3a5890086a69487b1cded0bb157f
bsg_manycore_sha = 4b74a0fee4c81ca2ea9ce6b66e6f0a6fba3eb17e

default: bitstreams

$(BSG_TREE_DIR):
	mkdir -p $@

$(BSG_TREE_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)
	git clone $(BSG_IP_CORES_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_ip_cores_sha) $(bsg_ip_cores_sha)

$(BSG_TREE_DIR)/bsg_designs: | $(BSG_TREE_DIR)
	git clone $(BSG_DESIGNS_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_designs_sha) $(bsg_designs_sha)

$(BSG_TREE_DIR)/bsg_rocket: | $(BSG_TREE_DIR)
	git clone $(BSG_ROCKET_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_rocket_sha) $(bsg_rocket_sha)

$(BSG_TREE_DIR)/bsg_packaging: | $(BSG_TREE_DIR)
	git clone $(BSG_PACKAGING_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_packaging_sha) $(bsg_packaging_sha)
	
$(BSG_TREE_DIR)/bsg_manycore: | $(BSG_TREE_DIR)
	git clone $(BSG_MANYCORE_DIR) $@
	cd $@ && git checkout -b fpga_$(bsg_manycore_sha) $(bsg_manycore_sha)

setup:  $(BSG_TREE_DIR)/bsg_ip_cores \
	$(BSG_TREE_DIR)/bsg_designs \
	$(BSG_TREE_DIR)/bsg_rocket \
	$(BSG_TREE_DIR)/bsg_packaging \
	$(BSG_TREE_DIR)/bsg_manycore

bsg_gateway/out/bsg_gateway_elf.bit: $(setup)
	make -C bsg_gateway

bsg_ml605/out/ise/bsg_ml605.bit: $(setup)
	make -C bsg_ml605

bitstreams: bsg_ml605/out/ise/bsg_ml605.bit \
	bsg_gateway/out/bsg_gateway_elf.bit

clean:
	-rm -rf $(BSG_TREE_DIR)
