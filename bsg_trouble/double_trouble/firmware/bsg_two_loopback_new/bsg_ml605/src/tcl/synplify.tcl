# synplify flow

source $::env(BSG_ML605_DIR)/src/tcl/common.tcl

project -new $bsg_syn_dir

# sverilog files
source $::env(BSG_ML605_DIR)/src/tcl/filelist.tcl
foreach f $ML_RTL_FILES { add_file -verilog $f }

# sverilog includes
source $::env(BSG_ML605_DIR)/src/tcl/include.tcl
foreach f $ML_RTL_INCLUDE { set_option -include_path $f }

# constraints
add_file -constraint $::env(BSG_ML605_DIR)/src/fdc/bsg_ml605.fdc
add_file -constraint $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/fdc/bsg_ml605_fmc.fdc

# chipscope
add_file -edif $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_chipscope/ndf/bsg_ml605_chipscope_icon.ndf
add_file -edif $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_chipscope/ndf/bsg_ml605_chipscope_ila.ndf
add_file -verilog $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_chipscope/v/bsg_ml605_chipscope_icon.v
add_file -verilog $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_chipscope/v/bsg_ml605_chipscope_ila.v
add_file -verilog $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_chipscope/v/bsg_ml605_chipscope.v

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
