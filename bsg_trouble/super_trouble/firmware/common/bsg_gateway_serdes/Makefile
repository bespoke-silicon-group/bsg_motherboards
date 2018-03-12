XIL_ENV = . $(XILINX_ISE_DS_DIR)/settings64.sh

export BSG_TOP_NAME=bsg_gateway
export BSG_XPS_DIR=$(BSG_OUT_DIR)/xps
export BSG_SYN_DIR=$(BSG_OUT_DIR)/syn
export BSG_ISE_DIR=$(BSG_OUT_DIR)/ise
export BSG_BSP_DIR=$(BSG_OUT_DIR)/bsp
export BSG_SDK_DIR=$(BSG_OUT_DIR)/sdk

# default rule
default: clean bitstream

XPS_NAME = board_ctrl
DEVICE = xc6slx150fgg676-3

# input
XPS_FLOW_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/bsg_gateway_microblaze/tcl/xps.tcl
XPS_MHS = $(BSG_FPGA_FIRMWARE_DIR)/common/bsg_gateway_microblaze/mhs/$(XPS_NAME).mhs
SYNPLIFY_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/tcl/synplify.tcl
XILINX_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/tcl/xilinx.tcl

GENERATE_SCR_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/tcl/generate_eco_scr.tcl
FPGA_EDLINE_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/tcl/fpga_edline_eco.tcl
XILINX_AFTER_ECO_TCL = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/tcl/xilinx_after_eco.tcl

# logs
SYNPLIFY_LOG = $(BSG_SYN_DIR)/synplify.log
XILINX_LOG = $(BSG_ISE_DIR)/xilinx.log

# output
XPS_BMM = $(BSG_XPS_DIR)/implementation/$(XPS_NAME)_stub.bmm
XPS_BD_BMM = $(BSG_XPS_DIR)/implementation/$(XPS_NAME)_stub_bd.bmm
XPS_XML = $(BSG_XPS_DIR)/SDK/SDK_Export/hw/$(XPS_NAME).xml
XPS_BIT = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).bit

SYNPLICITY_UCF = $(BSG_SYN_DIR)/synplicity.ucf
EDN_FILE = $(BSG_SYN_DIR)/$(BSG_TOP_NAME).edn
NCF_FILE = $(BSG_SYN_DIR)/$(BSG_TOP_NAME).ncf

GATEWAY_TIMING_RPT = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).twr
FPGA_EDLINE_SCR = $(BSG_ISE_DIR)/$(BSG_TOP_NAME).scr

IMP_DIR = $(BSG_XPS_DIR)/implementation

NGC_FILES = \
$(IMP_DIR)/board_ctrl_axi4lite_0_wrapper.ngc \
$(IMP_DIR)/board_ctrl_axi_gpio_0_wrapper.ngc \
$(IMP_DIR)/board_ctrl_axi_iic_cur_mon_wrapper.ngc \
$(IMP_DIR)/board_ctrl_axi_iic_dig_pot_wrapper.ngc \
$(IMP_DIR)/board_ctrl_axi_iic_dig_pot_pll_wrapper.ngc \
$(IMP_DIR)/board_ctrl_axi_uartlite_0_wrapper.ngc \
$(IMP_DIR)/board_ctrl_debug_module_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_bram_block_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_d_bram_ctrl_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_dlmb_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_i_bram_ctrl_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_ilmb_wrapper.ngc \
$(IMP_DIR)/board_ctrl_microblaze_0_wrapper.ngc \
$(IMP_DIR)/board_ctrl_proc_sys_reset_0_wrapper.ngc \
$(IMP_DIR)/board_ctrl.ngc

NDF_FILES = \
$(IMP_DIR)/board_ctrl_axi4lite_0_wrapper.ndf \
$(IMP_DIR)/board_ctrl_axi_gpio_0_wrapper.ndf \
$(IMP_DIR)/board_ctrl_axi_iic_cur_mon_wrapper.ndf \
$(IMP_DIR)/board_ctrl_axi_iic_dig_pot_wrapper.ndf \
$(IMP_DIR)/board_ctrl_axi_iic_dig_pot_pll_wrapper.ndf \
$(IMP_DIR)/board_ctrl_axi_uartlite_0_wrapper.ndf \
$(IMP_DIR)/board_ctrl_debug_module_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_bram_block_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_d_bram_ctrl_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_dlmb_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_i_bram_ctrl_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_ilmb_wrapper.ndf \
$(IMP_DIR)/board_ctrl_microblaze_0_wrapper.ndf \
$(IMP_DIR)/board_ctrl_proc_sys_reset_0_wrapper.ndf \
$(IMP_DIR)/board_ctrl.ndf

XPS_MSS = $(BSG_FPGA_FIRMWARE_DIR)/common/bsg_gateway_microblaze/mss/$(XPS_NAME).mss

ELF_FILE = $(BSG_SDK_DIR)/$(XPS_NAME).elf
ELF_SIZE = $(BSG_SDK_DIR)/$(XPS_NAME).elf.size
ELF_CHECK = $(BSG_SDK_DIR)/$(XPS_NAME).elf.elfcheck

