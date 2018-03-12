//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_comm_link_fuser_serdes.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_comm_link_fuser_serdes #
  (parameter channel_width_p = "inv"
  ,parameter channel_width_serdes_p = "inv"
  ,parameter serdes_ratio_p = "inv"
  ,parameter core_channels_p = "inv"
  ,parameter link_channels_p = "inv"
  ,parameter sbox_pipeline_in_p  = "inv"
  ,parameter sbox_pipeline_out_p = "inv"
  ,parameter channel_mask_p = "inv"
  ,parameter fuser_width_p = channel_width_p*core_channels_p
  ,parameter channel_select_p = (1<<(link_channels_p))-1)
  
  (input io_master_clk_i
  ,input core_clk_i
  ,input reset_i
  ,input core_calib_done_r_i
  ,input im_reset_i

  // ctrl
  ,input fast_core_clk_i
  ,input fast_reset_i
  ,input fast_core_calib_done_r_i
  ,input [link_channels_p-1:0] core_active_channels_i

  // unfused in
  ,input  [link_channels_p*2-1:0] unfused_valid_i
  ,input  [channel_width_p-1:0] unfused_data_i [link_channels_p*2-1:0]
  ,output logic [link_channels_p*2-1:0] unfused_yumi_o

  // unfused out
  ,output [link_channels_p-1:0] unfused_valid_o
  ,output [channel_width_serdes_p-1:0] unfused_data_o [link_channels_p-1:0]
  ,input  [link_channels_p-1:0] unfused_ready_i

  // fused in
  ,input                     fused_valid_i
  ,input [fuser_width_p-1:0] fused_data_i
  ,output                    fused_ready_o

  // fused out
  ,output                     fused_valid_o
  ,output [fuser_width_p-1:0] fused_data_o
  ,input                      fused_yumi_i);

  // sbox

  logic [link_channels_p-1:0] bao_valid_lo;
  logic [channel_width_serdes_p-1:0] bao_data_lo [link_channels_p-1:0];
  logic [link_channels_p-1:0] sbox_ready_lo;

  logic [link_channels_p*2-1:0] sbox_valid_lo;
  logic [channel_width_p-1:0] sbox_data_lo [link_channels_p*2-1:0];
  logic [link_channels_p*2-1:0] bai_yumi_lo;
  

	// No SBOX
	assign unfused_valid_o = bao_valid_lo;
	assign unfused_data_o = bao_data_lo;
	assign sbox_ready_lo = unfused_ready_i;

	assign sbox_valid_lo = unfused_valid_i;
	assign sbox_data_lo = unfused_data_i;
	assign unfused_yumi_o = bai_yumi_lo;
  
  // assembler
	
	bsg_assembler_out_serdes #
	(.width_p(channel_width_p)
	,.width_serdes_p(channel_width_serdes_p)
	,.num_in_p(core_channels_p)
	,.num_out_p(link_channels_p)
	,.serdes_ratio_p(serdes_ratio_p)
	,.channel_select_p(channel_select_p))
	bao
	(.io_master_clk(io_master_clk_i)
	,.core_clk(core_clk_i)
	,.reset(reset_i)
	,.im_reset(im_reset_i)
	// in
	,.valid_i(fused_valid_i)
	,.data_i(fused_data_i)
	,.ready_o(fused_ready_o)
	// out
	,.valid_o(bao_valid_lo)
	,.data_o(bao_data_lo)
	,.ready_i(sbox_ready_lo)
	);
	
	
  bsg_assembler_in_serdes #
    (.width_p(channel_width_p)
    ,.num_in_p(link_channels_p)
    ,.num_out_p(core_channels_p)
    ,.in_channel_count_mask_p(channel_mask_p)
	,.channel_select_p(channel_select_p))
  bai
    (.clk(core_clk_i)
    ,.reset(reset_i)
	,.calibration_done_i(core_calib_done_r_i)
	
    // ctrl
    ,.fast_calibration_done_i(fast_core_calib_done_r_i)
	,.fast_clk(fast_core_clk_i)
    ,.fast_reset(fast_reset_i)
    // in
    ,.valid_i(sbox_valid_lo)
    ,.data_i(sbox_data_lo)
    ,.yumi_o(bai_yumi_lo)
    // out
    ,.valid_o(fused_valid_o)
    ,.data_o(fused_data_o)
    ,.yumi_i(fused_yumi_i));

endmodule
