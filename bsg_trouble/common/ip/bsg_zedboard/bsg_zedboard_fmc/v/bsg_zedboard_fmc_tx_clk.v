//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_zedboard_fmc_tx_clk.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_zedboard_fmc_tx_clk
  (input clk_i
  ,output clk_p_o, clk_n_o);

  logic oddr_lo;

  ODDR #
    (.DDR_CLK_EDGE("OPPOSITE_EDGE")
    ,.INIT(1'b0)
    ,.SRTYPE("ASYNC"))
  oddr_clk_inst
    (.Q(oddr_lo)
    ,.C(clk_i)
    ,.CE(1'b1)
    ,.D1(1'b1)
    ,.D2(1'b0)
    ,.R(1'b0)
    ,.S(1'b0));

  OBUFDS #
    (.IOSTANDARD("DEFAULT"))
  obufds_clk_inst
    (.I(oddr_lo)
    ,.O(clk_p_o) ,.OB(clk_n_o));

endmodule
