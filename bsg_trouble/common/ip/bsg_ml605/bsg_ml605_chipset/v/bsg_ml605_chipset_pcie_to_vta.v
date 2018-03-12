//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_chipset_pcie_to_vta
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_chipset_pcie_to_vta
  (input clk_i
  ,input reset_i
  // pcie in
  ,input pcie_valid_i
  ,input [31:0] pcie_data_i
  ,output pcie_yumi_o
  // pcie out
  ,output pcie_valid_o
  ,output [31:0] pcie_data_o
  ,input pcie_ready_i
  // vta in
  ,input vta_valid_i
  ,input [31:0] vta_data_i
  ,output vta_thanks_o
  // vta out
  ,output vta_valid_o
  ,output [31:0] vta_data_o
  ,input vta_thanks_i);

  logic credit_available_lo;
  logic [2:0] credit_cnt_lo;
  logic fifo_ready_lo;
  logic fifo_valid_lo;
  logic [31:0] fifo_data_lo;

  bsg_counter_up_down #
    (.max_val_p(4)
    ,.init_val_p(4))
  credit_cnt
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.up_i(vta_thanks_i)
    ,.down_i(pcie_valid_i & credit_available_lo)
    ,.count_o(credit_cnt_lo));

  assign vta_valid_o = pcie_valid_i;
  assign vta_data_o = pcie_data_i;
  assign credit_available_lo = (| credit_cnt_lo);
  assign pcie_yumi_o = pcie_valid_i & credit_available_lo;

  bsg_fifo_1r1w_large #
    (.width_p(32)
    ,.els_p(8))
  fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // in
    ,.v_i(vta_valid_i)
    ,.data_i(vta_data_i)
    ,.ready_o(fifo_ready_lo)
    // out
    ,.v_o(fifo_valid_lo)
    ,.data_o(fifo_data_lo)
    ,.yumi_i(fifo_valid_lo & pcie_ready_i));

  assign vta_thanks_o = fifo_ready_lo & vta_valid_i;
  assign pcie_valid_o = fifo_valid_lo;
  assign pcie_data_o = fifo_data_lo;

endmodule