MICROBLAZE_PROCESSOR = microblaze_0
MICROBLAZE_LIB = $(BSG_BSP_DIR)/$(MICROBLAZE_PROCESSOR)/lib
MICROBLAZE_INC = $(BSG_BSP_DIR)/$(MICROBLAZE_PROCESSOR)/include

C_SRC_DIR = $(BSG_FPGA_FIRMWARE_DIR)/common/bsg_gateway_microblaze/c

LSCRIPT = $(C_SRC_DIR)/lscript.ld

C_SRCS = \
$(C_SRC_DIR)/board_cur_mon.c \
$(C_SRC_DIR)/board_dig_pot.c \
$(C_SRC_DIR)/board_gpio.c \
$(C_SRC_DIR)/board_uart.c \
$(C_SRC_DIR)/main.c \
$(C_SRC_DIR)/uart_console.c

OBJS = \
$(BSG_SDK_DIR)/board_cur_mon.o \
$(BSG_SDK_DIR)/board_dig_pot.o \
$(BSG_SDK_DIR)/board_gpio.o \
$(BSG_SDK_DIR)/board_uart.o \
$(BSG_SDK_DIR)/main.o \
$(BSG_SDK_DIR)/uart_console.o

LIBS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

SYSTEM_ELF_BIT = $(BSG_OUT_DIR)/$(BSG_TOP_NAME)_elf.bit

#------------------------------ source ------------------------------

# This Makefile solve dependencies (pulling code) to an specific git commit
repos = \
bsg_ip_cores \
bsg_designs

repos_dep = $(addprefix $(BSG_TREE_DIR)/,$(repos))

$(repos_dep):
	make -C $(BSG_BASE_DIR) setup

$(BSG_OUT_DIR):
	mkdir -p $@

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_TREE_DIR)/bsg_ip_cores $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_ip_cores $@

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_TREE_DIR)/bsg_designs $(BSG_OUT_DIR)
	ln -s $(BSG_TREE_DIR)/bsg_designs $@
	
bsg_trace_pll = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/trace/bsg_gateway_trace_pll.in
bsg_trace_pll_1 = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/trace/bsg_gateway_trace_pll_1.in
bsg_trace_pll_2 = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/trace/bsg_gateway_trace_pll_2.in
bsg_trace_pll_3 = $(BSG_FPGA_FIRMWARE_DIR)/common/$(BSG_GATEWAY_TARGET)/trace/bsg_gateway_trace_pll_3.in
bsg_gateway_pll_rom_v = $(BSG_OUT_DIR)/bsg_gateway_pll_rom.v
bsg_gateway_pll_1_rom_v = $(BSG_OUT_DIR)/bsg_gateway_pll_1_rom.v
bsg_gateway_pll_2_rom_v = $(BSG_OUT_DIR)/bsg_gateway_pll_2_rom.v
bsg_gateway_pll_3_rom_v = $(BSG_OUT_DIR)/bsg_gateway_pll_3_rom.v

$(bsg_gateway_pll_rom_v): | $(BSG_OUT_DIR)/bsg_ip_cores
	$(BSG_OUT_DIR)/bsg_ip_cores/bsg_mem/bsg_ascii_to_rom.py $(bsg_trace_pll) bsg_gateway_pll_rom > $@
	
$(bsg_gateway_pll_1_rom_v): | $(BSG_OUT_DIR)/bsg_ip_cores
	$(BSG_OUT_DIR)/bsg_ip_cores/bsg_mem/bsg_ascii_to_rom.py $(bsg_trace_pll_1) bsg_gateway_pll_1_rom > $@
	
$(bsg_gateway_pll_2_rom_v): | $(BSG_OUT_DIR)/bsg_ip_cores
	$(BSG_OUT_DIR)/bsg_ip_cores/bsg_mem/bsg_ascii_to_rom.py $(bsg_trace_pll_2) bsg_gateway_pll_2_rom > $@
	
$(bsg_gateway_pll_3_rom_v): | $(BSG_OUT_DIR)/bsg_ip_cores
	$(BSG_OUT_DIR)/bsg_ip_cores/bsg_mem/bsg_ascii_to_rom.py $(bsg_trace_pll_3) bsg_gateway_pll_3_rom > $@

setup_dep = $(addprefix $(BSG_OUT_DIR)/,$(repos)) $(bsg_gateway_pll_rom_v) $(bsg_gateway_pll_1_rom_v) $(bsg_gateway_pll_2_rom_v) $(bsg_gateway_pll_3_rom_v)

setup: $(setup_dep)

#------------------------------ hardware flow ------------------------------

