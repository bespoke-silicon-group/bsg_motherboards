//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: PIO.v
//
// Description: Programmed I/O module. Design implements 8 KBytes of programmable
//              memory space. Host processor can access this memory space using
//              Memory Read 32 and Memory Write 32 TLPs. Design accepts
//              1 Double Word(DW) payload length on Memory Write 32 TLP and
//              responds to 1 DW length Memory Read 32 TLPs with a Completion
//              with Data TLP(1DW payload).
//
//              The module designed to operate with 32 bit and 64 bit interfaces.
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

`timescale 1ns/1ps

`define PIO_64 1

module PIO #
 (parameter channel_p = 2)
 (input trn_clk
  ,input trn_reset_n
  ,input trn_lnk_up_n
`ifdef PIO_64
  ,output [63:0] trn_td
  ,output [7:0] trn_trem_n
`else // PIO_64
  `ifdef PIO_128
     ,output [127:0] trn_td
     ,output [1:0] trn_trem_n
  `else
     ,output [31:0] trn_td
  `endif
`endif // PIO_64
  ,output trn_tsof_n
  ,output trn_teof_n
  ,output trn_tsrc_rdy_n
  ,output trn_tsrc_dsc_n
  ,input trn_tdst_rdy_n
  ,input trn_tdst_dsc_n
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
  ,input trn_rsrc_dsc_n
  ,input [6:0] trn_rbar_hit_n
  ,output trn_rdst_rdy_n
  ,input cfg_to_turnoff_n
  ,output cfg_turnoff_ok_n
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

  wire req_compl;
  wire compl_done;

  wire pio_reset_n = ~trn_lnk_up_n;
  logic reset_lo;

  // PIO instance

  PIO_EP #
    (.channel_p(channel_p))
  PIO_EP
    (.clk (trn_clk)                                             // I
    ,.rst_n(pio_reset_n)                                        // I
    ,.trn_td(trn_td)                                            // O [63/31:0]
`ifndef PIO_32
    ,.trn_trem_n(trn_trem_n)                                    // O [7:0]
`endif // not PIO_32
    ,.trn_tsof_n(trn_tsof_n)                                    // O
    ,.trn_teof_n(trn_teof_n)                                    // O
    ,.trn_tsrc_rdy_n(trn_tsrc_rdy_n)                            // O
    ,.trn_tsrc_dsc_n(trn_tsrc_dsc_n)                            // O
    ,.trn_tdst_rdy_n(trn_tdst_rdy_n)                            // I
    ,.trn_tdst_dsc_n(trn_tdst_dsc_n)                            // I
    ,.trn_rd(trn_rd)                                            // I [63/31:0]
`ifndef PIO_32
    ,.trn_rrem_n(trn_rrem_n)                                    // I
`endif // not PIO_32
    ,.trn_rsof_n(trn_rsof_n)                                    // I
    ,.trn_reof_n(trn_reof_n)                                    // I
    ,.trn_rsrc_rdy_n(trn_rsrc_rdy_n)                            // I
    ,.trn_rsrc_dsc_n(trn_rsrc_dsc_n)                            // I
    ,.trn_rbar_hit_n(trn_rbar_hit_n)                            // I [6:0]
    ,.trn_rdst_rdy_n(trn_rdst_rdy_n)                            // O
    ,.req_compl_o(req_compl)                                    // O
    ,.compl_done_o(compl_done)                                  // O
    ,.cfg_completer_id(cfg_completer_id)                        // I [15:0]
    ,.cfg_bus_mstr_enable(cfg_bus_mstr_enable)                  // I
    // reset out
    ,.reset_o(reset_lo)
    // status register
    ,.status_register_i(status_register_i)
    // data in
    ,.valid_i(valid_i)
    ,.data_i(data_i)
    ,.ready_o(ready_o)
    // data out
    ,.valid_o(valid_o)
    ,.data_o(data_o)
    ,.ready_i(ready_i));

  assign reset_o = reset_lo;

  PIO_TO_CTRL PIO_TO
    (.clk(trn_clk)                             // I
    ,.rst_n(pio_reset_n & !reset_lo) // I
    ,.req_compl_i(req_compl)                   // I
    ,.compl_done_i(compl_done)                 // I
    ,.cfg_to_turnoff_n(cfg_to_turnoff_n)       // I
    ,.cfg_turnoff_ok_n(cfg_turnoff_ok_n));     // O

endmodule
