//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_zedboard_fmc.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//
// Note: this file pairs with bsg_gateway_fmc.v; and they are
// intended to interoperate. See that file for design rationale.
//------------------------------------------------------------

module bsg_zedboard_fmc #
  (parameter IODELAY_GRP = "IODELAY_FMC")
  (input clk_i
  // data in
  ,input valid_i
  ,input [79:0] data_i
  ,output ready_o
  // data out
  ,output valid_o
  ,output [79:0] data_o
  ,input ready_i
  // double trouble reset in
  ,input dt_reset_i
  // double-trouble calibration reset
  ,output dt_calib_reset_o
  // fmc clk zedboard/gateway
  ,input fmc_clk_i
  ,input fmc_clk_div_i
  ,input fmc_clk_200_mhz_i
  // fmc gateway reset out
  ,output FMC_LA20_P, FMC_LA20_N
  // fmc zedboard reset in
  ,input FMC_LA23_P, FMC_LA23_N
  // fmc tx clk out
  ,output FMC_LA17_CC_P, FMC_LA17_CC_N
  // fmc tx data out
  ,output FMC_LA31_P, FMC_LA31_N
  ,output FMC_LA33_P, FMC_LA33_N
  ,output FMC_LA30_P, FMC_LA30_N
  ,output FMC_LA32_P, FMC_LA32_N
  ,output FMC_LA28_P, FMC_LA28_N
  ,output FMC_LA25_P, FMC_LA25_N
  ,output FMC_LA29_P, FMC_LA29_N
  ,output FMC_LA26_P, FMC_LA26_N
  ,output FMC_LA21_P, FMC_LA21_N
  ,output FMC_LA27_P, FMC_LA27_N
  ,output FMC_LA22_P, FMC_LA22_N
  // fmc rx clk out
  ,output FMC_CLK0_P, FMC_CLK0_N
  // fmc rx clk in
  ,input FMC_LA00_CC_P, FMC_LA00_CC_N
  // fmc rx data in
  ,input FMC_LA01_CC_P, FMC_LA01_CC_N
  ,input FMC_LA16_P, FMC_LA16_N
  ,input FMC_LA15_P, FMC_LA15_N
  ,input FMC_LA13_P, FMC_LA13_N
  ,input FMC_LA11_P, FMC_LA11_N
  ,input FMC_LA10_P, FMC_LA10_N
  ,input FMC_LA14_P, FMC_LA14_N
  ,input FMC_LA09_P, FMC_LA09_N
  ,input FMC_LA04_P, FMC_LA04_N
  ,input FMC_LA07_P, FMC_LA07_N
  ,input FMC_LA08_P, FMC_LA08_N);

  // fmc gateway reset out

  logic [9:0] cnt_r;

  always_ff @(posedge fmc_clk_div_i)
    if (dt_reset_i == 1'b1)
      cnt_r <= 10'd0;
    else if (cnt_r < 10'd1023)
      cnt_r <= cnt_r + 1;

  logic gateway_reset_lo;

  assign gateway_reset_lo = (cnt_r > 4'd7 && cnt_r < 10'd1023)? 1'b1 : 1'b0;

  OBUFDS #
    (.IOSTANDARD("DEFAULT"))
  obufds_inst
    (.I(~gateway_reset_lo) // swapped due to pcb routing
    ,.O(FMC_LA20_P) ,.OB(FMC_LA20_N));

  // fmc zedboard reset in

  logic ibufds_zedboard_reset_lo;

  IBUFDS ibufds_inst
    (.I(FMC_LA23_P) ,.IB(FMC_LA23_N)
    ,.O(ibufds_zedboard_reset_lo));

  assign dt_calib_reset_o = ibufds_zedboard_reset_lo;

  // fmc buffering

  logic [87:0] tx_data_lo, rx_data_lo;
  logic rx_clk_div_lo;
  logic tx_cal_done_lo, rx_cal_done_lo;

  bsg_zedboard_fmc_buffer fmc_buffer_inst
    // core clk domain
    (.core_clk_i(clk_i)
    // core clk domain data in
    ,.core_valid_i(valid_i)
    ,.core_data_i(data_i)
    ,.core_ready_o(ready_o)
    // core clk domain data out
    ,.core_valid_o(valid_o)
    ,.core_data_o(data_o)
    ,.core_ready_i(ready_i)
    // fmc rx clk domain
    ,.rx_clk_div_i(rx_clk_div_lo)
    ,.rx_data_i(rx_data_lo)
    ,.rx_cal_done_i(rx_cal_done_lo)
    // fmc tx clk domain
    ,.tx_clk_div_i(fmc_clk_div_i)
    ,.tx_data_o(tx_data_lo)
    ,.tx_cal_done_i(tx_cal_done_lo));

  // fmc tx

  bsg_zedboard_fmc_tx fmc_tx_inst
    (.reset_i(ibufds_zedboard_reset_lo)
    ,.clk_i(fmc_clk_i)
    ,.clk_div_i(fmc_clk_div_i)
    ,.data_i(tx_data_lo)
    ,.cal_done_o(tx_cal_done_lo)
    // fmc tx clk out
    ,.FMC_LA17_CC_P(FMC_LA17_CC_P) ,.FMC_LA17_CC_N(FMC_LA17_CC_N)
    // fmc tx data out
    ,.FMC_LA31_P(FMC_LA31_P) ,.FMC_LA31_N(FMC_LA31_N)
    ,.FMC_LA33_P(FMC_LA33_P) ,.FMC_LA33_N(FMC_LA33_N)
    ,.FMC_LA30_P(FMC_LA30_P) ,.FMC_LA30_N(FMC_LA30_N)
    ,.FMC_LA32_P(FMC_LA32_P) ,.FMC_LA32_N(FMC_LA32_N)
    ,.FMC_LA28_P(FMC_LA28_P) ,.FMC_LA28_N(FMC_LA28_N)
    ,.FMC_LA25_P(FMC_LA25_P) ,.FMC_LA25_N(FMC_LA25_N)
    ,.FMC_LA29_P(FMC_LA29_P) ,.FMC_LA29_N(FMC_LA29_N)
    ,.FMC_LA26_P(FMC_LA26_P) ,.FMC_LA26_N(FMC_LA26_N)
    ,.FMC_LA21_P(FMC_LA21_P) ,.FMC_LA21_N(FMC_LA21_N)
    ,.FMC_LA27_P(FMC_LA27_P) ,.FMC_LA27_N(FMC_LA27_N)
    ,.FMC_LA22_P(FMC_LA22_P) ,.FMC_LA22_N(FMC_LA22_N));

  // fmc rx

  bsg_zedboard_fmc_rx #
    (.IODELAY_GRP(IODELAY_GRP))
  fmc_rx_inst
    (.reset_i(ibufds_zedboard_reset_lo)
    ,.clk_i(fmc_clk_i)
    ,.clk_200_mhz_i(fmc_clk_200_mhz_i)
    ,.clk_div_o(rx_clk_div_lo)
    ,.data_o(rx_data_lo)
    ,.cal_done_o(rx_cal_done_lo)
    // fmc rx clk out
    ,.FMC_CLK0_P(FMC_CLK0_P) ,.FMC_CLK0_N(FMC_CLK0_N)
    // fmc rx clk in
    ,.FMC_LA00_CC_P(FMC_LA00_CC_P) ,.FMC_LA00_CC_N(FMC_LA00_CC_N)
    // fmc rx data in
    ,.FMC_LA01_CC_P(FMC_LA01_CC_P) ,.FMC_LA01_CC_N(FMC_LA01_CC_N)
    ,.FMC_LA16_P(FMC_LA16_P) ,.FMC_LA16_N(FMC_LA16_N)
    ,.FMC_LA15_P(FMC_LA15_P) ,.FMC_LA15_N(FMC_LA15_N)
    ,.FMC_LA13_P(FMC_LA13_P) ,.FMC_LA13_N(FMC_LA13_N)
    ,.FMC_LA11_P(FMC_LA11_P) ,.FMC_LA11_N(FMC_LA11_N)
    ,.FMC_LA10_P(FMC_LA10_P) ,.FMC_LA10_N(FMC_LA10_N)
    ,.FMC_LA14_P(FMC_LA14_P) ,.FMC_LA14_N(FMC_LA14_N)
    ,.FMC_LA09_P(FMC_LA09_P) ,.FMC_LA09_N(FMC_LA09_N)
    ,.FMC_LA04_P(FMC_LA04_P) ,.FMC_LA04_N(FMC_LA04_N)
    ,.FMC_LA07_P(FMC_LA07_P) ,.FMC_LA07_N(FMC_LA07_N)
    ,.FMC_LA08_P(FMC_LA08_P) ,.FMC_LA08_N(FMC_LA08_N));

endmodule
