//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_tag.v
//
// Author: Paul Gao
//------------------------------------------------------------

module  bsg_gateway_tag

  #(parameter ring_width_p="inv"
   ,parameter num_clk_p="inv")

	(input clk_i
	,input reset_i
	,output done_o
	// microblaze control
    ,input mb_control_i
	,input [num_clk_p-1:0] mb_select_i
    ,input [7:0] mb_counter_i
	,input [7:0] mb_load_i
	,input [2:0] mb_mode_i
	// CLK control
	,output [1:0] clk_set_o [num_clk_p-1:0]
	,output [num_clk_p-1:0] clk_reset_o
	// Communication pins
	,output tag_tdi_o
	,output tag_tms_o
	// LED indicator
	,output logic test_output
   );
   
	// Deal with the async reset issue
	logic reset_lo;
	bsg_sync_sync #
	(.width_p(1))
	reset_ss
	(.oclk_i(clk_i)
	,.iclk_data_i(reset_i)
	,.oclk_data_o(reset_lo));
   
	// interface to fsb_trace_replay
	logic v_lo;
	logic [ring_width_p-1:0] data_lo;
	logic yumi_li;   // late

	// guaranteed not to exceed
	localparam rom_addr_width_lp=16;
	localparam trace_width_lp = ring_width_p+4;

	wire [trace_width_lp-1:0  ]   rom_data_lo;
	wire [rom_addr_width_lp-1:0]  rom_addr_li;

	// for wait cycle
	logic valid_wait_lo;
	logic [31:0] cycle_wait_lo;
	logic ready_wait_li;

	// For tag transmit
	logic valid_tag_lo;
	logic [31:0] data_tag_lo;
	logic ready_tag_li;

	// For tag control
	logic valid_control_lo;
	logic [31:0] data_control_lo;

	// conversion from fsb_trace_replay to bsg_tag modules
	always_comb
	begin
		valid_wait_lo = (v_lo & data_lo[ring_width_p-1] & yumi_li);
		valid_tag_lo = (v_lo & data_lo[ring_width_p-2] & yumi_li);
		valid_control_lo = (v_lo & data_lo[ring_width_p-3] & yumi_li);
		cycle_wait_lo = data_lo[31:0];
		data_tag_lo = data_lo[31:0];
		data_control_lo = data_lo[31:0];
		yumi_li = (ready_wait_li & ready_tag_li);
	end
   
   // trace replay module
   bsg_fsb_node_trace_replay
	#(.ring_width_p(ring_width_p)
	,.rom_addr_width_p(rom_addr_width_lp)) 
	tr
	(.clk_i(clk_i)
	,.reset_i(reset_lo)
	,.en_i(1'b1)

    ,.v_i()
    ,.data_i()
    ,.ready_o()

	,.v_o(v_lo)
	,.data_o(data_lo)
	,.yumi_i(yumi_li)

	,.rom_addr_o(rom_addr_li)
	,.rom_data_i(rom_data_lo)

	,.done_o(done_o)
    ,.error_o()
    );
	
	// ROM that contains commands
	bsg_gateway_tag_rom 
	#(.width_p(trace_width_lp)
	,.addr_width_p(rom_addr_width_lp))
	rom
	(.addr_i (rom_addr_li)
	,.data_o(rom_data_lo));
	
	// For delay cycles
	wait_cycle_32 w_cycle
	(.reset_i(reset_lo)
	,.enable_i(valid_wait_lo)
	,.clk_i(clk_i)
	,.cycle_i(cycle_wait_lo)
	,.ready_r_o(ready_wait_li)
	,.test_o(test_output));
    
    
    // For MB control
    logic mb_valid_lo;
    logic [31:0] mb_data_lo;
    logic mb_yumi_lo;
    
    bsg_tag_mb
    #(.num_clk_p(num_clk_p))
    mb_control
    (.reset_i(reset_lo)
    ,.clk_i(clk_i)
    // input from MB
    ,.mb_control_i(mb_control_i)
    ,.mb_select_i(mb_select_i)
    ,.mb_counter_i(mb_counter_i)
	,.mb_load_i(mb_load_i)
	,.mb_mode_i(mb_mode_i)
    // output to bsg_tag
    ,.mb_valid_o(mb_valid_lo)
    ,.mb_data_o(mb_data_lo)
    ,.mb_yumi_i(mb_yumi_lo));
    
	
	// For programming bsg_tag
  bsg_tag_output 
   #(.num_clk_p(num_clk_p))
  t_output
	(.reset_i(reset_lo)
	,.enable_i(valid_tag_lo)
	,.clk_i(clk_i)
	,.data_i(data_tag_lo)
	,.mb_valid_i(mb_valid_lo)
	,.mb_data_i(mb_data_lo)
	,.mb_yumi_o(mb_yumi_lo)
	,.ready_r_o(ready_tag_li)
	,.tag_tdi_o(tag_tdi_o));
	
	// For output pins control
  bsg_tag_control
   #(.num_clk_p(num_clk_p))
  t_control
	(.reset_i(reset_lo)
	,.enable_i(valid_control_lo)
	,.clk_i(clk_i)
	,.data_i(data_control_lo)
	,.clk_set_o(clk_set_o)
	,.clk_reset_o(clk_reset_o)
	,.tag_tms_o(tag_tms_o));

endmodule

