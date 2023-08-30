//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
//Date        : Sat Mar 21 23:31:31 2020
//Host        : dhcp196-212.ece.uw.edu running 64-bit CentOS Linux release 7.7.1908 (Core)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

`include "bsg_cache_dma_pkt.vh"

module design_1_wrapper

 import bp_common_pkg::*;
 import bp_common_aviary_pkg::*;
 import bp_be_pkg::*;
 import bp_be_rv64_pkg::*;
 import bp_cce_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_wormhole_router_pkg::*;
 import bsg_cache_pkg::*;
 
 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;
 
 #(parameter bp_cfg_e cfg_p = bp_cfg_gp
  `declare_bp_proc_params(bp_cfg_gp)
  ,localparam cce_mshr_width_lp = `bp_cce_mshr_width(num_lce_p, lce_assoc_p, paddr_width_p)
  `declare_bp_me_if_widths(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp)
  
  ,localparam cache_addr_width_p = 30 - `BSG_SAFE_CLOG2(1) // one cache_dma
  ,localparam axi_id_width_p     = 1
  ,localparam axi_addr_width_p   = 30
  ,localparam axi_data_width_p   = 256
  ,localparam axi_burst_len_p    = 2
  ,localparam cce_ucode_filename_lp = "bp_cce_inst_rom_mesi_lce8_wg16_assoc8.mem"

  ,parameter util_flit_width_p = 8
  ,parameter util_len_width_p  = 4
  ,parameter util_cord_width_p = 4
  )

   (ddr4_sdram_act_n,
    ddr4_sdram_adr,
    ddr4_sdram_ba,
    ddr4_sdram_bg,
    ddr4_sdram_ck_c,
    ddr4_sdram_ck_t,
    ddr4_sdram_cke,
    ddr4_sdram_cs_n,
    ddr4_sdram_dm_n,
    ddr4_sdram_dq,
    ddr4_sdram_dqs_c,
    ddr4_sdram_dqs_t,
    ddr4_sdram_odt,
    ddr4_sdram_reset_n,
    pci_express_x4_rxn,
    pci_express_x4_rxp,
    pci_express_x4_txn,
    pci_express_x4_txp,
    pcie_perstn,
    pcie_refclk_clk_n,
    pcie_refclk_clk_p,
    reset,
    reset_gpio,
    sysclk_300_clk_n,
    sysclk_300_clk_p,
    led
    
   // util_link
   ,clk125_clk_n
   ,clk125_clk_p
   ,rs232_uart_rxd
   ,rs232_uart_txd
   ,iic_main_scl_io
   ,iic_main_sda_io
   
   ,TPS0_CNTL
   ,DIG_POT_PLL_ADDR1
   ,DIG_POT_PLL_ADDR0
   ,DIG_POT_PLL_INDEP
   ,DIG_POT_PLL_NRST
   ,DIG_POT_IO_ADDR1
   ,DIG_POT_IO_ADDR0
   ,DIG_POT_IO_INDEP
   ,DIG_POT_IO_NRST
    
    // bsg_link
   ,IC1_GW_CL_CLK, IC1_GW_CL_V
   ,IC1_GW_CL_TKN
   ,IC1_GW_CL_D0, IC1_GW_CL_D1, IC1_GW_CL_D2, IC1_GW_CL_D3, IC1_GW_CL_D4, IC1_GW_CL_D5, IC1_GW_CL_D6, IC1_GW_CL_D7, IC1_GW_CL_D8

   ,GW_IC1_CL_CLK, GW_IC1_CL_V
   ,GW_IC1_CL_TKN
   ,GW_IC1_CL_D0, GW_IC1_CL_D1, GW_IC1_CL_D2, GW_IC1_CL_D3, GW_IC1_CL_D4, GW_IC1_CL_D5, GW_IC1_CL_D6, GW_IC1_CL_D7, GW_IC1_CL_D8
   
    // bsg_tag and misc
   ,GW_TAG_CLKO, GW_TAG_DATAO, GW_IC1_TAG_EN
   ,GW_CLKA, GW_CLKB, GW_CLKC
   ,GW_SEL0, GW_SEL1, GW_SEL2
   ,GW_CLK_RESET, GW_CORE_RESET

   // SMA
   ,FPGA_SMA0);

  output ddr4_sdram_act_n;
  output [16:0]ddr4_sdram_adr;
  output [1:0]ddr4_sdram_ba;
  output [1:0]ddr4_sdram_bg;
  output [0:0]ddr4_sdram_ck_c;
  output [0:0]ddr4_sdram_ck_t;
  output [0:0]ddr4_sdram_cke;
  output [0:0]ddr4_sdram_cs_n;
  inout [3:0]ddr4_sdram_dm_n;
  inout [31:0]ddr4_sdram_dq;
  inout [3:0]ddr4_sdram_dqs_c;
  inout [3:0]ddr4_sdram_dqs_t;
  output [0:0]ddr4_sdram_odt;
  output ddr4_sdram_reset_n;

  input [3:0]pci_express_x4_rxn;
  input [3:0]pci_express_x4_rxp;
  output [3:0]pci_express_x4_txn;
  output [3:0]pci_express_x4_txp;

  input pcie_perstn;
  input pcie_refclk_clk_n;
  input pcie_refclk_clk_p;
  input reset;
  input reset_gpio;
  input sysclk_300_clk_n;
  input sysclk_300_clk_p;
  output [3:0] led;
  
  input  clk125_clk_n;
  input  clk125_clk_p;
  input  rs232_uart_rxd;
  output rs232_uart_txd;
  inout  [2:0] iic_main_scl_io;
  inout  [2:0] iic_main_sda_io;

  output TPS0_CNTL;
  output DIG_POT_PLL_ADDR1;
  output DIG_POT_PLL_ADDR0;
  output DIG_POT_PLL_INDEP;
  output DIG_POT_PLL_NRST;
  output DIG_POT_IO_ADDR1;
  output DIG_POT_IO_ADDR0;
  output DIG_POT_IO_INDEP;
  output DIG_POT_IO_NRST;
  
  output FPGA_SMA0;
  

  wire ddr4_sdram_act_n;
  wire [16:0]ddr4_sdram_adr;
  wire [1:0]ddr4_sdram_ba;
  wire [1:0]ddr4_sdram_bg;
  wire [0:0]ddr4_sdram_ck_c;
  wire [0:0]ddr4_sdram_ck_t;
  wire [0:0]ddr4_sdram_cke;
  wire [0:0]ddr4_sdram_cs_n;
  wire [3:0]ddr4_sdram_dm_n;
  wire [31:0]ddr4_sdram_dq;
  wire [3:0]ddr4_sdram_dqs_c;
  wire [3:0]ddr4_sdram_dqs_t;
  wire [0:0]ddr4_sdram_odt;
  wire ddr4_sdram_reset_n;

  wire sysclk_300_clk_n;
  wire sysclk_300_clk_p;

  wire [31:0]m_axi_lite_araddr;
  wire [2:0]m_axi_lite_arprot;
  wire m_axi_lite_arready;
  wire m_axi_lite_arvalid;
  wire [31:0]m_axi_lite_awaddr;
  wire [2:0]m_axi_lite_awprot;
  wire m_axi_lite_awready;
  wire m_axi_lite_awvalid;
  wire m_axi_lite_bready;
  wire [1:0]m_axi_lite_bresp;
  wire m_axi_lite_bvalid;
  wire [31:0]m_axi_lite_rdata;
  wire m_axi_lite_rready;
  wire [1:0]m_axi_lite_rresp;
  wire m_axi_lite_rvalid;
  wire [31:0]m_axi_lite_wdata;
  wire m_axi_lite_wready;
  wire [3:0]m_axi_lite_wstrb;
  wire m_axi_lite_wvalid;

  wire mig_calib_done;
  wire mig_clk;
  wire [0:0]mig_rstn;

  wire [3:0]pci_express_x4_rxn;
  wire [3:0]pci_express_x4_rxp;
  wire [3:0]pci_express_x4_txn;
  wire [3:0]pci_express_x4_txp;

  wire pcie_clk;
  wire pcie_lnk_up;
  wire pcie_perstn;

  wire pcie_refclk_clk_n;
  wire pcie_refclk_clk_p;

  wire [0:0]pcie_rstn;
  wire reset;
  wire reset_gpio;
  wire [3:0] led;
  
  wire clk125_clk_n;
  wire clk125_clk_p;
  wire rs232_uart_rxd;
  wire rs232_uart_txd;
  wire [2:0] iic_main_scl_io;
  wire [2:0] iic_main_sda_io;

  wire TPS0_CNTL;
  wire DIG_POT_PLL_ADDR1;
  wire DIG_POT_PLL_ADDR0;
  wire DIG_POT_PLL_INDEP;
  wire DIG_POT_PLL_NRST;
  wire DIG_POT_IO_ADDR1;
  wire DIG_POT_IO_ADDR0;
  wire DIG_POT_IO_INDEP;
  wire DIG_POT_IO_NRST;
  
  wire FPGA_SMA0;
  
  

  wire [29:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [3:0]s_axi_arcache;
  wire [0:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire [0:0]s_axi_arlock;
  wire [2:0]s_axi_arprot;
  wire [3:0]s_axi_arqos;
  wire s_axi_arready;
  wire [3:0]s_axi_arregion;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;

  wire [29:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [0:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire s_axi_awready;
  wire [3:0]s_axi_awregion;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;

  wire [0:0]s_axi_bid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;

  wire [255:0]s_axi_rdata;
  wire [0:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rready;
  wire [1:0]s_axi_rresp;
  wire s_axi_rvalid;

  wire [255:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [31:0]s_axi_wstrb;
  wire s_axi_wvalid;
  
  
  wire m_axi_lite_v_lo, m_axi_lite_yumi_li;
  wire [31:0] m_axi_lite_addr_lo, m_axi_lite_data_lo;
  wire m_axi_lite_v_li, m_axi_lite_ready_lo;
  wire [31:0] m_axi_lite_data_li;
  
  // LEDs
  assign led[0] = pcie_lnk_up;
  assign led[1] = mig_calib_done;
  
  // mig_reset
  logic mig_reset;
  bsg_dff #(.width_p(1)) mig_dff
  (.clk_i (mig_clk)
  ,.data_i(~mig_rstn | ~mig_calib_done)
  ,.data_o(mig_reset)
  );
  
  // m_axi_lite adapter
  bsg_m_axi_lite_to_fifo
 #(.addr_width_p(32)
  ,.data_width_p(32)
  ,.buffer_size_p(16)
  ) m_axi_lite_adapter
  (.pcie_clk_i  (pcie_clk)
  ,.pcie_reset_i(~pcie_rstn)
  
  // read address
  ,.araddr_i (m_axi_lite_araddr)
  ,.arprot_i (m_axi_lite_arprot)
  ,.arready_o(m_axi_lite_arready)
  ,.arvalid_i(m_axi_lite_arvalid)
  // read data
  ,.rdata_o  (m_axi_lite_rdata)
  ,.rready_i (m_axi_lite_rready)
  ,.rresp_o  (m_axi_lite_rresp)
  ,.rvalid_o (m_axi_lite_rvalid)
  // write address
  ,.awaddr_i (m_axi_lite_awaddr)
  ,.awprot_i (m_axi_lite_awprot)
  ,.awready_o(m_axi_lite_awready)
  ,.awvalid_i(m_axi_lite_awvalid)
  // write data
  ,.wdata_i  (m_axi_lite_wdata)
  ,.wready_o (m_axi_lite_wready)
  ,.wstrb_i  (m_axi_lite_wstrb)
  ,.wvalid_i (m_axi_lite_wvalid)
  // write response
  ,.bready_i (m_axi_lite_bready)
  ,.bresp_o  (m_axi_lite_bresp)
  ,.bvalid_o (m_axi_lite_bvalid)
  
  ,.clk_i    (mig_clk)
  ,.reset_i  (mig_reset)
  // fifo output
  ,.v_o      (m_axi_lite_v_lo)
  ,.addr_o   (m_axi_lite_addr_lo)
  ,.data_o   (m_axi_lite_data_lo)
  ,.yumi_i   (m_axi_lite_yumi_li)
  // fifo input
  ,.v_i      (m_axi_lite_v_li)
  ,.data_i   (m_axi_lite_data_li)
  ,.ready_o  (m_axi_lite_ready_lo)
  );

  
  input  IC1_GW_CL_CLK, IC1_GW_CL_V;
  output IC1_GW_CL_TKN;
  input  IC1_GW_CL_D0, IC1_GW_CL_D1, IC1_GW_CL_D2, IC1_GW_CL_D3, IC1_GW_CL_D4, IC1_GW_CL_D5, IC1_GW_CL_D6, IC1_GW_CL_D7, IC1_GW_CL_D8;

  output GW_IC1_CL_CLK, GW_IC1_CL_V;
  input  GW_IC1_CL_TKN;
  output GW_IC1_CL_D0, GW_IC1_CL_D1, GW_IC1_CL_D2, GW_IC1_CL_D3, GW_IC1_CL_D4, GW_IC1_CL_D5, GW_IC1_CL_D6, GW_IC1_CL_D7, GW_IC1_CL_D8;
  
  output GW_TAG_CLKO, GW_TAG_DATAO, GW_IC1_TAG_EN;
  output GW_CLKA, GW_CLKB, GW_CLKC;
  output GW_SEL0, GW_SEL1, GW_SEL2;
  output GW_CLK_RESET, GW_CORE_RESET;


  wire IC1_GW_CL_CLK, IC1_GW_CL_V;
  wire IC1_GW_CL_TKN;
  wire IC1_GW_CL_D0, IC1_GW_CL_D1, IC1_GW_CL_D2, IC1_GW_CL_D3, IC1_GW_CL_D4, IC1_GW_CL_D5, IC1_GW_CL_D6, IC1_GW_CL_D7, IC1_GW_CL_D8;

  wire GW_IC1_CL_CLK, GW_IC1_CL_V;
  wire GW_IC1_CL_TKN;
  wire GW_IC1_CL_D0, GW_IC1_CL_D1, GW_IC1_CL_D2, GW_IC1_CL_D3, GW_IC1_CL_D4, GW_IC1_CL_D5, GW_IC1_CL_D6, GW_IC1_CL_D7, GW_IC1_CL_D8;
  
  wire GW_TAG_CLKO, GW_TAG_DATAO, GW_IC1_TAG_EN;
  wire GW_CLKA, GW_CLKB, GW_CLKC;
  wire GW_SEL0, GW_SEL1, GW_SEL2;
  wire GW_CLK_RESET, GW_CORE_RESET;

/*
  bsg_chip chip
  (.p_ci_clk_i (GW_IC1_CL_CLK)
  ,.p_ci_v_i   (GW_IC1_CL_V)
  ,.p_ci_tkn_o (GW_IC1_CL_TKN)
  ,.p_ci_0_i   (GW_IC1_CL_D0)
  ,.p_ci_1_i   (GW_IC1_CL_D1)
  ,.p_ci_2_i   (GW_IC1_CL_D2)
  ,.p_ci_3_i   (GW_IC1_CL_D3)
  ,.p_ci_4_i   (GW_IC1_CL_D4)
  ,.p_ci_5_i   (GW_IC1_CL_D5)
  ,.p_ci_6_i   (GW_IC1_CL_D6)
  ,.p_ci_7_i   (GW_IC1_CL_D7)
  ,.p_ci_8_i   (GW_IC1_CL_D8)

  ,.p_co_clk_i ()
  ,.p_co_v_i   ()
  ,.p_co_tkn_o ()
  ,.p_co_0_i   ()
  ,.p_co_1_i   ()
  ,.p_co_2_i   ()
  ,.p_co_3_i   ()
  ,.p_co_4_i   ()
  ,.p_co_5_i   ()
  ,.p_co_6_i   ()
  ,.p_co_7_i   ()
  ,.p_co_8_i   ()

  ,.p_ci2_clk_o(IC1_GW_CL_CLK)
  ,.p_ci2_v_o  (IC1_GW_CL_D4)
  ,.p_ci2_tkn_i(IC1_GW_CL_TKN)
  ,.p_ci2_0_o  (IC1_GW_CL_D6)
  ,.p_ci2_1_o  (IC1_GW_CL_D5)
  ,.p_ci2_2_o  (IC1_GW_CL_D7)
  ,.p_ci2_3_o  (IC1_GW_CL_D8)
  ,.p_ci2_4_o  (IC1_GW_CL_D3)
  ,.p_ci2_5_o  (IC1_GW_CL_V)
  ,.p_ci2_6_o  (IC1_GW_CL_D2)
  ,.p_ci2_7_o  (IC1_GW_CL_D1)
  ,.p_ci2_8_o  (IC1_GW_CL_D0)

  ,.p_co2_clk_o()
  ,.p_co2_v_o  ()
  ,.p_co2_tkn_i()
  ,.p_co2_0_o  ()
  ,.p_co2_1_o  ()
  ,.p_co2_2_o  ()
  ,.p_co2_3_o  ()
  ,.p_co2_4_o  ()
  ,.p_co2_5_o  ()
  ,.p_co2_6_o  ()
  ,.p_co2_7_o  ()
  ,.p_co2_8_o  ()

  // 32-bit ddr dram interface, 72 pins
  // ddr interface differential output clock pair
  ,.p_ddr_ck_p_o(DDR_CK_P_O)
  ,.p_ddr_ck_n_o(DDR_CK_N_O)

  // ddr interface output clock enable signal
  ,.p_ddr_cke_o(DDR_CKE_O)

  // ddr interface output command signals
  ,.p_ddr_cs_n_o (DDR_CS_N_O)
  ,.p_ddr_ras_n_o(DDR_RAS_N_O)
  ,.p_ddr_cas_n_o(DDR_CAS_N_O)
  ,.p_ddr_we_n_o (DDR_WE_N_O)

  // ddr interface output control signals
  ,.p_ddr_reset_n_o (DDR_RESET_N_O)
  ,.p_ddr_odt_o     (DDR_ODT_O)

  // ddr interface bank address
  ,.p_ddr_ba_0_o(DDR_BA0_O)
  ,.p_ddr_ba_1_o(DDR_BA1_O)
  ,.p_ddr_ba_2_o(DDR_BA2_O)

  // ddr interface address bus
  ,.p_ddr_addr_0_o (DDR_ADDR0_O)
  ,.p_ddr_addr_1_o (DDR_ADDR1_O)
  ,.p_ddr_addr_2_o (DDR_ADDR2_O)
  ,.p_ddr_addr_3_o (DDR_ADDR3_O)
  ,.p_ddr_addr_4_o (DDR_ADDR4_O)
  ,.p_ddr_addr_5_o (DDR_ADDR5_O)
  ,.p_ddr_addr_6_o (DDR_ADDR6_O)
  ,.p_ddr_addr_7_o (DDR_ADDR7_O)
  ,.p_ddr_addr_8_o (DDR_ADDR8_O)
  ,.p_ddr_addr_9_o (DDR_ADDR9_O)
  ,.p_ddr_addr_10_o(DDR_ADDR10_O)
  ,.p_ddr_addr_11_o(DDR_ADDR11_O)
  ,.p_ddr_addr_12_o(DDR_ADDR12_O)
  ,.p_ddr_addr_13_o(DDR_ADDR13_O)
  ,.p_ddr_addr_14_o(DDR_ADDR14_O)
  ,.p_ddr_addr_15_o(DDR_ADDR15_O)

  // 32-bit ddr interface data mask
  ,.p_ddr_dm_0_o(DDR_DM0_O)
  ,.p_ddr_dm_1_o(DDR_DM1_O)
  ,.p_ddr_dm_2_o(DDR_DM2_O)
  ,.p_ddr_dm_3_o(DDR_DM3_O)

  // 32-bit ddr interface dq strobe signals
  ,.p_ddr_dqs_p_0_io(DDR_DQS0_P_IO)
  ,.p_ddr_dqs_n_0_io(DDR_DQS0_N_IO)
  ,.p_ddr_dqs_p_1_io(DDR_DQS1_P_IO)
  ,.p_ddr_dqs_n_1_io(DDR_DQS1_N_IO)
  ,.p_ddr_dqs_p_2_io(DDR_DQS2_P_IO)
  ,.p_ddr_dqs_n_2_io(DDR_DQS2_N_IO)
  ,.p_ddr_dqs_p_3_io(DDR_DQS3_P_IO)
  ,.p_ddr_dqs_n_3_io(DDR_DQS3_N_IO)

  // ddr interface data bus
  ,.p_ddr_dq_0_io (DDR_DQ0_IO)
  ,.p_ddr_dq_1_io (DDR_DQ1_IO)
  ,.p_ddr_dq_2_io (DDR_DQ2_IO)
  ,.p_ddr_dq_3_io (DDR_DQ3_IO)
  ,.p_ddr_dq_4_io (DDR_DQ4_IO)
  ,.p_ddr_dq_5_io (DDR_DQ5_IO)
  ,.p_ddr_dq_6_io (DDR_DQ6_IO)
  ,.p_ddr_dq_7_io (DDR_DQ7_IO)
  ,.p_ddr_dq_8_io (DDR_DQ8_IO)
  ,.p_ddr_dq_9_io (DDR_DQ9_IO)
  ,.p_ddr_dq_10_io(DDR_DQ10_IO)
  ,.p_ddr_dq_11_io(DDR_DQ11_IO)
  ,.p_ddr_dq_12_io(DDR_DQ12_IO)
  ,.p_ddr_dq_13_io(DDR_DQ13_IO)
  ,.p_ddr_dq_14_io(DDR_DQ14_IO)
  ,.p_ddr_dq_15_io(DDR_DQ15_IO)
  ,.p_ddr_dq_16_io(DDR_DQ16_IO)
  ,.p_ddr_dq_17_io(DDR_DQ17_IO)
  ,.p_ddr_dq_18_io(DDR_DQ18_IO)
  ,.p_ddr_dq_19_io(DDR_DQ19_IO)
  ,.p_ddr_dq_20_io(DDR_DQ20_IO)
  ,.p_ddr_dq_21_io(DDR_DQ21_IO)
  ,.p_ddr_dq_22_io(DDR_DQ22_IO)
  ,.p_ddr_dq_23_io(DDR_DQ23_IO)
  ,.p_ddr_dq_24_io(DDR_DQ24_IO)
  ,.p_ddr_dq_25_io(DDR_DQ25_IO)
  ,.p_ddr_dq_26_io(DDR_DQ26_IO)
  ,.p_ddr_dq_27_io(DDR_DQ27_IO)
  ,.p_ddr_dq_28_io(DDR_DQ28_IO)
  ,.p_ddr_dq_29_io(DDR_DQ29_IO)
  ,.p_ddr_dq_30_io(DDR_DQ30_IO)
  ,.p_ddr_dq_31_io(DDR_DQ31_IO)

  // bsg tag interface, 5 pins
  ,.p_bsg_tag_clk_i  (GW_TAG_CLKO)
  ,.p_bsg_tag_en_i   (GW_IC1_TAG_EN)
  ,.p_bsg_tag_data_i (GW_TAG_DATAO)
  ,.p_bsg_tag_clk_o  ()
  ,.p_bsg_tag_data_o ()

  // clock and reset interface, 9 pins
  // clock input signals
  ,.p_clk_A_i(GW_CLKA)
  ,.p_clk_B_i(GW_CLKB)
  ,.p_clk_C_i(GW_CLKC)

  // clock output signal
  ,.p_clk_o  ()

  // 3-bit clock selection signals
  ,.p_sel_0_i(GW_SEL0)
  ,.p_sel_1_i(GW_SEL1)
  ,.p_sel_2_i(GW_SEL2)

  // asynchronous reset signals
  ,.p_clk_async_reset_i  (GW_CLK_RESET)
  ,.p_core_async_reset_i (GW_CORE_RESET)

  // miscellaneous signal, 1 pin
  ,.p_misc_o ()
  );
*/

  // Control clock generator output signal
  //assign GW_SEL0 = 1'b0;
  //assign GW_SEL1 = 1'b0;
  //assign GW_SEL2 = 1'b0;
  
  //assign GW_CLK_RESET  = 1'b0;
  //assign GW_CORE_RESET = 1'b0;
  
  // Enable ASIC power output
  //assign TPS0_CNTL = 1'b1;


  `declare_bsg_ready_and_link_sif_s(ct_width_gp, bsg_ready_and_link_sif_s);
  
  
  //////////////////////////////////////////////////
  //
  // Clock Generator(s)
  //

  logic blackparrot_clk;
  assign GW_CLKA = blackparrot_clk;
  assign blackparrot_clk = mig_clk;

  logic io_master_clk, io_master_clk90;
  assign GW_CLKB = io_master_clk;
  //assign io_master_clk = mig_clk;

  logic router_clk;
  assign GW_CLKC = router_clk;
  //assign router_clk = mig_clk;

  logic tag_clk;
  //logic [1:0] tag_clk_count;
  //assign tag_clk = tag_clk_count[1];
  assign GW_TAG_CLKO = ~tag_clk;
  //always_ff @(posedge mig_clk)
  //  tag_clk_count <= tag_clk_count+1'b1;

  design_2 design_2_i
 (.clk125_clk_n(clk125_clk_n)
 ,.clk125_clk_p(clk125_clk_p)
 ,.util_clk    (tag_clk)
 ,.io_clk      (io_master_clk)
 ,.io_clk90    (io_master_clk90)
 ,.router_clk  (router_clk)
 );
 
  // SMA clock output
  assign FPGA_SMA0 = io_master_clk;

  //////////////////////////////////////////////////
  //
  // Reset Generator(s)
  //

  logic tag_reset;
  bsg_launch_sync_sync 
 #(.width_p(1)
  ) blss_tag
  (.iclk_i      (mig_clk)
  ,.iclk_reset_i(1'b0)
  ,.oclk_i      (tag_clk)
  ,.iclk_data_i  (mig_reset)
  ,.iclk_data_o  ()
  ,.oclk_data_o  (tag_reset)
  );

  //////////////////////////////////////////////////
  //
  // BSG Util Link
  //
  
  `declare_bsg_ready_and_link_sif_s(util_flit_width_p, bsg_util_link_sif_s);
  bsg_util_link_sif_s tag_trace_link_li, tag_trace_link_lo;
  
  logic [31:0] gpio_lo;
  
  bsg_util_link
 #(.util_flit_width_p(util_flit_width_p)
  ,.util_len_width_p (util_len_width_p )
  ,.util_cord_width_p(util_cord_width_p)
  ,.use_legacy_router(1)
  ) util_link
  (.clk_i            (tag_clk)
  ,.reset_i          (tag_reset)

  ,.tag_trace_link_i (tag_trace_link_li)
  ,.tag_trace_link_o (tag_trace_link_lo)

  ,.rs232_uart_rxd   (rs232_uart_rxd)
  ,.rs232_uart_txd   (rs232_uart_txd)

  ,.iic_main_scl_io  (iic_main_scl_io)
  ,.iic_main_sda_io  (iic_main_sda_io)

  ,.gpio_o           (gpio_lo)
  );
  
  assign TPS0_CNTL         = gpio_lo[0];
  assign DIG_POT_PLL_ADDR1 = gpio_lo[1];
  assign DIG_POT_PLL_ADDR0 = gpio_lo[2];
  assign DIG_POT_PLL_INDEP = gpio_lo[3];
  assign DIG_POT_PLL_NRST  = gpio_lo[4];
  assign DIG_POT_IO_ADDR1  = gpio_lo[5];
  assign DIG_POT_IO_ADDR0  = gpio_lo[6];
  assign DIG_POT_IO_INDEP  = gpio_lo[7];
  assign DIG_POT_IO_NRST   = gpio_lo[8];

  assign GW_CLK_RESET      = gpio_lo[9];
  assign GW_CORE_RESET     = gpio_lo[10];
  assign GW_SEL0           = gpio_lo[11];
  assign GW_SEL1           = gpio_lo[12];
  assign GW_SEL2           = gpio_lo[13];

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 26;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic [1:0] tag_trace_en_r_lo;
  logic       tag_trace_done_lo;

  logic tag_trace_done_blackparrot_lo;
  bsg_launch_sync_sync 
 #(.width_p(1)
  ) blss_trace_done
  (.iclk_i      (tag_clk)
  ,.iclk_reset_i(1'b0)
  ,.oclk_i      (blackparrot_clk)
  ,.iclk_data_i  (tag_trace_done_lo)
  ,.iclk_data_o  ()
  ,.oclk_data_o  (tag_trace_done_blackparrot_lo)
  );

  // TAG TRACE ROM
  bsg_tag_boot_rom #(.width_p( tag_trace_rom_data_width_lp )
                    ,.addr_width_p( tag_trace_rom_addr_width_lp )
                    )
    tag_trace_rom
      (.addr_i( rom_addr_li )
      ,.data_o( rom_data_lo )
      );

  // TAG TRACE REPLAY
  bsg_tag_trace_replay_stream 
 #(.rom_addr_width_p( tag_trace_rom_addr_width_lp )
  ,.rom_data_width_p( tag_trace_rom_data_width_lp )
  ,.num_masters_p( 2 )
  ,.num_clients_p( tag_num_clients_gp )
  ,.max_payload_width_p( tag_max_payload_width_gp )
  ,.link_width_p(util_flit_width_p)
  ,.cord_width_p(util_cord_width_p)
  ,.len_width_p (util_len_width_p)
  ) tag_trace_replay
      (.clk_i   ( tag_clk )
      ,.reset_i ( tag_reset    )
      ,.en_i    ( 1'b1            )

      ,.rom_addr_o( rom_addr_li )
      ,.rom_data_i( rom_data_lo )

      ,.en_r_o     ( tag_trace_en_r_lo )
      ,.tag_data_o ( GW_TAG_DATAO )

      ,.link_i ( tag_trace_link_lo )
      ,.link_o ( tag_trace_link_li )

      ,.done_o  ( tag_trace_done_lo )
      ) ;

  assign GW_IC1_TAG_EN = tag_trace_en_r_lo[0];

  design_3 design_3_i
  (.clk(tag_clk)
  ,.data(GW_TAG_DATAO)
  ,.en({1'b0, tag_trace_en_r_lo})
  );

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance (Copied from ASIC)
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // // Tag lines for clock generators
  // bsg_tag_s       async_reset_tag_lines_lo;
  // bsg_tag_s [2:0] osc_tag_lines_lo;
  // bsg_tag_s [2:0] osc_trigger_tag_lines_lo;
  // bsg_tag_s [2:0] ds_tag_lines_lo;
  // bsg_tag_s [2:0] sel_tag_lines_lo;
  
  bsg_tag_s [bp_num_router_gp-1:0] router_core_tag_lines_lo;

  // assign async_reset_tag_lines_lo = tag_lines_lo[0];
  // assign osc_tag_lines_lo         = tag_lines_lo[3:1];
  // assign osc_trigger_tag_lines_lo = tag_lines_lo[6:4];
  // assign ds_tag_lines_lo          = tag_lines_lo[9:7];
  // assign sel_tag_lines_lo         = tag_lines_lo[12:10];

  // Tag lines for io complex
  wire bsg_tag_s prev_link_io_tag_lines_lo   = tag_lines_lo[13];
  wire bsg_tag_s prev_link_core_tag_lines_lo = tag_lines_lo[14];
  wire bsg_tag_s prev_ct_core_tag_lines_lo   = tag_lines_lo[15];
  wire bsg_tag_s next_link_io_tag_lines_lo   = tag_lines_lo[16];
  wire bsg_tag_s next_link_core_tag_lines_lo = tag_lines_lo[17];
  wire bsg_tag_s next_ct_core_tag_lines_lo   = tag_lines_lo[18];
  assign router_core_tag_lines_lo            = tag_lines_lo[19+:bp_num_router_gp];
  wire bsg_tag_s cfg_tag_line_lo             = tag_lines_lo[tag_num_clients_gp-2];
  wire bsg_tag_s bp_core_tag_line_lo         = tag_lines_lo[tag_num_clients_gp-1];

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( tag_clk )
      ,.data_i     ( tag_trace_en_r_lo[1] ? GW_TAG_DATAO : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance (Copied from ASIC)
  //

  // Tag payload for blackparrot control signals
  typedef struct packed { 
      logic reset;
      logic [wh_cord_width_gp-1:0] cord;
  } bp_tag_payload_s;

  // Tag payload for blackparrot control signals
  bp_tag_payload_s bp_tag_data_lo;
  logic            bp_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_blackparrot
      (.bsg_tag_i     ( bp_core_tag_line_lo )
      ,.recv_clk_i    ( blackparrot_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( bp_tag_new_data_lo )
      ,.recv_data_r_o ( bp_tag_data_lo )
      );

  // Tag payload for blackparrot config loader control signals
  bp_tag_payload_s cfg_tag_data_lo;
  logic            cfg_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_cfg
      (.bsg_tag_i     ( cfg_tag_line_lo )
      ,.recv_clk_i    ( blackparrot_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( cfg_tag_new_data_lo )
      ,.recv_data_r_o ( cfg_tag_data_lo )
      );

  //////////////////////////////////////////////////
  //
  // Commlink Swizzle
  //

  logic       ci_clk_li;
  logic       ci_v_li;
  logic [8:0] ci_data_li;
  logic       ci_tkn_lo;

  logic       co_clk_lo;
  logic       co_v_lo;
  logic [8:0] co_data_lo;
  logic       co_tkn_li;

  logic       ci2_clk_li;
  logic       ci2_v_li;
  logic [8:0] ci2_data_li;
  logic       ci2_tkn_lo;

  logic       co2_clk_lo;
  logic       co2_v_lo;
  logic [8:0] co2_data_lo;
  logic       co2_tkn_li;

  bsg_chip_swizzle_adapter
    swizzle
      (.port_ci_clk_i   ()
      ,.port_ci_v_i     ()
      ,.port_ci_data_i  ()
      ,.port_ci_tkn_o   ()

      ,.port_ci2_clk_o  ()
      ,.port_ci2_v_o    ()
      ,.port_ci2_data_o ()
      ,.port_ci2_tkn_i  ()

      ,.port_co_clk_i   (IC1_GW_CL_CLK)
      ,.port_co_v_i     (IC1_GW_CL_V)
      ,.port_co_data_i  ({IC1_GW_CL_D8, IC1_GW_CL_D7, IC1_GW_CL_D6, IC1_GW_CL_D5, IC1_GW_CL_D4, IC1_GW_CL_D3, IC1_GW_CL_D2, IC1_GW_CL_D1, IC1_GW_CL_D0})
      ,.port_co_tkn_o   (IC1_GW_CL_TKN)

      ,.port_co2_clk_o  (GW_IC1_CL_CLK)
      ,.port_co2_v_o    (GW_IC1_CL_D4)
      ,.port_co2_data_o ({GW_IC1_CL_D0, GW_IC1_CL_D1, GW_IC1_CL_D2, GW_IC1_CL_D3, GW_IC1_CL_D5, GW_IC1_CL_D6, GW_IC1_CL_V, GW_IC1_CL_D7, GW_IC1_CL_D8})
      ,.port_co2_tkn_i  (GW_IC1_CL_TKN)

      ,.guts_ci_clk_o  (ci_clk_li)
      ,.guts_ci_v_o    (ci_v_li)
      ,.guts_ci_data_o (ci_data_li)
      ,.guts_ci_tkn_i  (ci_tkn_lo)

      ,.guts_co_clk_i  (co_clk_lo)
      ,.guts_co_v_i    (co_v_lo)
      ,.guts_co_data_i (co_data_lo)
      ,.guts_co_tkn_o  (co_tkn_li)

      ,.guts_ci2_clk_o (ci2_clk_li)
      ,.guts_ci2_v_o   (ci2_v_li)
      ,.guts_ci2_data_o(ci2_data_li)
      ,.guts_ci2_tkn_i (ci2_tkn_lo)

      ,.guts_co2_clk_i (co2_clk_lo)
      ,.guts_co2_v_i   (co2_v_lo)
      ,.guts_co2_data_i(co2_data_lo)
      ,.guts_co2_tkn_o (co2_tkn_li)
      );
      
  //////////////////////////////////////////////////
  //
  // BSG Chip IO Complex
  //

  logic                        router_reset_lo;
  logic [wh_cord_width_gp-1:0] router_cord_lo;

  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_li;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_lo;

  bsg_chip_io_complex #(.num_router_groups_p( 1 )

                       ,.link_width_p( link_width_gp )
                       ,.link_channel_width_p( link_channel_width_gp )
                       ,.link_num_channels_p( link_num_channels_gp )
                       ,.link_lg_fifo_depth_p( link_lg_fifo_depth_gp )
                       ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )

                       ,.ct_width_p( ct_width_gp )
                       ,.ct_num_in_p( ct_num_in_gp )
                       ,.ct_remote_credits_p( ct_remote_credits_gp )
                       ,.ct_use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_gp )
                       ,.ct_lg_credit_decimation_p( ct_lg_credit_decimation_gp )

                       ,.wh_cord_markers_pos_p({wh_cord_markers_pos_b_gp, wh_cord_markers_pos_a_gp})
                       ,.wh_len_width_p( wh_len_width_gp )
                       )
    io_complex
      (.core_clk_i ( router_clk )
      ,.io_clk_i   ( io_master_clk )

      ,.prev_link_io_tag_lines_i( prev_link_io_tag_lines_lo )
      ,.prev_link_core_tag_lines_i( prev_link_core_tag_lines_lo )
      ,.prev_ct_core_tag_lines_i( prev_ct_core_tag_lines_lo )
      
      ,.next_link_io_tag_lines_i( next_link_io_tag_lines_lo )
      ,.next_link_core_tag_lines_i( next_link_core_tag_lines_lo )
      ,.next_ct_core_tag_lines_i( next_ct_core_tag_lines_lo )

      ,.rtr_core_tag_lines_i( router_core_tag_lines_lo[0] )
      
      ,.ci_clk_i  ( ci_clk_li )
      ,.ci_v_i    ( ci_v_li )
      ,.ci_data_i ( ci_data_li[link_channel_width_gp-1:0] )
      ,.ci_tkn_o  ( ci_tkn_lo )

      ,.co_clk_o  ( co_clk_lo )
      ,.co_v_o    ( co_v_lo )
      ,.co_data_o ( co_data_lo[link_channel_width_gp-1:0] )
      ,.co_tkn_i  ( co_tkn_li )

      ,.ci2_clk_i  ( ci2_clk_li )
      ,.ci2_v_i    ( ci2_v_li )
      ,.ci2_data_i ( ci2_data_li[link_channel_width_gp-1:0] )
      ,.ci2_tkn_o  ( ci2_tkn_lo )

      ,.co2_clk_o  ( co2_clk_lo )
      ,.co2_v_o    ( co2_v_lo )
      ,.co2_data_o ( co2_data_lo[link_channel_width_gp-1:0] )
      ,.co2_tkn_i  ( co2_tkn_li )
      
      ,.rtr_links_i ( rtr_links_li )
      ,.rtr_links_o ( rtr_links_lo )

      ,.rtr_reset_o ( router_reset_lo )
      ,.rtr_cord_o  ( router_cord_lo  )
      );

  //////////////////////////////////////////////////
  //
  // BP Config Loader
  //
  bsg_ready_and_link_sif_s gw_master_link_li, gw_master_link_lo;
  bsg_ready_and_link_sif_s gw_client_link_li, gw_client_link_lo;

  // Hardcoded based on bp_cfg = quad
  `declare_bp_me_if(39, 512, 8, 8, 112);
  bp_cce_mem_data_cmd_s cfg_data_cmd_lo;
  logic                 cfg_data_cmd_v_lo, cfg_data_cmd_yumi_li;
  bp_mem_cce_resp_s     cfg_resp_li;
  logic                 cfg_resp_v_li, cfg_resp_ready_lo;


  bp_me_cce_to_wormhole_link_master
   #(.cfg_p(bp_cfg_gp)
     ,.x_cord_width_p(wh_cord_width_gp-1)
     ,.y_cord_width_p(1)
     )
   master_link
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_blackparrot_lo )


     ,.mem_cmd_i('0)
     ,.mem_cmd_v_i('0)
     ,.mem_cmd_yumi_o()

     ,.mem_data_cmd_i(cfg_data_cmd_lo)
     ,.mem_data_cmd_v_i(cfg_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_o(cfg_data_cmd_yumi_li)

     ,.mem_resp_o(cfg_resp_li)
     ,.mem_resp_v_o(cfg_resp_v_li)
     ,.mem_resp_ready_i(cfg_resp_ready_lo)

     ,.mem_data_resp_o()
     ,.mem_data_resp_v_o()
     ,.mem_data_resp_ready_i('0)

     ,.my_x_i(bp_tag_data_lo.cord[0+:7])
     ,.my_y_i('0)

     ,.mem_cmd_dest_x_i('0)
     ,.mem_cmd_dest_y_i('0)

     ,.mem_data_cmd_dest_x_i(cfg_tag_data_lo.cord[0+:7])
     ,.mem_data_cmd_dest_y_i('0)

     ,.link_i(gw_master_link_li)
     ,.link_o(gw_master_link_lo)
     );

  bp_cce_mem_cmd_s           host_cmd_li;
  logic                      host_cmd_v_li, host_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s      host_data_cmd_li;
  logic                      host_data_cmd_v_li, host_data_cmd_yumi_lo;
  bp_mem_cce_resp_s          host_resp_lo;
  logic                      host_resp_v_lo, host_resp_ready_li;
  bp_mem_cce_data_resp_s     host_data_resp_lo;
  logic                      host_data_resp_v_lo, host_data_resp_ready_li;
  logic [bp_num_core_gp-1:0] program_finish_lo;
  
/*
  bp_nonsynth_host
   #(.cfg_p(bp_cfg_gp))
   host_mmio
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_blackparrot_lo)
     
     ,.mem_data_cmd_i(host_data_cmd_li)
     ,.mem_data_cmd_v_i(host_data_cmd_v_li)
     ,.mem_data_cmd_yumi_o(host_data_cmd_yumi_lo)

     ,.mem_resp_o(host_resp_lo)
     ,.mem_resp_v_o(host_resp_v_lo)
     ,.mem_resp_ready_i(host_resp_ready_li)

     ,.program_finish_o(program_finish_lo)
     );
*/
  assign host_cmd_yumi_lo    = '0;
  assign host_data_resp_v_lo = '0;
  assign host_data_resp_lo   = '0;


  bp_cce_mem_cmd_s       dram_cmd_li;
  logic                  dram_cmd_v_li, dram_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s  dram_data_cmd_li;
  logic                  dram_data_cmd_v_li, dram_data_cmd_yumi_lo;
  bp_mem_cce_resp_s      dram_resp_lo;
  logic                  dram_resp_v_lo, dram_resp_ready_li;
  bp_mem_cce_data_resp_s dram_data_resp_lo;
  logic                  dram_data_resp_v_lo, dram_data_resp_ready_li;
  
  bp_cce_mem_cmd_s       a_dram_cmd_li;
  logic                  a_dram_cmd_v_li, a_dram_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s  a_dram_data_cmd_li;
  logic                  a_dram_data_cmd_v_li, a_dram_data_cmd_yumi_lo;
  bp_mem_cce_resp_s      a_dram_resp_lo;
  logic                  a_dram_resp_v_lo, a_dram_resp_ready_li;
  bp_mem_cce_data_resp_s a_dram_data_resp_lo;
  logic                  a_dram_data_resp_v_lo, a_dram_data_resp_ready_li;

  bp_cce_mem_cmd_s       b_dram_cmd_li;
  logic                  b_dram_cmd_v_li, b_dram_cmd_yumi_lo;
  bp_cce_mem_data_cmd_s  b_dram_data_cmd_li;
  logic                  b_dram_data_cmd_v_li, b_dram_data_cmd_yumi_lo;
  bp_mem_cce_resp_s      b_dram_resp_lo;
  logic                  b_dram_resp_v_lo, b_dram_resp_ready_li;
  bp_mem_cce_data_resp_s b_dram_data_resp_lo;
  logic                  b_dram_data_resp_v_lo, b_dram_data_resp_ready_li;
  
  bp_cce_mem_data_cmd_s  nbf_dram_data_cmd_li;
  logic                  nbf_dram_data_cmd_v_li, nbf_dram_data_cmd_yumi_lo;
  bp_mem_cce_resp_s      nbf_dram_resp_lo;
  logic                  nbf_dram_resp_v_lo, nbf_dram_resp_ready_li;
  
/*
  bp_mem_dramsim2
   #(.mem_id_p(0)
     ,.clock_period_in_ps_p(`BLACKPARROT_CLK_PERIOD)
     ,.prog_name_p("prog.mem")
     ,.dram_cfg_p("dram_ch.ini")
     ,.dram_sys_cfg_p("dram_sys.ini")
     ,.dram_capacity_p(16384)
     ,.num_lce_p(8)
     ,.num_cce_p(4)
     ,.paddr_width_p(39)
     ,.lce_assoc_p(8)
     ,.block_size_in_bytes_p(512/8)
     ,.lce_sets_p(64)
     ,.lce_req_data_width_p(64)
     )
   mem
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_blackparrot_lo)

     ,.mem_cmd_i(dram_cmd_li)
     ,.mem_cmd_v_i(dram_cmd_v_li)
     ,.mem_cmd_yumi_o(dram_cmd_yumi_lo)

     ,.mem_data_cmd_i(dram_data_cmd_li)
     ,.mem_data_cmd_v_i(dram_data_cmd_v_li)
     ,.mem_data_cmd_yumi_o(dram_data_cmd_yumi_lo)

     ,.mem_resp_o(dram_resp_lo)
     ,.mem_resp_v_o(dram_resp_v_lo)
     ,.mem_resp_ready_i(dram_resp_ready_li)

     ,.mem_data_resp_o(dram_data_resp_lo)
     ,.mem_data_resp_v_o(dram_data_resp_v_lo)
     ,.mem_data_resp_ready_i(dram_data_resp_ready_li)
     );
*/
  bp_cce_mem_cmd_s       mem_cmd_lo;
  logic                  mem_cmd_v_lo, mem_cmd_yumi_li;
  bp_cce_mem_data_cmd_s  mem_data_cmd_lo;
  logic                  mem_data_cmd_v_lo, mem_data_cmd_yumi_li;
  bp_mem_cce_resp_s      mem_resp_li;
  logic                  mem_resp_v_li, mem_resp_ready_lo;
  bp_mem_cce_data_resp_s mem_data_resp_li;
  logic                  mem_data_resp_v_li, mem_data_resp_ready_lo;
  bp_me_cce_to_wormhole_link_client
   #(.cfg_p(bp_cfg_gp)
     ,.x_cord_width_p(wh_cord_width_gp-1)
     ,.y_cord_width_p(1)
     )
   client_link
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_blackparrot_lo)

     ,.mem_cmd_o(mem_cmd_lo)
     ,.mem_cmd_v_o(mem_cmd_v_lo)
     ,.mem_cmd_yumi_i(mem_cmd_yumi_li)

     ,.mem_data_cmd_o(mem_data_cmd_lo)
     ,.mem_data_cmd_v_o(mem_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_i(mem_data_cmd_yumi_li)

     ,.mem_resp_i(mem_resp_li)
     ,.mem_resp_v_i(mem_resp_v_li)
     ,.mem_resp_ready_o(mem_resp_ready_lo)

     ,.mem_data_resp_i(mem_data_resp_li)
     ,.mem_data_resp_v_i(mem_data_resp_v_li)
     ,.mem_data_resp_ready_o(mem_data_resp_ready_lo)

     ,.my_x_i(bp_tag_data_lo.cord[0+:7])
     ,.my_y_i('0)

     ,.link_i(gw_client_link_li)
     ,.link_o(gw_client_link_lo)
     );

  logic req_outstanding_r;
  bsg_dff_reset_en
   #(.width_p(1))
   req_outstanding_reg
    (.clk_i(blackparrot_clk)
     ,.reset_i(bp_tag_data_lo.reset | ~tag_trace_done_blackparrot_lo)
     ,.en_i(mem_cmd_yumi_li | mem_data_cmd_yumi_li | (mem_resp_v_li & mem_resp_ready_lo) | (mem_data_resp_v_li & mem_data_resp_ready_lo))
  
     ,.data_i(mem_cmd_yumi_li | mem_data_cmd_yumi_li)
     ,.data_o(req_outstanding_r)
     );
  
  wire host_data_cmd_not_dram = mem_data_cmd_v_lo & (mem_data_cmd_lo.addr < dram_base_addr_gp);
  wire host_cmd_not_dram      = mem_cmd_v_lo & (mem_cmd_lo.addr < dram_base_addr_gp);
  
  assign host_cmd_li          = mem_cmd_lo;
  assign host_cmd_v_li        = mem_cmd_v_lo & host_cmd_not_dram & ~req_outstanding_r;
  assign b_dram_cmd_li          = mem_cmd_lo;
  assign b_dram_cmd_v_li        = mem_cmd_v_lo & ~host_cmd_not_dram & ~req_outstanding_r;
  assign mem_cmd_yumi_li      = host_cmd_not_dram 
                                ? host_cmd_yumi_lo 
                                : b_dram_cmd_yumi_lo;
  
  assign host_data_cmd_li     = mem_data_cmd_lo;
  assign host_data_cmd_v_li   = mem_data_cmd_v_lo & host_data_cmd_not_dram & ~req_outstanding_r;
  assign b_dram_data_cmd_li     = mem_data_cmd_lo;
  assign b_dram_data_cmd_v_li   = mem_data_cmd_v_lo & ~host_data_cmd_not_dram & ~req_outstanding_r;
  assign mem_data_cmd_yumi_li = host_data_cmd_not_dram 
                                ? host_data_cmd_yumi_lo 
                                : b_dram_data_cmd_yumi_lo;
  
  assign mem_resp_li = host_resp_v_lo ? host_resp_lo : b_dram_resp_lo;
  assign mem_resp_v_li = host_resp_v_lo | b_dram_resp_v_lo;
  assign host_resp_ready_li = mem_resp_ready_lo;
  assign b_dram_resp_ready_li = mem_resp_ready_lo;
  
  assign mem_data_resp_li = host_data_resp_v_lo ? host_data_resp_lo : b_dram_data_resp_lo;
  assign mem_data_resp_v_li = host_data_resp_v_lo | b_dram_data_resp_v_lo;
  assign host_data_resp_ready_li = mem_data_resp_ready_lo;
  assign b_dram_data_resp_ready_li = mem_data_resp_ready_lo;

  //////////////////////////////////////////////////
  //
  // Async crossings
  //
  bsg_ready_and_link_sif_s io_cmd_link_li, io_cmd_link_lo;
  bsg_ready_and_link_sif_s io_resp_link_li, io_resp_link_lo;
  
  logic gw_master_link_full_lo;
  assign gw_master_link_li.ready_and_rev = ~gw_master_link_full_lo;
  wire gw_master_link_enq_li = gw_master_link_lo.v & gw_master_link_li.ready_and_rev;
  wire io_cmd_link_deq_li = io_cmd_link_li.v & io_cmd_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   gw_cmd_link_async_fifo
    (.w_clk_i(blackparrot_clk)
     ,.w_reset_i(bp_tag_data_lo.reset)
     ,.w_enq_i(gw_master_link_enq_li)
     ,.w_data_i(gw_master_link_lo.data)
     ,.w_full_o(gw_master_link_full_lo)

     ,.r_clk_i(router_clk)
     ,.r_reset_i(router_reset_lo)
     ,.r_deq_i(io_cmd_link_deq_li)
     ,.r_data_o(io_cmd_link_li.data)
     ,.r_valid_o(io_cmd_link_li.v)
     );

  logic gw_client_link_full_lo;
  assign gw_client_link_li.ready_and_rev = ~gw_client_link_full_lo;
  wire gw_client_link_enq_li = gw_client_link_lo.v & gw_client_link_li.ready_and_rev;
  wire io_resp_link_deq_li = io_resp_link_li.v & io_resp_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   gw_resp_async_fifo
    (.w_clk_i(blackparrot_clk)
     ,.w_reset_i(bp_tag_data_lo.reset)
     ,.w_enq_i(gw_client_link_enq_li)
     ,.w_data_i(gw_client_link_lo.data)
     ,.w_full_o(gw_client_link_full_lo)

     ,.r_clk_i(router_clk)
     ,.r_reset_i(router_reset_lo)
     ,.r_deq_i(io_resp_link_deq_li)
     ,.r_data_o(io_resp_link_li.data)
     ,.r_valid_o(io_resp_link_li.v)
     );

  logic io_cmd_link_full_lo;
  assign io_cmd_link_li.ready_and_rev = ~io_cmd_link_full_lo;
  wire io_cmd_link_enq_li = io_cmd_link_lo.v & io_cmd_link_li.ready_and_rev;
  wire gw_client_link_deq_li = gw_client_link_li.v & gw_client_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   io_cmd_link_async_fifo
    (.w_clk_i(router_clk)
     ,.w_reset_i(router_reset_lo)
     ,.w_enq_i(io_cmd_link_enq_li)
     ,.w_data_i(io_cmd_link_lo.data)
     ,.w_full_o(io_cmd_link_full_lo)

     ,.r_clk_i(blackparrot_clk)
     ,.r_reset_i(bp_tag_data_lo.reset)
     ,.r_deq_i(gw_client_link_deq_li)
     ,.r_data_o(gw_client_link_li.data)
     ,.r_valid_o(gw_client_link_li.v)
     );

  logic io_resp_link_full_lo;
  assign io_resp_link_li.ready_and_rev = ~io_resp_link_full_lo;
  wire io_resp_link_enq_li = io_resp_link_lo.v & io_resp_link_li.ready_and_rev;
  wire gw_master_link_deq_li = gw_master_link_li.v & gw_master_link_lo.ready_and_rev;
  bsg_async_fifo
   #(.lg_size_p(3)
     ,.width_p(ct_width_gp)
     )
   io_resp_link_async_fifo
    (.w_clk_i(router_clk)
     ,.w_reset_i(router_reset_lo)
     ,.w_enq_i(io_resp_link_enq_li)
     ,.w_data_i(io_resp_link_lo.data)
     ,.w_full_o(io_resp_link_full_lo)

     ,.r_clk_i(blackparrot_clk)
     ,.r_reset_i(bp_tag_data_lo.reset)
     ,.r_deq_i(gw_master_link_deq_li)
     ,.r_data_o(gw_master_link_li.data)
     ,.r_valid_o(gw_master_link_li.v)
     );

  assign rtr_links_li[0] = io_cmd_link_li;
  assign rtr_links_li[1] = io_resp_link_li;
  assign io_cmd_link_lo  = rtr_links_lo[0];
  assign io_resp_link_lo = rtr_links_lo[1];




logic nbf_done_lo, cfg_done_lo, dram_sel_lo;
    
    logic [7:0] counter_r, counter_n;
    logic nbf_done_r;
    always_ff @(posedge blackparrot_clk)
      begin
        if (~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset)
          begin
            counter_r <= 1;
            nbf_done_r <= 0;
          end
        else if (nbf_done_lo)
          begin
            if (counter_r == 0)
              begin
                nbf_done_r <= 1;
              end
            else
              begin
                counter_r <= counter_r + 1;
              end
          end
      end
    assign dram_sel_lo = nbf_done_r;
       
    bp_nbf_to_cce_mem
   #(.cfg_p(bp_cfg_gp)
    ) nbf_adapter
    (.clk_i(blackparrot_clk)
    ,.reset_i((~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset))

    ,.io_data_cmd_i(nbf_dram_data_cmd_li)
    ,.io_data_cmd_v_i(nbf_dram_data_cmd_v_li)
    ,.io_data_cmd_yumi_o(nbf_dram_data_cmd_yumi_lo)

    ,.io_resp_o(nbf_dram_resp_lo)
    ,.io_resp_v_o(nbf_dram_resp_v_lo)
    ,.io_resp_ready_i(nbf_dram_resp_ready_li)

    ,.mem_data_cmd_o(a_dram_data_cmd_li)
    ,.mem_data_cmd_v_o(a_dram_data_cmd_v_li)
    ,.mem_data_cmd_yumi_i(a_dram_data_cmd_yumi_lo)

    ,.mem_resp_i(a_dram_resp_lo)
    ,.mem_resp_v_i(a_dram_resp_v_lo)
    ,.mem_resp_ready_o(a_dram_resp_ready_li)
    );
    
    assign a_dram_cmd_v_li = 1'b0;
    assign a_dram_cmd_li = '0;
    assign a_dram_data_resp_ready_li = 1'b0;
    
/*   
    design_2 design_2_i
    (.clk(blackparrot_clk)
    ,.data_cmd(nbf_dram_data_cmd_li)
    ,.data_cmd_v(nbf_dram_data_cmd_v_li)
    ,.data_cmd_yumi(nbf_dram_data_cmd_yumi_lo)
    ,.resp(nbf_dram_resp_lo)
    ,.resp_v(nbf_dram_resp_v_lo)
    ,.resp_ready(nbf_dram_resp_ready_li)
    );
*/    

always_comb
  begin
    if (dram_sel_lo)
      begin
        dram_cmd_li = b_dram_cmd_li;
        dram_cmd_v_li = b_dram_cmd_v_li;
        b_dram_cmd_yumi_lo = dram_cmd_yumi_lo;
        
        b_dram_resp_lo = dram_resp_lo;
        b_dram_resp_v_lo = dram_resp_v_lo;
        dram_resp_ready_li = b_dram_resp_ready_li;
        
        a_dram_cmd_yumi_lo = a_dram_cmd_v_li;
        a_dram_resp_lo = '0;
        a_dram_resp_v_lo = 1'b0;
        
        dram_data_cmd_li = b_dram_data_cmd_li;
        dram_data_cmd_v_li = b_dram_data_cmd_v_li;
        b_dram_data_cmd_yumi_lo = dram_data_cmd_yumi_lo;
        
        b_dram_data_resp_lo = dram_data_resp_lo;
        b_dram_data_resp_v_lo = dram_data_resp_v_lo;
        dram_data_resp_ready_li = b_dram_data_resp_ready_li;
        
        a_dram_data_cmd_yumi_lo = a_dram_data_cmd_v_li;
        a_dram_data_resp_lo = '0;
        a_dram_data_resp_v_lo = 1'b0;
      end
    else
      begin
        dram_cmd_li = a_dram_cmd_li;
        dram_cmd_v_li = a_dram_cmd_v_li;
        a_dram_cmd_yumi_lo = dram_cmd_yumi_lo;
        
        a_dram_resp_lo = dram_resp_lo;
        a_dram_resp_v_lo = dram_resp_v_lo;
        dram_resp_ready_li = a_dram_resp_ready_li;
        
        b_dram_cmd_yumi_lo = b_dram_cmd_v_li;
        b_dram_resp_lo = '0;
        b_dram_resp_v_lo = 1'b0;
        
        dram_data_cmd_li = a_dram_data_cmd_li;
        dram_data_cmd_v_li = a_dram_data_cmd_v_li;
        a_dram_data_cmd_yumi_lo = dram_data_cmd_yumi_lo;
        
        a_dram_data_resp_lo = dram_data_resp_lo;
        a_dram_data_resp_v_lo = dram_data_resp_v_lo;
        dram_data_resp_ready_li = a_dram_data_resp_ready_li;
        
        b_dram_data_cmd_yumi_lo = b_dram_data_cmd_v_li;
        b_dram_data_resp_lo = '0;
        b_dram_data_resp_v_lo = 1'b0;
      end
  end


  bp_cce_mmio_cfg_loader
   #(.cfg_p(bp_cfg_gp)
     ,.inst_width_p(`bp_cce_inst_width)
     ,.inst_ram_addr_width_p(`BSG_SAFE_CLOG2(256))
     ,.inst_ram_els_p(256)
     ,.cce_ucode_filename_p(cce_ucode_filename_lp)
     ,.skip_ram_init_p(0)
     )
   cfg_loader
    (.clk_i(blackparrot_clk)
     ,.reset_i((~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset) | ~dram_sel_lo)

     ,.mem_data_cmd_o(cfg_data_cmd_lo)
     ,.mem_data_cmd_v_o(cfg_data_cmd_v_lo)
     ,.mem_data_cmd_yumi_i(cfg_data_cmd_yumi_li)

     ,.mem_resp_i(cfg_resp_li)
     ,.mem_resp_v_i(cfg_resp_v_li)
     ,.mem_resp_ready_o(cfg_resp_ready_lo)
     );

  
  // pcie stream host (NBF and MMIO)
  assign led[3] = nbf_done_lo;
  
  bp_stream_host
 #(.cfg_p(bp_cfg_gp)
  ,.stream_addr_width_p(32)
  ,.stream_data_width_p(32)
  ) host        
  (.clk_i          (blackparrot_clk)
  ,.reset_i        ((~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset))
  ,.prog_done_o    (nbf_done_lo)
  
  ,.io_data_cmd_i       (host_data_cmd_li)
  ,.io_data_cmd_v_i     (host_data_cmd_v_li)
  ,.io_data_cmd_yumi_o  (host_data_cmd_yumi_lo)

  ,.io_resp_o      (host_resp_lo)
  ,.io_resp_v_o    (host_resp_v_lo)
  ,.io_resp_ready_i(host_resp_ready_li)

  ,.io_data_cmd_o       (nbf_dram_data_cmd_li)
  ,.io_data_cmd_v_o     (nbf_dram_data_cmd_v_li)
  ,.io_data_cmd_yumi_i  (nbf_dram_data_cmd_yumi_lo)

  ,.io_resp_i      (nbf_dram_resp_lo)
  ,.io_resp_v_i    (nbf_dram_resp_v_lo)
  ,.io_resp_ready_o(nbf_dram_resp_ready_li)

  ,.stream_v_i     (m_axi_lite_v_lo)
  ,.stream_addr_i  (m_axi_lite_addr_lo)
  ,.stream_data_i  (m_axi_lite_data_lo)
  ,.stream_yumi_o  (m_axi_lite_yumi_li)
                   
  ,.stream_v_o     (m_axi_lite_v_li)
  ,.stream_data_o  (m_axi_lite_data_li)
  ,.stream_ready_i (m_axi_lite_ready_lo)
  );
  
  // CCE to cache dma
  `declare_bsg_cache_dma_pkt_s(paddr_width_p);
  
  bsg_cache_dma_pkt_s dma_pkt_lo;
  logic dma_pkt_v_lo, dma_pkt_yumi_li;
  
  logic [dword_width_p-1:0] dma_data_li;
  logic dma_data_v_li, dma_data_ready_lo;
  
  logic [dword_width_p-1:0] dma_data_lo;
  logic dma_data_v_lo, dma_data_yumi_li;
  
  logic [cache_addr_width_p+1-1:0] cache_dma_pkt_lo;
    assign cache_dma_pkt_lo = {dma_pkt_lo.write_not_read, dma_pkt_lo[cache_addr_width_p-1:0]};

  bp_me_cce_to_cache_dma
 #(.cfg_p(bp_cfg_gp)
  ) mem_to_dma
  (.clk_i           (blackparrot_clk)
  ,.reset_i         ((~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset))
                    
  ,.dma_pkt_o       (dma_pkt_lo)
  ,.dma_pkt_v_o     (dma_pkt_v_lo)
  ,.dma_pkt_yumi_i  (dma_pkt_yumi_li)

  ,.dma_data_i      (dma_data_li)
  ,.dma_data_v_i    (dma_data_v_li)
  ,.dma_data_ready_o(dma_data_ready_lo)

  ,.dma_data_o      (dma_data_lo)
  ,.dma_data_v_o    (dma_data_v_lo)
  ,.dma_data_yumi_i (dma_data_yumi_li)

  ,.mem_cmd_i       (dram_cmd_li)
  ,.mem_cmd_v_i     (dram_cmd_v_li)
  ,.mem_cmd_yumi_o  (dram_cmd_yumi_lo)
  
  ,.mem_data_cmd_i       (dram_data_cmd_li)
  ,.mem_data_cmd_v_i     (dram_data_cmd_v_li)
  ,.mem_data_cmd_yumi_o  (dram_data_cmd_yumi_lo)

  ,.mem_resp_o      (dram_resp_lo)
  ,.mem_resp_v_o    (dram_resp_v_lo)
  ,.mem_resp_ready_i(dram_resp_ready_li)
  
  ,.mem_data_resp_o      (dram_data_resp_lo)
  ,.mem_data_resp_v_o    (dram_data_resp_v_lo)
  ,.mem_data_resp_ready_i(dram_data_resp_ready_li)
  );

  // s_axi port
  // not supported
  assign s_axi_arqos    = '0;
  assign s_axi_arregion = '0;
  assign s_axi_awqos    = '0;
  assign s_axi_awregion = '0;

  bsg_cache_to_axi 
 #(.addr_width_p         (cache_addr_width_p)
  ,.block_size_in_words_p(cce_block_width_p/dword_width_p)
  ,.data_width_p         (dword_width_p)
  ,.num_cache_p          (1)
  ,.tag_fifo_els_p       (1)

  ,.axi_id_width_p       (axi_id_width_p)
  ,.axi_addr_width_p     (axi_addr_width_p)
  ,.axi_data_width_p     (axi_data_width_p)
  ,.axi_burst_len_p      (axi_burst_len_p)
  ) cache_to_axi 
  (.clk_i  (blackparrot_clk)
  ,.reset_i((~tag_trace_done_blackparrot_lo | bp_tag_data_lo.reset))
  
  ,.dma_pkt_i       (cache_dma_pkt_lo)
  ,.dma_pkt_v_i     (dma_pkt_v_lo)
  ,.dma_pkt_yumi_o  (dma_pkt_yumi_li)
  
  ,.dma_data_o      (dma_data_li)
  ,.dma_data_v_o    (dma_data_v_li)
  ,.dma_data_ready_i(dma_data_ready_lo)
  
  ,.dma_data_i      (dma_data_lo)
  ,.dma_data_v_i    (dma_data_v_lo)
  ,.dma_data_yumi_o (dma_data_yumi_li)

  ,.axi_awid_o      (s_axi_awid)
  ,.axi_awaddr_o    (s_axi_awaddr)
  ,.axi_awlen_o     (s_axi_awlen)
  ,.axi_awsize_o    (s_axi_awsize)
  ,.axi_awburst_o   (s_axi_awburst)
  ,.axi_awcache_o   (s_axi_awcache)
  ,.axi_awprot_o    (s_axi_awprot)
  ,.axi_awlock_o    (s_axi_awlock)
  ,.axi_awvalid_o   (s_axi_awvalid)
  ,.axi_awready_i   (s_axi_awready)
                    
  ,.axi_wdata_o     (s_axi_wdata)
  ,.axi_wstrb_o     (s_axi_wstrb)
  ,.axi_wlast_o     (s_axi_wlast)
  ,.axi_wvalid_o    (s_axi_wvalid)
  ,.axi_wready_i    (s_axi_wready)
                    
  ,.axi_bid_i       (s_axi_bid)
  ,.axi_bresp_i     (s_axi_bresp)
  ,.axi_bvalid_i    (s_axi_bvalid)
  ,.axi_bready_o    (s_axi_bready)
                    
  ,.axi_arid_o      (s_axi_arid)
  ,.axi_araddr_o    (s_axi_araddr)
  ,.axi_arlen_o     (s_axi_arlen)
  ,.axi_arsize_o    (s_axi_arsize)
  ,.axi_arburst_o   (s_axi_arburst)
  ,.axi_arcache_o   (s_axi_arcache)
  ,.axi_arprot_o    (s_axi_arprot)
  ,.axi_arlock_o    (s_axi_arlock)
  ,.axi_arvalid_o   (s_axi_arvalid)
  ,.axi_arready_i   (s_axi_arready)
                    
  ,.axi_rid_i       (s_axi_rid)
  ,.axi_rdata_i     (s_axi_rdata)
  ,.axi_rresp_i     (s_axi_rresp)
  ,.axi_rlast_i     (s_axi_rlast)
  ,.axi_rvalid_i    (s_axi_rvalid)
  ,.axi_rready_o    (s_axi_rready)
  );
  
  // LED breathing
  logic led_breath;
  logic [31:0] led_counter_r;
  assign led[2] = led_breath;
  always_ff @(posedge mig_clk)
    if (mig_reset)
      begin
        led_counter_r <= '0;
        led_breath <= 1'b0;
      end
    else
      begin
        led_counter_r <= (led_counter_r == 32'd50000000)? '0 : led_counter_r + 1;
        led_breath <= (led_counter_r == 32'd50000000)? ~led_breath : led_breath;
      end


  design_1 design_1_i
       (.ddr4_sdram_act_n(ddr4_sdram_act_n),
        .ddr4_sdram_adr(ddr4_sdram_adr),
        .ddr4_sdram_ba(ddr4_sdram_ba),
        .ddr4_sdram_bg(ddr4_sdram_bg),
        .ddr4_sdram_ck_c(ddr4_sdram_ck_c),
        .ddr4_sdram_ck_t(ddr4_sdram_ck_t),
        .ddr4_sdram_cke(ddr4_sdram_cke),
        .ddr4_sdram_cs_n(ddr4_sdram_cs_n),
        .ddr4_sdram_dm_n(ddr4_sdram_dm_n),
        .ddr4_sdram_dq(ddr4_sdram_dq),
        .ddr4_sdram_dqs_c(ddr4_sdram_dqs_c),
        .ddr4_sdram_dqs_t(ddr4_sdram_dqs_t),
        .ddr4_sdram_odt(ddr4_sdram_odt),
        .ddr4_sdram_reset_n(ddr4_sdram_reset_n),
        .sysclk_300_clk_n(sysclk_300_clk_n),
        .sysclk_300_clk_p(sysclk_300_clk_p),
        .m_axi_lite_araddr(m_axi_lite_araddr),
        .m_axi_lite_arprot(m_axi_lite_arprot),
        .m_axi_lite_arready(m_axi_lite_arready),
        .m_axi_lite_arvalid(m_axi_lite_arvalid),
        .m_axi_lite_awaddr(m_axi_lite_awaddr),
        .m_axi_lite_awprot(m_axi_lite_awprot),
        .m_axi_lite_awready(m_axi_lite_awready),
        .m_axi_lite_awvalid(m_axi_lite_awvalid),
        .m_axi_lite_bready(m_axi_lite_bready),
        .m_axi_lite_bresp(m_axi_lite_bresp),
        .m_axi_lite_bvalid(m_axi_lite_bvalid),
        .m_axi_lite_rdata(m_axi_lite_rdata),
        .m_axi_lite_rready(m_axi_lite_rready),
        .m_axi_lite_rresp(m_axi_lite_rresp),
        .m_axi_lite_rvalid(m_axi_lite_rvalid),
        .m_axi_lite_wdata(m_axi_lite_wdata),
        .m_axi_lite_wready(m_axi_lite_wready),
        .m_axi_lite_wstrb(m_axi_lite_wstrb),
        .m_axi_lite_wvalid(m_axi_lite_wvalid),
        .mig_calib_done(mig_calib_done),
        .mig_clk(mig_clk),
        .mig_rstn(mig_rstn),
        .pci_express_x4_rxn(pci_express_x4_rxn),
        .pci_express_x4_rxp(pci_express_x4_rxp),
        .pci_express_x4_txn(pci_express_x4_txn),
        .pci_express_x4_txp(pci_express_x4_txp),
        .pcie_clk(pcie_clk),
        .pcie_lnk_up(pcie_lnk_up),
        .pcie_perstn(pcie_perstn),
        .pcie_refclk_clk_n(pcie_refclk_clk_n),
        .pcie_refclk_clk_p(pcie_refclk_clk_p),
        .pcie_rstn(pcie_rstn),
        .reset(reset | reset_gpio),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arcache(s_axi_arcache),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arqos(s_axi_arqos),
        .s_axi_arready(s_axi_arready),
        .s_axi_arregion(s_axi_arregion),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awqos(s_axi_awqos),
        .s_axi_awready(s_axi_awready),
        .s_axi_awregion(s_axi_awregion),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid));
endmodule
