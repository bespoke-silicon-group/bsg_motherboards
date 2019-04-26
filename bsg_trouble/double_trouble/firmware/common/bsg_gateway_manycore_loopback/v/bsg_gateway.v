// bsg_gateway has FMC-support for these two boards:
//   * Xilinx ML605 (bsg_ml605)
//   * Digilent Zedboard (bsg_zedboard)
//
// BSG_ML605_FMC macro sets pinout for ML605
// BSG_ZEDBOARD_FMC macro sets pinout for Zedboard

`include "bsg_defines.v"
`include "bsg_manycore_packet.vh"

module bsg_gateway

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

  // clk osc
  (input CLK_OSC_P, CLK_OSC_N
`ifndef SIMULATION
  // reset
  ,input PWR_RSTN
  // voltage-rail enable
  ,output logic ASIC_CORE_EN, ASIC_IO_EN
  // current monitor
  ,output logic CUR_MON_ADDR0, CUR_MON_ADDR1
  ,inout CUR_MON_SCL, CUR_MON_SDA
  // potentiometer
  ,output logic DIG_POT_ADDR0, DIG_POT_ADDR1
  ,output logic DIG_POT_INDEP, DIG_POT_NRST
  ,inout DIG_POT_SCL, DIG_POT_SDA
  // uart
  ,input UART_RX
  ,output UART_TX
  // led
  ,output logic FPGA_LED0, FPGA_LED1
`endif
  ,output FPGA_LED2, FPGA_LED3

  // -------- ASIC --------

  // clk
  ,output MSTR_SDO_CLK
  ,output PLL_CLK_I
  ,output AIC1

  // asic reset
  ,output AID10

  // channel in

  // channel clk in
  ,input AOC0, BOC0, COC0, DOC0
  // channel valid in
  ,input AOD8, BOD8, COD8, DOD8
  // channel data in
  //      A     B     C     D
  ,input AOD0, BOD0, COD0, DOD0
  ,input AOD1, BOD1, COD1, DOD1
  ,input AOD2, BOD2, COD2, DOD2
  ,input AOD3, BOD3, COD3, DOD3
  ,input AOD4, BOD4, COD4, DOD4
  ,input AOD5, BOD5, COD5, DOD5
  ,input AOD6, BOD6, COD6, DOD6
  ,input AOD7, BOD7, COD7, DOD7
  // channel token out
  ,output AOT0, BOT0, COT0, DOT0

  // channel out

  // channel clk out
  ,output AIC0, BIC0, CIC0, DIC0
  // channel valid out
  ,output AID8, BID8, CID8, DID8
  // channel data out
  //       A     B     C     D
  ,output AID0, BID0, CID0, DID0
  ,output AID1, BID1, CID1, DID1
  ,output AID2, BID2, CID2, DID2
  ,output AID3, BID3, CID3, DID3
  ,output AID4, BID4, CID4, DID4
  ,output AID5, BID5, CID5, DID5
  ,output AID6, BID6, CID6, DID6
  ,output AID7, BID7, CID7, DID7
  // channel token in
  ,input AIT0, BIT0, CIT0, DIT0

  // -------- FMC --------
  // see bsg_gateway_fmc.v for notes on FMC usage.
  //
  // fmc reset in
  ,input F20_P, F20_N
  // fmc host reset out
  ,output F23_P, F23_N
  // fmc tx clk in
  ,input FCLK0_M2C_P, FCLK0_M2C_N

`ifdef BSG_ML605_FMC
  // fmc tx clk out
  ,output FCLK1_M2C_P, FCLK1_M2C_N
  // fmc tx data out [0]
  ,output F0_P, F0_N
`else
`ifdef BSG_ZEDBOARD_FMC
  // fmc tx clk out
  ,output F0_P, F0_N
  // fmc tx data out [0]
  ,output F1_P, F1_N
`endif
`endif

  // fmc tx data out [9:1]
  ,output F16_P, F16_N
  ,output F15_P, F15_N
  ,output F13_P, F13_N
  ,output F11_P, F11_N
  ,output F10_P, F10_N
  ,output F14_P, F14_N
  ,output F9_P, F9_N
  ,output F4_P, F4_N
  ,output F7_P, F7_N
  ,output F8_P, F8_N

  // fmc rx clk in
  ,input F17_P, F17_N
  // fmc rx data in
  ,input F31_P, F31_N
  ,input F33_P, F33_N
  ,input F30_P, F30_N
  ,input F32_P, F32_N
  ,input F28_P, F28_N
  ,input F25_P, F25_N
  ,input F29_P, F29_N
  ,input F26_P, F26_N
  ,input F21_P, F21_N
  ,input F27_P, F27_N
  ,input F22_P, F22_N);

  // clock generation

  logic mb_clk_lo;
  logic mc_clk_lo;
  logic core_clk_lo;
  logic io_2x_clk_lo;
  logic io_clk_lo;
  logic locked_lo;

  bsg_gateway_clk clk
    (.clk_150_mhz_p_i(CLK_OSC_P) ,.clk_150_mhz_n_i(CLK_OSC_N)
    // microblaze clock
    ,.mb_clk_o(mb_clk_lo)
    // internal clocks
    ,.int_core_clk_o(core_clk_lo)
    ,.int_io_master_clk_o(io_2x_clk_lo)
    ,.int_mc_clk_o(mc_clk_lo)
    // external clocks
    ,.ext_core_clk_o(MSTR_SDO_CLK)
    ,.ext_io_master_clk_o(PLL_CLK_I)
    ,.ext_mc_clk_o(AIC1)
    // locked
    ,.locked_o(locked_lo));
    
  always @(posedge io_2x_clk_lo) begin
    io_clk_lo <= ~io_clk_lo;
  end

`ifndef SIMULATION

  // power control

  logic [11:0] gpio;
  logic cpu_override_output_p;
  logic cpu_override_output_n;

  assign cpu_override_output_p = gpio[11];
  assign cpu_override_output_n = gpio[10];

  always_comb begin
    DIG_POT_INDEP = 1'b1;
    DIG_POT_NRST = 1'b1;
    DIG_POT_ADDR0 = 1'b1;
    DIG_POT_ADDR1 = 1'b1;
    CUR_MON_ADDR0 = 1'b1;
    CUR_MON_ADDR1 = 1'b1;
    ASIC_IO_EN = 1'b1;
    ASIC_CORE_EN = 1'b1;
    if (cpu_override_output_p == 1'b1 && cpu_override_output_n == 1'b0) begin
      DIG_POT_INDEP = gpio[2];
      DIG_POT_NRST = gpio[3];
      DIG_POT_ADDR0 = gpio[4];
      DIG_POT_ADDR1 = gpio[5];
      CUR_MON_ADDR0 = gpio[6];
      CUR_MON_ADDR1 = gpio[7];
      ASIC_IO_EN = gpio[8];
      ASIC_CORE_EN = gpio[9];
    end
  end

  (* BOX_TYPE = "user_black_box" *)
  board_ctrl board_ctrl_i
    (.RESET(1'b1)
    ,.CLK_50(mb_clk_lo)
    ,.CLK_LOCKED(locked_lo)
    ,.axi_iic_dig_pot_Gpo_pin()
    ,.axi_iic_dig_pot_Sda_pin(DIG_POT_SDA)
    ,.axi_iic_dig_pot_Scl_pin(DIG_POT_SCL)
    ,.axi_iic_cur_mon_Gpo_pin()
    ,.axi_iic_cur_mon_Sda_pin(CUR_MON_SDA)
    ,.axi_iic_cur_mon_Scl_pin(CUR_MON_SCL)
    ,.axi_gpio_0_GPIO_IO_O_pin(gpio)
    ,.axi_gpio_0_GPIO2_IO_I_pin()
    ,.axi_uartlite_0_RX_pin(UART_RX)
    ,.axi_uartlite_0_TX_pin(UART_TX));

`endif

  logic mc_clk_0, mc_clk_1, mc_reset_0, mc_reset_1;
  logic clk_0, clk_1, reset_0, reset_1;
  logic clk_1x_0, clk_1x_1, clk_2x_0, clk_2x_1;
  logic link_enable_0, link_enable_1;
  logic chip_reset_0, chip_reset_1;
  logic node_en_0, node_en_1, mc_en_0, mc_en_1;
  logic mc_error_0, mc_error_1;
  
  logic [bsg_manycore_link_sif_width_lp-1:0] out_mc_node_i;
  logic [bsg_manycore_link_sif_width_lp-1:0] out_mc_node_o;
  
  logic [1:0] out_node_valid_o, out_node_ready_i;
  logic [1:0][width_p-1:0] out_node_data_o;
  
  logic [1:0] out_node_valid_i, out_node_ready_o;
  logic [1:0][width_p-1:0] out_node_data_i;
  
  logic [1:0][2:0] out_router_valid_o, out_router_ready_i;
  logic [1:0][2:0][width_p-1:0] out_router_data_o;
  
  logic [1:0][2:0] out_router_valid_i, out_router_ready_o;
  logic [1:0][2:0][width_p-1:0] out_router_data_i;
  
  logic [1:0] out_demux_valid_o, out_demux_ready_i;
  logic [1:0][width_p-1:0] out_demux_data_o;
  
  logic [1:0] out_demux_valid_i, out_demux_ready_o;
  logic [1:0][width_p-1:0] out_demux_data_i;
  
  logic out_ct_valid_o, out_ct_ready_i;
  logic [width_p-1:0] out_ct_data_o;
  
  logic out_ct_valid_i, out_ct_ready_o;
  logic [width_p-1:0] out_ct_data_i;
  
  logic edge_clk_0, edge_valid_0, edge_token_0;
  logic [channel_width_p-1:0] edge_data_0;
  
  logic edge_clk_1, edge_valid_1, edge_token_1;
  logic [channel_width_p-1:0] edge_data_1;
  
  genvar i;
  
  assign clk_0 = core_clk_lo;
  assign clk_1x_0 = io_clk_lo;
  assign clk_2x_0 = io_2x_clk_lo;
  assign mc_clk_0 = mc_clk_lo;
  
  
  // Handling reset
  
  logic reset_sync;
  logic [15:0] rst_count_r, rst_count_n;
  logic [3:0] rst_state_r, rst_state_n;
  logic reset_n, chip_reset_n, link_enable_n, node_en_n;
  
  bsg_sync_sync 
 #(.width_p(1))
  rst_bss
  (.oclk_i(clk_0)
  ,.iclk_data_i(~PWR_RSTN)
  ,.oclk_data_o(reset_sync));
  
  always @(posedge clk_0) begin
    if (reset_sync) begin
        rst_count_r <= 0;
        rst_state_r <= 0;
        reset_0 <= 0;
        chip_reset_0 <= 1;
        link_enable_0 <= 0;
        node_en_0 <= 0;
    end else begin
        rst_count_r <= rst_count_n;
        rst_state_r <= rst_state_n;
        reset_0 <= reset_n;
        chip_reset_0 <= chip_reset_n;
        link_enable_0 <= link_enable_n;
        node_en_0 <= node_en_n;
    end
  end
  
  always_comb begin
    
    rst_count_n = rst_count_r;
    rst_state_n = rst_state_r;
    reset_n = reset_0;
    chip_reset_n = chip_reset_0;
    link_enable_n = link_enable_0;
    node_en_n = node_en_0;
    
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


`ifndef SIMULATION

  // chipscope

  bsg_gateway_chipscope cs
    (.clk_i(clk_0)
    ,.data_i({'0
             ,out_node_data_i[1]
             ,out_node_ready_o[1]
             ,out_node_valid_i[1]
             ,out_node_data_i[0]
             ,out_node_ready_o[0]
             ,out_node_valid_i[0]
             ,out_node_data_o[1]
             ,out_node_ready_i[1]
             ,out_node_valid_o[1]
             ,out_node_data_o[0]
             ,out_node_ready_i[0]
             ,out_node_valid_o[0]}));

`endif


  bsg_manycore_loopback_test_node
 #(.num_channel_p(mc_node_num_channel_p)
  ,.channel_width_p(channel_width_p)
  ,.addr_width_p(mc_addr_width_p)
  ,.data_width_p(mc_data_width_p)
  ,.load_id_width_p(mc_load_id_width_p)
  ,.x_cord_width_p(mc_x_cord_width_p)
  ,.y_cord_width_p(mc_y_cord_width_p))
  out_mc_node
  (.clk_i(mc_clk_0)
  ,.reset_i(mc_reset_0)
  ,.en_i(mc_en_0)
  ,.error_o(mc_error_0)

  ,.links_sif_i(out_mc_node_i)
  ,.links_sif_o(out_mc_node_o));


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
  ,.x_dest_p(3))
  out_adapter
  (.manycore_clk_i(mc_clk_0)
  ,.manycore_reset_o(mc_reset_0)
  ,.manycore_en_o(mc_en_0)
   
  ,.links_sif_i(out_mc_node_o)
  ,.links_sif_o(out_mc_node_i)
   
  ,.clk_i(clk_0)
  ,.reset_i(chip_reset_0)
  ,.en_i(node_en_0)

  ,.valid_i(out_node_valid_i)
  ,.data_i(out_node_data_i)
  ,.ready_o(out_node_ready_o)
 
  ,.valid_o(out_node_valid_o)
  ,.data_o(out_node_data_o)
  ,.yumi_i(out_node_valid_o & out_node_ready_i));
  
  
  for (i = 0; i < 2; i++) begin: r0
  
    bsg_wormhole_router
   #(.width_p(width_p)
    ,.x_cord_width_p(x_cord_width_p)
    ,.y_cord_width_p(y_cord_width_p)
    ,.len_width_p(len_width_p)
    ,.reserved_width_p(reserved_width_p)
    ,.enable_2d_routing_p(0)
    ,.stub_in_p(3'b010)
    ,.stub_out_p(3'b010))
    router_0
    (.clk_i(clk_0)
    ,.reset_i(chip_reset_0)
    // Configuration
    ,.local_x_cord_i((x_cord_width_p)'(2))
    ,.local_y_cord_i((y_cord_width_p)'(0))
    // Input Traffics
    ,.valid_i(out_router_valid_i[i])
    ,.data_i(out_router_data_i[i])
    ,.ready_o(out_router_ready_o[i])
    // Output Traffics
    ,.valid_o(out_router_valid_o[i])
    ,.data_o(out_router_data_o[i])
    ,.ready_i(out_router_ready_i[i]));
    
    assign out_node_valid_i[i] = out_router_valid_o[i][P];
    assign out_node_data_i[i] = out_router_data_o[i][P];
    assign out_router_ready_i[i][P] = out_node_ready_o[i];
    assign out_router_valid_i[i][P] = out_node_valid_o[i];
    assign out_router_data_i[i][P] = out_node_data_o[i];
    assign out_node_ready_i[i] = out_router_ready_o[i][P];
    
    assign out_demux_valid_i[i] = out_router_valid_o[i][E];
    assign out_demux_data_i[i] = out_router_data_o[i][E];
    assign out_router_ready_i[i][E] = out_demux_ready_o[i];
    assign out_router_valid_i[i][E] = out_demux_valid_o[i];
    assign out_router_data_i[i][E] = out_demux_data_o[i];
    assign out_demux_ready_i[i] = out_router_ready_o[i][E]; 
    
  end
  
  
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
  out_ct
  (.clk_i(clk_0)
  ,.reset_i(chip_reset_0)
  
  // incoming multiplexed data
  ,.multi_data_i(out_ct_data_i)
  ,.multi_v_i(out_ct_valid_i)
  ,.multi_ready_o(out_ct_ready_o)

  // outgoing multiplexed data
  ,.multi_data_o(out_ct_data_o)
  ,.multi_v_o(out_ct_valid_o)
  ,.multi_yumi_i(out_ct_ready_i&out_ct_valid_o)

  // incoming demultiplexed data
  ,.data_i(out_demux_data_i)
  ,.v_i(out_demux_valid_i)
  ,.ready_o(out_demux_ready_o)

  // outgoing demultiplexed data
  ,.data_o(out_demux_data_o)
  ,.v_o(out_demux_valid_o)
  ,.yumi_i(out_demux_valid_o&out_demux_ready_i));
  
  
  bsg_link_ddr
 #(.width_p(width_p)
  ,.channel_width_p(channel_width_p)
  ,.lg_fifo_depth_p(lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p))
  link_0
  (.clk_i(clk_0)
  ,.clk_1x_i(clk_1x_0)
  ,.clk_2x_i(clk_2x_0)
  ,.reset_i(reset_0)
  ,.chip_reset_i(chip_reset_0)
  ,.link_enable_i(link_enable_0)
  ,.link_enable_o()
  
  ,.data_i(out_ct_data_o)
  ,.valid_i(out_ct_valid_o)
  ,.ready_o(out_ct_ready_i)
  
  ,.data_o(out_ct_data_i)
  ,.valid_o(out_ct_valid_i)
  ,.yumi_i(out_ct_valid_i&out_ct_ready_o)

  ,.io_clk_r_o(edge_clk_0)
  ,.io_data_r_o(edge_data_0)
  ,.io_valid_r_o(edge_valid_0)
  ,.io_token_i(edge_token_0)

  ,.io_clk_i(edge_clk_1)
  ,.io_data_i(edge_data_1)
  ,.io_valid_i(edge_valid_1)
  ,.io_token_r_o(edge_token_1));


  // io

  // channel in

  assign edge_clk_1 = {AOC0};
  assign edge_valid_1 = {AOD8};
  assign edge_data_1 = {{AOD7, AOD6, AOD5, AOD4, AOD3, AOD2, AOD1, AOD0}};
  assign {AOT0} = edge_token_1;

  // channel out
  assign {AIC0} = edge_clk_0;
  assign {AID8} = edge_valid_0;
  assign {AID7, AID6, AID5, AID4, AID3, AID2, AID1, AID0} = edge_data_0;
  assign edge_token_0 = {AIT0};

  // reset signals for asic
  assign AID10 = ~PWR_RSTN;

  // led
  assign FPGA_LED0 = mc_error_0;
  assign FPGA_LED1 = mc_error_0;
  assign FPGA_LED2 = chip_reset_0;
  assign FPGA_LED3 = node_en_0;


endmodule
