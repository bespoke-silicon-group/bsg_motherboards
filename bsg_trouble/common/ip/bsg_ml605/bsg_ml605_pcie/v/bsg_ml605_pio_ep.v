//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pio_ep.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

//--------------------------------------------------------------
//                PIO Addressing
//--------------------------------------------------------------
// Channels
//     addr_i (rd/wr)       addr_i[5:4]        addr_i[3:0]
//     l2f_fifo_status        0 0                  i
//     write_fifo_data        0 1                  i
//     read_fifo_data         1 0                  i
//     f2l_fifo_status        1 1                  i
//
// Other useful Regs
//     NAME                 Address(Linux)   Address(PIO)
//     channel_register      0x7fc            0x1ff (1_1111_1111)
//     reset_register        0x7f8            0x1fe (1_1111_1110)
//     test_register         0x7f4            0x1fd (1_1111_1101)
//     status_register       0x7f0            0x1fc (1_1111_1100)
//--------------------------------------------------------------

module bsg_ml605_pio_ep #
  (parameter channel_p = 2)
  // clk
  (input clk_i
  // reset
  ,input reset_i
  // reset out
  ,output reset_o
  // status register
  ,input [31:0] status_register_i
  // data in
  ,input [channel_p - 1 : 0] valid_i
  ,input [32*channel_p - 1 : 0] data_i
  ,output  [channel_p - 1 : 0] ready_o
  // data out
  ,output  [channel_p - 1 : 0] valid_o
  ,output [32*channel_p - 1 : 0] data_o
  ,input [channel_p - 1 : 0] ready_i
  // read port
  ,input [10:0] rd_addr_i
  ,input [3:0] rd_be_i
  ,output [31:0] rd_data_o
  // write port
  ,input wr_en_i
  ,input [10:0] wr_addr_i
  ,input [31:0] wr_data_i
  ,input [7:0] wr_be_i
  ,output wr_busy_o);

  // write busy

  assign wr_busy_o = 1'b0;

  // reset

  localparam logic [8:0] reset_register_addr_lp = 9'h1fe;
  localparam logic [31:0] reset_register_data_lp = 32'hffffffff;

  logic gen_reset_lo;

  bsg_ml605_pio_ep_reset_ctrl #
    (.reset_register_addr_p(reset_register_addr_lp)
    ,.reset_register_data_p(reset_register_data_lp))
  reset_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.wr_en_i(wr_en_i)
    ,.wr_addr_i(wr_addr_i)
    ,.wr_data_i(wr_data_i)
    ,.reset_o(gen_reset_lo));

  assign reset_o = gen_reset_lo;

  // test register

  localparam logic [8:0] test_register_addr_lp = 9'h1fd;
  localparam logic [31:0] init_test_register_data_lp = 32'hfffffff0;

  logic [31:0] test_register;

  always_ff @(posedge clk_i or posedge reset_i)
    if (reset_i == 1'b1 || gen_reset_lo == 1'b1)
      test_register <= init_test_register_data_lp;
    else if (wr_addr_i[8:0] == test_register_addr_lp & wr_en_i == 1'b1)
      test_register <= wr_data_i;

  // In verilog, we need to use a 16 to 1 mux to code this circuit,
  // and it's better to use 2 level mux, which means use 5 4-1 mux.
  // Always to generate the rd_data_o_reg

  logic [3:0] read_index;

  assign read_index = rd_addr_i[3:0];

  logic [31:0] rd_data_o_reg;
  logic [31:0] rd_data_o_wire;

  logic [31:0] l2f_fifo_status_r [0:channel_p - 1];
  logic [31:0] f2l_fifo_status_r [0:channel_p - 1];

  localparam logic [6:0] l2f_fifo_status_addr_lp = 7'h00;
  localparam logic [6:0] read_fifo_data_addr_lp = 7'h02;
  localparam logic [6:0] f2l_fifo_status_addr_lp = 7'h03;

  localparam logic [8:0] channel_register_addr_lp = 9'h1ff;

  localparam logic [8:0] status_register_addr_lp = 9'h1fc;

  logic [31:0] status_register_r1, status_register_r2;

  always_ff @(posedge clk_i)
    {status_register_r2, status_register_r1} <= {status_register_r1, status_register_i};

  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i == 1'b1 || gen_reset_lo == 1'b1) begin
      rd_data_o_reg <= 32'b0;
    end
    else begin
      if (rd_addr_i[10:4] == l2f_fifo_status_addr_lp) begin
        rd_data_o_reg <= l2f_fifo_status_r[read_index];
      end
      else if (rd_addr_i[10:4] == read_fifo_data_addr_lp) begin
        rd_data_o_reg <= rd_data_o_wire;
      end
      else if (rd_addr_i[10:4] == f2l_fifo_status_addr_lp) begin
        rd_data_o_reg <= f2l_fifo_status_r[read_index];
      end
      else if (rd_addr_i[8:0] == channel_register_addr_lp) begin
        rd_data_o_reg <= channel_p;
      end
      else if (rd_addr_i[8:0] == test_register_addr_lp) begin
        rd_data_o_reg <= test_register;
      end
      else if (rd_addr_i[8:0] == status_register_addr_lp) begin
        rd_data_o_reg <= status_register_r2;
      end
      else begin
        rd_data_o_reg <= 32'b0;
      end
    end
  end

  assign rd_data_o = rd_data_o_reg;

  // Need a 16 to 1 mux, which has two level 4 to 1 mux, totally use 5 4-1mux
  // The second level

  logic [31:0] rd_data_o_wire_0;
  logic [31:0] rd_data_o_wire_1;
  logic [31:0] rd_data_o_wire_2;
  logic [31:0] rd_data_o_wire_3;

  always_comb
    case (rd_addr_i[3:2])
      2'b00: begin
        rd_data_o_wire = rd_data_o_wire_0;
      end
      2'b01: begin
        rd_data_o_wire = rd_data_o_wire_1;
      end
      2'b10: begin
        rd_data_o_wire = rd_data_o_wire_2;
      end
      2'b11: begin
        rd_data_o_wire = rd_data_o_wire_3;
      end
    endcase

  // The first level

  wire [32*16 - 1 : 0] f2l_fifo_data_lo;

  assign f2l_fifo_data_lo[32*16 - 1 : 32*channel_p] = {(32*(16 - channel_p)){1'b0}};

  always_comb
    case (rd_addr_i[1:0])
      2'b00: begin  //  0  4  8 12
        rd_data_o_wire_0 = f2l_fifo_data_lo[ 32 * 0  + 31: 32 * 0 ];
        rd_data_o_wire_1 = f2l_fifo_data_lo[ 32 * 4  + 31: 32 * 4 ];
        rd_data_o_wire_2 = f2l_fifo_data_lo[ 32 * 8  + 31: 32 * 8 ];
        rd_data_o_wire_3 = f2l_fifo_data_lo[ 32 * 12 + 31: 32 * 12 ];
      end
      2'b01: begin  //  1  5  9 13
        rd_data_o_wire_0 = f2l_fifo_data_lo[ 32 * 1  + 31: 32 * 1 ];
        rd_data_o_wire_1 = f2l_fifo_data_lo[ 32 * 5  + 31: 32 * 5 ];
        rd_data_o_wire_2 = f2l_fifo_data_lo[ 32 * 9  + 31: 32 * 9 ];
        rd_data_o_wire_3 = f2l_fifo_data_lo[ 32 * 13 + 31: 32 * 13];
      end
      2'b10: begin //   2  6 10 14
        rd_data_o_wire_0 = f2l_fifo_data_lo[ 32 * 2  + 31: 32 * 2 ];
        rd_data_o_wire_1 = f2l_fifo_data_lo[ 32 * 6  + 31: 32 * 6 ];
        rd_data_o_wire_2 = f2l_fifo_data_lo[ 32 * 10 + 31: 32 * 10];
        rd_data_o_wire_3 = f2l_fifo_data_lo[ 32 * 14 + 31: 32 * 14];
      end
      2'b11: begin //   3  7 11 15
        rd_data_o_wire_0 = f2l_fifo_data_lo[ 32 * 3  + 31: 32 * 3 ];
        rd_data_o_wire_1 = f2l_fifo_data_lo[ 32 * 7  + 31: 32 * 7 ];
        rd_data_o_wire_2 = f2l_fifo_data_lo[ 32 * 11 + 31: 32 * 11];
        rd_data_o_wire_3 = f2l_fifo_data_lo[ 32 * 15 + 31: 32 * 15];
      end
    endcase

  localparam fifo_lg_depth_lp = 9;

  genvar i;

  logic [channel_p - 1 : 0] f2l_fifo_deq_lo;
  logic [channel_p - 1 : 0] f2l_fifo_full_lo;

  generate
    for (i = 0; i < channel_p ; i++) begin

      assign f2l_fifo_deq_lo[i] = ( read_index == i
                                 && rd_addr_i[10:4] == read_fifo_data_addr_lp)? 1'b1 : 1'b0;

      bsg_ml605_pio_ep_fifo #
        (.I_WIDTH(32)
	,.A_WIDTH(0)
	,.LG_DEPTH(fifo_lg_depth_lp))
      f2l_fifo_inst
        (.clk(clk_i)
        ,.clear(reset_i | gen_reset_lo)
        // in
        ,.enque(~f2l_fifo_full_lo[i] & valid_i[i])
        ,.din(data_i[i*32 + 31 : i*32])
        ,.almost_full(f2l_fifo_full_lo[i])
        ,.full()
        // out
        ,.dout(f2l_fifo_data_lo[i*32 + 31 : i*32])
        ,.deque(f2l_fifo_deq_lo[i])
        ,.valid()
        ,.empty());

      // How many used entry in the transmit fifo
      always_ff @(posedge clk_i or posedge reset_i)
        if (reset_i == 1'b1 || gen_reset_lo == 1'b1)
          f2l_fifo_status_r[i] <= 0;
        else
          f2l_fifo_status_r[i] <= f2l_fifo_status_r[i]
                                - f2l_fifo_deq_lo[i]
                                + (~f2l_fifo_full_lo[i] & valid_i[i]);

      assign ready_o[i] = ~f2l_fifo_full_lo[i];

    end
  endgenerate

  localparam logic [6:0] write_fifo_data_addr_lp = 7'h01;

  logic [channel_p - 1 : 0] l2f_fifo_enq_lo;
  logic [channel_p - 1 : 0] l2f_fifo_empty_lo;
  logic [channel_p - 1 : 0] l2f_fifo_full_lo;

  generate
    for (i = 0; i < channel_p ; i++) begin

      assign l2f_fifo_enq_lo[i] = ( wr_addr_i[3:0] == i
                                 && wr_addr_i[10:4] == write_fifo_data_addr_lp
                                 && wr_en_i == 1'b1
                                 && l2f_fifo_full_lo[i] == 1'b0)? 1'b1 : 1'b0;

      bsg_ml605_pio_ep_fifo #
        (.I_WIDTH(32)
	,.A_WIDTH(0)
	,.LG_DEPTH(fifo_lg_depth_lp))
      l2f_fifo_inst
        (.clk(clk_i)
        ,.clear(reset_i | gen_reset_lo)
        // in
        ,.enque(l2f_fifo_enq_lo[i])
        ,.din(wr_data_i)
        ,.almost_full(l2f_fifo_full_lo[i])
        ,.full()
        // out
        ,.empty(l2f_fifo_empty_lo[i])
        ,.dout(data_o[i*32 + 31 : i*32])
        ,.deque(~l2f_fifo_empty_lo[i] & ready_i[i])
        ,.valid());

      // How many free entry in the receive fifo
      always_ff @(posedge clk_i or posedge reset_i)
        if (reset_i == 1'b1 || gen_reset_lo == 1'b1)
          l2f_fifo_status_r[i] <= (1 << fifo_lg_depth_lp) - 2'b11;
        else
          l2f_fifo_status_r[i] <= l2f_fifo_status_r[i]
                                - l2f_fifo_enq_lo[i]
                                + (~l2f_fifo_empty_lo[i] & ready_i[i]);

      assign valid_o[i] = ~l2f_fifo_empty_lo[i];

    end
  endgenerate

endmodule
