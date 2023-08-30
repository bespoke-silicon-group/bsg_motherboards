THIS_DIR :=$(realpath $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

GIT_CLONE_STYLE :=ssh
#GIT_CLONE_STYLE :=https

ifeq ($(GIT_CLONE_STYLE),ssh)
  GITHUB    :=git@github.com:
  BITBUCKET :=git@bitbucket.com:
else ifeq ($(GIT_CLONE_STYLE),https)
  GITHUB    :=https://github.com/
  BITBUCKET :=https://bitbucket.com/
endif

basejump_stl_dir := $(THIS_DIR)/basejump_stl
basejump_stl_url := $(GITHUB)bespoke-silicon-group/basejump_stl.git
basejump_stl_commit := e7732a57611d0d2f51d8fa488c9cfe6aa1822017
#basejump_stl_commit := tapeout_bp_rc0

basejump_stl_new_dir := $(THIS_DIR)/basejump_stl_new
basejump_stl_new_url := $(GITHUB)bespoke-silicon-group/basejump_stl.git
basejump_stl_new_commit := ef361dbe8a136d23277b921a736175f4a4185a67

bsg_packaging_dir := $(THIS_DIR)/bsg_packaging
bsg_packaging_url := $(GITHUB)bespoke-silicon-group/bsg_packaging.git
bsg_packaging_commit := ec2bd1759bd0fcb74aae073822496d426b8c94ef

bsg_designs_dir := $(THIS_DIR)/bsg_designs
bsg_designs_url := $(BITBUCKET)taylor-bsg/bsg_designs.git
bsg_designs_commit := 13c02a2e10cfc1849137ffec3cbfda58b9a66f7e
#bsg_designs_commit := snapshot_tapeout_2019_07_17

pre-alpha-release_dir := $(THIS_DIR)/pre-alpha-release
pre-alpha-release_url := $(GITHUB)black-parrot/black-parrot.git
pre-alpha-release_commit := 9f1d4b12fe4afa5dc960209c5e5bc35c1e588c11

vivado_bin := $(XILINX_VIVADO)/bin/vivado

project_dir := $(THIS_DIR)/ku11p_test
project_xpr_dir := $(project_dir)/ku11p_test.xpr
build_tcl_dir := $(THIS_DIR)/bp_fpga.tcl

script_dir := $(THIS_DIR)/script
generate_tcl := $(script_dir)/generate_bitstream.tcl
program_tcl_dir := $(script_dir)/program_fpga.tcl
update_tcl_dir := $(script_dir)/update_tcl.tcl


all: libs
libs: $(basejump_stl_dir) $(basejump_stl_new_dir) $(bsg_packaging_dir) $(bsg_designs_dir) $(pre-alpha-release_dir)
$(basejump_stl_dir):
	git clone $(basejump_stl_url) $@
	cd $@ && git checkout $(basejump_stl_commit)
$(basejump_stl_new_dir):
	git clone $(basejump_stl_new_url) $@
	cd $@ && git checkout $(basejump_stl_new_commit)
$(bsg_packaging_dir):
	git clone $(bsg_packaging_url) $@
	cd $@ && git checkout $(bsg_packaging_commit)
$(bsg_designs_dir):
	git clone $(bsg_designs_url) $@
	cd $@ && git checkout $(bsg_designs_commit)
$(pre-alpha-release_dir):
	git clone $(pre-alpha-release_url) $@
	cd $@ && git checkout $(pre-alpha-release_commit)
	cd $@ && make ucode

build: $(project_dir)
$(project_dir): libs $(build_tcl_dir)
	$(vivado_bin) -mode batch -source $(build_tcl_dir)

open:
	$(vivado_bin) $(project_xpr_dir) &

generate_bitstream:
	$(vivado_bin) -mode batch -source $(generate_tcl)

program_fpga:
	sudo $(vivado_bin) -mode batch -source $(program_tcl_dir) -tclargs $(XVC_URL)

update_tcl:
	$(vivado_bin) -mode batch -source $(update_tcl_dir)

clean_libs: are_you_sure
	rm -rf $(basejump_stl_dir) $(basejump_stl_new_dir) $(bsg_packaging_dir) $(bsg_designs_dir) $(pre-alpha-release_dir)

clean_build: are_you_sure
	rm -rf $(project_dir)

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))
