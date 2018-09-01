
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_tag_output.v
//
// Author: Paul Gao
//------------------------------------------------------------

// Library files
`include "bsg_tag.vh"
`include "bsg_clk_gen.vh"

module bsg_tag_output

   #(parameter num_clk_p="inv")

	(input reset_i
	,input enable_i
	,input clk_i
	// Command data in
	,input [31:0] data_i
	// microblaze control
	,input valid_mb_i
	,input [num_clk_p-1:0] mb_control_i
	,input [4:0] mb_osc_i
	,input [7:0] mb_div_i
	// Ready signal out
	,output logic ready_r_o
	// Output bit
	,output logic tag_tdi_o);
	
	
	/* define param begin */
	
	// These are the same as definition in "bsg_two_manycore_vanilla_clk_gen/bsg_chip.v"
	localparam num_adgs_p = 1;
	localparam ds_width_p = 8;
	localparam tag_els_p = 3*num_clk_p;
	
	`declare_bsg_clk_gen_osc_tag_payload_s(num_adgs_p)
	`declare_bsg_clk_gen_ds_tag_payload_s(ds_width_p)
	localparam max_payload_length_lp = `BSG_MAX($bits(bsg_clk_gen_osc_tag_payload_s),$bits(bsg_clk_gen_ds_tag_payload_s));
	localparam lg_max_payload_length_lp = $clog2(max_payload_length_lp+1);
	`declare_bsg_tag_header_s(tag_els_p,lg_max_payload_length_lp)
	
	bsg_tag_header_s ds_tag_header;
	bsg_tag_header_s osc_tag_header;
    bsg_tag_header_s osc_trigger_tag_header;
	bsg_clk_gen_osc_tag_payload_s osc_tag_payload;
	bsg_clk_gen_ds_tag_payload_s ds_tag_payload;
    logic osc_trigger_tag_payload;
	
	localparam osc_pkt_size_lp = $bits(bsg_tag_header_s)+$bits(bsg_clk_gen_osc_tag_payload_s)+1+1;
	wire [osc_pkt_size_lp-1:0] osc_pkt = { 1'b0, osc_tag_payload, osc_tag_header,1'b1 };

	localparam ds_pkt_size_lp  = $bits(bsg_tag_header_s)+$bits(bsg_clk_gen_ds_tag_payload_s)+1+1;
	wire [ds_pkt_size_lp-1:0]  ds_pkt  = { 1'b0, ds_tag_payload, ds_tag_header,1'b1 };
	
    localparam osc_trigger_pkt_size_lp  = $bits(bsg_tag_header_s)+1+1+1;
    wire [osc_trigger_pkt_size_lp-1:0] osc_trigger_pkt 
                                       = { 1'b0, osc_trigger_tag_payload, osc_trigger_tag_header, 1'b1};
                                      
	/* define param end */
	
	/* map data to different packets begin */
	
    logic [`BSG_SAFE_CLOG2(tag_els_p)-1:0] id_lo;
	logic [3:0] sub_op_lo;
    logic [2:0] mode_lo;
	logic data_not_reset_lo;
	logic [3:0] cycle_lo;
	logic [4:0] osc_payload_lo;
	logic [7:0] ds_payload_lo;
	logic ds_payload_reset_lo;
	
    integer i;
    always_comb begin
    
        id_lo = 0;
        sub_op_lo = data_i[22+:4];
        mode_lo = data_i[19+:3];
        data_not_reset_lo = data_i[18+:1];
        cycle_lo = data_i[14+:4];
        osc_payload_lo = data_i[9+:5];
        ds_payload_lo = data_i[1+:8];
        ds_payload_reset_lo = data_i[0+:1];
        for (i = 0; i < num_clk_p; i++) begin
            if (data_i[26+:6] == i)
                id_lo = i*3 + mode_lo;
        end
        
    end
	
	assign osc_tag_header.nodeID = id_lo[`BSG_SAFE_CLOG2(tag_els_p)-1:0];
	assign osc_tag_header.data_not_reset = data_not_reset_lo;
	assign osc_tag_header.len = cycle_lo[lg_max_payload_length_lp-1:0];
	
	assign ds_tag_header.nodeID = id_lo[`BSG_SAFE_CLOG2(tag_els_p)-1:0];
	assign ds_tag_header.data_not_reset = data_not_reset_lo;
	assign ds_tag_header.len = cycle_lo[lg_max_payload_length_lp-1:0];
	
    assign osc_trigger_tag_header.nodeID = id_lo[`BSG_SAFE_CLOG2(tag_els_p)-1:0];
	assign osc_trigger_tag_header.data_not_reset = data_not_reset_lo;
	assign osc_trigger_tag_header.len = cycle_lo[lg_max_payload_length_lp-1:0];
    
	// Microblaze control
	//logic [4:0] osc_preSelect = mb_osc_i;
	//logic [7:0] div_preSelect = mb_div_i;
	
	assign osc_tag_payload = osc_payload_lo[num_adgs_p+4-1:0];
	assign ds_tag_payload.val = ds_payload_lo[ds_width_p-1:0];
	assign ds_tag_payload.reset = ds_payload_reset_lo;
    assign osc_trigger_tag_payload = ds_payload_reset_lo;
	
	/* map data to different packets end */
	
	reg [8:0] counter_r, counter_n;
	reg ready_r, ready_n;
	reg [8:0] cycle_r, cycle_n;
	reg tag_tdi_r, tag_tdi_n;
	reg [31:0] shift_r, shift_n;
	
	assign ready_r_o = ready_r;
	assign tag_tdi_o = tag_tdi_r;
	assign counter_n = (ready_r == 1'b0)? (counter_r + 8'd1) : 8'd0;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			counter_r <= 8'd0;
			ready_r <= 1'b1;
			cycle_r <= 8'd0;
			tag_tdi_r <= 1'b0;
			shift_r <= 32'd0;
		end else begin
			counter_r <= counter_n;
			ready_r <= ready_n;
			cycle_r <= cycle_n;
			tag_tdi_r <= tag_tdi_n;
			shift_r <= shift_n;
		end
	end
	
	always_comb
	begin
	
		cycle_n = cycle_r;
		ready_n = ready_r;
		tag_tdi_n = 1'b0;
		shift_n = shift_r;
		
		// Send out different types of new packet
		if ((ready_r == 1'b1) & (enable_i == 1'b1)) begin
			ready_n = 1'b0;
			if (sub_op_lo == 4'd1) begin
				cycle_n = osc_pkt_size_lp;
				shift_n[osc_pkt_size_lp-1:0] = osc_pkt[osc_pkt_size_lp-1:0];
			end
			if (sub_op_lo == 4'd2) begin
				cycle_n = ds_pkt_size_lp;
				shift_n[ds_pkt_size_lp-1:0] = ds_pkt[ds_pkt_size_lp-1:0];
			end
			if (sub_op_lo == 4'd3) begin
				cycle_n = osc_trigger_pkt_size_lp;
				shift_n[osc_trigger_pkt_size_lp-1:0] = osc_trigger_pkt[osc_trigger_pkt_size_lp-1:0];
			end
            if (sub_op_lo == 4'd4) begin
				cycle_n = 8'd1;
				shift_n[0] = 1'b1;
			end
		end
		
		// Continue sending existing packet
		if (ready_r == 1'b0) begin
			if (counter_r == cycle_r) begin
				ready_n = 1'b1;
			end else begin
				tag_tdi_n = shift_r[0];
				shift_n = shift_r >> 1;
			end
		end
		
	end
	
endmodule
