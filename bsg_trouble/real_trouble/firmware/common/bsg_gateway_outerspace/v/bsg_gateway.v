// bsg_gateway has FMC-support for these two boards:
//   * Xilinx ML605 (bsg_ml605)
//   * Digilent Zedboard (bsg_zedboard)
//
// BSG_ML605_FMC macro sets pinout for ML605
// BSG_ZEDBOARD_FMC macro sets pinout for Zedboard

`include "bsg_defines.v"

module bsg_gateway
  // clk osc
  (input CLK_OSC_P, CLK_OSC_N
`ifndef SIMULATION
  // reset
  ,input PWR_RSTN
  // voltage-rail enable
  ,output logic ASIC_CORE_EN, ASIC_IO_EN, ASIC_PLL_EN
  // current monitor
  ,output logic CUR_MON_ADDR0, CUR_MON_ADDR1
  ,inout CUR_MON_SCL, CUR_MON_SDA
  // potentiometer
  ,output logic DIG_POT_ADDR0, DIG_POT_ADDR1
  ,output logic DIG_POT_INDEP, DIG_POT_NRST
  ,inout DIG_POT_SCL, DIG_POT_SDA
  ,output logic DIG_POT_PLL_ADDR0, DIG_POT_PLL_ADDR1
  ,output logic DIG_POT_PLL_INDEP, DIG_POT_PLL_NRST
  ,inout DIG_POT_PLL_SCL, DIG_POT_PLL_SDA
  // uart
  ,input UART_RX
  ,output UART_TX
  // led
  ,output logic FPGA_LED0, FPGA_LED1
