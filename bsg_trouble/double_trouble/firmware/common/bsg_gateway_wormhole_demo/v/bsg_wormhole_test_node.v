//
// Paul Gao 02/2019
//

module  bsg_wormhole_test_node

 #(parameter width_p = "inv"
  ,parameter x_cord_width_p = "inv"
  ,parameter y_cord_width_p = "inv"
  ,parameter len_width_p = "inv"
  ,parameter length_p = "inv"
  ,parameter reserved_width_p = 0
  ,parameter header_on_lsb_p = 1'b0
  ,localparam reserved_offset_lp = (header_on_lsb_p==0)? width_p-reserved_width_p : 0
  ,localparam x_cord_offset_lp = (header_on_lsb_p==0)? 
                    reserved_offset_lp-x_cord_width_p : reserved_offset_lp+reserved_width_p
  ,localparam y_cord_offset_lp = (header_on_lsb_p==0)?
                    x_cord_offset_lp-y_cord_width_p : x_cord_offset_lp+x_cord_width_p
  ,localparam len_offset_lp = (header_on_lsb_p==0)?
                    y_cord_offset_lp-len_width_p : y_cord_offset_lp+y_cord_width_p)

  (input clk_i
  ,input reset_i
  
  // Configuration
  ,input [x_cord_width_p-1:0] dest_x_i
  ,input [y_cord_width_p-1:0] dest_y_i
  ,input enable_i
  
  // Outgoing traffic
  ,output valid_o // early
  ,output [width_p-1:0] data_o
  ,input ready_i // early
  );
  
  
  // output fifo
  
  logic fifo_valid_i, fifo_ready_o;
  logic [width_p-1:0] fifo_data_i;

  bsg_two_fifo 
  #(.width_p(width_p)) 
  fifo
  (.clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.ready_o(fifo_ready_o)
  ,.data_i(fifo_data_i)
  ,.v_i(fifo_valid_i)

  ,.v_o(valid_o)
  ,.data_o(data_o)
  ,.yumi_i(valid_o & ready_i));
  
  
  // state machine
  
  logic [3:0] state_r, state_n;
  logic [width_p-1:0] counter_r, counter_n;
  
  always @(posedge clk_i) begin
	if (reset_i) begin
		state_r <= 0;
		counter_r <= 0;
	end else begin
		state_r <= state_n;
		counter_r <= counter_n;
	end
  end
  
  
  always @(*) begin
  
	state_n = state_r;
	counter_n = counter_r;
	
	fifo_valid_i = 0;
	fifo_data_i = counter_r;
	
	if (state_r == 0) begin
	
		if (enable_i) begin
			fifo_valid_i = 1;
			fifo_data_i[x_cord_offset_lp+:x_cord_width_p] = dest_x_i;
            fifo_data_i[y_cord_offset_lp+:y_cord_width_p] = dest_y_i;
            fifo_data_i[len_offset_lp+:len_width_p] = length_p;
			if (fifo_ready_o) begin
                if (length_p != 0) begin
                    counter_n = length_p-1;
                    state_n = 1;
                end
			end
		end
		
	end
	else if (state_r == 1) begin
		
		fifo_valid_i = 1;
		fifo_data_i = counter_r;
		if (fifo_ready_o) begin
			if (counter_r == 0) begin
				state_n = 0;
			end else begin
                counter_n = counter_r - 1;
            end
		end
		
	end
	
  end
  
  

endmodule



























