//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_tx_clk.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_tx_clk
  (input clk_p_i, clk_n_i
  ,output clk_p_o, clk_n_o
  ,output data_clk_div_o
  ,output data_clk_serdes_strobe_o
  ,output data_clk_p_o, data_clk_n_o);

  logic ibufds_clk_p_lo, ibufds_clk_n_lo;

  IBUFDS_DIFF_OUT #
    (.DIFF_TERM("TRUE"))
  ibufds_diff_out
    (.I(clk_p_i) ,.IB(clk_n_i)
    ,.O(ibufds_clk_p_lo) ,.OB(ibufds_clk_n_lo));

  logic iodelay_clk_p_lo, iodelay_clk_n_lo;

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

  logic bufio_clk_div_lo;
  logic bufio_clk_serdes_strobe_lo;
  logic bufio_clk_p_lo, bufio_clk_n_lo;

  BUFIO2_2CLK #
    (.DIVIDE(8))
  bufio2_2clk
    (.I(iodelay_clk_p_lo) ,.IB(iodelay_clk_n_lo)
    ,.IOCLK(bufio_clk_p_lo)
    ,.DIVCLK(bufio_clk_div_lo)
    ,.SERDESSTROBE(bufio_clk_serdes_strobe_lo));

  BUFIO2 #
    (.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("FALSE")
    ,.USE_DOUBLER("FALSE"))
  bufio2
    (.I(iodelay_clk_n_lo)
    ,.IOCLK(bufio_clk_n_lo)
    ,.DIVCLK()
    ,.SERDESSTROBE());

  logic bufg_clk_div_lo;

  BUFG bufg
    (.I(bufio_clk_div_lo)
    ,.O(bufg_clk_div_lo));

  logic oserdes_master_shiftout_1_lo;
  logic oserdes_master_shiftout_2_lo;
  logic oserdes_slave_shiftout_3_lo;
  logic oserdes_slave_shiftout_4_lo;

  logic oserdes_clk_lo;

  logic [7:0] clk_pattern;

  assign clk_pattern = 8'hAA;

  OSERDES2 #
    (.DATA_WIDTH(8)
    ,.DATA_RATE_OQ("DDR")
    ,.DATA_RATE_OT("DDR")
    ,.SERDES_MODE("MASTER")
    ,.OUTPUT_MODE("DIFFERENTIAL"))
  oserdes_master_data
    (.OQ(oserdes_clk_lo)
    ,.OCE(1'b1)
    ,.CLK0(bufio_clk_p_lo)
    ,.CLK1(bufio_clk_n_lo)
    ,.IOCE(bufio_clk_serdes_strobe_lo)
    ,.RST(1'b0)
    ,.CLKDIV(bufg_clk_div_lo)
    ,.D4(clk_pattern[7])
    ,.D3(clk_pattern[6])
    ,.D2(clk_pattern[5])
    ,.D1(clk_pattern[4])
    ,.TQ()
    ,.T1(1'b0)
    ,.T2(1'b0)
    ,.T3(1'b0)
    ,.T4(1'b0)
    ,.TRAIN(1'b0)
    ,.TCE(1'b1)
    ,.SHIFTIN1(1'b1)
    ,.SHIFTIN2(1'b1)
    ,.SHIFTIN3(oserdes_slave_shiftout_3_lo)
    ,.SHIFTIN4(oserdes_slave_shiftout_4_lo)
    ,.SHIFTOUT1(oserdes_master_shiftout_1_lo)
    ,.SHIFTOUT2(oserdes_master_shiftout_2_lo)
    ,.SHIFTOUT3()
    ,.SHIFTOUT4());

  OSERDES2 #
    (.DATA_WIDTH(8)
    ,.DATA_RATE_OQ("DDR")
    ,.DATA_RATE_OT("DDR")
    ,.SERDES_MODE("SLAVE")
    ,.OUTPUT_MODE("DIFFERENTIAL"))
  oserdes_slave_data
    (.OQ()
    ,.OCE(1'b1)
    ,.CLK0(bufio_clk_p_lo)
    ,.CLK1(bufio_clk_n_lo)
    ,.IOCE(bufio_clk_serdes_strobe_lo)
    ,.RST(1'b0)
    ,.CLKDIV(bufg_clk_div_lo)
    ,.D4(clk_pattern[3])
    ,.D3(clk_pattern[2])
    ,.D2(clk_pattern[1])
    ,.D1(clk_pattern[0])
    ,.TQ()
    ,.T1(1'b0)
    ,.T2(1'b0)
    ,.T3(1'b0)
    ,.T4(1'b0)
    ,.TRAIN(1'b0)
    ,.TCE(1'b1)
    ,.SHIFTIN1(oserdes_master_shiftout_1_lo)
    ,.SHIFTIN2(oserdes_master_shiftout_2_lo)
    ,.SHIFTIN3(1'b1)
    ,.SHIFTIN4(1'b1)
    ,.SHIFTOUT1()
    ,.SHIFTOUT2()
    ,.SHIFTOUT3(oserdes_slave_shiftout_3_lo)
    ,.SHIFTOUT4(oserdes_slave_shiftout_4_lo));

  OBUFDS obufds_data
    (.I(oserdes_clk_lo)
    ,.O(clk_p_o) ,.OB(clk_n_o));

  assign data_clk_div_o = bufg_clk_div_lo;
  assign data_clk_serdes_strobe_o = bufio_clk_serdes_strobe_lo;
  assign data_clk_p_o = bufio_clk_p_lo;
  assign data_clk_n_o = bufio_clk_n_lo;

endmodule