`endif
  ,output FPGA_LED2, FPGA_LED3
  
  // jumper switch
  ,input FG_SW0, FG_SW1, FG_SW2, FG_SW3
  ,input FG_SW4, FG_SW5, FG_SW6, FG_SW7

  // -------- ASIC --------

  // asic clk control
  ,output ASIC_CLK_SET_1
  ,output ASIC_CLK_SET_0
  ,input  ASIC_CLK
  ,output ASIC_CLK_SMA
  
  ,output ASIC_CORE_SET_1
  ,output ASIC_CORE_SET_0
  ,output ASIC_CORE_RESET
  ,output MSTR_SDO_CLK
  
  ,output ASIC_IO_SET_1
  ,output ASIC_IO_SET_0
  ,output ASIC_IO_RESET
  ,output PLL_CLK_I
  
  ,output ASIC_DFI2X_SET_1
  ,output ASIC_DFI2X_SET_0
  ,output ASIC_DFI2X_CLK
  
  ,output ASIC_DRLP_SET_1
  ,output ASIC_DRLP_SET_0
  ,output ASIC_DRLP_CLK
  
  ,output ASIC_FSB_SET_1
  ,output ASIC_FSB_SET_0
  ,output ASIC_FSB_CLK
  
  ,output ASIC_OP_SET_1
  ,output ASIC_OP_SET_0
  ,output ASIC_OP_CLK
  
  ,output ASIC_TAG_TCK
  ,output ASIC_TAG_TDI
  ,output ASIC_TAG_TMS

  // asic reset
  ,output Q7

  // channel in

  // channel clk in
  ,input AOC0, BOC0, COC0, DOC0
  // channel valid in
  ,input AOD8
  // channel data in
  //      A     B     C     D
  ,input AOD0
  ,input AOD1
  ,input AOD2
  ,input AOD3
  ,input AOD4
  ,input AOD5
  ,input AOD6
  ,input AOD7
  // channel token out
  ,output AOT0

  // channel out

  // channel clk out
  ,output AIC0
  // channel valid out
  ,output AID8
  // channel data out
  //       A     B     C     D
  ,output AID0
  ,output AID1
  ,output AID2
  ,output AID3
  ,output AID4
  ,output AID5
  ,output AID6
  ,output AID7
  // channel token in
  ,input AIT0

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
  logic clk_2x_lo;
  logic core_clk_lo;
  logic fast_core_clk_lo;
  logic io_master_clk_lo;
  logic locked_lo;
  
  logic [3:0] io_serdes_clk_lo;
  logic [3:0] io_strobe_lo;

  bsg_gateway_clk clk
    (.clk_150_mhz_p_i(CLK_OSC_P) ,.clk_150_mhz_n_i(CLK_OSC_N)
    // microblaze clock
    ,.mb_clk_o(mb_clk_lo)
	,.tag_tck_o(ASIC_TAG_TCK)
    // internal clocks
    ,.int_core_clk_o(core_clk_lo)
	,.int_fast_core_clk_o(fast_core_clk_lo)
    ,.int_io_master_clk_o(io_master_clk_lo)
	,.int_io_2x_clk_o(clk_2x_lo)
	// serdes clk
	,.io_serdes_clk_o(io_serdes_clk_lo)
	,.io_strobe_o(io_strobe_lo)
    // ext clk
    ,.ext_core_clk_o(MSTR_SDO_CLK)
    ,.ext_io_clk_o(PLL_CLK_I)
    ,.ext_fsb_clk_o(ASIC_FSB_CLK)
    ,.ext_op_clk_o(ASIC_OP_CLK)
    // locked
    ,.locked_o(locked_lo));
	
	
	logic mb_control_lo;
	logic [4:0] mb_io_osc_lo;
	logic [7:0] mb_io_div_lo;
	logic mb_io_isDiv_lo;
	logic [4:0] mb_core_osc_lo;
	logic [7:0] mb_core_div_lo;
	logic mb_core_isDiv_lo;

`ifndef SIMULATION

	// bsg_tag_gpio
	logic [31:0] tag_gpio;
	
	assign mb_control_lo = tag_gpio[0];
	assign mb_io_osc_lo = tag_gpio[1+:5];
	assign mb_io_div_lo = tag_gpio[6+:8];
	assign mb_io_isDiv_lo = tag_gpio[14];
	assign mb_core_osc_lo = tag_gpio[15+:5];
	assign mb_core_div_lo = tag_gpio[20+:8];
	assign mb_core_isDiv_lo = tag_gpio[28];

  // power control

  logic [31:0] gpio;
  logic cpu_override_output_p;
  logic cpu_override_output_n;

  assign cpu_override_output_p = gpio[11];
  assign cpu_override_output_n = gpio[10];

  always_comb begin
    FPGA_LED0 = 1'b1;
    FPGA_LED1 = 1'b1;
    DIG_POT_INDEP = 1'b1;
    DIG_POT_NRST = 1'b1;
    DIG_POT_ADDR0 = 1'b1;
    DIG_POT_ADDR1 = 1'b1;
    DIG_POT_PLL_INDEP = 1'b1;
    DIG_POT_PLL_NRST = 1'b1;
    DIG_POT_PLL_ADDR0 = 1'b1;
    DIG_POT_PLL_ADDR1 = 1'b1;
    CUR_MON_ADDR0 = 1'b1;
    CUR_MON_ADDR1 = 1'b1;
    ASIC_IO_EN = 1'b1;
    ASIC_CORE_EN = 1'b1;
	ASIC_PLL_EN = 1'b1;
    if (cpu_override_output_p == 1'b1 && cpu_override_output_n == 1'b0 && PWR_RSTN == 1'b1) begin
      FPGA_LED0 = gpio[0];
      FPGA_LED1 = gpio[1];
      DIG_POT_INDEP = gpio[2];
      DIG_POT_NRST = gpio[3];
      DIG_POT_ADDR0 = gpio[4];
      DIG_POT_ADDR1 = gpio[5];
      CUR_MON_ADDR0 = gpio[6];
      CUR_MON_ADDR1 = gpio[7];
      ASIC_IO_EN = gpio[8];
      ASIC_CORE_EN = gpio[9];
	  DIG_POT_PLL_INDEP = gpio[12];
      DIG_POT_PLL_NRST = gpio[13];
      DIG_POT_PLL_ADDR0 = gpio[14];
      DIG_POT_PLL_ADDR1 = gpio[15];
	  ASIC_PLL_EN = gpio[16];
    end
  end

  (* BOX_TYPE = "user_black_box" *)
  board_ctrl board_ctrl_i
    (.RESET(PWR_RSTN)
    ,.CLK_50(mb_clk_lo)
    ,.CLK_LOCKED(locked_lo)
    ,.axi_iic_dig_pot_Gpo_pin()
    ,.axi_iic_dig_pot_Sda_pin(DIG_POT_SDA)
    ,.axi_iic_dig_pot_Scl_pin(DIG_POT_SCL)
    ,.axi_iic_dig_pot_pll_Gpo_pin()
    ,.axi_iic_dig_pot_pll_Sda_pin(DIG_POT_PLL_SDA)
    ,.axi_iic_dig_pot_pll_Scl_pin(DIG_POT_PLL_SCL)
    ,.axi_iic_cur_mon_Gpo_pin()
    ,.axi_iic_cur_mon_Sda_pin(CUR_MON_SDA)
    ,.axi_iic_cur_mon_Scl_pin(CUR_MON_SCL)
    ,.axi_gpio_0_GPIO_IO_O_pin(tag_gpio)
    ,.axi_gpio_0_GPIO2_IO_O_pin(gpio)
    ,.axi_uartlite_0_RX_pin(UART_RX)
    ,.axi_uartlite_0_TX_pin(UART_TX));

`endif

  // fmc

  logic gateway_reset_lo;
  logic done_li;

  logic bcl_valid_lo;
  logic [79:0] bcl_data_lo;
  logic fmc_ready_lo;

  logic fmc_valid_lo;
  logic [79:0] fmc_data_lo;
  logic bcl_ready_lo;

  logic bcl_core_calib_done_lo;

  bsg_gateway_fmc fmc
    (.clk_i(core_clk_lo)
    // fmc reset out
    ,.fmc_reset_o(gateway_reset_lo)
    // host reset in
    ,.host_reset_i(~bcl_core_calib_done_lo)
    // data in
    ,.valid_i(bcl_valid_lo)
    ,.data_i(bcl_data_lo)
    ,.ready_o(fmc_ready_lo)
    // data out
    ,.valid_o(fmc_valid_lo)
    ,.data_o(fmc_data_lo)
    ,.ready_i(bcl_ready_lo)
    // fmc reset in
    ,.F20_P(F20_P) ,.F20_N(F20_N)
    // fmc host reset out
    ,.F23_P(F23_P) ,.F23_N(F23_N)
    // fmc tx clk in
    ,.FCLK0_M2C_P(FCLK0_M2C_P) ,.FCLK0_M2C_N(FCLK0_M2C_N)
`ifdef BSG_ML605_FMC
    // fmc tx clk out
    ,.FCLK1_M2C_P(FCLK1_M2C_P) ,.FCLK1_M2C_N(FCLK1_M2C_N)
    // fmc tx data out [0]
    ,.F0_P(F0_P) ,.F0_N(F0_N)
`else
`ifdef BSG_ZEDBOARD_FMC
    // fmc tx clk out
    ,.F0_P(F0_P) ,.F0_N(F0_N)
    // fmc tx data out [0]
    ,.F1_P(F1_P) ,.F1_N(F1_N)
`endif
`endif
    // fmc tx data out [9:1]
    ,.F16_P(F16_P) ,.F16_N(F16_N)
    ,.F15_P(F15_P) ,.F15_N(F15_N)
    ,.F13_P(F13_P) ,.F13_N(F13_N)
    ,.F11_P(F11_P) ,.F11_N(F11_N)
    ,.F10_P(F10_P) ,.F10_N(F10_N)
    ,.F14_P(F14_P) ,.F14_N(F14_N)
    ,.F9_P(F9_P) ,.F9_N(F9_N)
    ,.F4_P(F4_P) ,.F4_N(F4_N)
    ,.F7_P(F7_P) ,.F7_N(F7_N)
    ,.F8_P(F8_P) ,.F8_N(F8_N)
    // fmc rx clk in
    ,.F17_P(F17_P) ,.F17_N(F17_N)
    // fmc rx data in
    ,.F31_P(F31_P) ,.F31_N(F31_N)
    ,.F33_P(F33_P) ,.F33_N(F33_N)
    ,.F30_P(F30_P) ,.F30_N(F30_N)
    ,.F32_P(F32_P) ,.F32_N(F32_N)
    ,.F28_P(F28_P) ,.F28_N(F28_N)
    ,.F25_P(F25_P) ,.F25_N(F25_N)
    ,.F29_P(F29_P) ,.F29_N(F29_N)
    ,.F26_P(F26_P) ,.F26_N(F26_N)
    ,.F21_P(F21_P) ,.F21_N(F21_N)
    ,.F27_P(F27_P) ,.F27_N(F27_N)
    ,.F22_P(F22_P) ,.F22_N(F22_N));

