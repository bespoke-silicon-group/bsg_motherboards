# xilinx flow

source $::env(BSG_ML605_DIR)/src/tcl/common.tcl

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

project set top $bsg_top_name

process run "Generate Programming File"
