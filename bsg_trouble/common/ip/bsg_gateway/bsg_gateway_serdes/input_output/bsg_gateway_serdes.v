//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_serdes.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_serdes #

  (parameter width = 8
  ,parameter tap_array = {8'd35, 8'd35, 8'd35, 8'd35})

  (
  // Output Side
   input io_master_clk_i
  ,input clk_2x_i
  ,input [3:0] io_serdes_clk_i
  ,input [3:0] io_strobe_i
  ,input core_calib_done_i
  
  ,input [39:0] data_output_i [3:0]
  ,input [4:0] valid_output_i [3:0]
  ,output [3:0] token_input_o
  
  ,output [3:0] clk_output_o
  ,output [7:0] data_output_o [3:0]
  ,output [3:0] valid_output_o
  ,input [3:0] token_input_i
  
  // Input side
  ,input [3:0] raw_clk0_i
  ,output [3:0] div_clk_o
  
  ,input [7:0] data_input_i [3:0]
  ,input [3:0] valid_input_i
  ,output [3:0] token_output_o

  ,output [7:0] data_input_0_o [3:0]
  ,output [7:0] data_input_1_o [3:0]
  ,output [3:0] valid_input_0_o
  ,output [3:0] valid_input_1_o
  ,input [3:0] token_output_i);
  
	genvar i;
	
	for (i=0;i<4;i=i+1) begin: all_ch
	
		// Output channel
		bsg_gateway_serdes_channel #
		(.width(width))
		ch_output
		(.io_master_clk_i(io_master_clk_i)
		,.clk_2x_i(clk_2x_i)
		,.io_serdes_clk_i(io_serdes_clk_i[i])
		,.io_strobe_i(io_strobe_i[i])
		,.core_calib_done_i(core_calib_done_i)

		,.data_output_i(data_output_i[i])
		,.valid_output_i(valid_output_i[i])
		,.token_input_o(token_input_o[i])

		,.clk_output_o(clk_output_o[i])
		,.data_output_o(data_output_o[i])
		,.valid_output_o(valid_output_o[i])
		,.token_input_i(token_input_i[i]));
		
		// Input channel
		bsg_gateway_serdes_channel_rx #
		(.width(4)
		,.tap(tap_array[(8*i)+:8]))
		ch_input
		(.raw_clk0_i(raw_clk0_i[i])
		,.div_clk_o(div_clk_o[i])

		,.data_input_i(data_input_i[i])
		,.valid_input_i(valid_input_i[i])
		,.token_output_o(token_output_o[i])

		,.data_input_0_o(data_input_0_o[i])
		,.data_input_1_o(data_input_1_o[i])
		,.valid_input_0_o(valid_input_0_o[i])
		,.valid_input_1_o(valid_input_1_o[i])
		,.token_output_i(token_output_i[i]));
	
	end
	

endmodule
