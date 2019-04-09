set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_fpga_firmware_dir $::env(BSG_FPGA_FIRMWARE_DIR)
set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set bsg_ip_cores_dir $bsg_gateway_dir/out/bsg_ip_cores
set bsg_designs_dir $bsg_gateway_dir/out/bsg_designs

set GW_RTL_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_misc/bsg_wait_cycles.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down_variable.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode_with_v.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode.v
  $bsg_ip_cores_dir/bsg_misc/bsg_round_robin_arb.v
  $bsg_ip_cores_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux_one_hot.v
  $bsg_ip_cores_dir/bsg_misc/bsg_clkgate_optional.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dlatch.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_wormhole_test_node.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_wormhole_channel_tunnel.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_source_sync_upstream.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_source_sync_downstream.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_link_ddr_upstream.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_link_ddr_downstream.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_link_ddr.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_oddr_phy.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_iddr_phy.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_gateway_clk.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_gateway.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_parallel_in_serial_out.v
  $bsg_fpga_firmware_dir/common/bsg_gateway_wormhole_demo/v/bsg_serial_in_parallel_out_full.v
"]
