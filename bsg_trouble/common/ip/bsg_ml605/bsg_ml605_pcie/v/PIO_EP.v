//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: PIO_EP.v
//
// Description: Endpoint Programmed I/O module.
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

`timescale 1ns/1ns

`define PIO_64 1
`define PIO_RX_ENGINE PIO_64_RX_ENGINE
`define PIO_TX_ENGINE PIO_64_TX_ENGINE

module PIO_EP #
  (parameter channel_p = 2)
  (input clk
  ,input rst_n
`ifdef PIO_64
  ,output [63:0] trn_td
  ,output [7:0] trn_trem_n
`else // PIO_64
  `ifdef PIO_128
    ,output [127:0] trn_td
    ,output [1:0] trn_trem_n
  `else // PIO_128
    ,output [31:0] trn_td
  `endif
`endif // PIO_64
  ,output trn_tsof_n
  ,output trn_teof_n
  ,output trn_tsrc_dsc_n
  ,output trn_tsrc_rdy_n
  ,input trn_tdst_dsc_n
  ,input trn_tdst_rdy_n
`ifdef PIO_64
  ,input [63:0] trn_rd
  ,input [7:0] trn_rrem_n
`else // PIO_64
  `ifdef PIO_128
    ,input [127:0] trn_rd
    ,input [1:0] trn_rrem_n
  `else
    ,input [31:0] trn_rd
  `endif
`endif // PIO_64
  ,input trn_rsof_n
  ,input trn_reof_n
  ,input trn_rsrc_rdy_n
  ,input [6:0] trn_rbar_hit_n
  ,input trn_rsrc_dsc_n
  ,output trn_rdst_rdy_n
  ,output req_compl_o
  ,output compl_done_o
  ,input [15:0] cfg_completer_id
  ,input cfg_bus_mstr_enable
  // status register
  ,input [31:0] status_register_i
  // reset out
  ,output reset_o
  // data in
  ,input [channel_p - 1 : 0] valid_i
  ,input [32*channel_p - 1 : 0] data_i
  ,output [channel_p - 1 : 0] ready_o
  // data out
  ,output [channel_p - 1 : 0] valid_o
  ,output [32*channel_p - 1 : 0] data_o
  ,input [channel_p - 1 : 0] ready_i);

  wire [10:0] rd_addr;
  wire [3:0] rd_be;
  wire [31:0] rd_data;

  wire [10:0] wr_addr;
  wire [7:0] wr_be;
  wire [31:0] wr_data;
  wire wr_en;
  wire wr_busy;

  wire req_compl;
  wire compl_done;

  wire [2:0] req_tc;

  wire req_td;
  wire req_ep;

  wire [1:0] req_attr;
  wire [9:0] req_len;
  wire [15:0] req_rid;
  wire [7:0] req_tag;
  wire [7:0] req_be;
  wire [12:0] req_addr;

  logic reset_lo;

  bsg_ml605_pio_ep #
    (.channel_p(channel_p))
  bmpe_inst
    (.clk_i(clk)
    ,.reset_i(~rst_n)
    // status register
    ,.status_register_i(status_register_i)
    // reset out
    ,.reset_o(reset_lo)
    // data in
    ,.valid_i(valid_i)
    ,.data_i(data_i)
    ,.ready_o(ready_o)
    // data out
    ,.valid_o(valid_o)
    ,.data_o(data_o)
    ,.ready_i(ready_i)
    // read
    ,.rd_addr_i(rd_addr)
    ,.rd_be_i(rd_be)
    ,.rd_data_o({rd_data[7:0], rd_data[15:8], rd_data[23:16], rd_data[31:24]})
    // write
    ,.wr_en_i(wr_en)
    ,.wr_addr_i(wr_addr)
    ,.wr_data_i({wr_data[7:0], wr_data[15:8], wr_data[23:16], wr_data[31:24]})
    ,.wr_be_i(wr_be)
    ,.wr_busy_o(wr_busy));

  assign reset_o = reset_lo;

  // Local-Link Receive Controller
  `PIO_RX_ENGINE EP_RX
    (.clk(clk)                              // I
    ,.rst_n(rst_n)                          // I
    ,.reset_i(reset_lo)
    // LocalLink Rx
    ,.trn_rd(trn_rd)                        // I [63/31:0]
  `ifndef PIO_32
    ,.trn_rrem_n(trn_rrem_n)                // I [7:0]
  `endif // not PIO_32
    ,.trn_rsof_n(trn_rsof_n)                // I
    ,.trn_reof_n(trn_reof_n)                // I
    ,.trn_rsrc_rdy_n(trn_rsrc_rdy_n)        // I
    ,.trn_rsrc_dsc_n(trn_rsrc_dsc_n)        // I
    ,.trn_rbar_hit_n(trn_rbar_hit_n)        // I [6:0]
    ,.trn_rdst_rdy_n(trn_rdst_rdy_n)        // O
    // Handshake with Tx engine
    ,.req_compl_o(req_compl)                // O
    ,.compl_done_i(compl_done)              // I
    ,.req_tc_o(req_tc)                      // O [2:0]
    ,.req_td_o(req_td)                      // O
    ,.req_ep_o(req_ep)                      // O
    ,.req_attr_o(req_attr)                  // O [1:0]
    ,.req_len_o(req_len)                    // O [9:0]
    ,.req_rid_o(req_rid)                    // O [15:0]
    ,.req_tag_o(req_tag)                    // O [7:0]
    ,.req_be_o(req_be)                      // O [7:0]
    ,.req_addr_o(req_addr)                  // O [12:0]
    // Memory Write Port
    ,.wr_addr_o(wr_addr)                    // O [10:0]
    ,.wr_be_o(wr_be)                        // O [7:0]
    ,.wr_data_o(wr_data)                    // O [31:0]
    ,.wr_en_o(wr_en)                        // O
    ,.wr_busy_i(wr_busy));                  // I

  // Local-Link Transmit Controller
  `PIO_TX_ENGINE EP_TX
    (.clk(clk)                                     // I
    ,.rst_n(~reset_lo & rst_n)                     // I
    // LocalLink Tx
    ,.trn_td(trn_td)                               // O [63/31:0]
  `ifndef PIO_32
    ,.trn_trem_n(trn_trem_n)                       // O [7:0]
  `endif // not PIO_32
    ,.trn_tsof_n(trn_tsof_n)                       // O
    ,.trn_teof_n(trn_teof_n)                       // O
    ,.trn_tsrc_dsc_n(trn_tsrc_dsc_n)               // O
    ,.trn_tsrc_rdy_n(trn_tsrc_rdy_n)               // O
    ,.trn_tdst_dsc_n(trn_tdst_dsc_n)               // I
    ,.trn_tdst_rdy_n(trn_tdst_rdy_n)               // I
    // Handshake with Rx engine
    ,.req_compl_i(req_compl)                       // I
    ,.compl_done_o(compl_done)                     // 0
    ,.req_tc_i(req_tc)                             // I [2:0]
    ,.req_td_i(req_td)                             // I
    ,.req_ep_i(req_ep)                             // I
    ,.req_attr_i(req_attr)                         // I [1:0]
    ,.req_len_i(req_len)                           // I [9:0]
    ,.req_rid_i(req_rid)                           // I [15:0]
    ,.req_tag_i(req_tag)                           // I [7:0]
    ,.req_be_i(req_be)                             // I [7:0]
    ,.req_addr_i(req_addr)                         // I [12:0]
    // Read Port
    ,.rd_addr_o(rd_addr)                           // O [10:0]
    ,.rd_be_o(rd_be)                               // O [3:0]
    ,.rd_data_i(rd_data)                           // I [31:0]
    ,.completer_id_i(cfg_completer_id)             // I [15:0]
    ,.cfg_bus_mstr_enable_i(cfg_bus_mstr_enable)); // I

  assign req_compl_o  = req_compl;
  assign compl_done_o = compl_done;

endmodule
