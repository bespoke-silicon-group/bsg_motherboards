
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: wait_cycle_32.v
//
// Author: Paul Gao
//------------------------------------------------------------

module wait_cycle_32

	(input reset_i
	,input enable_i
	,input clk_i
	// number of cycles
	,input [31:0] cycle_i
	// output ready signal
	,output logic ready_r_o
	// output LED signal
	,output logic test_o);
	
	reg [31:0] counter_r, counter_n;
	reg [31:0] cycle_r, cycle_n;
	reg ready_r, ready_n;
	reg test_r, test_n;
	
	assign ready_r_o = ready_r;
	assign test_o = test_r;
	assign counter_n = (ready_r == 1'b0)? (counter_r + 32'd1) : 32'd1;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			counter_r <= 32'd1;
			ready_r <= 1'b1;
			cycle_r <= 32'd0;
			test_r <= 1'b0;
		end else begin
			counter_r <= counter_n;
			ready_r <= ready_n;
			cycle_r <= cycle_n;
			test_r <= test_n;
		end
	end
	
	always_comb
	begin
		cycle_n = cycle_r;
		ready_n = ready_r;
		test_n = test_r;
		// When waiting ends
		if ((ready_r == 1'b0) & (counter_r == cycle_r))
		begin
			ready_n = 1'b1;
		end
		// When waiting start
		if ((ready_r == 1'b1) & (enable_i == 1'b1))
		begin
			ready_n = 1'b0;
			cycle_n = cycle_i;
			test_n = ~test_r;
		end
	end
	
endmodule
