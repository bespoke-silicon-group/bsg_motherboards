//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pio_ep_fifo.v
//
// Author: Michael Taylor
//------------------------------------------------------------

`timescale 1ns / 1ps

module bsg_ml605_pio_ep_fifo #
  (parameter I_WIDTH=17
  ,parameter A_WIDTH=10
  ,parameter LG_DEPTH=3)
  (input clk
  ,input [I_WIDTH + A_WIDTH - 1:0] din
  ,input enque
  ,input deque
  ,input clear
  ,output [I_WIDTH + A_WIDTH - 1:0] dout
  ,output empty
  ,output full
  ,output almost_full
  ,output valid);

  // Some storage
  reg [I_WIDTH + A_WIDTH - 1:0] storage [(2**LG_DEPTH)-1:0];

  // One read pointer, one write pointer;
  reg [LG_DEPTH-1:0] rptr_r, wptr_r;

  // Lights up if the fifo was used incorrectly
  reg error_r;

  assign full = ((wptr_r + 1'b1) == rptr_r);
  assign almost_full = ((wptr_r + 2'b10) == rptr_r) | full;
  assign empty = (wptr_r == rptr_r);
  assign valid = !empty;

  assign dout = storage[rptr_r];

  always @(posedge clk)
    if (enque)
      storage[wptr_r] <= din;

  always @(posedge clk) begin
    if (clear) begin
      rptr_r <= 0;
      wptr_r <= 0;
      error_r <= 1'b0;
    end
    else begin
      rptr_r <= rptr_r + deque;
      wptr_r <= wptr_r + enque;
      error_r  <= error_r | (full & enque) | (empty & deque);
    end
  end

endmodule
