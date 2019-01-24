`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module bsg_zedboard
  import bsg_rocket_pkg::*;
  import bsg_fsb_pkg::*;
# (parameter channel_width_p=8
  ,parameter ring_bytes_p=10
  ,parameter ring_width_p=ring_bytes_p*channel_width_p
  ,parameter nodes_p=6
  ,parameter boot_id_p=0
  // FSB# = Rocket# + 1
  ,parameter rocket_id_p=1
  ,parameter rocket_id2_p=3)
  (input        GCLK
  // reset
  ,input        BTNC
  // led
  ,output       LD0, LD1, LD2, LD3
  ,output       LD4, LD5, LD6, LD7
  // ddr
  ,inout [14:0] DDR_addr
  ,inout  [2:0] DDR_ba
  ,inout        DDR_cas_n
  ,inout        DDR_ck_n
  ,inout        DDR_ck_p
  ,inout        DDR_cke
  ,inout        DDR_cs_n
  ,inout  [3:0] DDR_dm
  ,inout [31:0] DDR_dq
  ,inout  [3:0] DDR_dqs_n
  ,inout  [3:0] DDR_dqs_p
  ,inout        DDR_odt
  ,inout        DDR_ras_n
  ,inout        DDR_reset_n
  ,inout        DDR_we_n
  // ps
  ,inout        FIXED_IO_ddr_vrn
  ,inout        FIXED_IO_ddr_vrp
  ,inout [53:0] FIXED_IO_mio
  ,inout        FIXED_IO_ps_clk
  ,inout        FIXED_IO_ps_porb
  ,inout        FIXED_IO_ps_srstb
  // fmc gateway reset out
  ,output FMC_LA20_P, FMC_LA20_N
  // fmc zedboard reset in
  ,input FMC_LA23_P, FMC_LA23_N
  // fmc tx clk out
  ,output FMC_LA17_CC_P, FMC_LA17_CC_N
  // fmc tx data out
  ,output FMC_LA31_P, FMC_LA31_N
  ,output FMC_LA33_P, FMC_LA33_N
  ,output FMC_LA30_P, FMC_LA30_N
  ,output FMC_LA32_P, FMC_LA32_N
  ,output FMC_LA28_P, FMC_LA28_N
  ,output FMC_LA25_P, FMC_LA25_N
  ,output FMC_LA29_P, FMC_LA29_N
  ,output FMC_LA26_P, FMC_LA26_N
  ,output FMC_LA21_P, FMC_LA21_N
  ,output FMC_LA27_P, FMC_LA27_N
  ,output FMC_LA22_P, FMC_LA22_N
  // fmc rx clk out
  ,output FMC_CLK0_P, FMC_CLK0_N
  // fmc rx clk in
  ,input FMC_LA00_CC_P, FMC_LA00_CC_N
  // fmc rx data in
  ,input FMC_LA01_CC_P, FMC_LA01_CC_N
  ,input FMC_LA16_P, FMC_LA16_N
  ,input FMC_LA15_P, FMC_LA15_N
  ,input FMC_LA13_P, FMC_LA13_N
  ,input FMC_LA11_P, FMC_LA11_N
  ,input FMC_LA10_P, FMC_LA10_N
  ,input FMC_LA14_P, FMC_LA14_N
  ,input FMC_LA09_P, FMC_LA09_N
  ,input FMC_LA04_P, FMC_LA04_N
  ,input FMC_LA07_P, FMC_LA07_N
  ,input FMC_LA08_P, FMC_LA08_N

  );

  // clk
  wire clk_50_mhz, clk_200_mhz, mmcm_locked;

  bsg_zedboard_clk clk
    (.clk_100_mhz_i(GCLK)
    ,.clk_50_mhz_o(clk_50_mhz)
    ,.clk_200_mhz_o(clk_200_mhz)
    ,.locked_o(mmcm_locked));

  // host
  wire       host_reset;

  wire       host_in_valid;
  bsg_host_t host_in_data;
  wire       host_in_ready;

  wire       host_out_valid;
  bsg_host_t host_out_data;
  wire       host_out_ready;
  
  wire       host_reset2;

  wire       host_in_valid2;
  bsg_host_t host_in_data2;
  wire       host_in_ready2;

  wire       host_out_valid2;
  bsg_host_t host_out_data2;
  wire       host_out_ready2;

  // memory
  wire            mem_aw_valid;
  bsg_nasti_a_pkt mem_aw_data;
  wire            mem_aw_ready;
  wire            mem_w_valid;
  bsg_nasti_w_pkt mem_w_data;
  wire            mem_w_ready;
  wire            mem_b_valid;
  bsg_nasti_b_pkt mem_b_data;
  wire            mem_b_ready;
  wire            mem_ar_valid;
  bsg_nasti_a_pkt mem_ar_data;
  wire            mem_ar_ready;
  wire            mem_r_valid;
  bsg_nasti_r_pkt mem_r_data;
  wire            mem_r_ready;
  
  wire            mem_aw_valid2;
  bsg_nasti_a_pkt mem_aw_data2;
  wire            mem_aw_ready2;
  wire            mem_w_valid2;
  bsg_nasti_w_pkt mem_w_data2;
  wire            mem_w_ready2;
  wire            mem_b_valid2;
  bsg_nasti_b_pkt mem_b_data2;
  wire            mem_b_ready2;
  wire            mem_ar_valid2;
  bsg_nasti_a_pkt mem_ar_data2;
  wire            mem_ar_ready2;
  wire            mem_r_valid2;
  bsg_nasti_r_pkt mem_r_data2;
  wire            mem_r_ready2;

  wire FCLK_RESET0_N;

  wire boot_done;



  wire        host_ar_valid;
  wire [31:0] host_ar_addr;
  wire  [1:0] host_ar_burst;
  wire  [7:0] host_ar_len;
  wire  [2:0] host_ar_size;
  wire [11:0] host_ar_id;
  wire        host_ar_ready;

  wire        host_aw_valid;
  wire [31:0] host_aw_addr;
  wire  [1:0] host_aw_burst;
  wire  [7:0] host_aw_len;
  wire  [2:0] host_aw_size;
  wire [11:0] host_aw_id;
  wire        host_aw_ready;

  wire        host_b_valid;
  wire [11:0] host_b_id;
  wire        host_b_ready;

  wire        host_w_valid;
  wire [31:0] host_w_data;
  wire  [3:0] host_w_strb;
  wire        host_w_last;
  wire        host_w_ready;

  wire        host_r_valid;
  wire [31:0] host_r_data;
  wire        host_r_last;
  wire [11:0] host_r_id;
  wire        host_r_ready;
  
  
  wire        host_ar_valid2;
  wire [31:0] host_ar_addr2;
  wire  [1:0] host_ar_burst2;
  wire  [7:0] host_ar_len2;
  wire  [2:0] host_ar_size2;
  wire [11:0] host_ar_id2;
  wire        host_ar_ready2;

  wire        host_aw_valid2;
  wire [31:0] host_aw_addr2;
  wire  [1:0] host_aw_burst2;
  wire  [7:0] host_aw_len2;
  wire  [2:0] host_aw_size2;
  wire [11:0] host_aw_id2;
  wire        host_aw_ready2;

  wire        host_b_valid2;
  wire [11:0] host_b_id2;
  wire        host_b_ready2;

  wire        host_w_valid2;
  wire [31:0] host_w_data2;
  wire  [3:0] host_w_strb2;
  wire        host_w_last2;
  wire        host_w_ready2;

  wire        host_r_valid2;
  wire [31:0] host_r_data2;
  wire        host_r_last2;
  wire [11:0] host_r_id2;
  wire        host_r_ready2;
  

  // partition
  wire [31:0] mask_ar_addr = (32'h10000000 | (32'h0fffffff & mem_ar_data.addr));
  wire [31:0] mask_aw_addr = (32'h10000000 | (32'h0fffffff & mem_aw_data.addr));
  
  wire [31:0] mask_ar_addr2 = (32'h10000000 | (32'h0fffffff & mem_ar_data2.addr));
  wire [31:0] mask_aw_addr2 = (32'h10000000 | (32'h0fffffff & mem_aw_data2.addr));

  system system_i
    (.DDR_addr(DDR_addr)
    ,.DDR_ba(DDR_ba)
    ,.DDR_cas_n(DDR_cas_n)
    ,.DDR_ck_n(DDR_ck_n)
    ,.DDR_ck_p(DDR_ck_p)
    ,.DDR_cke(DDR_cke)
    ,.DDR_cs_n(DDR_cs_n)
    ,.DDR_dm(DDR_dm)
    ,.DDR_dq(DDR_dq)
    ,.DDR_dqs_n(DDR_dqs_n)
    ,.DDR_dqs_p(DDR_dqs_p)
    ,.DDR_odt(DDR_odt)
    ,.DDR_ras_n(DDR_ras_n)
    ,.DDR_reset_n(DDR_reset_n)
    ,.DDR_we_n(DDR_we_n)

    ,.FCLK_RESET0_N(FCLK_RESET0_N)

    ,.FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn)
    ,.FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp)
    ,.FIXED_IO_mio(FIXED_IO_mio)
    ,.FIXED_IO_ps_clk(FIXED_IO_ps_clk)
    ,.FIXED_IO_ps_porb(FIXED_IO_ps_porb)
    ,.FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)

    // CAREFUL if this is change it, update base design properly
    // base design is created in rocket_bd.tcl
    ,.ext_clk_in(clk_50_mhz)

    // [host] master AXI interface (zynq = master fpga = slave)

    ,.M_AXI_awvalid(host_aw_valid)
    ,.M_AXI_awaddr(host_aw_addr)
    ,.M_AXI_awburst(host_aw_burst)
    ,.M_AXI_awid(host_aw_id)
    ,.M_AXI_awlen(host_aw_len)
    ,.M_AXI_awsize(host_aw_size)
    ,.M_AXI_awready(host_aw_ready)

    ,.M_AXI_wvalid(host_w_valid)
    ,.M_AXI_wdata(host_w_data)
    ,.M_AXI_wlast(host_w_last)
    ,.M_AXI_wstrb(host_w_strb)
    ,.M_AXI_wready(host_w_ready)

    ,.M_AXI_bvalid(host_b_valid)
    ,.M_AXI_bid(host_b_id)
    ,.M_AXI_bresp(2'b00)
    ,.M_AXI_bready(host_b_ready)

    ,.M_AXI_arvalid(host_ar_valid)
    ,.M_AXI_araddr(host_ar_addr)
    ,.M_AXI_arburst(host_ar_burst)
    ,.M_AXI_arid(host_ar_id)
    ,.M_AXI_arlen(host_ar_len)
    ,.M_AXI_arsize(host_ar_size)
    ,.M_AXI_arready(host_ar_ready)

    ,.M_AXI_rvalid(host_r_valid)
    ,.M_AXI_rdata(host_r_data)
    ,.M_AXI_rid(host_r_id)
    ,.M_AXI_rlast(host_r_last)
    ,.M_AXI_rready(host_r_ready)

    // [memory] slave AXI interface (fpga = master zynq = slave)

    ,.S_AXI_awvalid(mem_aw_valid)
    ,.S_AXI_awaddr(mask_aw_addr)
    ,.S_AXI_awlen(mem_aw_data.len)
    ,.S_AXI_awsize(mem_aw_data.size)
    ,.S_AXI_awburst(mem_aw_data.burst)
    ,.S_AXI_awid(mem_aw_data.id)
    ,.S_AXI_awlock(mem_aw_data.lock)
    ,.S_AXI_awprot(mem_aw_data.prot)
    ,.S_AXI_awqos(mem_aw_data.qos)
    ,.S_AXI_awregion(mem_aw_data.region)
    ,.S_AXI_awcache(mem_aw_data.cache)
    ,.S_AXI_awready(mem_aw_ready)

    ,.S_AXI_wvalid(mem_w_valid)
    ,.S_AXI_wdata(mem_w_data.data)
    ,.S_AXI_wlast(mem_w_data.last)
    ,.S_AXI_wstrb(mem_w_data.strb)
    ,.S_AXI_wready(mem_w_ready)

    ,.S_AXI_bvalid(mem_b_valid)
    ,.S_AXI_bresp(mem_b_data.resp)
    ,.S_AXI_bid(mem_b_data.id)
    ,.S_AXI_bready(mem_b_ready)

    ,.S_AXI_arvalid(mem_ar_valid)
    ,.S_AXI_araddr(mask_ar_addr)
    ,.S_AXI_arlen(mem_ar_data.len)
    ,.S_AXI_arsize(mem_ar_data.size)
    ,.S_AXI_arburst(mem_ar_data.burst)
    ,.S_AXI_arid(mem_ar_data.id)
    ,.S_AXI_arlock(mem_ar_data.lock)
    ,.S_AXI_arprot(mem_ar_data.prot)
    ,.S_AXI_arqos(mem_ar_data.qos)
    ,.S_AXI_arregion(mem_ar_data.region)
    ,.S_AXI_arcache(mem_ar_data.cache)
    ,.S_AXI_arready(mem_ar_ready)

    ,.S_AXI_rvalid(mem_r_valid)
    ,.S_AXI_rid(mem_r_data.id)
    ,.S_AXI_rdata(mem_r_data.data)
    ,.S_AXI_rlast(mem_r_data.last)
    ,.S_AXI_rresp(mem_r_data.resp)
    ,.S_AXI_rready(mem_r_ready)
	
	
    ,.M_AXI2_awvalid(host_aw_valid2)
    ,.M_AXI2_awaddr(host_aw_addr2)
    ,.M_AXI2_awburst(host_aw_burst2)
    ,.M_AXI2_awid(host_aw_id2)
    ,.M_AXI2_awlen(host_aw_len2)
    ,.M_AXI2_awsize(host_aw_size2)
    ,.M_AXI2_awready(host_aw_ready2)

    ,.M_AXI2_wvalid(host_w_valid2)
    ,.M_AXI2_wdata(host_w_data2)
    ,.M_AXI2_wlast(host_w_last2)
    ,.M_AXI2_wstrb(host_w_strb2)
    ,.M_AXI2_wready(host_w_ready2)

    ,.M_AXI2_bvalid(host_b_valid2)
    ,.M_AXI2_bid(host_b_id2)
    ,.M_AXI2_bresp(2'b00)
    ,.M_AXI2_bready(host_b_ready2)

    ,.M_AXI2_arvalid(host_ar_valid2)
    ,.M_AXI2_araddr(host_ar_addr2)
    ,.M_AXI2_arburst(host_ar_burst2)
    ,.M_AXI2_arid(host_ar_id2)
    ,.M_AXI2_arlen(host_ar_len2)
    ,.M_AXI2_arsize(host_ar_size2)
    ,.M_AXI2_arready(host_ar_ready2)

    ,.M_AXI2_rvalid(host_r_valid2)
    ,.M_AXI2_rdata(host_r_data2)
    ,.M_AXI2_rid(host_r_id2)
    ,.M_AXI2_rlast(host_r_last2)
    ,.M_AXI2_rready(host_r_ready2)

    // [memory] slave AXI interface (fpga = master zynq = slave)

    ,.S_AXI2_awvalid(mem_aw_valid2)
    ,.S_AXI2_awaddr(mask_aw_addr2)
    ,.S_AXI2_awlen(mem_aw_data2.len)
    ,.S_AXI2_awsize(mem_aw_data2.size)
    ,.S_AXI2_awburst(mem_aw_data2.burst)
    ,.S_AXI2_awid(mem_aw_data2.id)
    ,.S_AXI2_awlock(mem_aw_data2.lock)
    ,.S_AXI2_awprot(mem_aw_data2.prot)
    ,.S_AXI2_awqos(mem_aw_data2.qos)
    ,.S_AXI2_awregion(mem_aw_data2.region)
    ,.S_AXI2_awcache(mem_aw_data2.cache)
    ,.S_AXI2_awready(mem_aw_ready2)

    ,.S_AXI2_wvalid(mem_w_valid2)
    ,.S_AXI2_wdata(mem_w_data2.data)
    ,.S_AXI2_wlast(mem_w_data2.last)
    ,.S_AXI2_wstrb(mem_w_data2.strb)
    ,.S_AXI2_wready(mem_w_ready2)

    ,.S_AXI2_bvalid(mem_b_valid2)
    ,.S_AXI2_bresp(mem_b_data2.resp)
    ,.S_AXI2_bid(mem_b_data2.id)
    ,.S_AXI2_bready(mem_b_ready2)

    ,.S_AXI2_arvalid(mem_ar_valid2)
    ,.S_AXI2_araddr(mask_ar_addr2)
    ,.S_AXI2_arlen(mem_ar_data2.len)
    ,.S_AXI2_arsize(mem_ar_data2.size)
    ,.S_AXI2_arburst(mem_ar_data2.burst)
    ,.S_AXI2_arid(mem_ar_data2.id)
    ,.S_AXI2_arlock(mem_ar_data2.lock)
    ,.S_AXI2_arprot(mem_ar_data2.prot)
    ,.S_AXI2_arqos(mem_ar_data2.qos)
    ,.S_AXI2_arregion(mem_ar_data2.region)
    ,.S_AXI2_arcache(mem_ar_data2.cache)
    ,.S_AXI2_arready(mem_ar_ready2)

    ,.S_AXI2_rvalid(mem_r_valid2)
    ,.S_AXI2_rid(mem_r_data2.id)
    ,.S_AXI2_rdata(mem_r_data2.data)
    ,.S_AXI2_rlast(mem_r_data2.last)
    ,.S_AXI2_rresp(mem_r_data2.resp)
    ,.S_AXI2_rready(mem_r_ready2)
	);
	

  host_axi_converter hac
    (.clk (clk_50_mhz)

    ,.reset(~FCLK_RESET0_N | ~mmcm_locked)
    ,.io_reset(host_reset)

    ,.io_host_in_valid(host_in_valid)
    ,.io_host_in_bits(host_in_data)
    ,.io_host_in_ready(host_in_ready)

    ,.io_host_out_valid(host_out_valid)
    ,.io_host_out_bits(host_out_data)
    ,.io_host_out_ready(host_out_ready)

    ,.io_nasti_aw_valid(host_aw_valid)
    ,.io_nasti_aw_bits_addr(host_aw_addr)
    ,.io_nasti_aw_bits_len(host_aw_len)
    ,.io_nasti_aw_bits_size(host_aw_size)
    ,.io_nasti_aw_bits_burst(host_aw_burst)
    ,.io_nasti_aw_bits_id(host_aw_id)
    ,.io_nasti_aw_ready(host_aw_ready)

    ,.io_nasti_w_valid(host_w_valid)
    ,.io_nasti_w_bits_data(host_w_data)
    ,.io_nasti_w_bits_strb(host_w_strb)
    ,.io_nasti_w_bits_last(host_w_last)
    ,.io_nasti_w_ready(host_w_ready)

    ,.io_nasti_b_valid(host_b_valid)
    ,.io_nasti_b_bits_id(host_b_id)
    ,.io_nasti_b_ready(host_b_ready)

    ,.io_nasti_ar_valid(host_ar_valid)
    ,.io_nasti_ar_bits_addr(host_ar_addr)
    ,.io_nasti_ar_bits_len(host_ar_len)
    ,.io_nasti_ar_bits_size(host_ar_size)
    ,.io_nasti_ar_bits_burst(host_ar_burst)
    ,.io_nasti_ar_bits_id(host_ar_id)
    ,.io_nasti_ar_ready(host_ar_ready)

    ,.io_nasti_r_valid(host_r_valid)
    ,.io_nasti_r_bits_id(host_r_id)
    ,.io_nasti_r_bits_data(host_r_data)
    ,.io_nasti_r_bits_last(host_r_last)
    ,.io_nasti_r_ready(host_r_ready));
	
	
  host_axi_converter hac2
    (.clk (clk_50_mhz)

    ,.reset(~FCLK_RESET0_N | ~mmcm_locked)
    ,.io_reset(host_reset2)

    ,.io_host_in_valid(host_in_valid2)
    ,.io_host_in_bits(host_in_data2)
    ,.io_host_in_ready(host_in_ready2)

    ,.io_host_out_valid(host_out_valid2)
    ,.io_host_out_bits(host_out_data2)
    ,.io_host_out_ready(host_out_ready2)

    ,.io_nasti_aw_valid(host_aw_valid2)
    ,.io_nasti_aw_bits_addr(host_aw_addr2)
    ,.io_nasti_aw_bits_len(host_aw_len2)
    ,.io_nasti_aw_bits_size(host_aw_size2)
    ,.io_nasti_aw_bits_burst(host_aw_burst2)
    ,.io_nasti_aw_bits_id(host_aw_id2)
    ,.io_nasti_aw_ready(host_aw_ready2)

    ,.io_nasti_w_valid(host_w_valid2)
    ,.io_nasti_w_bits_data(host_w_data2)
    ,.io_nasti_w_bits_strb(host_w_strb2)
    ,.io_nasti_w_bits_last(host_w_last2)
    ,.io_nasti_w_ready(host_w_ready2)

    ,.io_nasti_b_valid(host_b_valid2)
    ,.io_nasti_b_bits_id(host_b_id2)
    ,.io_nasti_b_ready(host_b_ready2)

    ,.io_nasti_ar_valid(host_ar_valid2)
    ,.io_nasti_ar_bits_addr(host_ar_addr2)
    ,.io_nasti_ar_bits_len(host_ar_len2)
    ,.io_nasti_ar_bits_size(host_ar_size2)
    ,.io_nasti_ar_bits_burst(host_ar_burst2)
    ,.io_nasti_ar_bits_id(host_ar_id2)
    ,.io_nasti_ar_ready(host_ar_ready2)

    ,.io_nasti_r_valid(host_r_valid2)
    ,.io_nasti_r_bits_id(host_r_id2)
    ,.io_nasti_r_bits_data(host_r_data2)
    ,.io_nasti_r_bits_last(host_r_last2)
    ,.io_nasti_r_ready(host_r_ready2));



  // into nodes (fsb interface)
  wire [nodes_p-1:0]      core_node_v_A;
  wire [ring_width_p-1:0] core_node_data_A [nodes_p-1:0];
  wire [nodes_p-1:0]      core_node_ready_A;

  // into nodes (control)
  wire [nodes_p-1:0]      core_node_en_r;
  wire [nodes_p-1:0]      core_node_reset_r;

  // out of nodes (fsb interface)
  wire [nodes_p-1:0]      core_node_v_B;
  wire [ring_width_p-1:0] core_node_data_B [nodes_p-1:0];
  wire [nodes_p-1:0]      core_node_yumi_B;

  // rocket node master

  genvar i;
  
  for (i=1; i<6; i++) begin
	if (i != rocket_id_p && i != rocket_id2_p) begin
		assign core_node_ready_A[i] = 1;
		assign core_node_v_B[i] = 0;
		assign core_node_data_B[i] = 0;
	end
  end
  
  bsg_rocket_node_master #
    (.dest_id_p(rocket_id_p))
  mstr
    (.clk_i(clk_50_mhz)
    // ctrl
    ,.reset_i(core_node_reset_r[rocket_id_p] | host_reset | ~boot_done)
    ,.en_i(core_node_en_r[rocket_id_p])
    // in
    ,.v_i(core_node_v_A[rocket_id_p])
    ,.data_i(core_node_data_A[rocket_id_p])
    ,.ready_o(core_node_ready_A[rocket_id_p])
    // out
    ,.v_o(core_node_v_B[rocket_id_p])
    ,.data_o(core_node_data_B[rocket_id_p])
    ,.yumi_i(core_node_yumi_B[rocket_id_p])
    // host in
    ,.host_valid_i(host_in_valid)
    ,.host_data_i(host_in_data)
    ,.host_ready_o(host_in_ready)
    // host out
    ,.host_valid_o(host_out_valid)
    ,.host_data_o(host_out_data)
    ,.host_ready_i(host_out_ready)
    // aw out
    ,.nasti_aw_valid_o(mem_aw_valid)
    ,.nasti_aw_data_o(mem_aw_data)
    ,.nasti_aw_ready_i(mem_aw_ready)
    // w out
    ,.nasti_w_valid_o(mem_w_valid)
    ,.nasti_w_data_o(mem_w_data)
    ,.nasti_w_ready_i(mem_w_ready)
    // b in
    ,.nasti_b_valid_i(mem_b_valid)
    ,.nasti_b_data_i(mem_b_data)
    ,.nasti_b_ready_o(mem_b_ready)
    // ar out
    ,.nasti_ar_valid_o(mem_ar_valid)
    ,.nasti_ar_data_o(mem_ar_data)
    ,.nasti_ar_ready_i(mem_ar_ready)
    // r in
    ,.nasti_r_valid_i(mem_r_valid)
    ,.nasti_r_data_i(mem_r_data)
    ,.nasti_r_ready_o(mem_r_ready));
	
	
  bsg_rocket_node_master #
    (.dest_id_p(rocket_id2_p))
  mstr2
    (.clk_i(clk_50_mhz)
    // ctrl
    ,.reset_i(core_node_reset_r[rocket_id2_p] | host_reset2 | ~boot_done)
    ,.en_i(core_node_en_r[rocket_id2_p])
    // in
    ,.v_i(core_node_v_A[rocket_id2_p])
    ,.data_i(core_node_data_A[rocket_id2_p])
    ,.ready_o(core_node_ready_A[rocket_id2_p])
    // out
    ,.v_o(core_node_v_B[rocket_id2_p])
    ,.data_o(core_node_data_B[rocket_id2_p])
    ,.yumi_i(core_node_yumi_B[rocket_id2_p])
    // host in
    ,.host_valid_i(host_in_valid2)
    ,.host_data_i(host_in_data2)
    ,.host_ready_o(host_in_ready2)
    // host out
    ,.host_valid_o(host_out_valid2)
    ,.host_data_o(host_out_data2)
    ,.host_ready_i(host_out_ready2)
    // aw out
    ,.nasti_aw_valid_o(mem_aw_valid2)
    ,.nasti_aw_data_o(mem_aw_data2)
    ,.nasti_aw_ready_i(mem_aw_ready2)
    // w out
    ,.nasti_w_valid_o(mem_w_valid2)
    ,.nasti_w_data_o(mem_w_data2)
    ,.nasti_w_ready_i(mem_w_ready2)
    // b in
    ,.nasti_b_valid_i(mem_b_valid2)
    ,.nasti_b_data_i(mem_b_data2)
    ,.nasti_b_ready_o(mem_b_ready2)
    // ar out
    ,.nasti_ar_valid_o(mem_ar_valid2)
    ,.nasti_ar_data_o(mem_ar_data2)
    ,.nasti_ar_ready_i(mem_ar_ready2)
    // r in
    ,.nasti_r_valid_i(mem_r_valid2)
    ,.nasti_r_data_i(mem_r_data2)
    ,.nasti_r_ready_o(mem_r_ready2));
	

  // boot node

  bsg_test_node_master #
    (.ring_width_p(ring_width_p))
  boot
    (.clk_i(clk_50_mhz)
    ,.reset_i(core_node_reset_r[boot_id_p])
    // control
    ,.en_i(core_node_en_r[boot_id_p])
    ,.done_o(boot_done)
    // out
    ,.v_o(core_node_v_B[boot_id_p])
    ,.data_o(core_node_data_B[boot_id_p])
    ,.yumi_i(core_node_yumi_B[boot_id_p])
    // not used
    ,.v_i('0)
    ,.data_i('0)
    ,.ready_o());

  // fsb

  wire dt_calib_reset;

  wire                    asm_in_valid;
  wire [ring_width_p-1:0] asm_in_data;
  wire                    asm_in_yumi;

  wire                    asm_out_valid;
  wire [ring_width_p-1:0] asm_out_data;
  wire                    asm_out_ready;
  
  
  // For rocket 4 debug
  logic [3:0] state_r, state_n;
  logic [ring_width_p-1:0] debug_data_r, debug_data_n;
  
  logic                    debug_asm_out_valid;
  logic [ring_width_p-1:0] debug_asm_out_data;
  logic                    debug_asm_out_ready;
  
  always @(posedge clk_50_mhz) begin
    if (core_node_reset_r[boot_id_p]) begin
        state_r <= 0;
        debug_data_r <= 0;
    end else begin
        state_r <= state_n;
        debug_data_r <= debug_data_n;
    end
  end
  
  always_comb begin
  
    state_n = state_r;
    debug_data_n = debug_data_r;
    
    debug_asm_out_valid = asm_out_valid;
    debug_asm_out_data = asm_out_data;
    debug_asm_out_ready = asm_out_ready;
  
    if (~core_node_reset_r[boot_id_p]) begin
        
        if (state_r == 0) begin
            if (asm_out_ready==1 && asm_out_valid==1 && asm_out_data[75]==0) begin
                //debug_data_n = asm_out_data;
                //state_n = 1;
                //debug_asm_out_data = asm_out_data | (1<<79);
            end
        end 
/*        
        if (state_r == 1) begin
            debug_asm_out_ready = 0;
            debug_asm_out_data = debug_data_r | (1<<79);
            debug_asm_out_valid = 0;
            if (asm_out_ready) begin
                debug_asm_out_valid = 1;
                state_n = 2;
            end
        end
        
        if (state_r == 2) begin
            debug_asm_out_ready = 0;
            debug_asm_out_data = debug_data_r;
            debug_asm_out_valid = 0;
            if (asm_out_ready) begin
                debug_asm_out_valid = 1;
                state_n = 3;
            end
        end
        
        if (state_r == 3) begin
            debug_asm_out_ready = 0;
            debug_asm_out_data = debug_data_r | (1<<79);
            debug_asm_out_valid = 0;
            if (asm_out_ready) begin
                debug_asm_out_valid = 1;
                state_n = 0;
            end
        end
*/        
    end
  end
  
  bsg_fsb #
    (.width_p(ring_width_p)
    ,.nodes_p(nodes_p)
    ,.snoop_vec_p({nodes_p{1'b0}})
    // if master, enable at startup so that it can drive things
    ,.enabled_at_start_vec_p({nodes_p{1'b1}}))
  fsb
    (.clk_i(clk_50_mhz)
    ,.reset_i(dt_calib_reset)
    // node ctrl
    ,.node_reset_r_o(core_node_reset_r)
    ,.node_en_r_o(core_node_en_r)
    // node in
    ,.node_v_i(core_node_v_B)
    ,.node_data_i(core_node_data_B)
    ,.node_yumi_o(core_node_yumi_B)
    // node out
    ,.node_v_o(core_node_v_A)
    ,.node_data_o(core_node_data_A)
    ,.node_ready_i(core_node_ready_A)
    // asm in
    ,.asm_v_i(asm_in_valid)
    ,.asm_data_i(asm_in_data)
    ,.asm_yumi_o(asm_in_yumi)
    // asm out
    ,.asm_v_o(asm_out_valid)
    ,.asm_data_o(asm_out_data)
    ,.asm_ready_i(debug_asm_out_ready));

  // fmc

  wire                    btf_valid;
  wire [ring_width_p-1:0] btf_data;
  wire                    btf_ready;

  bsg_two_fifo #
    (.width_p(80))
  btf
    (.clk_i(clk_50_mhz)
    ,.reset_i(dt_calib_reset)
    // in
    ,.v_i(btf_valid)
    ,.data_i(btf_data)
    ,.ready_o(btf_ready)
    // out
    ,.v_o(asm_in_valid)
    ,.data_o(asm_in_data)
    ,.yumi_i(asm_in_yumi));

  // fmc

  wire dt_reset = BTNC | ~mmcm_locked;

  bsg_zedboard_fmc fmc
    (.clk_i(clk_50_mhz)
    // data in
    ,.valid_i(debug_asm_out_valid)
    ,.data_i(debug_asm_out_data)
    ,.ready_o(asm_out_ready)
    // data out
    ,.valid_o(btf_valid)
    ,.data_o(btf_data)
    ,.ready_i(btf_ready)
    // double trouble reset in
    ,.dt_reset_i(dt_reset)
    // double-trouble calibration reset
    ,.dt_calib_reset_o(dt_calib_reset)
    // fmc clk for zedboard and gateway
    ,.fmc_clk_i(clk_200_mhz)
    ,.fmc_clk_div_i(clk_50_mhz)
    ,.fmc_clk_200_mhz_i(clk_200_mhz)
    // fmc gateway reset out
    ,.FMC_LA20_P(FMC_LA20_P) ,.FMC_LA20_N(FMC_LA20_N)
    // fmc zedboard reset in
    ,.FMC_LA23_P(FMC_LA23_P) ,.FMC_LA23_N(FMC_LA23_N)
    // fmc tx clk out
    ,.FMC_LA17_CC_P(FMC_LA17_CC_P) ,.FMC_LA17_CC_N(FMC_LA17_CC_N)
    // fmc tx data out
    ,.FMC_LA31_P(FMC_LA31_P) ,.FMC_LA31_N(FMC_LA31_N)
    ,.FMC_LA33_P(FMC_LA33_P) ,.FMC_LA33_N(FMC_LA33_N)
    ,.FMC_LA30_P(FMC_LA30_P) ,.FMC_LA30_N(FMC_LA30_N)
    ,.FMC_LA32_P(FMC_LA32_P) ,.FMC_LA32_N(FMC_LA32_N)
    ,.FMC_LA28_P(FMC_LA28_P) ,.FMC_LA28_N(FMC_LA28_N)
    ,.FMC_LA25_P(FMC_LA25_P) ,.FMC_LA25_N(FMC_LA25_N)
    ,.FMC_LA29_P(FMC_LA29_P) ,.FMC_LA29_N(FMC_LA29_N)
    ,.FMC_LA26_P(FMC_LA26_P) ,.FMC_LA26_N(FMC_LA26_N)
    ,.FMC_LA21_P(FMC_LA21_P) ,.FMC_LA21_N(FMC_LA21_N)
    ,.FMC_LA27_P(FMC_LA27_P) ,.FMC_LA27_N(FMC_LA27_N)
    ,.FMC_LA22_P(FMC_LA22_P) ,.FMC_LA22_N(FMC_LA22_N)
    // fmc rx clk out
    ,.FMC_CLK0_P(FMC_CLK0_P) ,.FMC_CLK0_N(FMC_CLK0_N)
    // fmc rx clk in
    ,.FMC_LA00_CC_P(FMC_LA00_CC_P) ,.FMC_LA00_CC_N(FMC_LA00_CC_N)
    // fmc rx data in
    ,.FMC_LA01_CC_P(FMC_LA01_CC_P) ,.FMC_LA01_CC_N(FMC_LA01_CC_N)
    ,.FMC_LA16_P(FMC_LA16_P) ,.FMC_LA16_N(FMC_LA16_N)
    ,.FMC_LA15_P(FMC_LA15_P) ,.FMC_LA15_N(FMC_LA15_N)
    ,.FMC_LA13_P(FMC_LA13_P) ,.FMC_LA13_N(FMC_LA13_N)
    ,.FMC_LA11_P(FMC_LA11_P) ,.FMC_LA11_N(FMC_LA11_N)
    ,.FMC_LA10_P(FMC_LA10_P) ,.FMC_LA10_N(FMC_LA10_N)
    ,.FMC_LA14_P(FMC_LA14_P) ,.FMC_LA14_N(FMC_LA14_N)
    ,.FMC_LA09_P(FMC_LA09_P) ,.FMC_LA09_N(FMC_LA09_N)
    ,.FMC_LA04_P(FMC_LA04_P) ,.FMC_LA04_N(FMC_LA04_N)
    ,.FMC_LA07_P(FMC_LA07_P) ,.FMC_LA07_N(FMC_LA07_N)
    ,.FMC_LA08_P(FMC_LA08_P) ,.FMC_LA08_N(FMC_LA08_N));

  assign LD0 = BTNC;
  assign LD1 = mmcm_locked;
  assign LD2 = host_reset;
  assign LD3 = dt_calib_reset;
  assign LD4 = boot_done;
  assign LD5 = FCLK_RESET0_N;
  assign LD6 = core_node_reset_r[0];
  assign LD7 = core_node_reset_r[1];

`ifndef SIMULATION

  (* mark_debug = "true" *) wire        d_host_reset;
  (* mark_debug = "true" *) wire        d_dt_reset;
  (* mark_debug = "true" *) wire        d_dt_calib_reset;
  (* mark_debug = "true" *) wire        d_asm_ready;
  (* mark_debug = "true" *) wire        d_asm_valid;
  (* mark_debug = "true" *) wire [79:0] d_asm_data;
  (* mark_debug = "true" *) wire        d_btf_ready;
  (* mark_debug = "true" *) wire        d_btf_valid;
  (* mark_debug = "true" *) wire [79:0] d_btf_data;

  assign d_host_reset = host_reset;
  assign d_dt_reset = dt_reset;
  assign d_dt_calib_reset = dt_calib_reset;

  assign d_asm_ready = asm_out_ready;
  assign d_asm_valid = asm_out_valid;
  assign d_asm_data  = asm_out_data;

  assign d_btf_ready = btf_ready;
  assign d_btf_valid = btf_valid;
  assign d_btf_data  = btf_data;

`endif

endmodule
