//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc_buffer.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_gateway_fmc_buffer
  // core clk domain
  (input core_clk_i
  // core clk domain data in
  ,input core_valid_i
  ,input [79:0] core_data_i
  ,output core_ready_o
  // core clk domain data out
  ,output core_valid_o
  ,output [79:0] core_data_o
  ,input core_ready_i
  // fmc rx clk domain
  ,input rx_clk_div_i
  ,input rx_cal_done_i
  ,input [87:0] rx_data_i
  // fmc tx clk domain
  ,input tx_clk_div_i
  ,input tx_cal_done_i
  ,output [87:0] tx_data_o);

  // reset rx

  logic reset_rx_lo;

  assign reset_rx_lo = ~rx_cal_done_i;

  // reset tx

  logic reset_tx_lo;

  assign reset_tx_lo = ~tx_cal_done_i;

  // fifo rx

  logic [79:0] rx_data_lo;
  logic rx_data_full_lo, rx_data_enq_lo;
  logic core_data_deq_lo, core_data_valid_lo;

  assign rx_data_enq_lo = rx_data_i[80] & (~rx_data_full_lo);
  assign rx_data_lo = rx_data_i[79:0];

  bsg_async_fifo #
    (.lg_size_p(6)  // FIXME: 2X credit
    ,.width_p(80))
  fifo_rx_data
    // rx clk domain
    (.w_clk_i(rx_clk_div_i)
    ,.w_reset_i(reset_rx_lo)
    ,.w_enq_i(rx_data_enq_lo)
    ,.w_data_i(rx_data_lo)
    ,.w_full_o(rx_data_full_lo)
    // core clk domain
    ,.r_clk_i(core_clk_i)
    ,.r_reset_i(reset_rx_lo)
    ,.r_deq_i(core_data_deq_lo)
    ,.r_data_o(core_data_o)
    ,.r_valid_o(core_data_valid_lo));

  assign core_data_deq_lo = core_ready_i & core_data_valid_lo;
  assign core_valid_o = core_data_valid_lo;

  logic tx_credit_out_avail_lo;
  logic baf_out_full_lo;
  logic baf_out_data_lo;
  logic baf_out_valid_lo;

  bsg_async_fifo #
    (.lg_size_p(5)
    ,.width_p(1))
  baf_out
    // core clk domain
    (.w_clk_i(core_clk_i)
    ,.w_reset_i(reset_rx_lo)
    ,.w_enq_i(core_data_deq_lo & (~baf_out_full_lo))
    ,.w_data_i(1'b1)
    ,.w_full_o(baf_out_full_lo)
    // tx clk domain
    ,.r_clk_i(tx_clk_div_i)
    ,.r_reset_i(reset_tx_lo)
    ,.r_deq_i(tx_credit_out_avail_lo)
    ,.r_data_o(baf_out_data_lo)
    ,.r_valid_o(baf_out_valid_lo));

  assign tx_credit_out_avail_lo = baf_out_data_lo & baf_out_valid_lo;

  // fifo tx

  logic tx_credit_in_avail_lo;
  logic tx_data_valid_lo;
  logic tx_data_deq_lo;

  logic rx_inc_credit_lo;

  assign rx_inc_credit_lo = rx_cal_done_i & rx_data_i[81];
  assign tx_data_deq_lo = tx_cal_done_i & tx_data_valid_lo & tx_credit_in_avail_lo;

  logic baf_in_full_lo;
  logic baf_in_valid_lo;
  logic baf_in_data_lo;

  logic inc_credit_lo;

  bsg_async_fifo #
    (.lg_size_p(5)
    ,.width_p(1))
  baf_in
    // rx clk domain
    (.w_clk_i(rx_clk_div_i)
    ,.w_reset_i(reset_rx_lo)
    ,.w_enq_i(rx_inc_credit_lo & (~baf_in_full_lo))
    ,.w_data_i(1'b1)
    ,.w_full_o(baf_in_full_lo)
    // tx clk domain
    ,.r_clk_i(tx_clk_div_i)
    ,.r_reset_i(reset_tx_lo)
    ,.r_deq_i(inc_credit_lo)
    ,.r_data_o(baf_in_data_lo)
    ,.r_valid_o(baf_in_valid_lo));

  assign inc_credit_lo = baf_in_data_lo & baf_in_valid_lo;

  logic [5:0] cnt_r;

  always_ff @(posedge tx_clk_div_i)
    if (reset_tx_lo == 1'b1)
      cnt_r <= {6{1'b1}};
    else if (inc_credit_lo == 1'b1 && tx_data_deq_lo == 1'b0)
      cnt_r <= cnt_r + 1;
    else if (inc_credit_lo == 1'b0 && tx_data_deq_lo == 1'b1)
      cnt_r <= cnt_r - 1;

  assign tx_credit_in_avail_lo = (| cnt_r);

  logic core_data_enq_lo, core_data_full_lo;
  logic [79:0] tx_data_lo;

  logic cal_done_lo;

  assign cal_done_lo = tx_cal_done_i & rx_cal_done_i;

  assign core_ready_o = ~core_data_full_lo & cal_done_lo;
  assign core_data_enq_lo = core_valid_i & (~core_data_full_lo) & cal_done_lo;

  bsg_async_fifo #
    (.lg_size_p(5)
    ,.width_p(80))
  fifo_tx_data
    // core clk domain
    (.w_clk_i(core_clk_i)
    ,.w_reset_i(reset_tx_lo)
    ,.w_enq_i(core_data_enq_lo)
    ,.w_data_i(core_data_i)
    ,.w_full_o(core_data_full_lo)
    // tx clk domain
    ,.r_clk_i(tx_clk_div_i)
    ,.r_reset_i(reset_tx_lo)
    ,.r_deq_i(tx_data_deq_lo)
    ,.r_data_o(tx_data_lo)
    ,.r_valid_o(tx_data_valid_lo));

  assign tx_data_o = (tx_data_deq_lo == 1'b1)?
                     {6'd0, tx_credit_out_avail_lo, 1'b1, tx_data_lo} :
                     {6'd0, tx_credit_out_avail_lo, 81'd0};

endmodule
