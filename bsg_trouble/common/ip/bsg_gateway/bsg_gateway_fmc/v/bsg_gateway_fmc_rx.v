//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_rx.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_rx
  (input reset_i
  ,output clk_div_o
  ,output [87:0] data_o
  ,output cal_done_o
  // fmc rx clk in
  ,input F17_P, F17_N
  // fmc rx data in
  ,input F31_P, F31_N
  ,input F33_P, F33_N
  ,input F30_P, F30_N
  ,input F32_P, F32_N
  ,input F28_P, F28_N
  ,input F25_P, F25_N
  ,input F29_P, F29_N
  ,input F26_P, F26_N
  ,input F21_P, F21_N
  ,input F27_P, F27_N
  ,input F22_P, F22_N);

  // fmc rx clk in

  logic clk_p_lo, clk_n_lo;
  logic clk_div_lo, clk_serdes_strobe_lo;

  bsg_gateway_fmc_rx_clk rx_clk
    (.clk_p_i(F17_P) ,.clk_n_i(F17_N)
    ,.clk_p_o(clk_p_lo) ,.clk_n_o(clk_n_lo)
    ,.clk_serdes_strobe_o(clk_serdes_strobe_lo)
    ,.clk_div_o(clk_div_lo));

  assign clk_div_o = clk_div_lo;

  // fmc rx data in

  logic [10:0] data_p_lo, data_n_lo;

  assign data_p_lo = {F22_P, F27_P, F21_P, F26_P, F29_P, F25_P, F28_P, F32_P, F30_P, F33_P, F31_P};
  assign data_n_lo = {F22_N, F27_N, F21_N, F26_N, F29_N, F25_N, F28_N, F32_N, F30_N, F33_N, F31_N};

  bsg_gateway_fmc_rx_data rx_data
    (.reset_i(reset_i)
    ,.clk_p_i(clk_p_lo) ,.clk_n_i(clk_n_lo)
    ,.clk_div_i(clk_div_lo)
    ,.clk_serdes_strobe_i(clk_serdes_strobe_lo)
    ,.data_p_i(data_p_lo) ,.data_n_i(data_n_lo)
    ,.cal_done_o(cal_done_o)
    ,.data_o(data_o));

endmodule
