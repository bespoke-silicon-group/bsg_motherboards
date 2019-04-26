

module bsg_link_ddr

 #(parameter width_p = "inv"
  ,parameter channel_width_p = 8
  ,parameter lg_fifo_depth_p = 6
  ,parameter lg_credit_to_token_decimation_p = 3)

  (input clk_i
  ,input clk_1x_i
  ,input clk_2x_i
  ,input reset_i
  ,input chip_reset_i
  ,input link_enable_i
  ,output link_enable_o
	
  // core side
  ,input [width_p-1:0] data_i
  ,input valid_i
  ,output ready_o

  ,output [width_p-1:0] data_o
  ,output valid_o
  ,input yumi_i

  // io side
  ,output logic io_clk_r_o
  ,output logic [channel_width_p-1:0] io_data_r_o
  ,output logic io_valid_r_o
  ,input io_token_i
	
  ,input io_clk_i
  ,input [channel_width_p-1:0] io_data_i
  ,input io_valid_i
  ,output logic io_token_r_o);
  
  
  bsg_link_ddr_upstream
 #(.width_p(width_p)
  ,.channel_width_p(channel_width_p)
  ,.lg_fifo_depth_p(lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p))
  upstream
  (.*);
  
  
  bsg_link_ddr_downstream
 #(.width_p(width_p)
  ,.channel_width_p(channel_width_p)
  ,.lg_fifo_depth_p(lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p))
  downstream
  (.*);
  

endmodule


























