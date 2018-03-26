# environment
include ../../common/Makefile.include

# bsg_two_loopback_new variables
include ../Makefile.include

export BSG_TOP_NAME:=bsg_asic
export BSG_OUT_DIR:=$(BSG_ASIC_DIR)/out
export BSG_SYN_DIR:=$(BSG_OUT_DIR)/syn
export BSG_ISE_DIR:=$(BSG_OUT_DIR)/ise

default: clean bitstream

repos = \
bsg_ip_cores \
bsg_designs \
bsg_packaging

repos_dep = $(addprefix $(BSG_TREE_DIR)/,$(repos))

$(repos_dep):
	make -C $(BSG_ASIC_DIR)/../ setup

$(BSG_OUT_DIR):
	mkdir -p $@

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)/bsg_ip_cores $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_ip_cores $@

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_TREE_DIR)/bsg_designs $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_designs $@

$(BSG_OUT_DIR)/bsg_packaging: | $(BSG_TREE_DIR)/bsg_packaging $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_packaging $@

setup_dep = $(addprefix $(BSG_OUT_DIR)/,$(repos))

setup: $(setup_dep)

# synplify
synplify_tcl = $(BSG_ASIC_DIR)/src/tcl/synplify.tcl
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
xilinx_tcl = $(BSG_ASIC_DIR)/src/tcl/xilinx.tcl
xilinx_log = $(BSG_ISE_DIR)/xilinx.log
asic_timing_rpt = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).twr

generate_scr_tcl = $(BSG_ASIC_DIR)/src/tcl/generate_eco_scr.tcl
fpga_edline_tcl = $(BSG_ASIC_DIR)/src/tcl/fpga_edline_eco.tcl
xilinx_after_eco_tcl = $(BSG_ASIC_DIR)/src/tcl/xilinx_after_eco.tcl
fpga_edline_scr = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).scr
bit_file = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).bit

$(BSG_ISE_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

$(asic_timing_rpt): $(syn_top_edn) $(syn_top_ncf) $(synplicity_ucf) | $(BSG_ISE_DIR)
	$(XTCLSH_BIN) $(xilinx_tcl) 2>&1 | tee $(xilinx_log)

$(fpga_edline_scr): $(asic_timing_rpt)
	cd $(BSG_ISE_DIR); tclsh $(generate_scr_tcl)

$(bit_file): $(fpga_edline_scr)
	cd $(BSG_ISE_DIR); source $(fpga_edline_tcl); $(XTCLSH_BIN) $(xilinx_after_eco_tcl)

bitstream: $(bit_file)

junk = $(BSG_OUT_DIR) *.tcl *.log *.log.*

clean:
	-rm -rf $(junk)
