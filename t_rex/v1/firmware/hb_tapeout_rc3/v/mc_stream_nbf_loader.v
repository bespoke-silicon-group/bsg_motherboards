/**
 *  mc_stream_nbf_loader.v
 *
 */

`include "bsg_manycore_packet.vh"

module mc_stream_nbf_loader

 #(parameter addr_width_p        = "inv"
  ,parameter data_width_p        = "inv"
  ,parameter y_cord_width_p      = "inv"
  ,parameter x_cord_width_p      = "inv"
  ,parameter load_id_width_p     = "inv"
  ,parameter stream_data_width_p = "inv"

  ,parameter packet_width_lp =
   `bsg_manycore_packet_width(addr_width_p,data_width_p,
     x_cord_width_p,y_cord_width_p,load_id_width_p)

  ,parameter nbf_width_lp      = 80
  ,parameter nbf_num_flits_lp  = `BSG_CDIV(nbf_width_lp, stream_data_width_p)
  )

  (input                            clk_i
  ,input                            reset_i
  ,output                           done_o

  ,output [packet_width_lp-1:0]     packet_o
  ,output logic                     v_o
  ,input                            ready_i

  ,input  [y_cord_width_p-1:0]      my_y_i
  ,input  [x_cord_width_p-1:0]      my_x_i

  ,input                            stream_v_i
  ,input  [stream_data_width_p-1:0] stream_data_i
  ,output                           stream_ready_o
  );

  // nbf packet
  //
  typedef struct packed {
    logic [7:0] x_cord;
    logic [7:0] y_cord;
    logic [31:0] epa;
    logic [31:0] data;
  } bsg_nbf_s;

  `declare_bsg_manycore_packet_s(addr_width_p,data_width_p,
    x_cord_width_p,y_cord_width_p,load_id_width_p);

  bsg_manycore_packet_s packet;
  assign packet_o = packet;

  // read nbf file.
  //
  logic incoming_nbf_v_lo, incoming_nbf_yumi_li;
  logic [nbf_num_flits_lp-1:0][stream_data_width_p-1:0] incoming_nbf;

  bsg_serial_in_parallel_out_full
 #(.width_p(stream_data_width_p)
  ,.els_p  (nbf_num_flits_lp)
  ) sipo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.v_i    (stream_v_i)
  ,.ready_o(stream_ready_o)
  ,.data_i (stream_data_i)
  ,.data_o (incoming_nbf)
  ,.v_o    (incoming_nbf_v_lo)
  ,.yumi_i (incoming_nbf_yumi_li)
  );

  bsg_nbf_s curr_nbf;
  assign curr_nbf = nbf_width_lp'(incoming_nbf);

  assign packet.addr = curr_nbf.epa[0+:addr_width_p];
  assign packet.op = `ePacketOp_remote_store;
  assign packet.op_ex = 4'b1111;
  assign packet.payload = curr_nbf.data;
  assign packet.src_y_cord = my_y_i;
  assign packet.src_x_cord = my_x_i;
  assign packet.y_cord = curr_nbf.y_cord[0+:y_cord_width_p];
  assign packet.x_cord = curr_nbf.x_cord[0+:x_cord_width_p];

  logic loader_done_r, loader_done_n;
  assign done_o = loader_done_r;
 
  always_comb 
  begin

    v_o = 1'b0;
    loader_done_n = loader_done_r;
    incoming_nbf_yumi_li = 1'b0;

    if (~reset_i & incoming_nbf_v_lo)
      begin
        // the last line in nbf should be '1
        if (&curr_nbf) 
          begin
            loader_done_n = 1'b1;
          end
        else 
          begin
            v_o = 1'b1;
            incoming_nbf_yumi_li = ready_i;
          end
      end

  end

  // sequential
  //
  always_ff @ (posedge clk_i) 
    if (reset_i) 
        loader_done_r <= 1'b0;
    else 
        loader_done_r <= loader_done_n;

endmodule