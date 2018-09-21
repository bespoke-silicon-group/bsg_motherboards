set bsg_zedboard_dir $::env(BSG_ZEDBOARD_DIR)
set bsg_ip_cores_dir $bsg_zedboard_dir/out/bsg_ip_cores
set bsg_fpga_zb_dir $::env(BSG_FPGA_IP_DIR)/bsg_zedboard
set bsg_out_dir $::env(BSG_OUT_DIR)
set proj_name $::env(PROJ_NAME)

set part_number "xc7z020clg484-1"
set proj_dir $bsg_out_dir/$proj_name

# create project
create_project $proj_name $proj_dir

# set project properties
set obj [get_projects $proj_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" $part_number $obj
set_property "board_part" "em.avnet.com:zed:part0:1.0" $obj

# source files
source $bsg_zedboard_dir/src/tcl/filelist.tcl
foreach f $ZB_RTL_FILES { read_verilog -sv $f }

# source includes
source $bsg_zedboard_dir/src/tcl/include.tcl
foreach f $ZB_RTL_INCLUDE { append include_dirs "-include_dirs $f " }

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
             -value $include_dirs \
             -objects [get_runs synth_1]

# the following is for files that use bsg_defines.v but don't
# specify actual include
set_property is_global_include true [get_files $bsg_ip_cores_dir/bsg_misc/bsg_defines.v]

# constraints
read_xdc $bsg_zedboard_dir/src/xdc/bsg_zedboard.xdc
read_xdc $bsg_fpga_zb_dir/bsg_zedboard_fmc/xdc/bsg_zedboard_fmc.xdc

# rocket base design system
source $bsg_fpga_zb_dir/bsg_zedboard_rocket/tcl/rocket_bd.tcl

# synth
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1

open_run synth_1 -name $proj_dir/proj.runs/synth_1

create_debug_core ila_0 ila
set_property C_DATA_DEPTH 1024 [get_debug_cores ila_0]
set_property C_TRIGIN_EN false [get_debug_cores ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores ila_0]
set_property ALL_PROBE_SAME_MU true [get_debug_cores ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores ila_0]
set_property port_width 1 [get_debug_ports ila_0/clk]
connect_debug_port ila_0/clk [get_nets [list clk_50_mhz]]
set_property port_width 167 [get_debug_ports ila_0/probe0]
connect_debug_port ila_0/probe0 [lsort -dictionary [get_nets -hier -filter {MARK_DEBUG==1}]]

write_debug_probes -force $bsg_out_dir/bsg_zedboard.ltx

# impl
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
