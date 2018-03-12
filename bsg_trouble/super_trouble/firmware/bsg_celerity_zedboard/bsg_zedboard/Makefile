# environment
include ../../../Makefile.include

# bsg_two_coyote_accum
include ../Makefile.include

export BSG_TOP_NAME:=bsg_zedboard
export BSG_OUT_DIR:=$(BSG_ZEDBOARD_DIR)/out
export PROJ_NAME:=proj

VIVADO_BIN = $(XILINX_VIVADO)/bin/vivado

boot_bin = $(BSG_OUT_DIR)/boot.bin
bsg_zedboard_rocket = $(BSG_FPGA_IP_DIR)/bsg_zedboard/bsg_zedboard_rocket

all: clean $(boot_bin)

repos = \
bsg_ip_cores \
bsg_designs \
bsg_rocket

repos_dep = $(addprefix $(BSG_TREE_DIR)/,$(repos))

$(repos_dep):
	make -C $(BSG_BASE_DIR) setup

$(BSG_OUT_DIR):
	mkdir $@

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)/bsg_ip_cores $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_ip_cores $@

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_TREE_DIR)/bsg_designs $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_designs $@

$(BSG_OUT_DIR)/bsg_rocket: | $(BSG_TREE_DIR)/bsg_rocket $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_rocket $@

bsg_fsb_trace_in = $(BSG_OUT_DIR)/bsg_designs/modules/bsg_guts/trace_replay/testing/bsg_fsb_master_rom.rocket.trace.in
generated_dir = $(BSG_OUT_DIR)/bsg_rocket/rockets/coyote/generated-src
bsg_fsb_master_rom_v = $(BSG_OUT_DIR)/bsg_fsb_master_rom.v

$(bsg_fsb_master_rom_v): | $(BSG_OUT_DIR)/bsg_ip_cores
	$(BSG_OUT_DIR)/bsg_ip_cores/bsg_mem/bsg_ascii_to_rom.py $(bsg_fsb_trace_in) bsg_fsb_master_rom > $@

setup_dep = $(addprefix $(BSG_OUT_DIR)/,$(repos)) $(bsg_fsb_master_rom_v)

setup: $(setup_dep)

vivado_tcl = $(BSG_ZEDBOARD_DIR)/src/tcl/vivado_flow.tcl
system_bit = $(BSG_OUT_DIR)/$(PROJ_NAME)/$(PROJ_NAME).runs/impl_1/$(BSG_TOP_NAME).bit

$(system_bit): $(setup_dep)
	$(VIVADO_BIN) -mode batch -source $(vivado_tcl)

zynq_fsb_elf = $(bsg_zedboard_rocket)/boot_image/zynq_fsbl.elf
uboot_elf = $(bsg_zedboard_rocket)/boot_image/u-boot.elf
boot_bif = $(BSG_OUT_DIR)/boot.bif

$(boot_bif): | $(BSG_OUT_DIR)
	@echo "the_ROM_image:{" > $@
	@echo "[bootloader]$(zynq_fsb_elf)" >> $@
	@echo $(system_bit) >> $@
	@echo "$(uboot_elf)}" >> $@

$(boot_bin): $(boot_bif) $(system_bit)
	$(XILINX_BOOTGEN_BIN) -image $< -w -o $@

junk = *.log *.jou ./.cache ./.Xil $(BSG_OUT_DIR)

clean:
	-rm -rf $(junk)
