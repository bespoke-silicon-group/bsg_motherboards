//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_fmc_rx_clk.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_fmc_rx_clk #
  (parameter IODELAY_GRP = "IODELAY_FMC")
  (input clk_p_i, clk_n_i
  ,output clk_o
  ,output clk_div_o);

  logic ibufds_clk_lo, iodelay_clk_lo;

  IBUFDS #
    (.DIFF_TERM("TRUE")
    ,.IOSTANDARD("LVDS_25"))
  ibufds_clk_inst
    (.I(clk_p_i) ,.IB(clk_n_i)
    ,.O(ibufds_clk_lo));

  (* IODELAY_GROUP = IODELAY_GRP *) IODELAYE1 #
    (.CINVCTRL_SEL("FALSE")
    ,.DELAY_SRC("I")
    ,.HIGH_PERFORMANCE_MODE("TRUE")
    ,.IDELAY_TYPE("FIXED")
    ,.IDELAY_VALUE(0)
    ,.ODELAY_TYPE("FIXED")
    ,.ODELAY_VALUE(0)
    ,.REFCLK_FREQUENCY(200.0)
    ,.SIGNAL_PATTERN("CLOCK"))
  iodelay_clk_inst
    (.CNTVALUEOUT()
    ,.DATAOUT(iodelay_clk_lo)
    ,.C(1'b0)
    ,.CE(1'b0)
    ,.CINVCTRL(1'b0)
    ,.CLKIN(1'b0)
    ,.CNTVALUEIN(5'd0)
    ,.DATAIN(1'b0)
    ,.IDATAIN(ibufds_clk_lo)
    ,.INC(1'b0)
    ,.ODATAIN(1'b0)
    ,.RST(1'b0)
    ,.T(1'b1));

  BUFIO bufio_clk_inst
    (.I(iodelay_clk_lo)
    ,.O(clk_o));

  BUFR #
    (.BUFR_DIVIDE("4")
    ,.SIM_DEVICE("VIRTEX6"))
  bufr_clk_inst
    (.O(clk_div_o)
    ,.CE(1'b1)
    ,.CLR(1'b0)
    ,.I(iodelay_clk_lo));

endmodule
