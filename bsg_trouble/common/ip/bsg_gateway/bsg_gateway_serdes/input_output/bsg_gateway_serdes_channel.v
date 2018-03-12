//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_serdes_channel.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_serdes_channel #

  (parameter width = 8)

  (input io_master_clk_i
  ,input clk_2x_i
  ,input io_serdes_clk_i
  ,input io_strobe_i
  ,input core_calib_done_i
  
  ,input [39:0] data_output_i
  ,input [4:0] valid_output_i
  ,output logic token_input_o
  
  ,output logic clk_output_o
  ,output logic [7:0] data_output_o
  ,output logic valid_output_o
  ,input token_input_i);
  

	logic [39:0] data_output_lo;
	logic [4:0] valid_output_lo;
	assign valid_output_lo = valid_output_i;
	assign data_output_lo = data_output_i;
  
	logic [4:0] clk_candidate_lo;
	logic [7:0] data_candidate_lo [4:0];
	logic [4:0] valid_candidate_lo;
	
	// Directly output token signal
	assign token_input_o = token_input_i;

	logic tx_toggle = 0;	
	logic old_tx_toggle = 0;
	logic core_calib_done_i_r = 0;
	
	// IO clock domain, generation of clock signal
	always @(posedge io_master_clk_i)
    begin
		tx_toggle <= ~tx_toggle;
    end

	// 2x clock domain, connected to output pins
	always @ (posedge clk_2x_i)
	begin
		old_tx_toggle <= tx_toggle;
		core_calib_done_i_r <= core_calib_done_i;
		
		if (core_calib_done_i_r == 1'b0) begin
			data_candidate_lo[4] <= data_output_lo[7:0];
			data_candidate_lo[3] <= data_output_lo[7:0];
			data_candidate_lo[2] <= data_output_lo[7:0];
			data_candidate_lo[1] <= data_output_lo[7:0];
			data_candidate_lo[0] <= data_output_lo[7:0];
			valid_candidate_lo <= {valid_output_lo[0], valid_output_lo[0], valid_output_lo[0], 
									valid_output_lo[0], valid_output_lo[0]};
			clk_candidate_lo[4] <= old_tx_toggle;
			clk_candidate_lo[3] <= old_tx_toggle;
			clk_candidate_lo[2] <= old_tx_toggle;
			clk_candidate_lo[1] <= old_tx_toggle;
			clk_candidate_lo[0] <= old_tx_toggle;
		end else begin 
			if (tx_toggle != old_tx_toggle) begin
				data_candidate_lo[4] <= data_output_lo[16+:8];
				data_candidate_lo[3] <= data_output_lo[8+:8];
				data_candidate_lo[2] <= data_output_lo[8+:8];
				data_candidate_lo[1] <= data_output_lo[0+:8];
				data_candidate_lo[0] <= data_output_lo[0+:8];
				valid_candidate_lo <= {valid_output_lo[2], valid_output_lo[1], valid_output_lo[1], 
										valid_output_lo[0], valid_output_lo[0]};
				clk_candidate_lo[4] <= ~old_tx_toggle;
				clk_candidate_lo[3] <= ~old_tx_toggle;
				clk_candidate_lo[2] <= old_tx_toggle;
				clk_candidate_lo[1] <= old_tx_toggle;
				clk_candidate_lo[0] <= ~old_tx_toggle;
			end
			else begin
				data_candidate_lo[4] <= data_output_lo[32+:8];
				data_candidate_lo[3] <= data_output_lo[32+:8];
				data_candidate_lo[2] <= data_output_lo[24+:8];
				data_candidate_lo[1] <= data_output_lo[24+:8];
				data_candidate_lo[0] <= data_output_lo[16+:8];
				valid_candidate_lo <= {valid_output_lo[4], valid_output_lo[4], valid_output_lo[3], 
										valid_output_lo[3], valid_output_lo[2]};	
				clk_candidate_lo[4] <= ~old_tx_toggle;
				clk_candidate_lo[3] <= old_tx_toggle;
				clk_candidate_lo[2] <= old_tx_toggle;
				clk_candidate_lo[1] <= ~old_tx_toggle;
				clk_candidate_lo[0] <= ~old_tx_toggle;
			end
		end
		
	end
	
	// Pipeline registers
	logic [4:0] clk_candidate_lo_r;
	logic [7:0] data_candidate_lo_r [4:0];
	logic [4:0] valid_candidate_lo_r;
	
	logic [4:0] clk_candidate_lo_n;
	logic [7:0] data_candidate_lo_n [4:0];
	logic [4:0] valid_candidate_lo_n;
	
	assign clk_candidate_lo_n = clk_candidate_lo;
	assign data_candidate_lo_n = data_candidate_lo;
	assign valid_candidate_lo_n = valid_candidate_lo;
	
	always @(posedge clk_2x_i) begin
		clk_candidate_lo_r <= clk_candidate_lo_n;
		data_candidate_lo_r <= data_candidate_lo_n;
		valid_candidate_lo_r <= valid_candidate_lo_n;
	end
	
	// For IO clock output
	bsg_gateway_serdes_output #
	(.width(width))
	clk
	(.io_master_clk_i(clk_2x_i)
	,.io_serdes_clk_i(io_serdes_clk_i)
	,.io_strobe_i(io_strobe_i)
	,.D5_i(clk_candidate_lo_r[4])
	,.D4_i(clk_candidate_lo_r[3])
	,.D3_i(clk_candidate_lo_r[2])
	,.D2_i(clk_candidate_lo_r[1])
	,.D1_i(clk_candidate_lo_r[0])
	,.Q_o(clk_output_o));
  
	// For valid bit output
	bsg_gateway_serdes_output #
	(.width(width))
	valid
	(.io_master_clk_i(clk_2x_i)
	,.io_serdes_clk_i(io_serdes_clk_i)
	,.io_strobe_i(io_strobe_i)
	,.D5_i(valid_candidate_lo_r[4])
	,.D4_i(valid_candidate_lo_r[3])
	,.D3_i(valid_candidate_lo_r[2])
	,.D2_i(valid_candidate_lo_r[1])
	,.D1_i(valid_candidate_lo_r[0])
	,.Q_o(valid_output_o));
	
	
	genvar i;

	// For all data outputs
	for(i=0;i<8;i=i+1)
	begin: data_loop
	  
		bsg_gateway_serdes_output #
		(.width(width))
		data
		(.io_master_clk_i(clk_2x_i)
		,.io_serdes_clk_i(io_serdes_clk_i)
		,.io_strobe_i(io_strobe_i)
		,.D5_i(data_candidate_lo_r[4][i])
		,.D4_i(data_candidate_lo_r[3][i])
		,.D3_i(data_candidate_lo_r[2][i])
		,.D2_i(data_candidate_lo_r[1][i])
		,.D1_i(data_candidate_lo_r[0][i])
		,.Q_o(data_output_o[i]));	

	end
	

endmodule
