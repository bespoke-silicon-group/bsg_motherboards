
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_tag_control.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_tag_control

   #(parameter num_clk_p="inv")
   
	(input reset_i
	,input enable_i
	,input clk_i
	// Command data
	,input [31:0] data_i
	// microblaze control
	,input valid_mb_i
	,input [num_clk_p-1:0] mb_control_i
	,input mb_isDiv_i
	// clock control
	,output logic [1:0] clk_set_o [num_clk_p-1:0]
	,output logic [num_clk_p-1:0] clk_reset_o
	// tag enable control
	,output logic tag_tms_o);

	logic [1:0] clk_set_r [num_clk_p-1:0];
    logic [1:0] clk_set_n [num_clk_p-1:0];
	logic [num_clk_p-1:0] clk_reset_r, clk_reset_n;
	logic tag_tms_r, tag_tms_n;
	
	assign clk_set_o = clk_set_r;
	assign clk_reset_o = clk_reset_r;
	assign tag_tms_o = tag_tms_r;
	
    integer i;
    
	always @(posedge clk_i)
	begin
        for (i = 0; i < num_clk_p; i++) begin
            if (reset_i) begin
                clk_set_r[i] <= 2'b11;
                clk_reset_r[i] <= 1'b0;
            end else begin
                clk_set_r[i] <= clk_set_n[i];
                clk_reset_r[i] <= clk_reset_n[i];
            end
        end
        if (reset_i) begin
            tag_tms_r <= 1'b0;
        end else begin
            tag_tms_r <= tag_tms_n;
        end
	end
	
	always_comb begin
    
        for (i = 0; i < num_clk_p; i++) begin
            clk_set_n[i] = clk_set_r[i];
            clk_reset_n[i] = clk_reset_r[i];
        end
		tag_tms_n = tag_tms_r;
        
		if (enable_i == 1'b1) begin
        
            for (i = 0; i < num_clk_p; i++) begin
                if (data_i[26+:6] == i) begin
                    if (data_i[25])
                        clk_set_n[i][1] = 1'b1;
                    if (data_i[24])
                        clk_set_n[i][1] = 1'b0;
                    if (data_i[23])
                        clk_set_n[i][0] = 1'b1;
                    if (data_i[22])
                        clk_set_n[i][0] = 1'b0;
                    if (data_i[21])
                        clk_reset_n[i] = 1'b1;
                    if (data_i[20])
                        clk_reset_n[i] = 1'b0;
                end
            end
            if (data_i[19])
                tag_tms_n = 1'b1;
            if (data_i[18])
                tag_tms_n = 1'b0; 
                
		end
	end
	
endmodule
