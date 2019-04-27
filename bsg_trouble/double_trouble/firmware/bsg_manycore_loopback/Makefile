# This Makefile solve dependencies (pulling code) from a specific git commit
# if you want to change temporarily code, you can do so on the BSG_TREE_DIR
# once changes are in good shape, update the repo_sha accordingly

# environment
include ../common/Makefile.include

# bsg_two_loopback_new variables
include Makefile.include

basejump_stl_sha = 00f04eae887273c9feaaba3d97755070c14ab69f
bsg_designs_sha = 36e4ee8fb39214b6518b1106d53d5dab82ed5770
bsg_rocket_sha = e238d9b2e3ad876947a9dddabe92d01cbc63d546
bsg_packaging_sha = 3834d0256d857193f53a7729db55c710fadedc1d
bsg_manycore_sha = 40312111afe3119e197588ea9b81f1038a47caf6

default: bitstreams

$(BSG_TREE_DIR):
	mkdir -p $@

$(BSG_TREE_DIR)/basejump_stl: | $(BSG_TREE_DIR)
	git clone $(BASEJUMP_STL_DIR) $@
	cd $@ && git checkout -b fpga_$(basejump_stl_sha) $(basejump_stl_sha)

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

setup:  $(BSG_TREE_DIR)/basejump_stl \
	$(BSG_TREE_DIR)/bsg_designs \
	$(BSG_TREE_DIR)/bsg_rocket \
	$(BSG_TREE_DIR)/bsg_packaging \
	$(BSG_TREE_DIR)/bsg_manycore

bsg_asic/out/ise/bsg_asic.bit: $(setup)
	make -C bsg_asic

bsg_gateway/out/bsg_gateway_elf.bit: $(setup)
	make -C bsg_gateway

bsg_ml605/out/ise/bsg_ml605.bit: $(setup)
	make -C bsg_ml605

bitstreams: bsg_asic/out/ise/bsg_asic.bit \
	bsg_gateway/out/bsg_gateway_elf.bit \
	bsg_ml605/out/ise/bsg_ml605.bit

clean:
	-rm -rf $(BSG_TREE_DIR)
