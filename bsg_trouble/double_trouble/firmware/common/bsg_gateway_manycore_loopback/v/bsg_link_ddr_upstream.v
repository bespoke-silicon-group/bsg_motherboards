

module bsg_link_ddr_upstream

 #(parameter width_p = "inv"
  ,parameter channel_width_p = 8
  ,parameter lg_fifo_depth_p = 6
  ,parameter lg_credit_to_token_decimation_p = 3
  ,localparam ddr_width_p = channel_width_p*2
  ,localparam piso_ratio_p = width_p/ddr_width_p)

  (input clk_i
  ,input clk_1x_i
  ,input clk_2x_i
  ,input reset_i
  ,input chip_reset_i
  ,input link_enable_i
	
  ,input [width_p-1:0] data_i
  ,input valid_i
  ,output ready_o  

  ,output logic io_clk_r_o
  ,output logic [channel_width_p-1:0] io_data_r_o
  ,output logic io_valid_r_o
  ,input io_token_i);
  
  
  logic out_ps_valid_o, out_ps_ready_i;
  logic [ddr_width_p-1:0] out_ps_data_o;
  
  bsg_parallel_in_serial_out 
 #(.width_p(ddr_width_p)
  ,.els_p(piso_ratio_p))
  out_piso
  (.clk_i(clk_i)
  ,.reset_i(chip_reset_i)
  ,.valid_i(valid_i)
  ,.data_i(data_i)
  ,.ready_o(ready_o)
  ,.valid_o(out_ps_valid_o)
  ,.data_o(out_ps_data_o)
  ,.yumi_i(out_ps_ready_i&out_ps_valid_o));
  
  
  logic io_reset_lo;
  logic out_ddr_valid_o;
  logic [ddr_width_p-1:0] out_ddr_data_o;
  
  bsg_source_sync_upstream
 #(.channel_width_p(ddr_width_p)
  ,.lg_fifo_depth_p(lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p))
  sso
  (// control signals  
   .core_clk_i(clk_i)
  ,.core_reset_i(reset_i)
  ,.io_master_clk_i(clk_1x_i)
  ,.link_enable_i(link_enable_i)
  ,.io_reset_o(io_reset_lo)
	
  // Input from chip core
  ,.core_data_i(out_ps_data_o)
  ,.core_valid_i(out_ps_valid_o)
  ,.core_ready_o(out_ps_ready_i)

  // source synchronous output channel; going to chip edge
  ,.io_data_r_o(out_ddr_data_o)
  ,.io_valid_r_o(out_ddr_valid_o)
  ,.token_clk_i(io_token_i));


  bsg_oddr_phy
 #(.width_p(channel_width_p))
  oddr_data
  (.reset_i(io_reset_lo)
  ,.clk_2x_i(clk_2x_i)
  ,.data_i(out_ddr_data_o)
  ,.data_r_o(io_data_r_o)
  ,.clk_r_o());
  

  bsg_oddr_phy
 #(.width_p(1))
  oddr_valid_clk
  (.reset_i(io_reset_lo)
  ,.clk_2x_i(clk_2x_i)
  ,.data_i({2{out_ddr_valid_o}})
  ,.data_r_o(io_valid_r_o)
  ,.clk_r_o(io_clk_r_o));
  

endmodule


























