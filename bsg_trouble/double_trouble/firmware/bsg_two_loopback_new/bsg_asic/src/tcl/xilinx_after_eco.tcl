source $::env(BSG_ASIC_DIR)/src/tcl/common.tcl

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
