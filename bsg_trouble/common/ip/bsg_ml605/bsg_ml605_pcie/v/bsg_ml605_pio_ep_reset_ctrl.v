//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pio_ep_reset_ctrl.v
//
// Author: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_pio_ep_reset_ctrl #
  (parameter reset_register_addr_p = "inv"
  ,parameter reset_register_data_p = "inv")
  // clk
  (input clk_i
  // reset
  ,input reset_i
  // write port
  ,input wr_en_i
  ,input [10:0] wr_addr_i
  ,input [31:0] wr_data_i
  // reset out
  ,output reset_o);

  logic  start_lo;

  assign start_lo = (  wr_en_i == 1'b1
                    && wr_addr_i[8:0] == reset_register_addr_p
		    && wr_data_i == reset_register_data_p)? 1'b1 : 1'b0;

  enum logic [1:0] {IDLE = 2'b01
                   ,RESET = 2'b10} c_state, n_state;

  always_ff @(posedge clk_i)
    if (reset_i == 1'b1)
      c_state <= IDLE;
    else
      c_state <= n_state;

  logic [9:0] cnt_r;

  always_ff @(posedge clk_i)
    if (reset_i == 1'b1 || c_state == IDLE)
      cnt_r <= {10{1'b0}};
    else
      cnt_r <= cnt_r + 1;

  localparam logic [9:0] reset_cycles_lp = 10'd1023;

  always_comb begin
    n_state = c_state;
    unique case (c_state)
      IDLE:
        if (start_lo == 1'b1)
          n_state = RESET;
      RESET:
        if (cnt_r == reset_cycles_lp)
          n_state = IDLE;
      default: begin
      end
    endcase
  end

  assign reset_o = (c_state == RESET)? 1'b1 : 1'b0;

endmodule
