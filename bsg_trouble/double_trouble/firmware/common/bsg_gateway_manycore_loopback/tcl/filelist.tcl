set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_fpga_firmware_dir $::env(BSG_FPGA_FIRMWARE_DIR)
set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set basejump_stl_dir $bsg_gateway_dir/out/basejump_stl
set bsg_designs_dir $bsg_gateway_dir/out/bsg_designs
set bsg_gateway_target $::env(BSG_GATEWAY_TARGET)

set GW_RTL_FILES [join "
  $basejump_stl_dir/bsg_misc/bsg_defines.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $basejump_stl_dir/bsg_misc/bsg_wait_cycles.v
  $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_clkgate_optional.v
  $basejump_stl_dir/bsg_misc/bsg_dlatch.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_test/test_bsg_data_gen.v
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_manycore_async_link_to_wormhole.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_manycore_loopback_test_node.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_wormhole_test_node.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_wormhole_channel_tunnel.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_source_sync_upstream.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_source_sync_downstream.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_link_ddr_upstream.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_link_ddr_downstream.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_link_ddr.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_oddr_phy.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_iddr_phy.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_gateway_clk.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_gateway.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_parallel_in_serial_out.v
  $bsg_fpga_firmware_dir/common/$bsg_gateway_target/v/bsg_serial_in_parallel_out_full.v
"]
