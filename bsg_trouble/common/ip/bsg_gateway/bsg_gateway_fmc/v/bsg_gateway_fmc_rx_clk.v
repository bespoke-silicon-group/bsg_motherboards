//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_rx_clk.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_rx_clk
  (input clk_p_i, clk_n_i
  ,output clk_p_o, clk_n_o
  ,output clk_serdes_strobe_o
  ,output clk_div_o);

  logic iodelay_clk_p_lo, iodelay_clk_n_lo;
  logic ibufds_clk_p_lo, ibufds_clk_n_lo;
  logic bufio_clk_div_lo;

  IBUFDS_DIFF_OUT #
    (.DIFF_TERM("TRUE"))
  ibufds_clk
    (.I(clk_p_i) ,.IB(clk_n_i)
    ,.O(ibufds_clk_p_lo) ,.OB(ibufds_clk_n_lo));

  IODELAY2 #
    (.DATA_RATE("DDR")
    ,.SIM_TAPDELAY_VALUE(49)
    ,.IDELAY_VALUE(0)
    ,.IDELAY2_VALUE(0)
    ,.ODELAY_VALUE(0)
    ,.IDELAY_MODE("NORMAL")
    ,.SERDES_MODE("MASTER")
    ,.IDELAY_TYPE("FIXED")
    ,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
    ,.DELAY_SRC("IDATAIN"))
  iodelay_clk_p
    (.IDATAIN(ibufds_clk_p_lo)
    ,.TOUT()
    ,.DOUT()
    ,.T(1'b1)
    ,.ODATAIN(1'b0)
    ,.DATAOUT(iodelay_clk_p_lo)
    ,.DATAOUT2()
    ,.IOCLK0(1'b0)
    ,.IOCLK1(1'b0)
    ,.CLK(1'b0)
    ,.CAL(1'b0)
    ,.INC(1'b0)
    ,.CE(1'b0)
    ,.RST(1'b0)
    ,.BUSY());

  IODELAY2 #
    (.DATA_RATE("DDR")
    ,.SIM_TAPDELAY_VALUE(49)
    ,.IDELAY_VALUE(0)
    ,.IDELAY2_VALUE(0)
    ,.ODELAY_VALUE(0)
    ,.IDELAY_MODE("NORMAL")
    ,.SERDES_MODE("SLAVE")
    ,.IDELAY_TYPE("FIXED")
    ,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
    ,.DELAY_SRC("IDATAIN"))
  iodelay_clk_n
    (.IDATAIN(ibufds_clk_n_lo)
    ,.TOUT()
    ,.DOUT()
    ,.T(1'b1)
    ,.ODATAIN(1'b0)
    ,.DATAOUT(iodelay_clk_n_lo)
    ,.DATAOUT2()
    ,.IOCLK0(1'b0)
    ,.IOCLK1(1'b0)
    ,.CLK(1'b0)
    ,.CAL(1'b0)
    ,.INC(1'b0)
    ,.CE(1'b0)
    ,.RST(1'b0)
    ,.BUSY());

  BUFIO2_2CLK #
    (.DIVIDE(8))
  bufio2_2clk
    (.I(iodelay_clk_p_lo) ,.IB(iodelay_clk_n_lo)
    ,.IOCLK(clk_p_o)
    ,.DIVCLK(bufio_clk_div_lo)
    ,.SERDESSTROBE(clk_serdes_strobe_o));

  BUFIO2 #
    (.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("FALSE")
    ,.USE_DOUBLER("FALSE"))
  bufio2
    (.I(iodelay_clk_n_lo)
    ,.IOCLK(clk_n_o)
    ,.DIVCLK()
    ,.SERDESSTROBE());

  BUFG bufg
    (.I(bufio_clk_div_lo)
    ,.O(clk_div_o));

endmodule
