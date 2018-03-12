//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_fmc_rx_data_bitslip_ctrl.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_fmc_rx_data_bitslip_ctrl
  (input clk_i
  ,input reset_i
  ,input [7:0] data_i
  ,output bitslip_o
  ,output done_o);

  logic [7:0] data_pattern;

  assign data_pattern = 8'h2C;

  enum logic [2:0] {IDLE    = 3'b001
                   ,BITSLIP = 3'b010
                   ,DONE    = 3'b100} c_state, n_state;

  logic [1:0] cnt_r;

  always_ff @(posedge clk_i)
    if (reset_i == 1'b1 || c_state == BITSLIP)
      cnt_r <= 4'd0;
    else if (c_state == IDLE)
      cnt_r <= cnt_r + 1;

  // fsm
  always_ff @(posedge clk_i) begin
    if (reset_i == 1'b1)
      c_state <= IDLE;
    else
      c_state <= n_state;
  end

  always_comb begin
    n_state = c_state;
    unique case(c_state)

      IDLE:
        if (cnt_r == 4'd3)
          if (data_i == data_pattern)
            n_state = DONE;
          else
            n_state = BITSLIP;

      BITSLIP:
        n_state = IDLE;

      DONE:
        n_state = DONE;

      default: begin
      end

    endcase
  end

  assign bitslip_o = (c_state == BITSLIP)? 1'b1 : 1'b0;
  assign done_o = (c_state == DONE)? 1'b1 : 1'b0;

endmodule
