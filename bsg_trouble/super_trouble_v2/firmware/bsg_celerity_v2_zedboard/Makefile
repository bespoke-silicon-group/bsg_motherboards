# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../common/Makefile.include

# bsg_two_loopback_new variables
include Makefile.include

bsg_ip_cores_sha = af00884ee0840f950fdcbd1f287605dee7141ba4
bsg_designs_sha = 9e132d669b1b5ccae3c8d5ad7c1446893abca2a3
bsg_rocket_sha = 9335ac3c51e40694c0d7423e22fe2c679959097c
bsg_packaging_sha = 135c1e3e172a3a5890086a69487b1cded0bb157f

default: setup

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

setup:  $(BSG_TREE_DIR)/bsg_ip_cores \
	$(BSG_TREE_DIR)/bsg_designs \
	$(BSG_TREE_DIR)/bsg_rocket \
	$(BSG_TREE_DIR)/bsg_packaging \

clean:
	-rm -rf $(BSG_TREE_DIR)
