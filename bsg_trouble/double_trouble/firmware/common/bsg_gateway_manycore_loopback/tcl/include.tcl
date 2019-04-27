set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set basejump_stl_dir $bsg_gateway_dir/out/basejump_stl
set bsg_manycore_dir $bsg_gateway_dir/out/bsg_manycore

set GW_RTL_INCLUDE [join "
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $bsg_manycore_dir/v
"]
