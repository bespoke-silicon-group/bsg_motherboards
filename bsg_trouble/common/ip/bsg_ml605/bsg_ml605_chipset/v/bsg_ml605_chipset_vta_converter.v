//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_chipset_vta_converter
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_chipset_vta_converter
  (input clk_i
  ,input reset_i
  // pcie in
  ,input [5:0] pcie_valid_i
  ,input [31:0] pcie_data_i [5:0]
  ,output [5:0] pcie_yumi_o
  // pcie out
  ,output [5:0] pcie_valid_o
  ,output [31:0] pcie_data_o [5:0]
  ,input [5:0] pcie_ready_i
  // dram in
  ,input dram_valid_i
  ,input [31:0] dram_data_i
  ,output dram_thanks_o
  // dram out
  ,output dram_valid_o
  ,output [31:0] dram_data_o
  ,input dram_thanks_i
  // vta south
  ,input port3_sif vta_south_i
  ,output port3_sif vta_south_o
  // vta west
  ,input port3_sif vta_west_i
  ,output port3_sif vta_west_o
  // vta test network
  ,input port_tn_sif vta_tn_i
  ,output port_tn_sif vta_tn_o);

  // vta south

  // pcie[3] <---> south[0]

  bsg_ml605_chipset_pcie_to_vta p3s0
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // pcie in
    ,.pcie_valid_i(pcie_valid_i[3])
    ,.pcie_data_i(pcie_data_i[3])
    ,.pcie_yumi_o(pcie_yumi_o[3])
    // pcie out
    ,.pcie_valid_o(pcie_valid_o[3])
    ,.pcie_data_o(pcie_data_o[3])
    ,.pcie_ready_i(pcie_ready_i[3])
    // vta in
    ,.vta_valid_i(vta_south_i.valid[0])
    ,.vta_data_i(vta_south_i.data[0])
    ,.vta_thanks_o(vta_south_o.thanks[0])
    // vta out
    ,.vta_valid_o(vta_south_o.valid[0])
    ,.vta_data_o(vta_south_o.data[0])
    ,.vta_thanks_i(vta_south_i.thanks[0]));

  // dram <---> south[1]

  assign dram_valid_o = vta_south_i.valid[1];
  assign dram_data_o = vta_south_i.data[1];
  assign dram_thanks_o = vta_south_i.thanks[1];

  assign vta_south_o.valid[1] = dram_valid_i;
  assign vta_south_o.data[1] = dram_data_i;
  assign vta_south_o.thanks[1] = dram_thanks_i;

  // pcie[4] <---> south[2]

  bsg_ml605_chipset_pcie_to_vta p4s2
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // pcie in
    ,.pcie_valid_i(pcie_valid_i[4])
    ,.pcie_data_i(pcie_data_i[4])
    ,.pcie_yumi_o(pcie_yumi_o[4])
    // pcie out
    ,.pcie_valid_o(pcie_valid_o[4])
    ,.pcie_data_o(pcie_data_o[4])
    ,.pcie_ready_i(pcie_ready_i[4])
    // vta in
    ,.vta_valid_i(vta_south_i.valid[2])
    ,.vta_data_i(vta_south_i.data[2])
    ,.vta_thanks_o(vta_south_o.thanks[2])
    // vta out
    ,.vta_valid_o(vta_south_o.valid[2])
    ,.vta_data_o(vta_south_o.data[2])
    ,.vta_thanks_i(vta_south_i.thanks[2]));

  // vta west

  // pcie[0] <---> west[0]

  bsg_ml605_chipset_pcie_to_vta p0w0
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // pcie in
    ,.pcie_valid_i(pcie_valid_i[0])
    ,.pcie_data_i(pcie_data_i[0])
    ,.pcie_yumi_o(pcie_yumi_o[0])
    // pcie out
    ,.pcie_valid_o(pcie_valid_o[0])
    ,.pcie_data_o(pcie_data_o[0])
    ,.pcie_ready_i(pcie_ready_i[0])
    // vta in
    ,.vta_valid_i(vta_west_i.valid[0])
    ,.vta_data_i(vta_west_i.data[0])
    ,.vta_thanks_o(vta_west_o.thanks[0])
    // vta out
    ,.vta_valid_o(vta_west_o.valid[0])
    ,.vta_data_o(vta_west_o.data[0])
    ,.vta_thanks_i(vta_west_i.thanks[0]));

  // pcie[2] <---> west[1]

  bsg_ml605_chipset_pcie_to_vta p2w1
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // pcie in
    ,.pcie_valid_i(pcie_valid_i[2])
    ,.pcie_data_i(pcie_data_i[2])
    ,.pcie_yumi_o(pcie_yumi_o[2])
    // pcie out
    ,.pcie_valid_o(pcie_valid_o[2])
    ,.pcie_data_o(pcie_data_o[2])
    ,.pcie_ready_i(pcie_ready_i[2])
    // vta in
    ,.vta_valid_i(vta_west_i.valid[1])
    ,.vta_data_i(vta_west_i.data[1])
    ,.vta_thanks_o(vta_west_o.thanks[1])
    // vta out
    ,.vta_valid_o(vta_west_o.valid[1])
    ,.vta_data_o(vta_west_o.data[1])
    ,.vta_thanks_i(vta_west_i.thanks[1]));

  // pcie[1] <---> west[2]

  bsg_ml605_chipset_pcie_to_vta p1w2
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // pcie in
    ,.pcie_valid_i(pcie_valid_i[1])
    ,.pcie_data_i(pcie_data_i[1])
    ,.pcie_yumi_o(pcie_yumi_o[1])
    // pcie out
    ,.pcie_valid_o(pcie_valid_o[1])
    ,.pcie_data_o(pcie_data_o[1])
    ,.pcie_ready_i(pcie_ready_i[1])
    // vta in
    ,.vta_valid_i(vta_west_i.valid[2])
    ,.vta_data_i(vta_west_i.data[2])
    ,.vta_thanks_o(vta_west_o.thanks[2])
    // vta out
    ,.vta_valid_o(vta_west_o.valid[2])
    ,.vta_data_o(vta_west_o.data[2])
    ,.vta_thanks_i(vta_west_i.thanks[2]));

  // vta test network

  // pcie[5] <--- tn

  raw_tn_packet_s tn_fifo_data_li, tn_fifo_data_lo;

  logic tn_fifo_valid_li;
  logic tn_fifo_ready_lo;
  logic tn_fifo_valid_lo;

  assign tn_fifo_data_li = vta_tn_i.tn_data;
  assign tn_fifo_valid_li = (tn_fifo_data_li.tc != kNOP)? 1'b1 : 1'b0;

  assign vta_tn_o.tn_valid = 1'b0;
  assign vta_tn_o.tn_data = '0;
  assign vta_tn_o.tn_thanks = tn_fifo_ready_lo & tn_fifo_valid_li;

  bsg_fifo_1r1w_large #
    (.width_p($bits(raw_tn_packet_s))
    ,.els_p(8))
  tn_fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // in
    ,.v_i(tn_fifo_valid_li)
    ,.data_i(tn_fifo_data_li)
    ,.ready_o(tn_fifo_ready_lo)
    // out
    ,.v_o(tn_fifo_valid_lo)
    ,.data_o(tn_fifo_data_lo)
    ,.yumi_i(tn_fifo_valid_lo));

  assign pcie_valid_o[5] = tn_fifo_valid_lo;
  assign pcie_data_o[5] = {tn_fifo_data_lo.tc, tn_fifo_data_lo.data[29:0]};
  assign pcie_yumi_o[5] = tn_fifo_valid_lo;

endmodule
