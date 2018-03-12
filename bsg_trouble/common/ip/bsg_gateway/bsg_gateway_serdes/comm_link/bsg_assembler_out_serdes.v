
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_assembler_out_serdes.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_assembler_out_serdes #

	(parameter width_p = "inv"
	,parameter width_serdes_p = "inv"
	,parameter num_in_p = "inv"
	,parameter serdes_ratio_p = "inv"
	,parameter num_out_p = "inv"
	,parameter channel_select_p = (1<<(link_channels_p))-1)

	(input io_master_clk
	,input core_clk
	,input reset
	,input im_reset
	,input valid_i
	,input [num_in_p*width_p-1:0] data_i
	,output logic ready_o                // more permissive than yumi_o

	,output logic [num_out_p-1:0] valid_o
	,output logic [width_serdes_p-1:0] data_o [num_out_p-1:0]
	,input [num_out_p-1:0] ready_i  // we need to peek before deciding what to do.
	);

	// all channels full speed mode
	if (channel_select_p == 4'b1111) begin
	
		logic [2-1:0] fifo_valid_small_vec;
		logic [num_in_p*width_p*2-1:0] fifo_data_vec;	

		bsg_async_widen #
		(.in_width_p(num_in_p*width_p))
		bao_widen
		(.in_clk(core_clk)
		,.in_reset(reset)
		,.valid_i(valid_i)
		,.data_i(data_i)
		,.ready_o(ready_o)
		,.out_clk(io_master_clk)
		,.out_reset(im_reset)
		,.valid_o(fifo_valid_small_vec)
		,.data_o(fifo_data_vec)
		,.ready_i(& ready_i));
		
		genvar i, j;
		
		logic [num_in_p*2-1:0] fifo_valid_vec;
		for (i = 0; i < num_in_p; i = i + 1) begin
			assign fifo_valid_vec[i] = fifo_valid_small_vec[0];
			assign fifo_valid_vec[num_in_p+i] = fifo_valid_small_vec[1];
		end
		
		for (i = 0; i < 4; i = i + 1) begin
			for (j = 0; j < serdes_ratio_p; j = j + 1) begin
				assign data_o[i][(j*width_p)+:width_p] = fifo_data_vec[((j*num_out_p+i)*width_p)+:width_p];
				assign data_o[i][serdes_ratio_p*width_p+j] = fifo_valid_vec[j*num_out_p+i];
			end		
			always_comb begin
				valid_o[i] = | data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p];
				data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b000;
				if (data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p] == 5'b11111)
					data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b101;
				if (data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p] == 5'b11000)
					data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b010;
				if (data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p] == 5'b00011)
					data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b010;
				if (data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p] == 5'b11100)
					data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b011;
				if (data_o[i][(serdes_ratio_p*width_p)+:serdes_ratio_p] == 5'b00111)
					data_o[i][(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b011;
			end		
		end	
		
	end
	
	// Single channel testing mode
	if (channel_select_p==4'b0001 || channel_select_p==4'b0010 
	|| channel_select_p==4'b0100 || channel_select_p==4'b1000) begin
	
		logic true_ready_i;
		logic [width_serdes_p-1:0] true_data_o;
		logic true_valid_o;
		
		always_comb begin
			true_ready_i = 0;
			valid_o = 0;
			data_o = 0;
			if (channel_select_p==4'b0001) begin
				true_ready_i = ready_i[0];
				valid_o[0] = true_valid_o;
				data_o[0] = true_data_o;
			end
			if (channel_select_p==4'b0010) begin
				true_ready_i = ready_i[1];
				valid_o[1] = true_valid_o;
				data_o[1] = true_data_o;
			end
			if (channel_select_p==4'b0100) begin
				true_ready_i = ready_i[2];
				valid_o[2] = true_valid_o;
				data_o[2] = true_data_o;
			end
			if (channel_select_p==4'b1000) begin
				true_ready_i = ready_i[3];
				valid_o[3] = true_valid_o;
				data_o[3] = true_data_o;
			end
		end
		
		logic fifo_valid_vec;
		logic [num_in_p*width_p/2-1:0] fifo_data_vec;	
		logic full_lo;	
		assign ready_o = (~full_lo) & (~reset);
		
		logic fifo_valid_lo;
		logic fifo_deq_lo;
		logic [num_in_p*width_p-1:0] fifo_data_lo;

		// generate fifos to hold words of input packet

		bsg_async_fifo #
		(.lg_size_p(3)
		,.width_p(num_in_p*width_p))
		ring_packet_fifo
		(.w_clk_i(core_clk)
		,.w_reset_i(reset)
		,.w_enq_i(valid_i & ready_o)
		,.w_data_i(data_i)
		,.w_full_o(full_lo)
		,.r_clk_i(io_master_clk)
		,.r_reset_i(im_reset)
		,.r_deq_i(fifo_deq_lo)
		,.r_data_o(fifo_data_lo)
		,.r_valid_o(fifo_valid_lo));
		
		logic toggle_slow_r, toggle_slow_n;
		
		always @(posedge io_master_clk) begin
			if (im_reset == 1) begin
				toggle_slow_r <= 0;
			end else begin
				toggle_slow_r <= toggle_slow_n;
			end
		end
		
		always_comb begin
			toggle_slow_n = toggle_slow_r;
			fifo_valid_vec = 0;
			fifo_data_vec = 0;
			fifo_deq_lo = 0;
			if (toggle_slow_r == 0) begin
				if ((true_ready_i & fifo_valid_lo) == 1) begin
					fifo_valid_vec = 1;
					fifo_data_vec = fifo_data_lo[0+:num_in_p*width_p/2];
					toggle_slow_n = 1;
				end
			end else begin
				if ((true_ready_i & fifo_valid_lo) == 1) begin
					fifo_valid_vec = 1;
					fifo_data_vec = fifo_data_lo[(num_in_p*width_p/2)+:num_in_p*width_p/2];
					toggle_slow_n = 0;
					fifo_deq_lo = 1;
				end
			end
		end	
		
		genvar j;
		for (j = 0; j < serdes_ratio_p; j = j + 1) begin
			assign true_data_o[(j*width_p)+:width_p] = fifo_data_vec[(j*width_p)+:width_p];
			assign true_data_o[serdes_ratio_p*width_p+j] = fifo_valid_vec;
		end
		
		always_comb begin
			true_valid_o = fifo_valid_vec;
			true_data_o[(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b000;
			if (fifo_valid_vec == 1)
				true_data_o[(serdes_ratio_p*width_p+serdes_ratio_p)+:$clog2(serdes_ratio_p+1)] = 3'b101;
		end			
		
	end

endmodule // bsg_assembler_out
