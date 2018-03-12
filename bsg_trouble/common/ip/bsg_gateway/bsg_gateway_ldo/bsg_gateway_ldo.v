
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_ldo.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_ldo

	(input reset_i
	,input clk_i
	,output logic rstin_o
	,output logic spi_out_o
	,output logic spi_clk_o
	,output logic spi_rst_o);
	
	logic [10:0] spi_stream_lo;
	assign spi_stream_lo = 11'b10110001111;
	
	logic [3:0] state_r, state_n;
	logic [7:0] counter_r, counter_n;
	logic [7:0] counter_2_r, counter_2_n;
	logic rstin_r, rstin_n;
	logic spi_rst_r, spi_rst_n;
	logic spi_out_r, spi_out_n;
	logic spi_clk_r, spi_clk_n;
	
	assign rstin_o = rstin_r;
	assign spi_rst_o = spi_rst_r;
	assign spi_out_o = spi_out_r;
	assign spi_clk_o = spi_clk_r;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			state_r <= 0;
			counter_r <= 0;
			counter_2_r <= 0;
			rstin_r <= 1;
			spi_rst_r <= 0;
			spi_out_r <= 0;
			spi_clk_r <= 0;
		end else begin
			state_r <= state_n;
			counter_r <= counter_n;
			counter_2_r <= counter_2_n;
			rstin_r <= rstin_n;
			spi_rst_r <= spi_rst_n;
			spi_out_r <= spi_out_n;
			spi_clk_r <= spi_clk_n;
		end
	end
	
	always_comb
	begin
	
		state_n = state_r;
		counter_n = counter_r;
		counter_2_n = counter_2_r;
		rstin_n = rstin_r;
		spi_rst_n = spi_rst_r;
		spi_out_n = spi_out_r;
		spi_clk_n = spi_clk_r;
		
		if (~reset_i) begin
			if (state_r == 0) begin
				if (counter_r == 16) begin
					state_n = 0;
					spi_rst_n = 1;
					counter_n = 0;
					spi_out_n = spi_stream_lo[counter_n];
				end else begin
					spi_rst_n = 1;
					counter_n = counter_r + 1;
				end
			end
			if (state_r == 1) begin
				counter_2_n = counter_2_r + 1;
				if (counter_2_r == 3) begin
					spi_clk_n = 1;
				end
				if (counter_2_r == 7) begin
					spi_clk_n = 0;
					counter_n = counter_r + 1;
					counter_2_n = 0;
					if (counter_n == 11) begin
						state_n = 2;
						spi_out_n = 0;
						counter_n = 0;
					end else begin
						spi_out_n = spi_stream_lo[counter_n];
					end
				end
			end
			if (state_r == 2) begin
				if (counter_r == 16) begin
					state_n = 3;
					rstin_n = 1;
					counter_n = 0;
				end else begin
					rstin_n = 0;
					counter_n = counter_r + 1;
				end
			end
		end
		
	end
	
endmodule
