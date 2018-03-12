//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_zedboard_fmc_rx_data.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_zedboard_fmc_rx_data #
  (parameter IODELAY_GRP = "IODELAY_FMC")
  (input clk_i
  ,input clk_div_i
  ,input reset_i
  ,input [10:0] data_p_i, data_n_i
  ,output cal_done_o
  ,output [87:0] data_o);

  // data

  logic [87:0] iserdes_data_lo;

  logic [10:0] ibufds_data_lo, iodelay_data_lo;
  logic [10:0] iserdes_shiftout_1_lo, iserdes_shiftout_2_lo;

  logic [10:0] ctrl_bitslip_lo, ctrl_bitslip_done_lo;

  genvar i;
  generate
    for (i = 0; i < 11; i++) begin

      IBUFDS #
        (.DIFF_TERM("TRUE")
        ,.IOSTANDARD("DEFAULT"))
      ibufds_data_inst
        (.I(data_p_i[i]) ,.IB(data_n_i[i])
        ,.O(ibufds_data_lo[i]));

      (* IODELAY_GROUP = IODELAY_GRP *) IDELAYE2 #
        (.CINVCTRL_SEL("FALSE")
        ,.DELAY_SRC("IDATAIN")
        ,.HIGH_PERFORMANCE_MODE("TRUE")
        ,.IDELAY_TYPE("FIXED")
      `ifdef SIMULATION
        ,.IDELAY_VALUE(1)
      `else
        ,.IDELAY_VALUE(0)
      `endif
        ,.PIPE_SEL("FALSE")
        ,.REFCLK_FREQUENCY(200.0)
        ,.SIGNAL_PATTERN("DATA"))
      iodelay_data_inst
        (.CNTVALUEOUT()
        ,.DATAOUT(iodelay_data_lo[i])
        ,.C(clk_div_i)
        ,.CE(1'b0)
        ,.CINVCTRL(1'b0)
        ,.CNTVALUEIN(5'd0)
        ,.DATAIN(1'b0)
        ,.IDATAIN(ibufds_data_lo[i])
        ,.INC(1'b0)
        ,.LD(1'b0)
        ,.LDPIPEEN(1'b0)
        ,.REGRST(reset_i));

      ISERDESE2 #
        (.DATA_RATE("DDR")
        ,.DATA_WIDTH(8)
        ,.DYN_CLKDIV_INV_EN("FALSE")
        ,.DYN_CLK_INV_EN("FALSE")
        ,.INIT_Q1(1'b0)
        ,.INIT_Q2(1'b0)
        ,.INIT_Q3(1'b0)
        ,.INIT_Q4(1'b0)
        ,.INTERFACE_TYPE("NETWORKING")
        ,.IOBDELAY("IFD")
        ,.NUM_CE(1)
        ,.OFB_USED("FALSE")
        ,.SERDES_MODE("MASTER")
        ,.SRVAL_Q1(1'b0)
        ,.SRVAL_Q2(1'b0)
        ,.SRVAL_Q3(1'b0)
        ,.SRVAL_Q4(1'b0))
      iserdes_master_data_inst
        (.O()
        ,.Q1(iserdes_data_lo[(8*i) + 7])
        ,.Q2(iserdes_data_lo[(8*i) + 6])
        ,.Q3(iserdes_data_lo[(8*i) + 5])
        ,.Q4(iserdes_data_lo[(8*i) + 4])
        ,.Q5(iserdes_data_lo[(8*i) + 3])
        ,.Q6(iserdes_data_lo[(8*i) + 2])
        ,.Q7(iserdes_data_lo[(8*i) + 1])
        ,.Q8(iserdes_data_lo[(8*i) + 0])
        ,.SHIFTOUT1()
        ,.SHIFTOUT2()
        ,.BITSLIP(ctrl_bitslip_lo[i])
        ,.CE1(1'b1)
        ,.CE2(1'b0)
        ,.CLKDIVP()
        ,.CLK(clk_i)
        ,.CLKB(~clk_i)
        ,.CLKDIV(clk_div_i)
        ,.OCLK(1'b0)
        ,.DYNCLKDIVSEL(1'b0)
        ,.DYNCLKSEL(1'b0)
        ,.D(1'b0)
        ,.DDLY(iodelay_data_lo[i])
        ,.OFB(1'b0)
        ,.OCLKB(1'b0)
        ,.RST(reset_i)
        ,.SHIFTIN1(1'b0)
        ,.SHIFTIN2(1'b0));

      bsg_zedboard_fmc_rx_data_bitslip_ctrl bitslip_ctrl_inst
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
