//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie_async_fifo.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_pcie_async_fifo #
  (parameter channel_p = 2)
  // core clk
  (input core_clk_i
  // core reset
  ,input core_reset_i
  // core data in
  ,input [channel_p - 1 : 0] core_valid_i
  ,input [31:0] core_data_i [channel_p - 1 : 0]
  ,output [channel_p - 1 : 0] core_ready_o
  // core data out
  ,output [channel_p - 1 : 0] core_valid_o
  ,output [31:0] core_data_o [channel_p - 1 : 0]
  ,input [channel_p - 1 : 0] core_yumi_i
  // pcie clk
  ,input pcie_clk_i
  // pcie reset
  ,input pcie_reset_i
  // pcie data in
  ,input [channel_p - 1 : 0] pcie_valid_i
  ,input [32*channel_p - 1 : 0] pcie_data_i
  ,output [channel_p - 1 : 0] pcie_ready_o
  // pcie data out
  ,output [channel_p - 1 : 0] pcie_valid_o
  ,output [32*channel_p - 1 : 0] pcie_data_o
  ,input [channel_p - 1 : 0] pcie_ready_i);

  logic [channel_p - 1 : 0] fi_full_lo;
  logic [channel_p - 1 : 0] fo_valid_lo;
  logic [channel_p - 1 : 0] fo_full_lo;

  logic [channel_p - 1 : 0] fi_valid_lo;
  logic [31:0] fi_data_lo [channel_p - 1 : 0];
  logic [channel_p - 1 : 0] btf_ready_lo;

  genvar i;
  generate
    for (i = 0; i < channel_p; i = i + 1) begin

      bsg_async_fifo #
        (.lg_size_p(4)
        ,.width_p(32))
      fi_inst
        // pcie data in
        (.w_clk_i(pcie_clk_i)
        ,.w_reset_i(pcie_reset_i)
        ,.w_enq_i(~fi_full_lo[i] & pcie_valid_i[i])
        ,.w_data_i(pcie_data_i[i*32 + 31 : i*32])
        ,.w_full_o(fi_full_lo[i])
        // core data out
        ,.r_clk_i(core_clk_i)
        ,.r_reset_i(core_reset_i)
        ,.r_deq_i(fi_valid_lo[i] & btf_ready_lo[i])
        ,.r_data_o(fi_data_lo[i])
        ,.r_valid_o(fi_valid_lo[i]));

      assign pcie_ready_o[i] = ~fi_full_lo[i];

      bsg_two_fifo #
        (.width_p(32))
      btf_inst
        (.clk_i(core_clk_i)
        ,.reset_i(core_reset_i)
        // in
        ,.v_i(fi_valid_lo[i])
        ,.data_i(fi_data_lo[i])
        ,.ready_o(btf_ready_lo[i])
        // out
        ,.v_o(core_valid_o[i])
        ,.data_o(core_data_o[i])
        ,.yumi_i(core_yumi_i[i]));

      bsg_async_fifo #
        (.lg_size_p(4)
        ,.width_p(32))
      fo_inst
        // core data in
        (.w_clk_i(core_clk_i)
        ,.w_reset_i(core_reset_i)
        ,.w_enq_i(~fo_full_lo[i] & core_valid_i[i])
        ,.w_data_i(core_data_i[i])
        ,.w_full_o(fo_full_lo[i])
        // pcie data out
        ,.r_clk_i(pcie_clk_i)
        ,.r_reset_i(pcie_reset_i)
        ,.r_deq_i(fo_valid_lo[i] & pcie_ready_i[i])
        ,.r_data_o(pcie_data_o[i*32 + 31 : i*32])
        ,.r_valid_o(fo_valid_lo[i]));

      assign core_ready_o[i] = ~fo_full_lo[i];
      assign pcie_valid_o[i] = fo_valid_lo[i];

    end
  endgenerate

endmodule
