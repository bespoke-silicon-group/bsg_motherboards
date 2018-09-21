set bsg_zedboard_dir $::env(BSG_ZEDBOARD_DIR)
set bsg_ip_cores_dir $bsg_zedboard_dir/out/bsg_ip_cores
set bsg_rocket_dir $bsg_zedboard_dir/out/bsg_rocket

set ZB_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_fsb
  $bsg_rocket_dir/modules/bsg_rocket_fsb
"]
