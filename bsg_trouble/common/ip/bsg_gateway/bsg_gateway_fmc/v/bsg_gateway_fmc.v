//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

// Pin names are explicitly given in the module
// signature because these pins were selected according to
// ML-605 LPC and DT FPGA subbanking/clocking constraints,
// and top-level instantiators need to obey these pin assignments.
//
// DoubleTrouble's FMC pins are grouped into two sub-banks
//   subbank BR: F17-F33 (F17 and F18 are clock capable (CC) on DT side) = 17 pins
//   subbank BL: F0-F16, FCLK0_M2C, FCLK1_M2C (F0 and FCLK0_M2C are DT CC) = 19 pins
//
// ML-605 FMC LPC pins are grouped into two banks
//   bank 15: F17-F33 (F17, F18 are ML605 CC) = 17 pins.
//   bank 16: F0-F16, FCLK1_M2C (F0,F1,FCLK1_M2C are ML605 CC) = 18 pins
//   bank 34: FCLK0_M2C = 1 pin
//
// Generally, input clocks must be part of the bank of the data signals they are matched with at
// least in the DT board. And input clocks must be connected to "CC" clock capable pins.
//
// see https://docs.google.com/spreadsheets/d/1v_qp4qbDF0bKDqPtvAs_vNdXaMVtJgvdCSDbODfMDFM/edit#gid=2051376245
// for the document where we derived pin mappings
// and http://bjump.org/pdf/Double_Trouble_V1.00_Schematic.pdf and
// http://www.xilinx.com/support/documentation/boards_and_kits/xtp052_ml605_schematics.pdf for board schematics.
//
// Pin allocation
// --------------
// The following pin allocation is intended to work with two boards Xilinx
// ML605 and Zedboard. There are two pins that change between these two boards.
// These pins are for tx-clock-out and tx-data[0]. The remaining pins stays the same
//
// Current TX pin allocation (subbank BL) is:
//  tx clock in:  FCLK0_M2C_P (this pin alone in ML605 bank 34 so cannot be part of a source sync channel)
//  tx clock out: FCLK1_M2C_P (for bsg_ml605) or {0} (for bsg_zedboard)
//  tx data[0]:   {0}         (for bsg ml605) or {1} (for bsg_zedboard)
//  tx data[9:1]: {8,7,4,9,14,10,11,13,15,16}
//  unalloc[5:0]: {1,2,3,5,6,12}
//
// Current RX pin allocation (subbank BR) is:
//  rx clock out:  {17}
//  rx data[10:0]: {22,27,21,26,29,25,28,32,30,33,31}
//  reset out:     {23}
//  reset in:      {20}
//  unalloc[2:0]:  {18,19,24}
//
//  For those seeking more bandwidth, this could be potentially swizzled in the following way
//          1-6: tx data (5 more pins)
//           12: reset in, reset out (break the differential pair into two single ended signals)
//  18-20,23,24: rx data (5 more pins)
//
//  This would allow for a full 16 bits in each direction, differential.

