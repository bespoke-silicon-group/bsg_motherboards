
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_pll_control.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_pll_control

	(input reset_i
	,input enable_i
	,input clk_i
	// Command data
	,input [31:0] data_i
	// tag enable control
	,output logic [2:0] spi_rst_o);

	reg [2:0] spi_rst_r, spi_rst_n;
	assign spi_rst_o = spi_rst_r;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			spi_rst_r <= 3'b111;
		end else begin
			spi_rst_r <= spi_rst_n;
		end
	end
	
	always_comb
	begin
		spi_rst_n = spi_rst_r;
		if (enable_i == 1'b1)
		begin
			if (data_i[31])
				spi_rst_n[2] = 1'b1;
			if (data_i[30])
				spi_rst_n[2] = 1'b0;
			if (data_i[29])
				spi_rst_n[1] = 1'b1;
			if (data_i[28])
				spi_rst_n[1] = 1'b0;
			if (data_i[27])
				spi_rst_n[0] = 1'b1;
			if (data_i[26])
				spi_rst_n[0] = 1'b0;
		end
	end
	
endmodule