`ifndef SIMULATION

  // chipscope
/*
  bsg_gateway_chipscope cs
    (.clk_i(core_clk_lo)
    ,.data_i({'0
             ,bcl_core_calib_done_lo
             ,bcl_ready_lo
             ,fmc_valid_lo
             ,fmc_data_lo
             ,fmc_ready_lo
             ,bcl_valid_lo
             ,bcl_data_lo}));
*/
`endif

  // comm link

  logic bcl_slave_reset_lo;

  logic [3:0] io_clk0_li;
  logic [3:0] io_valid_li;
  logic [7:0] io_data_li [3:0];
  logic [3:0] bcl_io_token_lo;
  
  logic [3:0] io_clk_li_serdes;
  logic [3:0] io_valid_0_li_serdes;
  logic [7:0] io_data_0_li_serdes [3:0];
  logic [3:0] io_valid_1_li_serdes;
  logic [7:0] io_data_1_li_serdes [3:0];
  logic [3:0] bcl_io_token_lo_serdes;

  logic [3:0] bcl_im_clk_lo;
  logic [4:0] bcl_im_valid_lo [3:0];
  logic [39:0] bcl_im_data_lo [3:0];
  logic [3:0] token_clk_li;
  
  logic [3:0] bcl_im_clk_lo_serdes;
  logic [3:0] bcl_im_valid_lo_serdes;
  logic [7:0] bcl_im_data_lo_serdes [3:0];
  logic [3:0] token_clk_li_serdes;

  `define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }
  
  
  // Channel select mask
  parameter channel_select = 4'b0001;
  
  
  // SERDES
	bsg_gateway_serdes #
	(.width(5)
	,.tap_array({8'd72, 8'd72, 8'd74, 8'd71}))
	gw_serdes
	(.io_master_clk_i(io_master_clk_lo)
	,.clk_2x_i(clk_2x_lo)
	,.io_serdes_clk_i(io_serdes_clk_lo)
	,.io_strobe_i(io_strobe_lo)
	,.core_calib_done_i(bcl_core_calib_done_lo)

	,.data_output_i(`BSG_SWIZZLE_3120(bcl_im_data_lo))
	,.valid_output_i(`BSG_SWIZZLE_3120(bcl_im_valid_lo))
	,.token_input_o(`BSG_SWIZZLE_3120(token_clk_li))

	,.clk_output_o(bcl_im_clk_lo_serdes)
	,.data_output_o(bcl_im_data_lo_serdes)
	,.valid_output_o(bcl_im_valid_lo_serdes)
	,.token_input_i(token_clk_li_serdes)
	
	,.raw_clk0_i(io_clk0_li)
	,.div_clk_o(io_clk_li_serdes)

	,.data_input_i(io_data_li)
	,.valid_input_i(io_valid_li)
	,.token_output_o(bcl_io_token_lo)

	,.data_input_0_o(io_data_0_li_serdes)
	,.data_input_1_o(io_data_1_li_serdes)
	,.valid_input_0_o(io_valid_0_li_serdes)
	,.valid_input_1_o(io_valid_1_li_serdes)
	,.token_output_i(bcl_io_token_lo_serdes));
	
  // common_link
  bsg_comm_link_serdes #
    (.channel_width_p(8)
    ,.core_channels_p(10)
    ,.link_channels_p(4)
	,.serdes_ratio_p(5)
    ,.master_p(1)
    ,.master_bypass_test_p(5'b11111)
	,.channel_select_p(channel_select))
  bcl
    (.io_master_clk_i(io_master_clk_lo)
	,.core_clk_i(core_clk_lo)
	,.fast_core_clk_i(fast_core_clk_lo)
    ,.async_reset_i(FG_SW5?(~done_li):gateway_reset_lo)
    // core ctrl
    ,.core_calib_done_r_o(bcl_core_calib_done_lo)
    // core in
    ,.core_valid_i(fmc_valid_lo)
    ,.core_data_i(fmc_data_lo)
    ,.core_ready_o(bcl_ready_lo)
    // core out
    ,.core_valid_o(bcl_valid_lo)
    ,.core_data_o(bcl_data_lo)
    ,.core_yumi_i(bcl_valid_lo & fmc_ready_lo)
    // io in
    ,.io_clk_tline_i(io_clk_li_serdes)
    ,.io_valid_0_tline_i(io_valid_0_li_serdes)
    ,.io_data_0_tline_i(io_data_0_li_serdes)
	,.io_valid_1_tline_i(io_valid_1_li_serdes)
    ,.io_data_1_tline_i(io_data_1_li_serdes)
    ,.io_token_clk_tline_o(bcl_io_token_lo_serdes)
    // im out
    ,.im_clk_tline_o(bcl_im_clk_lo)
    ,.im_valid_tline_o(bcl_im_valid_lo)
    ,.im_data_tline_o(bcl_im_data_lo)
    // im slave reset for ASIC
    ,.im_slave_reset_tline_r_o(bcl_slave_reset_lo)
    // token in
    ,.token_clk_tline_i(token_clk_li));

  // io

  // channel in

  assign io_clk0_li = {DOC0, COC0, BOC0, AOC0};

  assign io_valid_li = {1'b0, 1'b0, 1'b0, AOD8};

  assign io_data_li = {{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}
                           ,{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}
                           ,{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}
                           ,{AOD7, AOD6, AOD5, AOD4, AOD3, AOD2, AOD1, AOD0}};

  assign AOT0}= bcl_io_token_lo[0];

  // channel out

  assign AIC0 = bcl_im_clk_lo_serdes[0];

  assign AID8 = bcl_im_valid_lo_serdes[0];

  //assign {DID7, DID6, DID5, DID4, DID3, DID2, DID1, DID0} = bcl_im_data_lo_serdes[3];
  //assign {CID7, CID6, CID5, CID4, CID3, CID2, CID1, CID0} = bcl_im_data_lo_serdes[2];
  //assign {BID7, BID6, BID5, BID4, BID3, BID2, BID1, BID0} = bcl_im_data_lo_serdes[1];
  assign {AID7, AID6, AID5, AID4, AID3, AID2, AID1, AID0} = bcl_im_data_lo_serdes[0];

  assign token_clk_li_serdes = {1'b0, 1'b0, 1'b0,  AIT0};

  // reset for asic
  assign Q7 = bcl_slave_reset_lo;

  // led
  assign FPGA_LED2 = gateway_reset_lo;
  
  
  // Set bsg tag clock test pin output mode
  assign ASIC_CLK_SET_1 = FG_SW7;
  assign ASIC_CLK_SET_0 = FG_SW6;
  assign ASIC_CLK_SMA = ASIC_CLK;
  
  // For testing bsg tag
	logic [5:0] clk_reset_lo;
	logic [1:0] clk_set_lo [5:0];
    
	assign ASIC_CORE_RESET = clk_reset_lo[0];
    assign ASIC_IO_RESET = clk_reset_lo[1];
/*    
	assign {ASIC_CORE_SET_1, ASIC_CORE_SET_0} = clk_set_lo[0];
	assign {ASIC_IO_SET_1, ASIC_IO_SET_0} = clk_set_lo[1];
	assign {ASIC_DFI2X_SET_1, ASIC_DFI2X_SET_0} = clk_set_lo[2];
	assign {ASIC_DRLP_SET_1, ASIC_DRLP_SET_0} = clk_set_lo[3];
	assign {ASIC_FSB_SET_1, ASIC_FSB_SET_0} = clk_set_lo[4];
	assign {ASIC_OP_SET_1, ASIC_OP_SET_0} = clk_set_lo[5];
*/	

	assign {ASIC_CORE_SET_1, ASIC_CORE_SET_0} = 2'b10;
	assign {ASIC_IO_SET_1, ASIC_IO_SET_0} = 2'b10;
	assign {ASIC_DFI2X_SET_1, ASIC_DFI2X_SET_0} = 2'b10;
	assign {ASIC_DRLP_SET_1, ASIC_DRLP_SET_0} = 2'b10;
	assign {ASIC_FSB_SET_1, ASIC_FSB_SET_0} = 2'b10;
	assign {ASIC_OP_SET_1, ASIC_OP_SET_0} = 2'b10;

	logic tag_tdi_lo, tag_tms_lo;
	assign ASIC_TAG_TDI = tag_tdi_lo;
	assign ASIC_TAG_TMS = tag_tms_lo;
	
	logic test_output_lo;
	assign FPGA_LED3 = test_output_lo;
	
	logic fmc_tag_reset_lo = FG_SW5;
  
	bsg_gateway_tag
	#(.ring_width_p(36)
     ,.num_clk_p(6))
    tag_inst
	(.clk_i(mb_clk_lo)
	,.reset_i(1'b1)
	,.done_o(done_li)
	
	,.mb_control_i()
	,.mb_osc_i()
	,.mb_div_i()
	,.mb_isDiv_i()
  
	,.clk_set_o(clk_set_lo)
	,.clk_reset_o(clk_reset_lo)

	,.tag_tdi_o(tag_tdi_lo)
	,.tag_tms_o(tag_tms_lo)
	
	,.test_output(test_output_lo)
	);

endmodule
