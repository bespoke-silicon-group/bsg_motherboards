//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc.v
//
// Author: Zihou Gao - zig053@eng.ucsd.edu
//------------------------------------------------------------

module bsg_asic_iodelay

  (input [3:0] clk_output_i
  ,input [7:0] data_a_output_i
  ,input [7:0] data_b_output_i
  ,input [7:0] data_c_output_i
  ,input [7:0] data_d_output_i
  ,input [3:0] valid_output_i
  ,output [3:0] clk_output_o
  ,output [7:0] data_a_output_o
  ,output [7:0] data_b_output_o
  ,output [7:0] data_c_output_o
  ,output [7:0] data_d_output_o
  ,output [3:0] valid_output_o);

  parameter [7:0] clk_output_tap [3:0] = {8'd0,8'd0,8'd0,8'd0};
  parameter [7:0] data_a_output_tap [7:0] = {8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0};
  parameter [7:0] data_b_output_tap [7:0] = {8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0};
  parameter [7:0] data_c_output_tap [7:0] = {8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0};
  parameter [7:0] data_d_output_tap [7:0] = {8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0};
  parameter [7:0] valid_output_tap [3:0] = {8'd0,8'd0,8'd0,8'd0};

  genvar i;

  for(i=0;i<4;i=i+1)
  begin: c0
    bsg_asic_iodelay_output #
	(.tap_i(clk_output_tap[i]))
	clk_temp
	(.bit_i(clk_output_i[i])
	,.bit_o(clk_output_o[i]));

	bsg_asic_iodelay_output #
	(.tap_i(valid_output_tap[i]))
	valid_temp
	(.bit_i(valid_output_i[i])
	,.bit_o(valid_output_o[i]));
  end

  for(i=0;i<8;i=i+1)
  begin: c1
    bsg_asic_iodelay_output #
	(.tap_i(data_a_output_tap[i]))
	data_a_temp
	(.bit_i(data_a_output_i[i])
	,.bit_o(data_a_output_o[i]));

	bsg_asic_iodelay_output #
	(.tap_i(data_b_output_tap[i]))
	data_b_temp
	(.bit_i(data_b_output_i[i])
	,.bit_o(data_b_output_o[i]));

	bsg_asic_iodelay_output #
	(.tap_i(data_c_output_tap[i]))
	data_c_temp
	(.bit_i(data_c_output_i[i])
	,.bit_o(data_c_output_o[i]));

	bsg_asic_iodelay_output #
	(.tap_i(data_d_output_tap[i]))
	data_d_temp
	(.bit_i(data_d_output_i[i])
	,.bit_o(data_d_output_o[i]));
  end

endmodule
