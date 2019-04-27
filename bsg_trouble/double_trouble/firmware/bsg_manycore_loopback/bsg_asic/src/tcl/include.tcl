set bsg_asic_dir $::env(BSG_ASIC_DIR)
set basejump_stl_dir $bsg_asic_dir/out/basejump_stl
set bsg_manycore_dir $bsg_asic_dir/out/bsg_manycore

set AC_RTL_INCLUDE [join "
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $bsg_manycore_dir/v
"]
