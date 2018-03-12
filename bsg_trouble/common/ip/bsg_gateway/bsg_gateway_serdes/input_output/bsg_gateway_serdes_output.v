//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_serdes_output.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_serdes_output

  #(parameter width = 8)
  (input io_master_clk_i
  ,input io_serdes_clk_i
  ,input io_strobe_i
  ,input D8_i
  ,input D7_i
  ,input D6_i
  ,input D5_i
  ,input D4_i
  ,input D3_i
  ,input D2_i
  ,input D1_i
  ,output Q_o);

  logic oserdes_master_shiftout_1_lo;
  logic oserdes_master_shiftout_2_lo;
  logic oserdes_slave_shiftout_3_lo;
  logic oserdes_slave_shiftout_4_lo;

  // Using two OSERDES2 in cascade mode to get 2x width
  OSERDES2 #
	(.DATA_WIDTH(width)
	,.DATA_RATE_OQ("SDR")
	,.DATA_RATE_OT("SDR")
	,.SERDES_MODE("MASTER")
	,.OUTPUT_MODE("SINGLE_ENDED"))
  oserdes_master
	(.OQ(Q_o)
	,.OCE(1'b1)
	,.CLK0(io_serdes_clk_i)
	,.CLK1()
	,.IOCE(io_strobe_i)
	,.RST(1'b0)
	,.CLKDIV(io_master_clk_i)
	,.D4(D8_i)
	,.D3(D7_i)
	,.D2(D6_i)
	,.D1(D5_i)
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
	(.DATA_WIDTH(width)
	,.DATA_RATE_OQ("SDR")
	,.DATA_RATE_OT("SDR")
	,.SERDES_MODE("SLAVE")
	,.OUTPUT_MODE("SINGLE_ENDED"))
  oserdes_slave
	(.OQ()
	,.OCE(1'b1)
	,.CLK0(io_serdes_clk_i)
	,.CLK1()
	,.IOCE(io_strobe_i)
	,.RST(1'b0)
	,.CLKDIV(io_master_clk_i)
	,.D4(D4_i)
	,.D3(D3_i)
	,.D2(D2_i)
	,.D1(D1_i)
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

endmodule
