
`include "bsg_manycore_packet.vh"

module bsg_manycore_async_link_to_wormhole

 #(parameter addr_width_p="inv"
  ,parameter data_width_p="inv"
  ,parameter load_id_width_p = 5
  ,parameter x_cord_width_p="inv"
  ,parameter y_cord_width_p="inv"
  ,parameter wormhole_req_ratio_p = "inv"
  ,parameter wormhole_resp_ratio_p = "inv"
  ,parameter wormhole_width_p = "inv"
  ,parameter wormhole_x_cord_width_p = "inv"
  ,parameter wormhole_y_cord_width_p = "inv"
  ,parameter wormhole_len_width_p = "inv"
  ,parameter wormhole_reserved_width_p = "inv"
  ,parameter fifo_depth_p = 6
  // Dangerous parameter! Should be removed later
  ,parameter x_dest_p = 0
  ,localparam num_nets_lp = 2
  ,localparam bsg_manycore_link_sif_width_lp=`bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p))
    
  (input manycore_clk_i
  ,output manycore_reset_o
  ,output manycore_en_o
   
  ,input [bsg_manycore_link_sif_width_lp-1:0] links_sif_i
  ,output [bsg_manycore_link_sif_width_lp-1:0] links_sif_o
   
  ,input clk_i
  ,input reset_i
  ,input en_i

  ,input [num_nets_lp-1:0] valid_i
  ,input [num_nets_lp-1:0][wormhole_width_p-1:0] data_i
  ,output [num_nets_lp-1:0] ready_o
 
  ,output [num_nets_lp-1:0] valid_o
  ,output [num_nets_lp-1:0][wormhole_width_p-1:0] data_o
  ,input [num_nets_lp-1:0] yumi_i);
  
  
  // Reset signals
  
  bsg_launch_sync_sync 
 #(.width_p(1))
  mc_reset_blss
  (.iclk_i(clk_i)
  ,.iclk_reset_i(1'b0)
  ,.oclk_i(manycore_clk_i)
  ,.iclk_data_i(reset_i)
  ,.iclk_data_o()
  ,.oclk_data_o(manycore_reset_o));
  
  bsg_launch_sync_sync 
 #(.width_p(1))
  mc_en_blss
  (.iclk_i(clk_i)
  ,.iclk_reset_i(1'b0)
  ,.oclk_i(manycore_clk_i)
  ,.iclk_data_i(en_i)
  ,.iclk_data_o()
  ,.oclk_data_o(manycore_en_o));
  

  // Manycore side async fifo input
  logic [num_nets_lp-1:0][wormhole_width_p-1:0] mc_data_li;
  logic [num_nets_lp-1:0] mc_enq_li, mc_valid_li;
  logic [num_nets_lp-1:0] mc_full_lo, mc_ready_lo;
  
  assign mc_ready_lo = ~mc_full_lo;
  assign mc_enq_li = mc_valid_li & mc_ready_lo;

  // Manycore side async fifo output
  logic [num_nets_lp-1:0][wormhole_width_p-1:0] mc_data_lo;
  logic [num_nets_lp-1:0] mc_valid_lo;
  logic [num_nets_lp-1:0] mc_deq_li, mc_ready_li;
  
  assign mc_deq_li = mc_ready_li & mc_valid_lo;
  
  // Wormhole side async fifo input
  logic [num_nets_lp-1:0] wh_full_lo;
  logic [num_nets_lp-1:0] wh_enq_li;
  
  assign ready_o = ~wh_full_lo;
  assign wh_enq_li = valid_i & ready_o;


  genvar i;
  
  for (i = 0; i < 2; i++) begin: afifo
  
    bsg_async_fifo
   #(.lg_size_p(fifo_depth_p)
    ,.width_p(wormhole_width_p))
    wh_2_mc_fifo
    (.w_clk_i(clk_i)
    ,.w_reset_i(reset_i)
    ,.w_enq_i(wh_enq_li[i])
    ,.w_data_i(data_i[i])
    ,.w_full_o(wh_full_lo[i])

    ,.r_clk_i(manycore_clk_i)
    ,.r_reset_i(manycore_reset_o)
    ,.r_deq_i(mc_deq_li[i])
    ,.r_data_o(mc_data_lo[i])
    ,.r_valid_o(mc_valid_lo[i]));
    
    bsg_async_fifo
   #(.lg_size_p(fifo_depth_p)
    ,.width_p(wormhole_width_p))
    mc_2_wh_fifo
    (.w_clk_i(manycore_clk_i)
    ,.w_reset_i(manycore_reset_o)
    ,.w_enq_i(mc_enq_li[i])
    ,.w_data_i(mc_data_li[i])
    ,.w_full_o(mc_full_lo[i])

    ,.r_clk_i(clk_i)
    ,.r_reset_i(reset_i)
    ,.r_deq_i(yumi_i[i])
    ,.r_data_o(data_o[i])
    ,.r_valid_o(valid_o[i]));
  
  end


  // Define link packets
  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p);
  // Define req and resp packets
  `declare_bsg_manycore_packet_s  (addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p);

  localparam mc_req_width_lp = $bits(bsg_manycore_packet_s);
  localparam mc_resp_width_lp = $bits(bsg_manycore_return_packet_s);
  
  localparam wh_req_width_lp = wormhole_width_p*wormhole_req_ratio_p;
  localparam wh_resp_width_lp = wormhole_width_p*wormhole_resp_ratio_p;
  localparam wh_width_lp = `BSG_MAX(wh_req_width_lp, wh_resp_width_lp);
  
  localparam wh_header_width_lp = wormhole_reserved_width_p+wormhole_len_width_p+wormhole_x_cord_width_p+wormhole_y_cord_width_p;
  localparam wh_req_header_offset_lp = wh_req_width_lp - wh_header_width_lp;
  localparam wh_resp_header_offset_lp = wh_resp_width_lp - wh_header_width_lp;
  
  
   // synopsys translate_off
   initial begin
     assert (mc_req_width_lp + wh_header_width_lp <= wh_req_width_lp)
     else $error("Wormhole request packet width %d is smaller than manycore request packet width %d plus header width %d", wh_req_width_lp, mc_req_width_lp, wh_header_width_lp);
     
     assert (mc_resp_width_lp + wh_header_width_lp <= wh_resp_width_lp)
     else $error("Wormhole request packet width %d is smaller than manycore request packet width %d plus header width %d", wh_resp_width_lp, mc_resp_width_lp, wh_header_width_lp);
   end
   // synopsys translate_on

  
  
  // input to piso
  logic [num_nets_lp-1:0][wh_width_lp-1:0] mc_ps_data_li;
  logic [num_nets_lp-1:0] mc_ps_valid_li;
  logic [num_nets_lp-1:0] mc_ps_ready_lo;

  // output from sipof
  logic [num_nets_lp-1:0][wh_width_lp-1:0] mc_ps_data_lo;
  logic [num_nets_lp-1:0] mc_ps_valid_lo;
  logic [num_nets_lp-1:0] mc_ps_yumi_li;
  
  
  for (i = 0; i < num_nets_lp; i++) begin: ps
    
    localparam ps_width_lp = (i==0)? wh_req_width_lp : wh_resp_width_lp;
    localparam ps_els_lp = ps_width_lp / wormhole_width_p;
  
    bsg_parallel_in_serial_out 
   #(.width_p(wormhole_width_p)
    ,.els_p(ps_els_lp)
    ,.msb_then_lsb_p(1))
    piso
    (.clk_i(manycore_clk_i)
    ,.reset_i(manycore_reset_o)
    ,.valid_i(mc_ps_valid_li[i])
    ,.data_i(mc_ps_data_li[i][ps_width_lp-1:0])
    ,.ready_o(mc_ps_ready_lo[i])
    ,.valid_o(mc_valid_li[i])
    ,.data_o(mc_data_li[i])
    ,.yumi_i(mc_ready_lo[i]&mc_valid_li[i]));
    
    bsg_serial_in_parallel_out_full
   #(.width_p(wormhole_width_p)
    ,.els_p(ps_els_lp)
    ,.msb_then_lsb_p(1))
    sipof
    (.clk_i(manycore_clk_i)
    ,.reset_i(manycore_reset_o)
    ,.v_i(mc_valid_lo[i])
    ,.ready_o(mc_ready_li[i])
    ,.data_i(mc_data_lo[i])
    ,.data_o(mc_ps_data_lo[i][ps_width_lp-1:0])
    ,.v_o(mc_ps_valid_lo[i])
    ,.yumi_i(mc_ps_yumi_li[i]));  
  
  end
  
  
  // Cast of link packets
  bsg_manycore_link_sif_s links_sif_i_cast, links_sif_o_cast;

  assign links_sif_i_cast = links_sif_i;
  assign links_sif_o = links_sif_o_cast;
  
  
  // Req and Resp packets
  bsg_manycore_fwd_link_sif_s fwd_li, fwd_lo;
  bsg_manycore_rev_link_sif_s rev_li, rev_lo;

  // coming in from manycore
  assign fwd_li = links_sif_i_cast.fwd;
  assign rev_li = links_sif_i_cast.rev;

  // going out to manycore
  assign links_sif_o_cast.fwd = fwd_lo;
  assign links_sif_o_cast.rev = rev_lo;
  
  
  always_comb begin
  
    // Init data packets
    mc_ps_data_li[0] = 0;
    mc_ps_data_li[1] = 0;
  
    // req going out of manycore
    mc_ps_valid_li[0] = fwd_li.v;
    mc_ps_data_li[0][mc_req_width_lp-1:0] = fwd_li.data;
    mc_ps_data_li[0][wh_req_header_offset_lp+:wh_header_width_lp] = {(wormhole_reserved_width_p)'(0), (wormhole_x_cord_width_p)'(x_dest_p), (wormhole_y_cord_width_p)'(0), (wormhole_len_width_p)'(wormhole_req_ratio_p-1)};
    fwd_lo.ready_and_rev = mc_ps_ready_lo[0];

    // req coming into manycore
    fwd_lo.v = mc_ps_valid_lo[0];
    fwd_lo.data = mc_ps_data_lo[0][mc_req_width_lp-1:0];
    mc_ps_yumi_li[0] = mc_ps_valid_lo[0] & fwd_li.ready_and_rev;

    // resp going out of manycore
    mc_ps_valid_li[1] = rev_li.v;
    mc_ps_data_li[1][mc_resp_width_lp-1:0] = rev_li.data;
    mc_ps_data_li[1][wh_resp_header_offset_lp+:wh_header_width_lp] = {(wormhole_reserved_width_p)'(0), (wormhole_x_cord_width_p)'(x_dest_p), (wormhole_y_cord_width_p)'(0), (wormhole_len_width_p)'(wormhole_resp_ratio_p-1)};
    rev_lo.ready_and_rev = mc_ps_ready_lo[1];

    // resp coming into manycore
    rev_lo.v = mc_ps_valid_lo[1];
    rev_lo.data = mc_ps_data_lo[1][mc_resp_width_lp-1:0];
    mc_ps_yumi_li[1] = mc_ps_valid_lo[1] & rev_li.ready_and_rev;
  
  end
  
  


endmodule
