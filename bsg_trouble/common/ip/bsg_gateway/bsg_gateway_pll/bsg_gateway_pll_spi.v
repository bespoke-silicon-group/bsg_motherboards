
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_pll_spi.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_pll_spi

	(input clk_i
	,input reset_i
	// Init RAM
	,input init_en_i
	,input [15:0] init_data_i
	// SPI Out
	,input spi_en_i
	,output logic spi_ready_o
	,output logic spi_cs_o
	,output logic spi_out_o
	// MB Control
	,input mb_en_i
	,input mb_reset_i
	,input [7:0] mb_addr_i
	,input [15:0] mb_data_i);
	
	// Init RAM
	logic [15:0] data_r [255:0];
	logic [15:0] data_n;
	logic [7:0] counter_r, counter_n;
	
	// SPI Out
	logic spi_ready_r, spi_ready_n;
	logic [31:0] spi_shift_r, spi_shift_n;
	logic [7:0] big_counter_r, big_counter_n;
	logic [7:0] small_counter_r, small_counter_n;
	logic spi_cs_r, spi_cs_n;
	logic spi_out_r, spi_out_n;
	logic [7:0] mb_prev_r, mb_prev_n;
	
	assign spi_ready_o = spi_ready_r;
	assign spi_cs_o = spi_cs_r;
	assign spi_out_o = spi_out_r;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			counter_r <= 0;
			big_counter_r <= 0;
			small_counter_r <= 0;
			spi_ready_r <= 1;
			spi_shift_r <= 0;
			spi_cs_r <= 1;
			spi_out_r <= 1;
			mb_prev_r <= 0;
		end else begin
			data_r[counter_r] <= data_n;
			counter_r <= counter_n;
			big_counter_r <= big_counter_n;
			small_counter_r <= small_counter_n;
			spi_ready_r <= spi_ready_n;
			spi_shift_r <= spi_shift_n;
			spi_cs_r <= spi_cs_n;
			spi_out_r <= spi_out_n;
			mb_prev_r <= mb_prev_n;
		end
	end
	
	always_comb
	begin
		// Init RAM
		data_n = data_r[counter_r];
		counter_n = counter_r;
		if (init_en_i == 1'b1)
		begin
			data_n = init_data_i;
			counter_n = counter_r + 1'b1;
		end
		// MB Control
		mb_prev_n = mb_prev_r;
		if (mb_en_i) begin
			if (mb_reset_i == 1'b1) begin
				mb_prev_n = 0;
				counter_n = 0;
			end
			if (mb_addr_i > mb_prev_r) begin
				mb_prev_n = mb_addr_i;
				counter_n = counter_r + 1;
				data_n = mb_data_i;
			end
		end
		// SPI Out
		spi_ready_n = spi_ready_r;
		spi_shift_n = spi_shift_r;
		big_counter_n = big_counter_r;
		small_counter_n = small_counter_r;
		spi_out_n = 1;
		spi_cs_n = 1;
		
		if ((spi_ready_r == 1'b1) & (spi_en_i == 1'b1)) begin
			spi_ready_n = 1'b0;
			big_counter_n = 0;
			small_counter_n = 0;
			spi_shift_n = {8'b00100000, data_r[big_counter_n], 8'b00000000};
		end
		
		if (spi_ready_r == 1'b0) begin	
			if (big_counter_r == counter_r) begin			
				spi_ready_n = 1'b1;			
			end else begin			
				if (small_counter_r == 32) begin
					big_counter_n = big_counter_r + 1;
					spi_shift_n = {8'b00100000, data_r[big_counter_n], 8'b00000000};
					small_counter_n = 0;
				end	else begin
					spi_cs_n = 1'b0;
					spi_out_n = spi_shift_r[31];
					spi_shift_n = spi_shift_r << 1;
					small_counter_n = small_counter_r + 1;			
				end
			end	
		end
		
	end
	
endmodule
