set target $::env(BSG_GATEWAY_TARGET)

source $::env(BSG_FPGA_FIRMWARE_DIR)/common/$target/tcl/common.tcl

set bsg_ise_dir $::env(BSG_ISE_DIR)

set project_dir $bsg_ise_dir/$bsg_top_name
set proj_exts [ list ise xise gise ]

foreach ext $proj_exts {
  set proj_name "${project_dir}.$ext"
  if { [ file exists $proj_name ] } {
    file delete $proj_name
  }
}

project new $project_dir

project set family $device_tech
project set device $device_name
project set package $device_package
project set speed $device_speed_grade

project set "Netlist Translation Type" "Timestamp"
project set "Other NGDBuild Command Line Options" "-verbose"
project set "Generate Detailed MAP Report" TRUE
project set {Place & Route Effort Level (Overall)} "High"

xfile add $bsg_syn_dir/$bsg_top_name.edn
xfile add $bsg_syn_dir/$bsg_top_name.ncf
xfile add $bsg_syn_dir/synplicity.ucf
xfile add $bsg_xps_dir/implementation/board_ctrl_stub.bmm
xfile add $bsg_fpga_firmware_dir/common/$target/ucf/bsg_gateway_customized.ucf

project set top $bsg_top_name

process run "Generate Programming File"
