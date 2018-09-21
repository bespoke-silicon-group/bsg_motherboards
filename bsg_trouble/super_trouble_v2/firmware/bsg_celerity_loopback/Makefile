# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../common/Makefile.include

# bsg_celerity_loopback variables
include Makefile.include

bsg_ip_cores_sha = af00884ee0840f950fdcbd1f287605dee7141ba4
bsg_designs_sha = 9e132d669b1b5ccae3c8d5ad7c1446893abca2a3
bsg_rocket_sha = 9335ac3c51e40694c0d7423e22fe2c679959097c
bsg_packaging_sha = 135c1e3e172a3a5890086a69487b1cded0bb157f
bsg_manycore_sha = 9a707acc9d2ba39bb8bc2caf12fde3d5052bf3ff

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