module bsg_gateway_fmc
  (input clk_i
  // fmc reset out
  ,output fmc_reset_o
  // host reset in
  ,input host_reset_i
  // data in
  ,input valid_i
  ,input [79:0] data_i
  ,output ready_o
  // data out
  ,output valid_o
  ,output [79:0] data_o
  ,input ready_i
  // fmc gateway reset in
  ,input F20_P, F20_N
  // fmc host reset out
  ,output F23_P, F23_N
  // fmc tx clk in
  ,input FCLK0_M2C_P, FCLK0_M2C_N
  // fmc tx clk out

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
  ,output F8_P, F8_N
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

  // fmc reset in

  IBUFDS #
    (.DIFF_TERM("TRUE"))
  ibufds_reset
    (.I(F20_P) ,.IB(F20_N)
    ,.O(fmc_reset_o));

  // fmc host reset out

  OBUFDS obufds_core_calib_reset
    (.I(~host_reset_i) // swapped due to pcb routing
    ,.O(F23_P) ,.OB(F23_N));

  // fmc buffer

  logic [87:0] tx_data_lo, rx_data_lo;
  logic tx_clk_div_lo, rx_clk_div_lo;
  logic tx_cal_done_lo, rx_cal_done_lo;

  bsg_gateway_fmc_buffer fmc_buffer
    // core clk domain
    (.core_clk_i(clk_i)
    // core clk domain data in
    ,.core_valid_i(valid_i)
    ,.core_data_i(data_i)
    ,.core_ready_o(ready_o)
    // core clk domain data out
    ,.core_valid_o(valid_o)
    ,.core_data_o(data_o)
    ,.core_ready_i(ready_i)
    // fmc rx clk domain
    ,.rx_clk_div_i(rx_clk_div_lo)
    ,.rx_data_i(rx_data_lo)
    ,.rx_cal_done_i(rx_cal_done_lo)
    // fmc tx clk domain
    ,.tx_clk_div_i(tx_clk_div_lo)
    ,.tx_data_o(tx_data_lo)
    ,.tx_cal_done_i(tx_cal_done_lo));

  // fmc tx

  bsg_gateway_fmc_tx fmc_tx
    (.reset_i(host_reset_i)
    ,.clk_div_o(tx_clk_div_lo)
    ,.data_i(tx_data_lo)
    ,.cal_done_o(tx_cal_done_lo)
    // fmc tx clk in
    ,.FCLK0_M2C_P(FCLK0_M2C_P) ,.FCLK0_M2C_N(FCLK0_M2C_N)
`ifdef BSG_ML605_FMC
    // fmc tx clk out
    ,.FCLK1_M2C_P(FCLK1_M2C_P) ,.FCLK1_M2C_N(FCLK1_M2C_N)
    // fmc tx data out [0]
    ,.F0_P(F0_P) ,.F0_N(F0_N)
`else
`ifdef BSG_ZEDBOARD_FMC
    // fmc tx clk out
    ,.F0_P(F0_P) ,.F0_N(F0_N)
    // fmc tx data out [0]
    ,.F1_P(F1_P) ,.F1_N(F1_N)
`endif
`endif
    // fmc tx data out [9:1]
    ,.F16_P(F16_P) ,.F16_N(F16_N)
    ,.F15_P(F15_P) ,.F15_N(F15_N)
    ,.F13_P(F13_P) ,.F13_N(F13_N)
    ,.F11_P(F11_P) ,.F11_N(F11_N)
    ,.F10_P(F10_P) ,.F10_N(F10_N)
    ,.F14_P(F14_P) ,.F14_N(F14_N)
    ,.F9_P(F9_P) ,.F9_N(F9_N)
    ,.F4_P(F4_P) ,.F4_N(F4_N)
    ,.F7_P(F7_P) ,.F7_N(F7_N)
    ,.F8_P(F8_P) ,.F8_N(F8_N));

  // fmc rx

  bsg_gateway_fmc_rx fmc_rx
    (.reset_i(host_reset_i)
    ,.clk_div_o(rx_clk_div_lo)
    ,.data_o(rx_data_lo)
    ,.cal_done_o(rx_cal_done_lo)
    // fmc rx clk in
    ,.F17_P(F17_P) ,.F17_N(F17_N)
    // fmc rx data in
    ,.F31_P(F31_P) ,.F31_N(F31_N)
    ,.F33_P(F33_P) ,.F33_N(F33_N)
    ,.F30_P(F30_P) ,.F30_N(F30_N)
    ,.F32_P(F32_P) ,.F32_N(F32_N)
    ,.F28_P(F28_P) ,.F28_N(F28_N)
    ,.F25_P(F25_P) ,.F25_N(F25_N)
    ,.F29_P(F29_P) ,.F29_N(F29_N)
    ,.F26_P(F26_P) ,.F26_N(F26_N)
    ,.F21_P(F21_P) ,.F21_N(F21_N)
    ,.F27_P(F27_P) ,.F27_N(F27_N)
    ,.F22_P(F22_P) ,.F22_N(F22_N));

endmodule
