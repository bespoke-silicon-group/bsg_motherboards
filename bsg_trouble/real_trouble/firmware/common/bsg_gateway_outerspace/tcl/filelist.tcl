set bsg_fpga_ip_dir $::env(BSG_FPGA_IP_DIR)
set bsg_fpga_firmware_dir $::env(BSG_FPGA_FIRMWARE_DIR)
set bsg_gateway_dir $::env(BSG_GATEWAY_DIR)
set bsg_ip_cores_dir $bsg_gateway_dir/out/bsg_ip_cores
set bsg_designs_dir $bsg_gateway_dir/out/bsg_designs
set target $::env(BSG_GATEWAY_TARGET)

set GW_RTL_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_misc/bsg_and.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_misc/bsg_popcount.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_rotate_right.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_encode_one_hot.v
  $bsg_ip_cores_dir/bsg_misc/bsg_wait_cycles.v
  $bsg_ip_cores_dir/bsg_misc/bsg_wait_after_reset.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_async/bsg_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_flatten_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_make_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_sbox.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_scatter_gather.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_narrow.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_narrowed.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master_master.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_slave.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_in.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_out.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_input.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_node_trace_replay.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_rx_clk.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_rx_data_bitslip_ctrl.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_rx_data.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_rx.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_tx_clk.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_tx_data.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_tx.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc_buffer.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_fmc/v/bsg_gateway_fmc.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_tag_new/bsg_gateway_tag.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_tag_new/bsg_tag_output.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_tag_new/bsg_tag_control.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_tag_new/bsg_tag_mb.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_tag_new/wait_cycle_32.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/input_output/bsg_gateway_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/input_output/bsg_gateway_serdes_channel.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/input_output/bsg_gateway_serdes_channel_rx.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/input_output/bsg_gateway_serdes_output.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_comm_link_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_comm_link_kernel_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_comm_link_fuser_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_source_sync_output_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_source_sync_input_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_async_credit_counter_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_assembler_out_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_assembler_in_serdes.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_async_widen.v
  $bsg_fpga_ip_dir/bsg_gateway/bsg_gateway_serdes/comm_link/bsg_async_ptr_gray_serdes.v
  $bsg_fpga_firmware_dir/common/$target/v/bsg_gateway.v
  $bsg_fpga_firmware_dir/common/$target/v/bsg_gateway_clk.v
  $bsg_gateway_dir/out/bsg_gateway_tag_rom.v
"]
