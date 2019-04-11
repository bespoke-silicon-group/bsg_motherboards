
`include "bsg_manycore_packet.vh"

module bsg_asic

  import bsg_noc_pkg::Dirs
       , bsg_noc_pkg::P  // proc (local node)
       , bsg_noc_pkg::W  // west
       , bsg_noc_pkg::E  // east
       , bsg_noc_pkg::N  // north
       , bsg_noc_pkg::S; // south

 #(parameter mc_addr_width_p = 10
  ,parameter mc_data_width_p = 40
  ,parameter mc_load_id_width_p = 5
  ,parameter mc_x_cord_width_p = 5
  ,parameter mc_y_cord_width_p = 5
  ,parameter req_ratio_p = 3
  ,parameter resp_ratio_p = 2
  ,parameter mc_node_num_channel_p = 7
  ,parameter width_p = 32
  ,parameter x_cord_width_p = 2
  ,parameter y_cord_width_p = 2
  ,parameter len_width_p = 2
  ,parameter reserved_width_p = 2
  ,parameter channel_width_p = 8
  ,parameter lg_fifo_depth_p = 6
  ,parameter lg_credit_to_token_decimation_p = 3
  ,parameter remote_credits_p = 32
  ,parameter ct_max_len_p = 3-1
  ,parameter ct_lg_credit_decimation_p = 3
  ,localparam bsg_manycore_link_sif_width_lp=`bsg_manycore_link_sif_width(mc_addr_width_p,mc_data_width_p,mc_x_cord_width_p,mc_y_cord_width_p,mc_load_id_width_p))

  // clk
  (input MSTR_SDO_CLK
  ,input PLL_CLK_I

  // reset
  ,input AID10

  // led
  ,output ASIC_LED0, ASIC_LED1

  //-------- GATEWAY --------

  // channel out

  // channel clk out
  ,output AOC0, BOC0, COC0, DOC0
  // channel valid out
  ,output AOD8, BOD8, COD8, DOD8
  // channel data out
  //       A     B     C     D
  ,output AOD0, BOD0, COD0, DOD0
  ,output AOD1, BOD1, COD1, DOD1
  ,output AOD2, BOD2, COD2, DOD2
  ,output AOD3, BOD3, COD3, DOD3
  ,output AOD4, BOD4, COD4, DOD4
  ,output AOD5, BOD5, COD5, DOD5
  ,output AOD6, BOD6, COD6, DOD6
  ,output AOD7, BOD7, COD7, DOD7
  // channel token in
  ,input AOT0, BOT0, COT0, DOT0

  // channel in

  // channel clk in
  ,input AIC0, BIC0, CIC0, DIC0
  // channel valid in
  ,input AID8, BID8, CID8, DID8
  // channel data in
  //      A     B     C     D
  ,input AID0, BID0, CID0, DID0
  ,input AID1, BID1, CID1, DID1
  ,input AID2, BID2, CID2, DID2
  ,input AID3, BID3, CID3, DID3
  ,input AID4, BID4, CID4, DID4
  ,input AID5, BID5, CID5, DID5
  ,input AID6, BID6, CID6, DID6
  ,input AID7, BID7, CID7, DID7
  // channel token out
  ,output AIT0,  BIT0, CIT0, DIT0);

  // clock

  logic core_clk_lo /* synthesis syn_keep = 1 */;
  logic io_2x_clk_lo, io_clk_lo;

  bsg_asic_clk clk
    (.core_clk_i(MSTR_SDO_CLK)
    ,.io_clk_i(PLL_CLK_I)
    ,.core_clk_o(core_clk_lo)
    ,.io_clk_o(io_2x_clk_lo));
    
  always @(posedge io_2x_clk_lo) begin
    io_clk_lo <= ~io_clk_lo;
  end
    
    
  logic mc_clk_0, mc_clk_1, mc_reset_0, mc_reset_1;
  logic clk_0, clk_1, clk_2x_0, clk_2x_1, reset_0, reset_1;
  logic link_enable_0, link_enable_1;
  logic chip_reset_0, chip_reset_1;
  logic node_en_0, node_en_1, mc_en_0, mc_en_1;
  logic mc_error_0, mc_error_1;
  
  logic edge_clk_0, edge_valid_0, edge_token_0;
  logic [channel_width_p-1:0] edge_data_0;
  
  logic edge_clk_1, edge_valid_1, edge_token_1;
  logic [channel_width_p-1:0] edge_data_1;
  
  logic in_ct_valid_i, in_ct_ready_o;
  logic [width_p-1:0] in_ct_data_i;
  
  logic in_ct_valid_o, in_ct_ready_i;
  logic [width_p-1:0] in_ct_data_o;
  
  logic [1:0] in_demux_valid_o, in_demux_ready_i;
  logic [1:0][width_p-1:0] in_demux_data_o;
  
  logic [1:0] in_demux_valid_i, in_demux_ready_o;
  logic [1:0][width_p-1:0] in_demux_data_i;
  
  logic [1:0][2:0] in_router_valid_o, in_router_ready_i;
  logic [1:0][2:0][width_p-1:0] in_router_data_o;
  
  logic [1:0][2:0] in_router_valid_i, in_router_ready_o;
  logic [1:0][2:0][width_p-1:0] in_router_data_i;
  
  logic [1:0] in_node_valid_i, in_node_ready_o;
  logic [1:0][width_p-1:0] in_node_data_i;
  
  logic [1:0] in_node_valid_o, in_node_ready_i;
  logic [1:0][width_p-1:0] in_node_data_o;
  
  logic [bsg_manycore_link_sif_width_lp-1:0] in_mc_node_i;
  logic [bsg_manycore_link_sif_width_lp-1:0] in_mc_node_o;
  
  genvar i;
  
  assign clk_1 = io_clk_lo;
  assign clk_2x_1 = io_2x_clk_lo;
  assign mc_clk_1 = core_clk_lo;
    

  // reset

  logic reset_sync;
  logic [15:0] rst_count_r, rst_count_n;
  logic [3:0] rst_state_r, rst_state_n;
  logic reset_n, chip_reset_n, link_enable_n, node_en_n;
  
  bsg_sync_sync 
 #(.width_p(1))
  rst_bss
  (.oclk_i(clk_1)
  ,.iclk_data_i(AID10)
  ,.oclk_data_o(reset_sync));
  
  always @(posedge clk_1) begin
    if (reset_sync) begin
        rst_count_r <= 0;
        rst_state_r <= 0;
        reset_1 <= 0;
        chip_reset_1 <= 1;
        link_enable_1 <= 0;
        node_en_1 <= 0;
    end else begin
        rst_count_r <= rst_count_n;
        rst_state_r <= rst_state_n;
        reset_1 <= reset_n;
        chip_reset_1 <= chip_reset_n;
        link_enable_1 <= link_enable_n;
        node_en_1 <= node_en_n;
    end
  end
  
  always_comb begin
    
    rst_count_n = rst_count_r;
    rst_state_n = rst_state_r;
    reset_n = reset_1;
    chip_reset_n = chip_reset_1;
    link_enable_n = link_enable_1;
    node_en_n = node_en_1;
    
    if (rst_state_r == 0) begin
        rst_count_n = rst_count_r + 1;
        if (rst_count_r == 5000) begin
            reset_n = 1;
            rst_count_n = 0;
            rst_state_n = 1;
        end
    end
    else if (rst_state_r == 1) begin
        rst_count_n = rst_count_r + 1;
        if (rst_count_r == 5000) begin
            reset_n = 0;
            rst_count_n = 0;
            rst_state_n = 2;
        end
    end
    else if (rst_state_r == 2) begin
        rst_count_n = rst_count_r + 1;
        if (rst_count_r == 5000) begin
            link_enable_n = 1;
            rst_count_n = 0;
            rst_state_n = 3;
        end
    end
    else if (rst_state_r == 3) begin
        rst_count_n = rst_count_r + 1;
        if (rst_count_r == 5000) begin
            chip_reset_n = 0;
            rst_count_n = 0;
            rst_state_n = 4;
        end
    end
    else if (rst_state_r == 4) begin
        rst_count_n = rst_count_r + 1;
        if (rst_count_r == 5000) begin
            node_en_n = 1;
            rst_count_n = 0;
            rst_state_n = 5;
        end
    end
    
  end
  
  
  // chipscope

  bsg_gateway_chipscope cs
    (.clk_i(clk_1)
    ,.data_i({'0
             ,in_node_data_i[1]
             ,in_node_ready_o[1]
             ,in_node_valid_i[1]
             ,in_node_data_i[0]
             ,in_node_ready_o[0]
             ,in_node_valid_i[0]
             ,in_node_data_o[1]
             ,in_node_ready_i[1]
             ,in_node_valid_o[1]
             ,in_node_data_o[0]
             ,in_node_ready_i[0]
             ,in_node_valid_o[0]}));
  
  
  bsg_link_ddr
 #(.width_p(width_p)
  ,.channel_width_p(channel_width_p)
  ,.lg_fifo_depth_p(lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p))
  link_1
  (.clk_i(clk_1)
  ,.clk_2x_i(clk_2x_1)
  ,.reset_i(reset_1)
  ,.chip_reset_i(chip_reset_1)
  ,.link_enable_i(link_enable_1)
  ,.link_enable_o()
  
  ,.data_i(in_ct_data_o)
  ,.valid_i(in_ct_valid_o)
  ,.ready_o(in_ct_ready_i)
  
  ,.data_o(in_ct_data_i)
  ,.valid_o(in_ct_valid_i)
  ,.yumi_i(in_ct_valid_i&in_ct_ready_o)

  ,.io_clk_r_o(edge_clk_1)
  ,.io_data_r_o(edge_data_1)
  ,.io_valid_r_o(edge_valid_1)
  ,.io_token_i(edge_token_1)
  
  ,.io_clk_i(edge_clk_0)
  ,.io_data_i(edge_data_0)
  ,.io_valid_i(edge_valid_0)
  ,.io_token_r_o(edge_token_0));


  bsg_wormhole_channel_tunnel
 #(.width_p(width_p)
  ,.x_cord_width_p(x_cord_width_p)
  ,.y_cord_width_p(y_cord_width_p)
  ,.len_width_p(len_width_p)
  ,.reserved_width_p(reserved_width_p)
  ,.num_in_p(2)
  ,.remote_credits_p(remote_credits_p)
  ,.max_len_p(ct_max_len_p)
  ,.lg_credit_decimation_p(ct_lg_credit_decimation_p))
  in_ct
  (.clk_i(clk_1)
  ,.reset_i(chip_reset_1)
  
  // incoming multiplexed data
  ,.multi_data_i(in_ct_data_i)
  ,.multi_v_i(in_ct_valid_i)
  ,.multi_ready_o(in_ct_ready_o)

  // outgoing multiplexed data
  ,.multi_data_o(in_ct_data_o)
  ,.multi_v_o(in_ct_valid_o)
  ,.multi_yumi_i(in_ct_ready_i&in_ct_valid_o)

  // incoming demultiplexed data
  ,.data_i(in_demux_data_i)
  ,.v_i(in_demux_valid_i)
  ,.ready_o(in_demux_ready_o)

  // outgoing demultiplexed data
  ,.data_o(in_demux_data_o)
  ,.v_o(in_demux_valid_o)
  ,.yumi_i(in_demux_valid_o&in_demux_ready_i));
  
  
  for (i = 0; i < 2; i++) begin: r1
  
    bsg_wormhole_router
   #(.width_p(width_p)
    ,.x_cord_width_p(x_cord_width_p)
    ,.y_cord_width_p(y_cord_width_p)
    ,.len_width_p(len_width_p)
    ,.reserved_width_p(reserved_width_p)
    ,.enable_2d_routing_p(0)
    ,.stub_in_p(3'b100)
    ,.stub_out_p(3'b100))
    router_1
    (.clk_i(clk_1)
    ,.reset_i(chip_reset_1)
    // Configuration
    ,.local_x_cord_i((x_cord_width_p)'(3))
    ,.local_y_cord_i((y_cord_width_p)'(0))
    // Input Traffics
    ,.valid_i(in_router_valid_i[i])
    ,.data_i(in_router_data_i[i])
    ,.ready_o(in_router_ready_o[i])
    // Output Traffics
    ,.valid_o(in_router_valid_o[i])
    ,.data_o(in_router_data_o[i])
    ,.ready_i(in_router_ready_i[i]));
    
    assign in_node_valid_i[i] = in_router_valid_o[i][P];
    assign in_node_data_i[i] = in_router_data_o[i][P];
    assign in_router_ready_i[i][P] = in_node_ready_o[i];
    assign in_router_valid_i[i][P] = in_node_valid_o[i];
    assign in_router_data_i[i][P] = in_node_data_o[i];
    assign in_node_ready_i[i] = in_router_ready_o[i][P];
    
    assign in_demux_valid_i[i] = in_router_valid_o[i][W];
    assign in_demux_data_i[i] = in_router_data_o[i][W];
    assign in_router_ready_i[i][W] = in_demux_ready_o[i];
    assign in_router_valid_i[i][W] = in_demux_valid_o[i];
    assign in_router_data_i[i][W] = in_demux_data_o[i];
    assign in_demux_ready_i[i] = in_router_ready_o[i][W];
    
  end


  bsg_manycore_async_link_to_wormhole
 #(.addr_width_p(mc_addr_width_p)
  ,.data_width_p(mc_data_width_p)
  ,.load_id_width_p(mc_load_id_width_p)
  ,.x_cord_width_p(mc_x_cord_width_p)
  ,.y_cord_width_p(mc_y_cord_width_p)
  ,.wormhole_req_ratio_p(req_ratio_p)
  ,.wormhole_resp_ratio_p(resp_ratio_p)
  ,.wormhole_width_p(width_p)
  ,.wormhole_x_cord_width_p(x_cord_width_p)
  ,.wormhole_y_cord_width_p(y_cord_width_p)
  ,.wormhole_len_width_p(len_width_p)
  ,.wormhole_reserved_width_p(reserved_width_p)
  ,.x_dest_p(2))
  in_adapter
  (.manycore_clk_i(mc_clk_1)
  ,.manycore_reset_o(mc_reset_1)
  ,.manycore_en_o(mc_en_1)
   
  ,.links_sif_i(in_mc_node_o)
  ,.links_sif_o(in_mc_node_i)
   
  ,.clk_i(clk_1)
  ,.reset_i(chip_reset_1)
  ,.en_i(node_en_1)

  ,.valid_i(in_node_valid_i)
  ,.data_i(in_node_data_i)
  ,.ready_o(in_node_ready_o)
 
  ,.valid_o(in_node_valid_o)
  ,.data_o(in_node_data_o)
  ,.yumi_i(in_node_valid_o & in_node_ready_i));
  
  
  bsg_manycore_loopback_test_node
 #(.num_channel_p(mc_node_num_channel_p)
  ,.channel_width_p(channel_width_p)
  ,.addr_width_p(mc_addr_width_p)
  ,.data_width_p(mc_data_width_p)
  ,.load_id_width_p(mc_load_id_width_p)
  ,.x_cord_width_p(mc_x_cord_width_p)
  ,.y_cord_width_p(mc_y_cord_width_p))
  in_mc_node
  (.clk_i(mc_clk_1)
  ,.reset_i(mc_reset_1)
  ,.en_i(mc_en_1)
  ,.error_o(mc_error_1)

  ,.links_sif_i(in_mc_node_i)
  ,.links_sif_o(in_mc_node_o));


  // channel in

  assign edge_clk_0 = {AIC0};
  assign edge_valid_0 = {AID8};
  assign edge_data_0 = {{AID7, AID6, AID5, AID4, AID3, AID2, AID1, AID0}};
  assign {AIT0} = edge_token_0;

  // channel out

  assign {AOC0} = edge_clk_1;
  assign {AOD8} = edge_valid_1;
  assign {AOD7, AOD6, AOD5, AOD4, AOD3, AOD2, AOD1, AOD0} = edge_data_1;
  assign edge_token_1 = {AOT0};
  

  // led

  assign ASIC_LED0 = AID10;
  assign ASIC_LED1 = mc_error_1;

endmodule
