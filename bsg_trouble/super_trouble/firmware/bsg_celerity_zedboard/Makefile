# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../../Makefile.include

# bsg_two_loopback_new variables
include Makefile.include

bsg_ip_cores_sha = 1dbbaf947be66974f6dd8a9ac9d7b5d8bb28a515
bsg_designs_sha = 718815067a4d129048b54fae72b8ffa7ab2db8db
bsg_rocket_sha = c8238b944840a0cf3740866761659027bc4de6aa
bsg_packaging_sha = 3834d0256d857193f53a7729db55c710fadedc1d

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
