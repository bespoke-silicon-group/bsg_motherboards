set bsg_ml605_dir $::env(BSG_ML605_DIR)
set bsg_ip_cores_dir $bsg_ml605_dir/out/bsg_ip_cores

set ML_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
"]
