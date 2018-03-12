set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_zedboard_dir $::env(BSG_ZEDBOARD_DIR)
set bsg_ip_cores_dir $bsg_zedboard_dir/out/bsg_ip_cores
set bsg_designs_dir $bsg_zedboard_dir/out/bsg_designs
set bsg_rocket_dir $bsg_zedboard_dir/out/bsg_rocket

set ZB_RTL_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down_variable.v
  $bsg_ip_cores_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $bsg_ip_cores_dir/bsg_misc/bsg_round_robin_arb.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode_with_v.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux_one_hot.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_node_trace_replay.v
  $bsg_rocket_dir/modules/bsg_rocket_fsb/bsg_host.v
  $bsg_rocket_dir/modules/bsg_rocket_fsb/bsg_nasti_master_req.v
  $bsg_rocket_dir/modules/bsg_rocket_fsb/bsg_nasti_master_resp.v
  $bsg_rocket_dir/modules/bsg_rocket_fsb/bsg_nasti_master.v
  $bsg_rocket_dir/modules/bsg_rocket_fsb/bsg_fsb_to_rocket.v
  $bsg_rocket_dir/modules/bsg_rocket_node/bsg_rocket_node_master.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_buffer.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_tx.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_tx_clk.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_tx_data.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_rx.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_rx_clk.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_rx_data.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_fmc/v/bsg_zedboard_fmc_rx_data_bitslip_ctrl.v
  $bsg_fpga_ip_dir/bsg_zedboard/bsg_zedboard_rocket/v/host_axi_converter.v
  $bsg_zedboard_dir/out/bsg_fsb_master_rom.v
  $bsg_designs_dir/modules/bsg_guts/trace_replay/bsg_test_node_master.v
  $bsg_zedboard_dir/src/v/bsg_zedboard_clk.v
  $bsg_zedboard_dir/src/v/bsg_zedboard.v
"]
