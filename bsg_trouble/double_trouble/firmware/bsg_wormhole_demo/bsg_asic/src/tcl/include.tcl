set bsg_asic_dir $::env(BSG_ASIC_DIR)
set bsg_ip_cores_dir $bsg_asic_dir/out/bsg_ip_cores

set AC_RTL_INCLUDE [join "
  $bsg_ip_cores_dir/bsg_misc
"]
