// This module uses the synthesizable bsg_fsb_node_trace_replay module
// to communicate over bsg_tag. This module instantitates a trace-replay,
// removes the output data to match what bsg_tag is expecting, and
// finally it serializes the trace data down to a single bit.
//
// Each trace should be in the following format:
//
// M = number of masters
// N = clog2( #_of_tag_clients ) )
// D = max( client_1_width, client_2_width, ..., client_n_width )
// L = clog2( D + 1 ) )
//
// |<    4-bits    >|< M-bits >|< N-bits >|<     1-bit    >|< L-bits >|< D-bits >|
// +----------------+----------+----------+----------------+----------+----------+
// | replay command | masterEn |  nodeID  | data_not_reset |  length  |   data   |
// +----------------+----------+----------+----------------+----------+----------+
//
//  Replay Commands
//    0 = 0000 = Wait a cycle
//    1 = 0001 = Send data
//    2 = 0010 = Receive data
//    3 = 0011 = Assert done_o ouput signal
//    4 = 0100 = End test (calls $finish)
//    5 = 0101 = Wait for cycle_counter == 0
//    6 = 0110 = Initialize cycle_counter with a 16 bit number
//
// To reset the bsg_tag_master, we just need to send a bunch of 0's,
// so we can send a trace of all 0's and just wait for many cycles. This
// will continuously send 0's down bsg_tag thus reseting the master.
//
// To reset a client, set the nodeID, data_not_reset=0, and length
// fields correctly, then set the data to all 1's.
//

