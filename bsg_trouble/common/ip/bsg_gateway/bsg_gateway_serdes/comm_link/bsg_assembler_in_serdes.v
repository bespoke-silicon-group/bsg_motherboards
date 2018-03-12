//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_assembler_in_serdes.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_assembler_in_serdes #

	(parameter width_p="inv"
	,parameter num_in_p="inv"
	,parameter num_out_p="inv"
	,parameter in_channel_count_mask_p=(1 << (num_in_p-1))
	,parameter channel_select_p=(1 << (num_in_p-1)))
	
	( input clk
	, input  reset
	, input  calibration_done_i

	, input fast_reset
	, input fast_clk
	, input fast_calibration_done_i

	, input         [num_in_p*2-1:0] valid_i
	, input         [width_p-1:0] data_i [num_in_p*2-1:0]
	, output logic  [num_in_p*2-1:0] yumi_o

	, output                          valid_o
	, output  [num_out_p*width_p-1:0] data_o
	, input                           yumi_i

	);
	
   integer i, j;
   genvar k, m;
   
   logic valid_o_lo, not_yumi_i_lo;
   logic [num_out_p*width_p-1:0] data_o_lo;
   
   logic [num_out_p/2-1:0] fifo_enq_vec, fifo_not_full_vec, fifo_valid_vec;
   logic [2*width_p-1:0] fifo_data_vec [num_out_p/2-1:0];
   
   logic [num_in_p-1:0] valid_lo, yumi_lo;
   logic [2*width_p-1:0] data_lo [num_in_p-1:0];
   
   // Single channel testing mode
   for (m=0; m<num_in_p; m++) begin
   
	   if (channel_select_p == (1 << m)) begin
	   
			for (k=0; k<num_in_p; k++) begin
				assign valid_lo[k] = valid_i[k+num_in_p] & valid_i[k];
				assign data_lo[k] = {data_i[k+num_in_p], data_i[k]};
				assign yumi_o[k+num_in_p] = yumi_lo[k];
				assign yumi_o[k] = yumi_lo[k];
			end

			logic [$clog2(num_in_p)-1:0] assem_toggle_r, assem_toggle_n;
			logic [$clog2(num_out_p/2)-1:0] assem_stage_r, assem_stage_n;
			
			logic middle_valid_li, middle_ready_lo;
			logic [num_in_p*2*width_p+num_in_p-1:0] middle_data_li;
			
			logic middle_valid_lo, middle_yumi_li;
			logic [num_in_p*2*width_p+num_in_p-1:0] middle_data_lo;
			
			always @(posedge fast_clk) begin
				if (fast_reset) begin
					assem_toggle_r <= m;
					assem_stage_r <= 0;
				end else begin
					assem_toggle_r <= assem_toggle_n;
					assem_stage_r <= assem_stage_n;
				end
			end
			
			always_comb begin
			
				assem_toggle_n = assem_toggle_r;
				yumi_lo = 0;
				middle_data_li[num_in_p*2*width_p+:num_in_p] = 0;
				middle_valid_li = 0;
				
				for (i=0; i<num_in_p; i=i+1) begin
					if (assem_toggle_r == i) begin
						for (j=0; j<num_in_p; j++) begin
							middle_data_li[(j*2*width_p)+:2*width_p] = data_lo[(i+j)%num_in_p];
						end
						if (middle_ready_lo) begin
						
							if (valid_lo[(i+0)%num_in_p]) begin
								middle_valid_li = 1;
								middle_data_li[num_in_p*2*width_p+0] = 1;
								yumi_lo[(i+0)%num_in_p] = 1;
								if (valid_lo[(i+1)%num_in_p]) begin
									yumi_lo[(i+1)%num_in_p] = 1;
									if (valid_lo[(i+2)%num_in_p]) begin
										yumi_lo[(i+2)%num_in_p] = 1;
										if (valid_lo[(i+3)%num_in_p]) begin
											yumi_lo[(i+3)%num_in_p] = 1;
										end
									end
								end
								assem_toggle_n = (i+0)%num_in_p;
							end

						end
					end
				end
			end
			
			bsg_two_fifo
			#(.width_p(num_in_p*2*width_p+num_in_p))
			middle_fifo
			(.clk_i  (fast_clk)
			,.reset_i(fast_reset)
			,.ready_o(middle_ready_lo)
			,.v_i    (middle_valid_li)
			,.data_i (middle_data_li)
			,.v_o    (middle_valid_lo)
			,.data_o (middle_data_lo)
			,.yumi_i (middle_yumi_li)
			);
			
			always_comb begin
				
				assem_stage_n = assem_stage_r;
				middle_yumi_li = 0;
				fifo_enq_vec = 0;
				
				for (j=0; j<(num_out_p/2); j++) begin
				
					if (assem_stage_r == j) begin
						for (i=0; i<num_in_p; i++) begin
							fifo_data_vec[(j+i)%(num_out_p/2)] = middle_data_lo[i*2*width_p+:2*width_p];
						end
						for (i=num_in_p; i<num_out_p/2; i++) begin
							fifo_data_vec[(j+i)%(num_out_p/2)] = 0;
						end
						
						if (middle_valid_lo&fifo_not_full_vec[(j+num_in_p-1)%(num_out_p/2)]) begin
							middle_yumi_li = 1;
							for (i=0; i<num_in_p; i++) begin
								fifo_enq_vec[(j+i)%(num_out_p/2)] = middle_data_lo[num_in_p*2*width_p+i];
							end

							if (middle_data_lo[num_in_p*2*width_p+0]) begin
								if (middle_data_lo[num_in_p*2*width_p+1]) begin
									if (middle_data_lo[num_in_p*2*width_p+2]) begin
										if (middle_data_lo[num_in_p*2*width_p+3]) begin
											assem_stage_n = (j+4)%(num_out_p/2);
										end else begin
											assem_stage_n = (j+3)%(num_out_p/2);
										end
									end else begin
										assem_stage_n = (j+2)%(num_out_p/2);
									end
								end else begin
									assem_stage_n = (j+1)%(num_out_p/2);
								end
							end

						end
					end
				
				end
				
			end			
			
			for (k = 0; k < num_out_p/2; k=k+1)
			 begin : fifos
				
				bsg_fifo_1r1w_small #
				(.width_p(2*width_p)
				,.els_p(3))
				ring_packet_fifo_original
				(.clk_i  (fast_clk)
				,.reset_i(fast_reset)
				,.ready_o(fifo_not_full_vec[k])
				,.v_i    (fifo_enq_vec[k])
				,.data_i (fifo_data_vec[k])
				,.v_o    (fifo_valid_vec[k])
				,.data_o (data_o_lo[(2*width_p*k)+:(2*width_p)])
				,.yumi_i ((~not_yumi_i_lo)&valid_o_lo)
				);
			
			 end 
			 
		end
	end
   
   // all channels full speed mode
   if (channel_select_p == (1<<num_in_p)-1) begin
   
      for (k=0; k<num_in_p; k++) begin
		assign valid_lo[k] = valid_i[2*k+1] & valid_i[2*k];
		assign data_lo[k] = {data_i[2*k+1], data_i[2*k]};
		assign yumi_o[2*k+1] = yumi_lo[k];
		assign yumi_o[2*k] = yumi_lo[k];
	  end

		logic [$clog2(num_in_p)-1:0] assem_toggle_r, assem_toggle_n;
		logic [$clog2(num_out_p/2)-1:0] assem_stage_r, assem_stage_n;
		
		logic middle_valid_li, middle_ready_lo;
		logic [num_in_p*2*width_p+num_in_p-1:0] middle_data_li;
		
		logic middle_valid_lo, middle_yumi_li;
		logic [num_in_p*2*width_p+num_in_p-1:0] middle_data_lo;
		
		always @(posedge fast_clk) begin
			if (fast_reset) begin
				assem_toggle_r <= 0;
				assem_stage_r <= 0;
			end else begin
				assem_toggle_r <= assem_toggle_n;
				assem_stage_r <= assem_stage_n;
			end
		end
		
		always_comb begin
		
			assem_toggle_n = assem_toggle_r;
			yumi_lo = 0;
			middle_data_li[num_in_p*2*width_p+:num_in_p] = 0;
			middle_valid_li = 0;
			
			for (i=0; i<num_in_p; i=i+1) begin
				if (assem_toggle_r == i) begin
					for (j=0; j<num_in_p; j++) begin
						middle_data_li[(j*2*width_p)+:2*width_p] = data_lo[(i+j)%num_in_p];
					end
					if (middle_ready_lo) begin
					
						if (valid_lo[(i+0)%num_in_p]) begin
							middle_valid_li = 1;
							middle_data_li[num_in_p*2*width_p+0] = 1;
							yumi_lo[(i+0)%num_in_p] = 1;
							if (valid_lo[(i+1)%num_in_p]) begin
								middle_data_li[num_in_p*2*width_p+1] = 1;
								yumi_lo[(i+1)%num_in_p] = 1;
								if (valid_lo[(i+2)%num_in_p]) begin
									middle_data_li[num_in_p*2*width_p+2] = 1;
									yumi_lo[(i+2)%num_in_p] = 1;
									if (valid_lo[(i+3)%num_in_p]) begin
										middle_data_li[num_in_p*2*width_p+3] = 1;
										yumi_lo[(i+3)%num_in_p] = 1;
										assem_toggle_n = (i+4)%num_in_p;
									end else begin
										assem_toggle_n = (i+3)%num_in_p;
									end
								end else begin
									assem_toggle_n = (i+2)%num_in_p;
								end
							end else begin
								assem_toggle_n = (i+1)%num_in_p;
							end
						end

					end
				end
			end
		end
		
		bsg_two_fifo
		#(.width_p(num_in_p*2*width_p+num_in_p)
		 ,.allow_enq_deq_on_full_p(0))
		middle_fifo
		(.clk_i  (fast_clk)
		,.reset_i(fast_reset)
		,.ready_o(middle_ready_lo)
		,.v_i    (middle_valid_li)
		,.data_i (middle_data_li)
		,.v_o    (middle_valid_lo)
		,.data_o (middle_data_lo)
		,.yumi_i (middle_yumi_li)
		);
		
		always_comb begin
			
			assem_stage_n = assem_stage_r;
			middle_yumi_li = 0;
			fifo_enq_vec = 0;
			
			for (j=0; j<(num_out_p/2); j++) begin
			
				if (assem_stage_r == j) begin
					for (i=0; i<num_in_p; i++) begin
						fifo_data_vec[(j+i)%(num_out_p/2)] = middle_data_lo[i*2*width_p+:2*width_p];
					end
					for (i=num_in_p; i<num_out_p/2; i++) begin
						fifo_data_vec[(j+i)%(num_out_p/2)] = 0;
					end
					
					if (middle_valid_lo&fifo_not_full_vec[(j+num_in_p-1)%(num_out_p/2)]) begin
						middle_yumi_li = 1;
						for (i=0; i<num_in_p; i++) begin
							fifo_enq_vec[(j+i)%(num_out_p/2)] = middle_data_lo[num_in_p*2*width_p+i];
						end

						if (middle_data_lo[num_in_p*2*width_p+0]) begin
							if (middle_data_lo[num_in_p*2*width_p+1]) begin
								if (middle_data_lo[num_in_p*2*width_p+2]) begin
									if (middle_data_lo[num_in_p*2*width_p+3]) begin
										assem_stage_n = (j+4)%(num_out_p/2);
									end else begin
										assem_stage_n = (j+3)%(num_out_p/2);
									end
								end else begin
									assem_stage_n = (j+2)%(num_out_p/2);
								end
							end else begin
								assem_stage_n = (j+1)%(num_out_p/2);
							end
						end

					end
				end
			
			end
			
		end
		
		
		for (k = 0; k < num_out_p/2; k=k+1)
		 begin : fifos

			bsg_fifo_1r1w_small #
			(.width_p(2*width_p)
			,.els_p(3))
			ring_packet_fifo_original
			(.clk_i  (fast_clk)
			,.reset_i(fast_reset)
			,.ready_o(fifo_not_full_vec[k])
			,.v_i    (fifo_enq_vec[k])
			,.data_i (fifo_data_vec[k])
			,.v_o    (fifo_valid_vec[k])
			,.data_o (data_o_lo[(2*width_p*k)+:(2*width_p)])
			,.yumi_i ((~not_yumi_i_lo)&valid_o_lo)
			);
			
		 end 
		
   
   end

	assign valid_o_lo = (& fifo_valid_vec) & fast_calibration_done_i;
   
	bsg_async_fifo #
	(.lg_size_p(3)
	,.width_p(num_out_p*width_p))
	ring_packet_fifo
	(.w_clk_i(fast_clk)
	,.w_reset_i(fast_reset)
	,.w_enq_i(valid_o_lo&(~not_yumi_i_lo))
	,.w_data_i(data_o_lo)
	,.w_full_o(not_yumi_i_lo)
	,.r_clk_i(clk)
	,.r_reset_i(reset)
	,.r_deq_i(yumi_i&valid_o)
	,.r_data_o(data_o)
	,.r_valid_o(valid_o));

endmodule 