# xps dir
$(BSG_XPS_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

# xilinx xps flow
$(NGC_FILES): | $(BSG_XPS_DIR)
	ln -sf $(XPS_MHS) $(BSG_XPS_DIR)
	ln -sf $(XPS_FLOW_TCL) $(BSG_XPS_DIR)
	$(XIL_ENV); cd $(BSG_XPS_DIR) && xps -nw < $(XPS_FLOW_TCL)
	$(XIL_ENV); cd $(BSG_XPS_DIR) && make -f $(XPS_NAME).make netlist
	$(XIL_ENV); cd $(BSG_XPS_DIR) && make -f $(XPS_NAME).make exporttosdk

# xilinx ngc-to-edif
$(IMP_DIR)/%.ndf: $(IMP_DIR)/%.ngc $(NGC_FILES)
	$(XIL_ENV); ngc2edif -intstyle ise -log $(IMP_DIR)/ngc2edif.log $< $@

# synplify dir
$(BSG_SYN_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

# synplify flow
$(EDN_FILE) $(NCF_FILE) $(SYNPLICITY_UCF): $(NDF_FILES) | $(BSG_SYN_DIR) $(setup_dep)
	$(SYNPLIFY_BIN) -batch \
	-licensetype synplifypremierdp \
	-tcl $(SYNPLIFY_TCL) 2>&1 | tee $(SYNPLIFY_LOG)

# xilinx ise dir
$(BSG_ISE_DIR): | $(BSG_OUT_DIR)
	mkdir -p $(BSG_ISE_DIR)

# xilinx ise flow
$(XPS_BIT): $(EDN_FILE) $(NCF_FILE) $(SYNPLICITY_UCF) | $(BSG_ISE_DIR)
	$(XIL_ENV); xtclsh $(XILINX_TCL) 2>&1 | tee $(XILINX_LOG)
	
# xilinx ise flow
#$(GATEWAY_TIMING_RPT): $(EDN_FILE) $(NCF_FILE) $(SYNPLICITY_UCF) | $(BSG_ISE_DIR)
#	$(XIL_ENV); xtclsh $(XILINX_TCL) 2>&1 | tee $(XILINX_LOG)

# generate fpga_edline script
#$(FPGA_EDLINE_SCR): $(GATEWAY_TIMING_RPT)
#	cd $(BSG_ISE_DIR); tclsh $(GENERATE_SCR_TCL)

# apply eco result
#$(XPS_BIT): $(FPGA_EDLINE_SCR)
#	cd $(BSG_ISE_DIR); source $(FPGA_EDLINE_TCL); $(XTCLSH_BIN) $(XILINX_AFTER_ECO_TCL)

#------------------------------ software flow ------------------------------

$(BSG_BSP_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

$(BSG_BSP_DIR)/$(MICROBLAZE_PROCESSOR): $(XPS_BIT) | $(BSG_BSP_DIR)
	$(XIL_ENV); libgen -hw ${XPS_XML} \
	-pe ${MICROBLAZE_PROCESSOR} \
	-od $(BSG_BSP_DIR) \
	-log $(BSG_BSP_DIR)/libgen.log $(XPS_MSS)

# sdk dir
$(BSG_SDK_DIR): | $(BSG_OUT_DIR)
	mkdir -p $@

$(BSG_SDK_DIR)/%.o: $(C_SRC_DIR)/%.c | $(BSG_SDK_DIR) $(BSG_BSP_DIR)/$(MICROBLAZE_PROCESSOR)
	$(XIL_ENV); mb-gcc -Wall -O2 -c -fmessage-length=0 -I$(MICROBLAZE_INC) \
	-mlittle-endian -mxl-barrel-shift -mxl-pattern-compare \
	-mcpu=v8.50.c -mno-xl-soft-mul -Wl,--no-relax \
	-ffunction-sections -fdata-sections -MMD -MP \
	-MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"

$(ELF_FILE): $(OBJS) $(LSCRIPT)
	$(XIL_ENV); mb-gcc -Wl,-T -Wl,$(LSCRIPT) -L$(MICROBLAZE_LIB) -mlittle-endian \
	-mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.50.c \
	-mno-xl-soft-mul -Wl,--no-relax \
	-Wl,--gc-sections -o $(ELF_FILE) $(OBJS) $(LIBS)

$(ELF_SIZE): $(ELF_FILE)
	$(XIL_ENV); mb-size $(ELF_FILE) | tee $(ELF_SIZE)

$(ELF_CHECK): $(ELF_SIZE)
	$(XIL_ENV); elfcheck $(ELF_FILE) -hw $(XPS_XML) \
	-pe $(MICROBLAZE_PROCESSOR) | tee $(ELF_CHECK)

$(SYSTEM_ELF_BIT): $(ELF_CHECK)
	$(XIL_ENV); bitinit -p $(DEVICE) $(XPS_MHS) \
	-pe $(MICROBLAZE_PROCESSOR) $(ELF_FILE) \
	-bm $(XPS_BD_BMM) \
	-bt $(XPS_BIT) \
	-o $(SYSTEM_ELF_BIT) \
	-log $(BSG_OUT_DIR)/bitinit.log

bitstream: $(SYSTEM_ELF_BIT)

junk += $(BSG_OUT_DIR) *.log synlog.tcl licbug.txt xlnx_auto_0_xdb *.xrpt *.xml
junk += *.html _xmsgs *.twr *.twx *.log.bak

clean:
	-rm -rf $(junk)
