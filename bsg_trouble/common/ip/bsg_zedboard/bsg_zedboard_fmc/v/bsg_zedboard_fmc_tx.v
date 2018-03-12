//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_zedboard_fmc_tx.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_zedboard_fmc_tx
  (input clk_i
  ,input clk_div_i
  ,input reset_i
  ,input [87:0] data_i
  ,output cal_done_o
  // fmc tx clk out
  ,output FMC_LA17_CC_P, FMC_LA17_CC_N
  // fmc tx data out
  ,output FMC_LA31_P, FMC_LA31_N
  ,output FMC_LA33_P, FMC_LA33_N
  ,output FMC_LA30_P, FMC_LA30_N
  ,output FMC_LA32_P, FMC_LA32_N
  ,output FMC_LA28_P, FMC_LA28_N
  ,output FMC_LA25_P, FMC_LA25_N
  ,output FMC_LA29_P, FMC_LA29_N
  ,output FMC_LA26_P, FMC_LA26_N
  ,output FMC_LA21_P, FMC_LA21_N
  ,output FMC_LA27_P, FMC_LA27_N
  ,output FMC_LA22_P, FMC_LA22_N);

  // fmc tx clk out

  bsg_zedboard_fmc_tx_clk tx_clk_inst
    (.clk_i(clk_i)
    ,.clk_p_o(FMC_LA17_CC_P) ,.clk_n_o(FMC_LA17_CC_N));

  // fmc tx data out

  logic [10:0] data_p_lo, data_n_lo;

  assign {FMC_LA22_P
         ,FMC_LA27_P
         ,FMC_LA21_P
         ,FMC_LA26_P
         ,FMC_LA29_P
         ,FMC_LA25_P
         ,FMC_LA28_P
         ,FMC_LA32_P
         ,FMC_LA30_P
         ,FMC_LA33_P
         ,FMC_LA31_P} = data_p_lo;

  assign {FMC_LA22_N
         ,FMC_LA27_N
         ,FMC_LA21_N
         ,FMC_LA26_N
         ,FMC_LA29_N
         ,FMC_LA25_N
         ,FMC_LA28_N
         ,FMC_LA32_N
         ,FMC_LA30_N
         ,FMC_LA33_N
         ,FMC_LA31_N} = data_n_lo;

  bsg_zedboard_fmc_tx_data tx_data_inst
    (.clk_i(clk_i)
    ,.clk_div_i(clk_div_i)
    ,.reset_i(reset_i)
    ,.data_i(data_i)
    ,.cal_done_o(cal_done_o)
    ,.data_p_o(data_p_lo) ,.data_n_o(data_n_lo));

endmodule
