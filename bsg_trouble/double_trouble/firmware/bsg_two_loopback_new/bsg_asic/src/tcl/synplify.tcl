source $::env(BSG_ASIC_DIR)/src/tcl/common.tcl

set bsg_designs_dir $::env(BSG_ASIC_DIR)/out/bsg_designs

project -new $bsg_syn_dir

# source files
source $bsg_designs_dir/toplevels/$bsg_asic_top_name/tcl/filelist.tcl
foreach f $AC_RTL_FILES { add_file -verilog $f }

# include path
source $bsg_designs_dir/toplevels/$bsg_asic_top_name/tcl/include.tcl
foreach f $AC_RTL_INCLUDE { set_option -include_path $f }

# constraint
add_file -constraint $::env(BSG_ASIC_DIR)/src/fdc/$bsg_top_name.fdc

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
