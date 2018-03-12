//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_fmc_tx_data.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_fmc_tx_data
  (input clk_i
  ,input clk_div_i
  ,input reset_i
  ,input [87:0] data_i
  ,output cal_done_o
  ,output [10:0] data_p_o, data_n_o);

  logic [9:0] cnt_r;

  always_ff @(posedge clk_div_i)
    if (reset_i == 1'b1)
      cnt_r <= 10'd0;
    else if (cnt_r < 10'd1023)
      cnt_r <= cnt_r + 1;

  logic [87:0] data_cal_first_pattern;
  logic [87:0] data_cal_second_pattern;

  assign data_cal_first_pattern = {11{8'h2C}};
  assign data_cal_second_pattern = {11{8'hF8}};

  logic [87:0] swap_data_lo, data_lo;

  always_comb
    if (cnt_r < 10'd1008)
      data_lo = data_cal_first_pattern;
    else if (cnt_r < 10'd1009)
      data_lo = data_cal_second_pattern;
    else if (cnt_r < 10'd1023)
      data_lo = {11{8'h00}};
    else
      data_lo = data_i;

  assign swap_data_lo = ~data_lo; // swapped due to pcb routing

  assign cal_done_o = (cnt_r == 10'd1023)? 1'b1 : 1'b0;

  logic [10:0] oserdes_data_lo;
  logic [10:0] oserdes_slave_shiftout_1_lo, oserdes_slave_shiftout_2_lo;

  genvar i;
  generate
    for (i = 0; i < 11; i++) begin

      OSERDESE1 #
        (.DATA_RATE_OQ("DDR")
        ,.DATA_RATE_TQ("SDR")
        ,.DATA_WIDTH(8)
        ,.DDR3_DATA(1)
        ,.INIT_OQ(1'b0)
        ,.INIT_TQ(1'b0)
        ,.INTERFACE_TYPE("DEFAULT")
        ,.ODELAY_USED(0)
        ,.SERDES_MODE("MASTER")
        ,.SRVAL_OQ(1'b0)
        ,.SRVAL_TQ(1'b0)
        ,.TRISTATE_WIDTH(1))
      oserdes_master_data_inst
        (.SHIFTOUT1()
        ,.SHIFTOUT2()
        ,.TFB()
        ,.TQ()
        ,.OCBEXTEND()
        ,.OFB()
        ,.OQ(oserdes_data_lo[i])
        ,.CLK(clk_i)
        ,.CLKDIV(clk_div_i)
        ,.CLKPERF()
        ,.CLKPERFDELAY()
        ,.D1(swap_data_lo[(8*i) + 0])
        ,.D2(swap_data_lo[(8*i) + 1])
        ,.D3(swap_data_lo[(8*i) + 2])
        ,.D4(swap_data_lo[(8*i) + 3])
        ,.D5(swap_data_lo[(8*i) + 4])
        ,.D6(swap_data_lo[(8*i) + 5])
        ,.OCE(1'b1)
        ,.ODV(1'b0)
        ,.RST(reset_i)
        ,.SHIFTIN1(oserdes_slave_shiftout_1_lo[i])
        ,.SHIFTIN2(oserdes_slave_shiftout_2_lo[i])
        ,.T1(1'b0)
        ,.T2(1'b0)
        ,.T3(1'b0)
        ,.T4(1'b0)
        ,.TCE(1'b0)
        ,.WC(1'b0));

      OSERDESE1 #
        (.DATA_RATE_OQ("DDR")
        ,.DATA_RATE_TQ("SDR")
        ,.DATA_WIDTH(8)
        ,.DDR3_DATA(1)
        ,.INIT_OQ(1'b0)
        ,.INIT_TQ(1'b0)
        ,.INTERFACE_TYPE("DEFAULT")
        ,.ODELAY_USED(0)
        ,.SERDES_MODE("SLAVE")
        ,.SRVAL_OQ(1'b0)
        ,.SRVAL_TQ(1'b0)
        ,.TRISTATE_WIDTH(1))
      oserdes_slave_data_inst
        (.SHIFTOUT1(oserdes_slave_shiftout_1_lo[i])
        ,.SHIFTOUT2(oserdes_slave_shiftout_2_lo[i])
        ,.TFB()
        ,.TQ()
        ,.OCBEXTEND()
        ,.OFB()
        ,.OQ()
        ,.CLK(clk_i)
        ,.CLKDIV(clk_div_i)
        ,.CLKPERF()
        ,.CLKPERFDELAY()
        ,.D1()
        ,.D2()
        ,.D3(swap_data_lo[(8*i) + 6])
        ,.D4(swap_data_lo[(8*i) + 7])
        ,.D5()
        ,.D6()
        ,.OCE(1'b1)
        ,.ODV(1'b0)
        ,.RST(reset_i)
        ,.SHIFTIN1(1'b0)
        ,.SHIFTIN2(1'b0)
        ,.T1(1'b0)
        ,.T2(1'b0)
        ,.T3(1'b0)
        ,.T4(1'b0)
        ,.TCE(1'b0)
        ,.WC(1'b0));

      OBUFDS #
        (.IOSTANDARD("LVDS_25"))
      obufds_data_inst
        (.I(oserdes_data_lo[i])
        ,.O(data_p_o[i]) ,.OB(data_n_o[i]));

    end
  endgenerate

endmodule
