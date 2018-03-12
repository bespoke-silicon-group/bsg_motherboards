//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_tx.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_tx
  (input reset_i
  ,output clk_div_o
  ,input [87:0] data_i
  ,output cal_done_o
  // fmc tx clk in
  ,input FCLK0_M2C_P, FCLK0_M2C_N

`ifdef BSG_ML605_FMC
  // fmc tx clk out
  ,output FCLK1_M2C_P, FCLK1_M2C_N
  // fmc tx data out [0]
  ,output F0_P, F0_N
`else
`ifdef BSG_ZEDBOARD_FMC
  // fmc tx clk out
  ,output F0_P, F0_N
  // fmc tx data out [0]
  ,output F1_P, F1_N
`endif
`endif

  // fmc tx data out [9:1]
  ,output F16_P, F16_N
  ,output F15_P, F15_N
  ,output F13_P, F13_N
  ,output F11_P, F11_N
  ,output F10_P, F10_N
  ,output F14_P, F14_N
  ,output F9_P, F9_N
  ,output F4_P, F4_N
  ,output F7_P, F7_N
  ,output F8_P, F8_N);

  logic data_clk_div_lo;
  logic data_clk_serdes_strobe_lo;
  logic data_clk_p_lo, data_clk_n_lo;

  bsg_gateway_fmc_tx_clk tx_clk
    (.clk_p_i(FCLK0_M2C_P) ,.clk_n_i(FCLK0_M2C_N)
`ifdef BSG_ML605_FMC
    ,.clk_p_o(FCLK1_M2C_P) ,.clk_n_o(FCLK1_M2C_N)
`else
`ifdef BSG_ZEDBOARD_FMC
    ,.clk_p_o(F0_P) ,.clk_n_o(F0_N)
`endif
`endif
    ,.data_clk_div_o(data_clk_div_lo)
    ,.data_clk_serdes_strobe_o(data_clk_serdes_strobe_lo)
    ,.data_clk_p_o(data_clk_p_lo) ,.data_clk_n_o(data_clk_n_lo));

  assign clk_div_o = data_clk_div_lo;

  logic [10:0] data_p_lo, data_n_lo;

  // 10 MSB bits [10:1]

  assign {F8_P
         ,F7_P
         ,F4_P
         ,F9_P
         ,F14_P
         ,F10_P
         ,F11_P
         ,F13_P
         ,F15_P
         ,F16_P} = data_p_lo[10:1];

  assign {F8_N
         ,F7_N
         ,F4_N
         ,F9_N
         ,F14_N
         ,F10_N
         ,F11_N
         ,F13_N
         ,F15_N
         ,F16_N} = data_n_lo[10:1];

  // bit[0]
`ifdef BSG_ML605_FMC

  assign F0_P = data_p_lo[0];
  assign F0_N = data_n_lo[0];

`else
`ifdef BSG_ZEDBOARD_FMC

  assign F1_P = data_p_lo[0];
  assign F1_N = data_n_lo[0];

`endif
`endif

  bsg_gateway_fmc_tx_data tx_data
    (.reset_i(reset_i)
    ,.clk_p_i(data_clk_p_lo) ,.clk_n_i(data_clk_n_lo)
    ,.clk_div_i(data_clk_div_lo)
    ,.clk_serdes_strobe_i(data_clk_serdes_strobe_lo)
    ,.data_i(data_i)
    ,.cal_done_o(cal_done_o)
    ,.data_p_o(data_p_lo) ,.data_n_o(data_n_lo));

endmodule
