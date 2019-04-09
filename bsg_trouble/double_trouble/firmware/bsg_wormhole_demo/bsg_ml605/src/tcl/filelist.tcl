set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_ml605_dir $::env(BSG_ML605_DIR)
set bsg_ip_cores_dir $bsg_ml605_dir/out/bsg_ip_cores
set bsg_designs_dir $bsg_ml605_dir/out/bsg_designs

set ML_RTL_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
  $bsg_ip_cores_dir/bsg_test/test_bsg_data_gen.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_node_trace_replay.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_buffer.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_clk.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_data_bitslip_ctrl.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_data.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx_clk.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx_data.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc.v
  $bsg_designs_dir/modules/bsg_guts/bsg_test_node.v
  $bsg_ml605_dir/src/v/bsg_ml605_clk.v
  $bsg_ml605_dir/src/v/bsg_ml605.v
"]
