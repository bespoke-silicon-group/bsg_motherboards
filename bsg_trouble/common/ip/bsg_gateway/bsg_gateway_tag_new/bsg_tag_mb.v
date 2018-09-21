
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_tag_mb.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_tag_mb

   #(parameter num_clk_p="inv")
   
	(input reset_i
	,input clk_i
	// input from MB
    ,input mb_control_i
    ,input [num_clk_p-1:0] mb_select_i
    ,input [7:0] mb_counter_i
	,input [7:0] mb_load_i
	,input [2:0] mb_mode_i
    // output to bsg_tag
    ,output mb_valid_o
    ,output [31:0] mb_data_o
    ,input mb_yumi_i);

    logic fifo_in_valid;
    logic [31:0] fifo_in_data;
    logic fifo_in_ready;
    
    logic fifo_out_valid;
    logic [31:0] fifo_out_data;
    logic fifo_out_yumi;
    
    assign mb_valid_o = fifo_out_valid;
    assign mb_data_o = fifo_out_data;
    assign fifo_out_yumi = mb_yumi_i;
    
    bsg_fifo_1r1w_small 
    #(.width_p(32)
    ,.els_p(32)
    ,.ready_THEN_valid_p(1))
    fifo1
    (.clk_i  (clk_i)
    ,.reset_i(reset_i)
    // input side
    ,.ready_o(fifo_in_ready)
    ,.data_i (fifo_in_data) 
    ,.v_i    (fifo_in_valid)
    // output side
    ,.v_o    (fifo_out_valid)
    ,.data_o (fifo_out_data)
    ,.yumi_i (fifo_out_yumi));
    
    logic [7:0] counter_r, counter_n;
    
    always @(posedge clk_i) begin
        if (reset_i) begin
            counter_r <= 0;
        end else begin
            counter_r <= counter_n;
        end
    end
    
    always_comb begin
    
        counter_n = counter_r;
        
        fifo_in_valid = 0;
        fifo_in_data[0] = (mb_mode_i == 2)? mb_load_i[0] : 0;
        fifo_in_data[1+:8] = (mb_mode_i == 1)? mb_load_i[7:0] : 0;
        fifo_in_data[9+:5] = (mb_mode_i == 0)? mb_load_i[4:0] : 0;
        fifo_in_data[14+:4] = (mb_mode_i == 2)? 1 : ((mb_mode_i == 1)? 9 : 5);
        fifo_in_data[18] = 1;
        fifo_in_data[19+:3] = mb_mode_i;
        fifo_in_data[22+:4] = mb_mode_i + 1;
        fifo_in_data[26+:6] = mb_select_i;
        
        if (counter_r != mb_counter_i & mb_control_i & fifo_in_ready) begin
            fifo_in_valid = 1;
            counter_n = counter_r + 1;
        end
    
    end
	
endmodule

































