//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_tx_data.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_tx_data
  (input reset_i
  ,input clk_p_i, clk_n_i
  ,input clk_div_i
  ,input clk_serdes_strobe_i
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

  logic [10:0] oserdes_master_shiftout_1_lo, oserdes_master_shiftout_2_lo;
  logic [10:0] oserdes_slave_shiftout_3_lo, oserdes_slave_shiftout_4_lo;

  logic [10:0] oserdes_data_lo;

  genvar i;
  generate
    for (i = 0; i < 11; i++) begin

      OSERDES2 #
        (.DATA_WIDTH(8)
        ,.DATA_RATE_OQ("DDR")
        ,.DATA_RATE_OT("DDR")
        ,.SERDES_MODE("MASTER")
        ,.OUTPUT_MODE("DIFFERENTIAL"))
      oserdes_master_data
        (.OQ(oserdes_data_lo[i])
        ,.OCE(1'b1)
        ,.CLK0(clk_p_i)
        ,.CLK1(clk_n_i)
        ,.IOCE(clk_serdes_strobe_i)
        ,.RST(1'b0)
        ,.CLKDIV(clk_div_i)
        ,.D4(swap_data_lo[(8*i) + 7])
        ,.D3(swap_data_lo[(8*i) + 6])
        ,.D2(swap_data_lo[(8*i) + 5])
        ,.D1(swap_data_lo[(8*i) + 4])
        ,.TQ()
        ,.T1(1'b0)
        ,.T2(1'b0)
        ,.T3(1'b0)
        ,.T4(1'b0)
        ,.TRAIN(1'b0)
        ,.TCE(1'b1)
        ,.SHIFTIN1(1'b1)
        ,.SHIFTIN2(1'b1)
        ,.SHIFTIN3(oserdes_slave_shiftout_3_lo[i])
        ,.SHIFTIN4(oserdes_slave_shiftout_4_lo[i])
        ,.SHIFTOUT1(oserdes_master_shiftout_1_lo[i])
        ,.SHIFTOUT2(oserdes_master_shiftout_2_lo[i])
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
        ,.CLK0(clk_p_i)
        ,.CLK1(clk_n_i)
        ,.IOCE(clk_serdes_strobe_i)
        ,.RST(1'b0)
        ,.CLKDIV(clk_div_i)
        ,.D4(swap_data_lo[(8*i) + 3])
        ,.D3(swap_data_lo[(8*i) + 2])
        ,.D2(swap_data_lo[(8*i) + 1])
        ,.D1(swap_data_lo[(8*i) + 0])
        ,.TQ()
        ,.T1(1'b0)
        ,.T2(1'b0)
        ,.T3(1'b0)
        ,.T4(1'b0)
        ,.TRAIN(1'b0)
        ,.TCE(1'b1)
        ,.SHIFTIN1(oserdes_master_shiftout_1_lo[i])
        ,.SHIFTIN2(oserdes_master_shiftout_2_lo[i])
        ,.SHIFTIN3(1'b1)
        ,.SHIFTIN4(1'b1)
        ,.SHIFTOUT1()
        ,.SHIFTOUT2()
        ,.SHIFTOUT3(oserdes_slave_shiftout_3_lo[i])
        ,.SHIFTOUT4(oserdes_slave_shiftout_4_lo[i]));

      OBUFDS obufds_data
        (.I(oserdes_data_lo[i])
        ,.O(data_p_o[i]) ,.OB(data_n_o[i]));

  end
  endgenerate

endmodule
