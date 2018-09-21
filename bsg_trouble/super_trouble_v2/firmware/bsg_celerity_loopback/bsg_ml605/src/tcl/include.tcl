set bsg_ml605_dir $::env(BSG_ML605_DIR)
set bsg_ip_cores_dir $bsg_ml605_dir/out/bsg_ip_cores
set bsg_manycore_dir $bsg_ml605_dir/out/bsg_manycore

set ML_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_noc
  $bsg_manycore_dir/v
"]
