set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set bsg_ip_cores_dir $bsg_gateway_dir/out/bsg_ip_cores

set GW_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
"]
