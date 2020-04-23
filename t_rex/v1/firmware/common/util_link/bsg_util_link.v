
`timescale 1 ps / 1 ps
`include "bsg_noc_links.vh"

module bsg_util_link

  import bsg_noc_pkg::*;
  import bsg_wormhole_router_pkg::*;

 #(parameter util_flit_width_p = 8
  ,parameter util_len_width_p  = 4
  ,parameter util_cord_width_p = 4
  ,parameter use_legacy_router = 0

  ,parameter util_dims_p = 1
  ,parameter util_dirs_p = util_dims_p*2+1
  ,parameter int util_cord_markers_pos_p[util_dims_p:0] = '{util_cord_width_p, 0}
  ,parameter bit [1:0][util_dirs_p-1:0][util_dirs_p-1:0] util_routing_matrix_p = StrictX

  ,parameter util_nodes_p = 5
  ,parameter num_iic_p    = 3
  ,parameter iic_offset_p = 1
  ,parameter tag_offset_p = 4
  
  ,localparam util_link_width_lp = `bsg_ready_and_link_sif_width(util_flit_width_p)
  )

  (input  clk_i
  ,input  reset_i
  
  ,input  [util_link_width_lp-1:0] tag_trace_link_i
  ,output [util_link_width_lp-1:0] tag_trace_link_o

  ,input  rs232_uart_rxd
  ,output rs232_uart_txd

  ,inout  [num_iic_p-1:0] iic_main_scl_io
  ,inout  [num_iic_p-1:0] iic_main_sda_io

  ,output TPS0_CNTL
  ,output DIG_POT_PLL_ADDR1
  ,output DIG_POT_PLL_ADDR0
  ,output DIG_POT_PLL_INDEP
  ,output DIG_POT_PLL_NRST
  ,output DIG_POT_IO_ADDR1
  ,output DIG_POT_IO_ADDR0
  ,output DIG_POT_IO_INDEP
  ,output DIG_POT_IO_NRST
  );

  // uart axil slave
  logic [3:0]  uart_axil_s_araddr;
  logic        uart_axil_s_arready;
  logic        uart_axil_s_arvalid;
  
  logic [3:0]  uart_axil_s_awaddr;
  logic        uart_axil_s_awready;
  logic        uart_axil_s_awvalid;
  
  logic        uart_axil_s_bready;
  logic [1:0]  uart_axil_s_bresp;
  logic        uart_axil_s_bvalid;
  
  logic [31:0] uart_axil_s_rdata;
  logic        uart_axil_s_rready;
  logic [1:0]  uart_axil_s_rresp;
  logic        uart_axil_s_rvalid;
  
  logic [31:0] uart_axil_s_wdata;
  logic        uart_axil_s_wready;
  logic [3:0]  uart_axil_s_wstrb;
  logic        uart_axil_s_wvalid;
  
  // wormhole definition
  `declare_bsg_ready_and_link_sif_s(util_flit_width_p, bsg_util_link_sif_s);
  
  // wormhole router
  bsg_util_link_sif_s [util_nodes_p-1:0][util_dirs_p-1:0] util_link_li;
  bsg_util_link_sif_s [util_nodes_p-1:0][util_dirs_p-1:0] util_link_lo;
  
  for (genvar i = 0; i < util_nodes_p; i++) 
  begin : util_loop
    if (use_legacy_router == 0)
      begin: rtr
        bsg_wormhole_router
       #(.flit_width_p(util_flit_width_p)
        ,.dims_p(util_dims_p)
        ,.cord_markers_pos_p(util_cord_markers_pos_p)
        ,.routing_matrix_p(util_routing_matrix_p)
        ,.reverse_order_p(0)
        ,.len_width_p(util_len_width_p)
        ) util_rtr
        (.clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.my_cord_i(util_cord_width_p'(i))
        ,.link_i(util_link_li[i])
        ,.link_o(util_link_lo[i])
        );
      end
    else
      begin: legacy
        bsg_wormhole_router_generalized
       #(.flit_width_p(util_flit_width_p)
        ,.dims_p(util_dims_p)
        ,.cord_markers_pos_p(util_cord_markers_pos_p)
        ,.routing_matrix_p(util_routing_matrix_p)
        ,.reverse_order_p(0)
        ,.len_width_p(util_len_width_p)
        ) util_rtr
        (.clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.my_cord_i(util_cord_width_p'(i))
        ,.link_i(util_link_li[i])
        ,.link_o(util_link_lo[i])
        );
      end
    
    // stitching
    if (i == 0)
        assign util_link_li[i][W] = '0;
    else
        assign util_link_li[i][W] = util_link_lo[i-1][E];

    if (i == util_nodes_p-1)
        assign util_link_li[i][E] = '0;
    else
        assign util_link_li[i][E] = util_link_lo[i+1][W];
  end
  
  // uart_axil_s_to_fifo
  bsg_uart_axil_s_to_fifo
 #(.addr_width_p    (4)
  ,.data_width_p    (32)
  ,.uart_data_bits_p(util_flit_width_p)
  ,.buffer_size_p   (16)
  ) uart_adapter
  (.clk_i    (clk_i)
  ,.reset_i  (reset_i)
  
  ,.araddr_o (uart_axil_s_araddr)
  ,.arready_i(uart_axil_s_arready)
  ,.arvalid_o(uart_axil_s_arvalid)
  
  ,.awaddr_o (uart_axil_s_awaddr)
  ,.awready_i(uart_axil_s_awready)
  ,.awvalid_o(uart_axil_s_awvalid)
  
  ,.bready_o (uart_axil_s_bready)
  ,.bresp_i  (uart_axil_s_bresp)
  ,.bvalid_i (uart_axil_s_bvalid)

  ,.rdata_i  (uart_axil_s_rdata)
  ,.rready_o (uart_axil_s_rready)
  ,.rresp_i  (uart_axil_s_rresp)
  ,.rvalid_i (uart_axil_s_rvalid)

  ,.wdata_o  (uart_axil_s_wdata)
  ,.wready_i (uart_axil_s_wready)
  ,.wstrb_o  (uart_axil_s_wstrb)
  ,.wvalid_o (uart_axil_s_wvalid)

  ,.link_o   (util_link_li[0][P])
  ,.link_i   (util_link_lo[0][P])
  );
  
  util_design_1 util_design_1_i
       (.clk(clk_i),
        .rstn(~reset_i),
        .rs232_uart_rxd(rs232_uart_rxd),
        .rs232_uart_txd(rs232_uart_txd),
        .uart_axil_s_araddr(uart_axil_s_araddr),
        .uart_axil_s_arready(uart_axil_s_arready),
        .uart_axil_s_arvalid(uart_axil_s_arvalid),
        .uart_axil_s_awaddr(uart_axil_s_awaddr),
        .uart_axil_s_awready(uart_axil_s_awready),
        .uart_axil_s_awvalid(uart_axil_s_awvalid),
        .uart_axil_s_bready(uart_axil_s_bready),
        .uart_axil_s_bresp(uart_axil_s_bresp),
        .uart_axil_s_bvalid(uart_axil_s_bvalid),
        .uart_axil_s_rdata(uart_axil_s_rdata),
        .uart_axil_s_rready(uart_axil_s_rready),
        .uart_axil_s_rresp(uart_axil_s_rresp),
        .uart_axil_s_rvalid(uart_axil_s_rvalid),
        .uart_axil_s_wdata(uart_axil_s_wdata),
        .uart_axil_s_wready(uart_axil_s_wready),
        .uart_axil_s_wstrb(uart_axil_s_wstrb),
        .uart_axil_s_wvalid(uart_axil_s_wvalid));


  // TODO
  assign TPS0_CNTL = 1'b1;
  
  assign DIG_POT_PLL_ADDR1 = 1'b1;
  assign DIG_POT_PLL_ADDR0 = 1'b1;
  assign DIG_POT_PLL_INDEP = 1'b1;
  assign DIG_POT_PLL_NRST  = 1'b1;

  assign DIG_POT_IO_ADDR1  = 1'b1;
  assign DIG_POT_IO_ADDR0  = 1'b1;
  assign DIG_POT_IO_INDEP  = 1'b1;
  assign DIG_POT_IO_NRST   = 1'b1;


  for (genvar i = 0; i < num_iic_p; i++)
  begin: iic_loop
  
    logic iic_main_scl_i;
    logic iic_main_scl_o;
    logic iic_main_scl_t;
    logic iic_main_sda_i;
    logic iic_main_sda_o;
    logic iic_main_sda_t;
    
    // iic axil slave
    logic [8:0]  iic_axil_s_araddr;
    logic        iic_axil_s_arready;
    logic        iic_axil_s_arvalid;
    
    logic [8:0]  iic_axil_s_awaddr;
    logic        iic_axil_s_awready;
    logic        iic_axil_s_awvalid;
    
    logic        iic_axil_s_bready;
    logic [1:0]  iic_axil_s_bresp;
    logic        iic_axil_s_bvalid;
    
    logic [31:0] iic_axil_s_rdata;
    logic        iic_axil_s_rready;
    logic [1:0]  iic_axil_s_rresp;
    logic        iic_axil_s_rvalid;
    
    logic [31:0] iic_axil_s_wdata;
    logic        iic_axil_s_wready;
    logic [3:0]  iic_axil_s_wstrb;
    logic        iic_axil_s_wvalid;
    
    // iic_axil_s_to_fifo
    bsg_iic_axil_s_to_fifo
 #  (.addr_width_p    (9)
    ,.data_width_p    (32)
    ,.iic_data_bits_p (util_flit_width_p)
    ,.buffer_size_p   (16)
    ,.cord_width_p    (util_cord_width_p)
    ,.len_width_p     (util_len_width_p)
    ) iic_adapter
    (.clk_i    (clk_i)
    ,.reset_i  (reset_i)
    
    ,.araddr_o (iic_axil_s_araddr)
    ,.arready_i(iic_axil_s_arready)
    ,.arvalid_o(iic_axil_s_arvalid)
    
    ,.awaddr_o (iic_axil_s_awaddr)
    ,.awready_i(iic_axil_s_awready)
    ,.awvalid_o(iic_axil_s_awvalid)
    
    ,.bready_o (iic_axil_s_bready)
    ,.bresp_i  (iic_axil_s_bresp)
    ,.bvalid_i (iic_axil_s_bvalid)
    
    ,.rdata_i  (iic_axil_s_rdata)
    ,.rready_o (iic_axil_s_rready)
    ,.rresp_i  (iic_axil_s_rresp)
    ,.rvalid_i (iic_axil_s_rvalid)
    
    ,.wdata_o  (iic_axil_s_wdata)
    ,.wready_i (iic_axil_s_wready)
    ,.wstrb_o  (iic_axil_s_wstrb)
    ,.wvalid_o (iic_axil_s_wvalid)
    
    ,.dest_cord_i('0)
    
    ,.link_o   (util_link_li[i+iic_offset_p][P])
    ,.link_i   (util_link_lo[i+iic_offset_p][P])
    );
    
    util_design_2 util_design_2_i
         (.iic_axil_s_araddr(iic_axil_s_araddr),
          .iic_axil_s_arready(iic_axil_s_arready),
          .iic_axil_s_arvalid(iic_axil_s_arvalid),
          .iic_axil_s_awaddr(iic_axil_s_awaddr),
          .iic_axil_s_awready(iic_axil_s_awready),
          .iic_axil_s_awvalid(iic_axil_s_awvalid),
          .iic_axil_s_bready(iic_axil_s_bready),
          .iic_axil_s_bresp(iic_axil_s_bresp),
          .iic_axil_s_bvalid(iic_axil_s_bvalid),
          .iic_axil_s_rdata(iic_axil_s_rdata),
          .iic_axil_s_rready(iic_axil_s_rready),
          .iic_axil_s_rresp(iic_axil_s_rresp),
          .iic_axil_s_rvalid(iic_axil_s_rvalid),
          .iic_axil_s_wdata(iic_axil_s_wdata),
          .iic_axil_s_wready(iic_axil_s_wready),
          .iic_axil_s_wstrb(iic_axil_s_wstrb),
          .iic_axil_s_wvalid(iic_axil_s_wvalid),
          .iic_main_scl_i(iic_main_scl_i),
          .iic_main_scl_o(iic_main_scl_o),
          .iic_main_scl_t(iic_main_scl_t),
          .iic_main_sda_i(iic_main_sda_i),
          .iic_main_sda_o(iic_main_sda_o),
          .iic_main_sda_t(iic_main_sda_t),
          .clk(clk_i),
          .rstn(~reset_i));
          
    IOBUF iic_main_scl_iobuf
         (.I (iic_main_scl_o),
          .IO(iic_main_scl_io[i]),
          .O (iic_main_scl_i),
          .T (iic_main_scl_t));
    
    IOBUF iic_main_sda_iobuf
         (.I (iic_main_sda_o),
          .IO(iic_main_sda_io[i]),
          .O (iic_main_sda_i),
          .T (iic_main_sda_t));
          
  end
  
  // tag trace links
  assign util_link_li[tag_offset_p][P] = tag_trace_link_i;
  assign tag_trace_link_o = util_link_lo[tag_offset_p][P];

endmodule