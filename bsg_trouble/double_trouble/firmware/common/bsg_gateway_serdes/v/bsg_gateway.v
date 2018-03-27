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
  
  // jumper switch
  ,input FG_SW0, FG_SW1, FG_SW2, FG_SW3
  ,input FG_SW4, FG_SW5, FG_SW6, FG_SW7

  // -------- ASIC --------

  // clk
  ,output MSTR_SDO_CLK
  ,output PLL_CLK_I

  // asic reset
  ,output Q7

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
    // internal clocks
    ,.int_core_clk_o(core_clk_lo)
	,.int_fast_core_clk_o(fast_core_clk_lo)
    ,.int_io_master_clk_o(io_master_clk_lo)
	,.int_io_2x_clk_o(clk_2x_lo)
    // external clocks
    ,.ext_core_clk_o(MSTR_SDO_CLK)
    ,.ext_io_master_clk_o(PLL_CLK_I)
	// serdes clk
	,.io_serdes_clk_o(io_serdes_clk_lo)
	,.io_strobe_o(io_strobe_lo)
    // locked
    ,.locked_o(locked_lo));
	

`ifndef SIMULATION

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
    CUR_MON_ADDR0 = 1'b1;
    CUR_MON_ADDR1 = 1'b1;
    ASIC_IO_EN = 1'b1;
    ASIC_CORE_EN = 1'b1;
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
    ,.axi_iic_cur_mon_Gpo_pin()
    ,.axi_iic_cur_mon_Sda_pin(CUR_MON_SDA)
    ,.axi_iic_cur_mon_Scl_pin(CUR_MON_SCL)
    ,.axi_gpio_0_GPIO_IO_O_pin(gpio)
    ,.axi_gpio_0_GPIO2_IO_I_pin()
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
  parameter channel_select = 4'b1111;
  
  
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

  assign io_valid_li = {DOD8, COD8, BOD8, AOD8};

  assign io_data_li = {{DOD7, DOD6, DOD5, DOD4, DOD3, DOD2, DOD1, DOD0}
                           ,{COD7, COD6, COD5, COD4, COD3, COD2, COD1, COD0}
                           ,{BOD7, BOD6, BOD5, BOD4, BOD3, BOD2, BOD1, BOD0}
                           ,{AOD7, AOD6, AOD5, AOD4, AOD3, AOD2, AOD1, AOD0}};

  assign {DOT0, COT0, BOT0, AOT0} = bcl_io_token_lo;

  // channel out

  assign {DIC0, CIC0, BIC0, AIC0} = bcl_im_clk_lo_serdes;

  assign {DID8, CID8, BID8, AID8} = bcl_im_valid_lo_serdes;

  assign {DID7, DID6, DID5, DID4, DID3, DID2, DID1, DID0} = bcl_im_data_lo_serdes[3];
  assign {CID7, CID6, CID5, CID4, CID3, CID2, CID1, CID0} = bcl_im_data_lo_serdes[2];
  assign {BID7, BID6, BID5, BID4, BID3, BID2, BID1, BID0} = bcl_im_data_lo_serdes[1];
  assign {AID7, AID6, AID5, AID4, AID3, AID2, AID1, AID0} = bcl_im_data_lo_serdes[0];

  assign token_clk_li_serdes = {DIT0, CIT0, BIT0, AIT0};

  // reset for asic
  assign Q7 = bcl_slave_reset_lo;

  // led
  assign FPGA_LED2 = gateway_reset_lo;
  assign FPGA_LED3 = bcl_core_calib_done_lo;  

endmodule
