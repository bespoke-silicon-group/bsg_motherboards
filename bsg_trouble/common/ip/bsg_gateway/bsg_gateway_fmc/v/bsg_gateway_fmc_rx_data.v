//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_rx_data.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_rx_data
  (input reset_i
  ,input clk_p_i, clk_n_i
  ,input [10:0] data_p_i, data_n_i
  ,input clk_div_i
  ,input clk_serdes_strobe_i
  ,output cal_done_o
  ,output [87:0] data_o);

  logic [87:0] iserdes_data_lo;

  logic [10:0] ibufds_data_lo, iodelay_data_lo;
  logic [10:0] iserdes_slave_shiftout_lo, iserdes_master_shiftout_lo;

  logic [10:0] ctrl_bitslip_lo, ctrl_bitslip_done_lo;

  genvar i;
  generate
    for (i = 0; i < 11; i++) begin

      IBUFDS #
        (.DIFF_TERM("TRUE"))
      ibufds
        (.I(data_p_i[i]) ,.IB(data_n_i[i])
        ,.O(ibufds_data_lo[i]));

      IODELAY2 #
        (.DATA_RATE("DDR")
        ,.IDELAY_VALUE(0)
        ,.IDELAY2_VALUE(0)
        ,.IDELAY_MODE("NORMAL")
        ,.ODELAY_VALUE(0)
        ,.IDELAY_TYPE("FIXED")
        ,.COUNTER_WRAPAROUND("WRAPAROUND" )
        ,.DELAY_SRC("IDATAIN" )
        ,.SERDES_MODE("MASTER")
        ,.SIM_TAPDELAY_VALUE(49))
      iodelay_data
        (.IDATAIN(ibufds_data_lo[i])
        ,.TOUT()
        ,.DOUT()
        ,.T(1'b1)
        ,.ODATAIN(1'b0)
        ,.DATAOUT(iodelay_data_lo[i])
        ,.DATAOUT2()
        ,.IOCLK0(clk_p_i)
        ,.IOCLK1(clk_n_i)
        ,.CLK(clk_div_i)
        ,.CAL(1'b0)
        ,.INC(1'b0)
        ,.CE(1'b0)
        ,.RST(reset_i)
        ,.BUSY());

      ISERDES2 #
        (.DATA_WIDTH(8)
        ,.DATA_RATE("DDR")
        ,.BITSLIP_ENABLE("TRUE")
        ,.SERDES_MODE("MASTER")
        ,.INTERFACE_TYPE("RETIMED"))
      iserdes_master
        (.D(iodelay_data_lo[i])
        ,.CE0(1'b1)
        ,.CLK0(clk_p_i)
        ,.CLK1(clk_n_i)
        ,.IOCE(clk_serdes_strobe_i)
        ,.RST(reset_i)
        ,.CLKDIV(clk_div_i)
        ,.SHIFTIN(iserdes_slave_shiftout_lo[i])
        ,.BITSLIP(ctrl_bitslip_lo[i])
        ,.FABRICOUT()
        ,.Q4(iserdes_data_lo[(8*i) + 7])
        ,.Q3(iserdes_data_lo[(8*i) + 6])
        ,.Q2(iserdes_data_lo[(8*i) + 5])
        ,.Q1(iserdes_data_lo[(8*i) + 4])
        ,.DFB()
        ,.CFB0()
        ,.CFB1()
        ,.VALID()
        ,.INCDEC()
        ,.SHIFTOUT(iserdes_master_shiftout_lo[i]));

      ISERDES2 #
        (.DATA_WIDTH(8)
        ,.DATA_RATE("DDR")
        ,.BITSLIP_ENABLE("TRUE")
        ,.SERDES_MODE("SLAVE")
        ,.INTERFACE_TYPE("RETIMED"))
      iserdes_slave
        (.D()
        ,.CE0(1'b1)
        ,.CLK0(clk_p_i)
        ,.CLK1(clk_n_i)
        ,.IOCE(clk_serdes_strobe_i)
        ,.RST(reset_i)
        ,.CLKDIV(clk_div_i)
        ,.SHIFTIN(iserdes_master_shiftout_lo[i])
        ,.BITSLIP(ctrl_bitslip_lo[i])
        ,.FABRICOUT()
        ,.Q4(iserdes_data_lo[(8*i) + 3])
        ,.Q3(iserdes_data_lo[(8*i) + 2])
        ,.Q2(iserdes_data_lo[(8*i) + 1])
        ,.Q1(iserdes_data_lo[(8*i) + 0])
        ,.DFB()
        ,.CFB0()
        ,.CFB1()
        ,.VALID()
        ,.INCDEC()
        ,.SHIFTOUT(iserdes_slave_shiftout_lo[i]));

      bsg_gateway_fmc_rx_data_bitslip_ctrl bitslip_ctrl
        (.clk_i(clk_div_i)
        ,.reset_i(reset_i)
        ,.data_i(iserdes_data_lo[8*i + 7 : 8*i])
        ,.bitslip_o(ctrl_bitslip_lo[i])
        ,.done_o(ctrl_bitslip_done_lo[i]));

  end
  endgenerate

  logic bitslip_done_lo, cal_done_r;

  assign bitslip_done_lo = (& ctrl_bitslip_done_lo);

  always_ff @(posedge clk_div_i)
    if (reset_i == 1'b1)
      cal_done_r <= 1'b0;
    else if (bitslip_done_lo == 1'b1 && iserdes_data_lo == {11{8'hF8}})
      cal_done_r <= 1'b1;

  assign cal_done_o = cal_done_r;

  assign data_o = (cal_done_r == 1'b1)? iserdes_data_lo : {11{8'd0}};

endmodule
