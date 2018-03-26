set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_ml605_dir $::env(BSG_ML605_DIR)
set bsg_ip_cores_dir $bsg_ml605_dir/out/bsg_ip_cores
set bsg_designs_dir $bsg_ml605_dir/out/bsg_designs
set bsg_manycore_dir $bsg_ml605_dir/out/bsg_manycore

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
  $bsg_ip_cores_dir/bsg_noc/bsg_noc_pkg.v
  $bsg_ip_cores_dir/bsg_misc/bsg_cycle_counter.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $bsg_ip_cores_dir/bsg_misc/bsg_round_robin_arb.v
  $bsg_ip_cores_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux_one_hot.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down_variable.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode_with_v.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_buffer.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_clk.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_data_bitslip_ctrl.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx_data.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_rx.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx_clk.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx_data.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc_tx.v
  $bsg_fpga_ip_dir/bsg_ml605/bsg_ml605_fmc/v/bsg_ml605_fmc.v
  $bsg_ml605_dir/src/v/bsg_ml605_clk.v
  $bsg_ml605_dir/src/v/bsg_ml605.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_io_complex.v
  $bsg_manycore_dir/testbenches/common/v/bsg_manycore_spmd_loader.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_monitor.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint.v
  $bsg_manycore_dir/v/bsg_manycore_pkt_decode.v
  $bsg_manycore_dir/v/bsg_manycore_links_to_fsb.v
  $bsg_designs_dir/modules/bsg_guts/bsg_test_node.v
  $bsg_designs_dir/toplevels/bsg_two_manycore_vanilla_clk_gen/v/bsg_chip_pkg.v
  $bsg_designs_dir/toplevels/bsg_two_manycore_vanilla_clk_gen/testing/bsg_manycore_io_complex_rom.v
  $bsg_designs_dir/toplevels/bsg_two_manycore_vanilla_clk_gen/testing/bsg_test_node_master.v
  
"]
