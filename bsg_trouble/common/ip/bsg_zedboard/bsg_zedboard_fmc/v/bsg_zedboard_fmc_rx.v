//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_zedboard_fmc_rx.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_zedboard_fmc_rx #
  (parameter IODELAY_GRP = "IODELAY_FMC")
  (input reset_i
  ,input clk_i
  ,input clk_200_mhz_i
  ,output clk_div_o
  ,output [87:0] data_o
  ,output cal_done_o
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

  // idelay controller

  logic idelayctrl_ready_lo;

  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL idelayctrl_inst
    (.RDY(idelayctrl_ready_lo)
    ,.REFCLK(clk_200_mhz_i)
    ,.RST(reset_i));

  // reset

  logic reset_lo;

  assign reset_lo = reset_i | (~idelayctrl_ready_lo);

  // clk out

  logic oddr_lo;

  ODDR #
    (.DDR_CLK_EDGE("OPPOSITE_EDGE")
    ,.INIT(1'b0)
    ,.SRTYPE("ASYNC"))
  oddr_clk
    (.Q(oddr_lo)
    ,.C(clk_i)
    ,.CE(1'b1)
    ,.D1(1'b1)
    ,.D2(1'b0)
    ,.R(1'b0)
    ,.S(1'b0));

  OBUFDS #
    (.IOSTANDARD("DEFAULT"))
  obufds_clk
    (.I(oddr_lo)
    ,.O(FMC_CLK0_P) ,.OB(FMC_CLK0_N));

  // clk in

  logic clk_lo, clk_div_lo;

  bsg_zedboard_fmc_rx_clk #
    (.IODELAY_GRP(IODELAY_GRP))
  rx_clk_inst
    (.clk_p_i(FMC_LA00_CC_P) ,.clk_n_i(FMC_LA00_CC_N)
    ,.clk_o(clk_lo)
    ,.clk_div_o(clk_div_lo));

  assign clk_div_o = clk_div_lo;

  // data in

  logic [10:0] data_p_lo, data_n_lo;

  assign data_p_lo = {FMC_LA08_P
                     ,FMC_LA07_P
                     ,FMC_LA04_P
                     ,FMC_LA09_P
                     ,FMC_LA14_P
                     ,FMC_LA10_P
                     ,FMC_LA11_P
                     ,FMC_LA13_P
                     ,FMC_LA15_P
                     ,FMC_LA16_P
                     ,FMC_LA01_CC_P};

  assign data_n_lo = {FMC_LA08_N
                     ,FMC_LA07_N
                     ,FMC_LA04_N
                     ,FMC_LA09_N
                     ,FMC_LA14_N
                     ,FMC_LA10_N
                     ,FMC_LA11_N
                     ,FMC_LA13_N
                     ,FMC_LA15_N
                     ,FMC_LA16_N
                     ,FMC_LA01_CC_N};

  bsg_zedboard_fmc_rx_data #
    (.IODELAY_GRP(IODELAY_GRP))
  rx_data_inst
    (.clk_i(clk_lo)
    ,.clk_div_i(clk_div_lo)
    ,.reset_i(reset_lo)
    ,.data_p_i(data_p_lo) ,.data_n_i(data_n_lo)
    ,.cal_done_o(cal_done_o)
    ,.data_o(data_o));

endmodule