`include "bsg_noc_links.vh"

module bsg_tag_trace_replay_stream

   #( parameter rom_addr_width_p    = -1
    , parameter rom_data_width_p    = -1
    , parameter num_masters_p       = 0
    , parameter num_clients_p       = -1
    , parameter max_payload_width_p = -1 
    , parameter link_width_p        = "inv"
    , parameter cord_width_p        = "inv"
    , parameter len_width_p         = "inv"
    , localparam bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(link_width_p)  
    )

    ( input clk_i
    , input reset_i
    , input en_i
      
    , output [rom_addr_width_p-1:0] rom_addr_o
    , input  [rom_data_width_p-1:0] rom_data_i

    , output [`BSG_MAX(1,num_masters_p)-1:0] en_r_o
    , output                                 tag_data_o
    
    , input  [bsg_ready_and_link_sif_width_lp-1:0] link_i
    , output [bsg_ready_and_link_sif_width_lp-1:0] link_o

    , output done_o
    ) ;

    `include "bsg_tag.vh"

    // The trace ring width is the size of the rom data width
    // minus the 4-bits for the trace-replay command.
    localparam trace_ring_width_lp = rom_data_width_p - 4;

    // The number of bits needed to represent the length of the
    // payload inside bsg_tag.
    localparam lg_max_payload_width_lp = `BSG_SAFE_CLOG2(max_payload_width_p + 1);

    // The number of bits in the header of the tag packet.
    `declare_bsg_tag_header_s(num_clients_p, lg_max_payload_width_lp);
    localparam bsg_tag_header_width_lp = $bits(bsg_tag_header_s);

    // Data signals between trace_replay and parallel_in_serial_out.
    logic                           tr_valid_lo;
    logic [trace_ring_width_lp-1:0] tr_data_lo;
    logic                           tr_ready_li;
    
    logic                           link_valid_lo;
    logic [trace_ring_width_lp-1:0] link_data_lo;
    logic [cord_width_p+len_width_p-1:0] link_hdr_lo;
    logic                           link_ready_li;
    
    logic                           piso_valid_li;
    logic [trace_ring_width_lp-1:0] piso_data_li;
    logic                           piso_ready_lo;
    
    
    // Stream link
    `declare_bsg_ready_and_link_sif_s(link_width_p, bsg_ready_and_link_sif_s);
    bsg_ready_and_link_sif_s link_i_cast, link_o_cast;
    assign link_i_cast = link_i;
    assign link_o      = link_o_cast;
    
    bsg_serial_in_parallel_out_full
   #(.width_p(link_width_p)
    ,.els_p  (`BSG_CDIV(trace_ring_width_lp+cord_width_p+len_width_p, link_width_p))
    ) link_sipof
    (.clk_i  (clk_i)
    ,.reset_i(reset_i)

    ,.v_i    (link_i_cast.v)
    ,.ready_o(link_o_cast.ready_and_rev)
    ,.data_i (link_i_cast.data)

    ,.data_o ({link_data_lo, link_hdr_lo})
    ,.v_o    (link_valid_lo)
    ,.yumi_i (link_valid_lo & link_ready_li)
    );
    
    // tieoff output link
    assign link_o_cast.v = 1'b0;
    assign link_o_cast.data = '0;

    // Switch between trace rom and stream link
    always_comb
      begin
        if (done_o)
          begin
            piso_valid_li = link_valid_lo;
            piso_data_li  = link_data_lo;
            link_ready_li = piso_ready_lo;
            tr_ready_li   = 1'b0;
          end
        else
          begin
            piso_valid_li = tr_valid_lo;
            piso_data_li  = tr_data_lo;
            tr_ready_li   = piso_ready_lo;
            link_ready_li = 1'b0;
          end
      end
    

    // Instantiate the trace replay
    bsg_fsb_node_trace_replay #( .ring_width_p(trace_ring_width_lp)
                               , .rom_addr_width_p(rom_addr_width_p) )
      trace_replay
        (.clk_i   (clk_i)
        ,.reset_i (reset_i)
        ,.en_i    (en_i)

        /* input channel */
        ,.v_i     (1'b0)
        ,.data_i  ('0)
        ,.ready_o ()

        /* output channel */
        ,.v_o    (tr_valid_lo)
        ,.data_o (tr_data_lo)
        ,.yumi_i (tr_valid_lo & tr_ready_li)

        /* rom connections */
        ,.rom_addr_o (rom_addr_o)
        ,.rom_data_i (rom_data_i)

        /* signals */
        ,.done_o  (done_o)
        ,.error_o ()
        );

    // Reform the data between the trace-replay and the piso
    // to properly act like a bsg_tag packet. This includes adding
    // a 1-bit to the beginning of the data and a 0-bit to the
    // end. Furthermore, swap the header and payload order.
    wire [bsg_tag_header_width_lp-1:0]   header_n  = piso_data_li[max_payload_width_p+:bsg_tag_header_width_lp];
    wire [max_payload_width_p-1:0]       payload_n = piso_data_li[0+:max_payload_width_p];
    wire [trace_ring_width_lp + 2 - 1:0] data_n    = {1'b0, payload_n, header_n, 1'b1};
    wire piso_valid_lo;
   
    // Instantiate the paralle-in serial-out data structure.
    bsg_parallel_in_serial_out #( .width_p(1)
                                , .els_p(trace_ring_width_lp + 2) )
      trace_piso
        (.clk_i   (clk_i)
        ,.reset_i (reset_i)
   
        /* Data Input Channel (Valid then Yumi) */
        ,.valid_i (piso_valid_li)
        ,.data_i  (data_n)
        ,.ready_o (piso_ready_lo)
   
        /* Data Output Channel (Valid then Yumi) */
        ,.valid_o (piso_valid_lo)
        ,.data_o  (tag_data_o)
        ,.yumi_i  (piso_valid_lo)
        );

  // If there are "no masters" (or at least none required to drive the enables
  // for) then we will disconnect en_r_o, otherwise we will instantiate a
  // register to capture the enables.
  if (num_masters_p == 0)
    begin
      assign en_r_o = 1'bz;
    end
  else
    begin
      logic [1:0] en_count_r;
      always_ff @(posedge clk_i)
          if (reset_i)
            en_count_r <= '0;
          else if (piso_valid_li & piso_ready_lo & (en_count_r<2))
            en_count_r <= en_count_r + 1'b1;
    
      logic [num_masters_p-1:0] en_r_lo;
      assign en_r_o = (piso_valid_lo | (en_count_r<2))? en_r_lo : '0;
    
      bsg_dff_en #( .width_p(num_masters_p) )
        en_reg
          (.clk_i  (clk_i)
          ,.en_i   (piso_valid_li & piso_ready_lo)
          ,.data_i (piso_data_li[(max_payload_width_p+bsg_tag_header_width_lp)+:num_masters_p])
          ,.data_o (en_r_lo)
          );
    end

endmodule
