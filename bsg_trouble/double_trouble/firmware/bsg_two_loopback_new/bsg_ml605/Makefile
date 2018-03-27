# environment
include ../../common/Makefile.include

# bsg_two_loopback_new variables
include ../Makefile.include

export BSG_TOP_NAME:=bsg_ml605
export BSG_OUT_DIR:=$(BSG_ML605_DIR)/out
export BSG_SYN_DIR:=$(BSG_OUT_DIR)/syn
export BSG_ISE_DIR:=$(BSG_OUT_DIR)/ise

default: clean bitstream

repos = \
bsg_ip_cores \
bsg_designs \

repos_dep = $(addprefix $(BSG_TREE_DIR)/,$(repos))

$(repos_dep):
	make -C $(BSG_ML605_DIR)/../ setup

$(BSG_OUT_DIR):
	mkdir -p $@

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)/bsg_ip_cores $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_ip_cores $@

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_TREE_DIR)/bsg_designs $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_designs $@

setup_dep = $(addprefix $(BSG_OUT_DIR)/,$(repos))

setup: $(setup_dep)

# synplify
synplify_tcl = $(BSG_ML605_DIR)/src/tcl/synplify.tcl
synplify_log = $(BSG_SYN_DIR)/synplify.log
synplicity_ucf = $(BSG_SYN_DIR)/synplicity.ucf
syn_top_ncf = $(BSG_SYN_DIR)/$(BSG_TOP_NAME).ncf
syn_top_edn = $(BSG_SYN_DIR)/$(BSG_TOP_NAME).edn

$(BSG_SYN_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

$(syn_top_edn) $(syn_top_ncf) $(synplicity_ucf): $(setup_dep) | $(BSG_SYN_DIR)
	$(SYNPLIFY_BIN) -batch \
	                -licensetype synplifypremierdp \
	                -tcl $(synplify_tcl) 2>&1 | tee $(synplify_log)

synth: $(syn_top_edn) $(syn_top_ncf) $(synplicity_ucf)

# xilinx
xilinx_tcl = $(BSG_ML605_DIR)/src/tcl/xilinx.tcl
xilinx_log = $(BSG_ISE_DIR)/xilinx.log
bit_file = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).bit

$(BSG_ISE_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

$(bit_file): $(syn_top_edn) $(syn_top_ncf) $(synplicity_ucf) | $(BSG_ISE_DIR)
	$(XTCLSH_BIN) $(xilinx_tcl) 2>&1 | tee $(xilinx_log)

bitstream: $(bit_file)

junk = $(BSG_OUT_DIR) *.tcl *.log *.log.*

clean:
	-rm -rf $(junk)
