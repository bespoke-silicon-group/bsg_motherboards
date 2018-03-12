//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_pll.v
//
// Author: Paul Gao
//------------------------------------------------------------

module  bsg_gateway_pll

  #(parameter ring_width_p="inv")

	(input clk_i
	,input first_reset_i
	,input reset_i
	,output done_o
	// microblaze control
	,input mb_master_reset_i
	,input mb_pll_reset_i
	,input [3:0] mb_pll_sel_i
	,input [7:0] mb_pll_addr_i
	,input [15:0] mb_pll_data_i
	// SPI output
	,output [2:0] spi_cs_o
	,output [2:0] spi_out_o
	,output spi_clk_o
	,output [2:0] spi_rst_o
	// LED indicator
	,output logic test_output
   );
   
   genvar i;
   
	// Deal with the async reset issue
	logic reset_lo, first_reset_lo;
	bsg_sync_sync #
	(.width_p(1))
	first_reset_ss
	(.oclk_i(clk_i)
	,.iclk_data_i(first_reset_i)
	,.oclk_data_o(first_reset_lo));
	bsg_sync_sync #
	(.width_p(1))
	reset_ss
	(.oclk_i(clk_i)
	,.iclk_data_i(reset_i)
	,.oclk_data_o(reset_lo));
   
	// PLL init signal
	logic [2:0] pll_init_done_lo;
	logic pll_not_done_lo;
	assign pll_not_done_lo = ~(& pll_init_done_lo);
   
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

	// For spi transmit
	logic [2:0] valid_spi_lo;
	logic [2:0] ready_spi_li;
	logic [2:0] mode_spi_lo;

	// For tag control
	logic valid_control_lo;
	logic [31:0] data_control_lo;

	// conversion from fsb_trace_replay to bsg_tag modules
	always_comb begin
		valid_wait_lo = (v_lo & (data_lo[(ring_width_p-4)+:4]==4'b1000) & yumi_li);
		valid_control_lo = (v_lo & (data_lo[(ring_width_p-4)+:4]==4'b0100) & yumi_li);
		mode_spi_lo = 0;
		if(data_lo[(ring_width_p-4)+:4] == 4'b0000) begin
			mode_spi_lo = 3'b111;
		end
		if(data_lo[(ring_width_p-4)+:4] == 4'b0001) begin
			mode_spi_lo = 3'b001;
		end
		if(data_lo[(ring_width_p-4)+:4] == 4'b0010) begin
			mode_spi_lo = 3'b010;
		end
		if(data_lo[(ring_width_p-4)+:4] == 4'b0011) begin
			mode_spi_lo = 3'b100;
		end
		valid_spi_lo[2] = (v_lo & mode_spi_lo[2] & yumi_li);
		valid_spi_lo[1] = (v_lo & mode_spi_lo[1] & yumi_li);
		valid_spi_lo[0] = (v_lo & mode_spi_lo[0] & yumi_li);
		cycle_wait_lo = data_lo[31:0];
		data_control_lo = data_lo[31:0];
		yumi_li = (ready_wait_li & (&ready_spi_li));
	end
	
	
	// Microblaze Control
	logic mb_master_reset_lo;
	logic mb_pll_reset_lo;
	logic [3:0] mb_pll_sel_lo;
	logic [7:0] mb_pll_addr_lo;
	logic [15:0] mb_pll_data_lo;
	
	assign mb_master_reset_lo = mb_master_reset_i;
	assign mb_pll_reset_lo = mb_pll_reset_i;
	assign mb_pll_sel_lo = mb_pll_sel_i;
	assign mb_pll_addr_lo = mb_pll_addr_i;
	assign mb_pll_data_lo = mb_pll_data_i;
	
	logic mb_spi_master_reset_lo;
	logic mb_spi_reset_lo;
	logic [3:0] mb_spi_sel_lo;
	logic [7:0] mb_spi_addr_lo;
	logic [15:0] mb_spi_data_lo;
	
	always @(posedge clk_i) begin
		mb_spi_master_reset_lo <= mb_master_reset_lo;
		mb_spi_reset_lo <= mb_pll_reset_lo;
		mb_spi_sel_lo <= mb_pll_sel_lo;
		mb_spi_addr_lo <= mb_pll_addr_lo;
		mb_spi_data_lo <= mb_pll_data_lo;
	end
   
   
   // trace replay module
   bsg_fsb_node_trace_replay
	#(.ring_width_p(ring_width_p)
	,.rom_addr_width_p(rom_addr_width_lp)) 
	tr
	(.clk_i(clk_i)
	,.reset_i(reset_lo | pll_not_done_lo | mb_spi_master_reset_lo)
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
	bsg_gateway_pll_rom 
	#(.width_p(trace_width_lp)
	,.addr_width_p(rom_addr_width_lp))
	pll_rom
	(.addr_i (rom_addr_li)
	,.data_o(rom_data_lo));
	
	
	// Trace replay for 3 PLLs
	logic [79:0] pll_rom_data_lo [2:0];
	logic [7:0] pll_rom_addr_li [2:0];
	
	for (i=0; i<3; i++) begin
		logic pll_v_lo;
		logic [15:0] pll_data_lo;
	
		bsg_fsb_node_trace_replay
		#(.ring_width_p(16)
		,.rom_addr_width_p(8)) 
		tr_pll_init
		(.clk_i(clk_i)
		,.reset_i(first_reset_lo)
		,.en_i(1'b1)

		,.v_i()
		,.data_i()
		,.ready_o()

		,.v_o(pll_v_lo)
		,.data_o(pll_data_lo)
		,.yumi_i(1'b1)

		,.rom_addr_o(pll_rom_addr_li[i])
		,.rom_data_i({pll_rom_data_lo[i][76+:4], pll_rom_data_lo[i][52+:16]})

		,.done_o(pll_init_done_lo[i])
		,.error_o()
		);
	
		bsg_gateway_pll_spi spi_block
		(.reset_i(first_reset_lo)
		,.clk_i(clk_i)
		,.init_en_i(pll_v_lo)
		,.init_data_i(pll_data_lo)
		,.spi_en_i(valid_spi_lo[i])
		,.spi_ready_o(ready_spi_li[i])
		,.spi_cs_o(spi_cs_o[i])
		,.spi_out_o(spi_out_o[i])
		,.mb_en_i(mb_spi_sel_lo == (i+1))
		,.mb_reset_i(mb_spi_reset_lo)
		,.mb_addr_i(mb_spi_addr_lo)
		,.mb_data_i(mb_spi_data_lo));
	end
	
	bsg_gateway_pll_1_rom 
	#(.width_p(80)
	,.addr_width_p(8))
	pll_1_rom
	(.addr_i(pll_rom_addr_li[0])
	,.data_o(pll_rom_data_lo[0]));
	
	bsg_gateway_pll_2_rom 
	#(.width_p(80)
	,.addr_width_p(8))
	pll_2_rom
	(.addr_i(pll_rom_addr_li[1])
	,.data_o(pll_rom_data_lo[1]));
	
	bsg_gateway_pll_3_rom 
	#(.width_p(80)
	,.addr_width_p(8))
	pll_3_rom
	(.addr_i(pll_rom_addr_li[2])
	,.data_o(pll_rom_data_lo[2]));
	
	// For delay cycles
	wait_cycle_32 w_cycle
	(.reset_i(reset_lo | pll_not_done_lo | mb_spi_master_reset_lo)
	,.enable_i(valid_wait_lo)
	,.clk_i(clk_i)
	,.cycle_i(cycle_wait_lo)
	,.ready_r_o(ready_wait_li)
	,.test_o(test_output));
	
	// For output pins control
	bsg_gateway_pll_control pll_control
	(.reset_i(reset_lo | pll_not_done_lo | mb_spi_master_reset_lo)
	,.enable_i(valid_control_lo)
	,.clk_i(clk_i)
	,.data_i(data_control_lo)
	,.spi_rst_o(spi_rst_o));
	
	// For SCLK output
	logic sclk_disable_lo;
	assign sclk_disable_lo = 1'b0;
	// assign sclk_disable_lo = ~((| valid_spi_lo) | (~(& ready_spi_li)));
	
	ODDR2 oddr_sclk
	(.D0(1'b1)
	,.D1(sclk_disable_lo)
	,.C0(clk_i)
	,.C1(~clk_i)
	,.CE(1'b1)
	,.S(1'b0)
	,.R(1'b0)
	,.Q(spi_clk_o));

endmodule

