set bsg_asic_dir $::env(BSG_ASIC_DIR)
set bsg_ip_cores_dir $bsg_asic_dir/out/bsg_ip_cores
set bsg_manycore_dir $bsg_asic_dir/out/bsg_manycore

set AC_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_noc
  $bsg_manycore_dir/v
"]
