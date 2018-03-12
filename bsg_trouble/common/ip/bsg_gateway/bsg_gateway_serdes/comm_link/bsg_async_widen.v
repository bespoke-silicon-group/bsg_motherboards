
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_async_widen.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_async_widen #

	(parameter in_width_p = "inv")

	// Input fast data
	(input in_clk
	,input in_reset
	,input valid_i
	,input [in_width_p-1:0] data_i
	,output logic ready_o
	
	// Output 2x wide data
	,input out_clk
	,input out_reset
	,output logic [2-1:0] valid_o
	,output logic [in_width_p*2-1:0] data_o
	,input ready_i
	);
	
	/* Input side begin */
	
	logic toggle_r, toggle_n;
	logic full_1, full_2;
	logic valid_1, valid_2;
	logic ready_o_1, ready_o_2;
	
	assign ready_o_1 = (~full_1) & (~in_reset);
	assign ready_o_2 = (~full_2) & (~in_reset);
	
	always @(posedge in_clk) begin
		if (in_reset == 1) begin
			toggle_r <= 0;
		end else begin
			toggle_r <= toggle_n;
		end
	end
	
	always_comb begin
		toggle_n = toggle_r;
		valid_1 = 0;
		valid_2 = 0;
		ready_o = 0;
		// Map input data to correct fifo
		if (toggle_r == 0) begin
			ready_o = ready_o_1;
			valid_1 = valid_i & ready_o_1;
			if (valid_1 == 1) begin
				toggle_n = ~toggle_r;
			end
		end else begin
			ready_o = ready_o_2;
			valid_2 = valid_i & ready_o_2;
			if (valid_2 == 1) begin
				toggle_n = ~toggle_r;
			end
		end
	end
	
	logic fifo_valid_1, fifo_valid_2;
	logic fifo_deq_1, fifo_deq_2;
	logic [in_width_p-1:0] fifo_data_1, fifo_data_2;

	/* Input side end */

	bsg_async_fifo #
	(.lg_size_p(3)
	,.width_p(in_width_p))
	ring_packet_fifo_1
	(.w_clk_i(in_clk)
	,.w_reset_i(in_reset)
	,.w_enq_i(valid_1)
	,.w_data_i(data_i)
	,.w_full_o(full_1)
	,.r_clk_i(out_clk)
	,.r_reset_i(out_reset)
	,.r_deq_i(fifo_deq_1)
	,.r_data_o(fifo_data_1)
	,.r_valid_o(fifo_valid_1));
	
	bsg_async_fifo #
	(.lg_size_p(3)
	,.width_p(in_width_p))
	ring_packet_fifo_2
	(.w_clk_i(in_clk)
	,.w_reset_i(in_reset)
	,.w_enq_i(valid_2)
	,.w_data_i(data_i)
	,.w_full_o(full_2)
	,.r_clk_i(out_clk)
	,.r_reset_i(out_reset)
	,.r_deq_i(fifo_deq_2)
	,.r_data_o(fifo_data_2)
	,.r_valid_o(fifo_valid_2));
	
	/* Output side begin */
	
	logic toggle_slow_r, toggle_slow_n;
	
	always @(posedge out_clk) begin
		if (out_reset == 1) begin
			toggle_slow_r <= 0;
		end else begin
			toggle_slow_r <= toggle_slow_n;
		end
	end
	
	always_comb begin
		toggle_slow_n = toggle_slow_r;
		valid_o = 0;
		data_o = 0;
		fifo_deq_1 = 0;
		fifo_deq_2 = 0;
		// Map output data in correct sequence
		if (toggle_slow_r == 0) begin
			fifo_deq_1 = ready_i & fifo_valid_1;
			if (fifo_deq_1 == 1) begin
				valid_o[0] = 1'b1;
				data_o[0+:in_width_p] = fifo_data_1;
				fifo_deq_2 = ready_i & fifo_valid_2;
				if (fifo_deq_2 == 0) begin
					toggle_slow_n = 1;
				end else begin
					valid_o[1] = 1'b1;
					data_o[in_width_p+:in_width_p] = fifo_data_2;
				end
			end
		end else begin
			fifo_deq_2 = ready_i & fifo_valid_2;
			if (fifo_deq_2 == 1) begin
				valid_o[1] = 1'b1;
				data_o[in_width_p+:in_width_p] = fifo_data_2;
				toggle_slow_n = 0;
			end
		end
	end	
	
	/* Output side end */

endmodule

