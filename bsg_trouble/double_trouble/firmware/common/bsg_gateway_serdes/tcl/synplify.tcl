set target $::env(BSG_GATEWAY_TARGET)

source $::env(BSG_FPGA_FIRMWARE_DIR)/common/$target/tcl/common.tcl

project -new $bsg_syn_dir

# verilog files
source $bsg_fpga_firmware_dir/common/$target/tcl/filelist.tcl
foreach f $GW_RTL_FILES {add_file -verilog $f}

# verilog files
source $bsg_fpga_firmware_dir/common/$target/tcl/include.tcl
foreach f $GW_RTL_INCLUDE {set_option -include_path $f}

add_file -constraint $bsg_fpga_firmware_dir/common/$target/fdc/bsg_gateway.fdc

# host board (ML605 or Zedboard)

if {[info exists env(BSG_ML605_FMC)] && ![info exists env(BSG_ZEDBOARD_FMC)]} {
  add_file -constraint $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/fdc/bsg_gateway_fmc_ml605.fdc
  set_option -hdl_define -set "BSG_ML605_FMC"
} elseif {![info exists env(BSG_ML605_FMC)] && [info exists env(BSG_ZEDBOARD_FMC)]} {
  add_file -constraint $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/fdc/bsg_gateway_fmc_zedboard.fdc
  set_option -hdl_define -set "BSG_ZEDBOARD_FMC"
} else {
  error "ERROR(BSG): Only one host board (ML605/Zedboad) must be defined"
}

# microblaze (power control)
add_file -edif $bsg_xps_dir/implementation/board_ctrl_axi4lite_0_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_axi_gpio_0_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_axi_iic_cur_mon_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_axi_iic_dig_pot_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_axi_uartlite_0_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_debug_module_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_bram_block_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_d_bram_ctrl_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_dlmb_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_i_bram_ctrl_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_ilmb_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_microblaze_0_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl_proc_sys_reset_0_wrapper.ndf
add_file -edif $bsg_xps_dir/implementation/board_ctrl.ndf
add_file -verilog $bsg_xps_dir/hdl/board_ctrl.v

# bsg gateway chipscope
add_file -edif $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_chipscope/ndf/bsg_gateway_chipscope_icon.ndf
add_file -edif $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_chipscope/ndf/bsg_gateway_chipscope_ila.ndf
add_file -verilog $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_chipscope/v/bsg_gateway_chipscope_icon.v
add_file -verilog $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_chipscope/v/bsg_gateway_chipscope_ila.v
add_file -verilog $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_chipscope/v/bsg_gateway_chipscope.v

# options
set_option -technology $device_tech
set_option -part $device_name
set_option -package $device_package
set_option -speed_grade $device_speed_grade
set_option -top_module $bsg_top_name
set_option -symbolic_fsm_compiler 1
set_option -frequency auto
set_option -vlog_std sysv
set_option -enable64bit 1
set_option -resource_sharing 1
set_option -pipe 1
set_option -write_verilog 1
set_option -maxfan 1000

# project
project -result_format "edif"
project -result_file $bsg_syn_dir/$bsg_top_name.edn
project -run
project -save $bsg_syn_dir/$bsg_top_name.prj
