set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set bsg_ip_cores_dir $bsg_gateway_dir/out/bsg_ip_cores
set bsg_manycore_dir $bsg_gateway_dir/out/bsg_manycore

set GW_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_noc
  $bsg_manycore_dir/v
"]
