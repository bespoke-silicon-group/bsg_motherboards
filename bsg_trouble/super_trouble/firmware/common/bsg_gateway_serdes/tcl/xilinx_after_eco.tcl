
set target $::env(BSG_GATEWAY_TARGET)

source $::env(BSG_FPGA_FIRMWARE_DIR)/common/$target/tcl/common.tcl
# set bsg_top_name bsg_gateway

set fileSuffix ".xise"
set fileName "$bsg_top_name$fileSuffix"

# Open project
project open $fileName

# Run PAR again
# process run "Place & Route"

# Run STA
# process run "Generate Post-Place & Route Static Timing"

# Generate bitstream again
process run "Generate Programming File"

# Close project
project close
