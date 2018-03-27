module bsg_asic
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

  wire core_clk_lo, io_clk_lo;

  bsg_asic_clk clk
    (.core_clk_i(MSTR_SDO_CLK)
    ,.io_clk_i(PLL_CLK_I)
    ,.core_clk_o(core_clk_lo)
    ,.io_clk_o(io_clk_lo));

  // reset

  wire reset_lo;

  assign reset_lo = AID10;

  // io

  wire [3:0] io_clk_li;
  wire [3:0] io_valid_li;
  wire [7:0] io_data_li [3:0];
  wire [3:0] io_token_lo;

  wire [3:0] im_clk_lo;
  wire [3:0] im_valid_lo;
  wire [7:0] im_data_lo [3:0];
  wire [3:0] token_clk_li;

  wire [3:0] im_clk_lo_delayed;
  wire [3:0] im_valid_lo_delayed;
  wire [7:0] im_data_lo_delayed [3:0];

  // channel in

  assign io_clk_li = {DIC0, CIC0, BIC0, AIC0};

  assign io_valid_li = {DID8, CID8, BID8, AID8};

  assign io_data_li = {{DID7, DID6, DID5, DID4, DID3, DID2, DID1, DID0}
                      ,{CID7, CID6, CID5, CID4, CID3, CID2, CID1, CID0}
                      ,{BID7, BID6, BID5, BID4, BID3, BID2, BID1, BID0}
                      ,{AID7, AID6, AID5, AID4, AID3, AID2, AID1, AID0}};

  assign {DIT0, CIT0, BIT0, AIT0} = io_token_lo;

  // channel out

  assign {DOC0, COC0, BOC0, AOC0} = im_clk_lo_delayed;

  assign {DOD8, COD8, BOD8, AOD8} = im_valid_lo_delayed;

  assign {DOD7, DOD6, DOD5, DOD4, DOD3, DOD2, DOD1, DOD0} = im_data_lo_delayed[3];
  assign {COD7, COD6, COD5, COD4, COD3, COD2, COD1, COD0} = im_data_lo_delayed[2];
  assign {BOD7, BOD6, BOD5, BOD4, BOD3, BOD2, BOD1, BOD0} = im_data_lo_delayed[1];
  assign {AOD7, AOD6, AOD5, AOD4, AOD3, AOD2, AOD1, AOD0} = im_data_lo_delayed[0];

  assign token_clk_li = {DOT0, COT0, BOT0, AOT0};


  // IODELAY
  bsg_asic_iodelay delay (
     .clk_output_i(im_clk_lo)
    ,.data_a_output_i(im_data_lo[0])
	,.data_b_output_i(im_data_lo[1])
	,.data_c_output_i(im_data_lo[2])
	,.data_d_output_i(im_data_lo[3])
    ,.valid_output_i(im_valid_lo)
    ,.clk_output_o(im_clk_lo_delayed)
    ,.data_a_output_o(im_data_lo_delayed[0])
	,.data_b_output_o(im_data_lo_delayed[1])
	,.data_c_output_o(im_data_lo_delayed[2])
	,.data_d_output_o(im_data_lo_delayed[3])
    ,.valid_output_o(im_valid_lo_delayed)
  );

  // ASIC

  `define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }

   bsg_chip ASIC
     (
	  .p_clk_0_p_i()   // unused
     ,.p_clk_0_n_i()   // unused
     ,.p_clk_1_p_i()   // unused
     ,.p_clk_1_n_i()   // unused

     ,.p_SMA_in_p_i()  // unused
     ,.p_SMA_in_n_i()  // unused
     ,.p_SMA_out_p_o() // unused
     ,.p_SMA_out_n_o() // unused

	 ,.p_PLL_CLK_i(io_clk_lo)

     ,.p_sdi_sclk_i(`BSG_SWIZZLE_3120(io_clk_li))
     ,.p_sdi_ncmd_i(`BSG_SWIZZLE_3120(io_valid_li))
     // swizzled b and c
     ,.p_sdi_A_data_i(io_data_li[0])
     ,.p_sdi_B_data_i(io_data_li[2])
     ,.p_sdi_C_data_i(io_data_li[1])
     ,.p_sdi_D_data_i(io_data_li[3])

     ,.p_sdi_token_o(`BSG_SWIZZLE_3120(io_token_lo))

	 ,.p_sdo_sclk_o(im_clk_lo)
     ,.p_sdo_ncmd_o(im_valid_lo)
     ,.p_sdo_A_data_o(im_data_lo[0])
     ,.p_sdo_B_data_o(im_data_lo[1])
     ,.p_sdo_C_data_o(im_data_lo[2])
     ,.p_sdo_D_data_o(im_data_lo[3])

     ,.p_sdo_A_data_8_o() // unused
     ,.p_sdo_C_data_8_o() // unused

     ,.p_sdo_token_i(token_clk_li)

     ,.p_sdi_sclk_ex_i() // unused
     ,.p_sdo_sclk_ex_o() // unused

     ,.p_sdi_tkn_ex_o() // unused
     ,.p_sdo_tkn_ex_i() // unused

     ,.p_misc_T_0_i()     // unused
     ,.p_misc_T_1_i()     // unused
     ,.p_misc_T_2_i()     // unused

     //,.p_misc_L_i({4'd0, core_clk_lo, 3'd0})
     //,.p_misc_R_i() // unused
	 ,.p_misc_L_7_i()
	 ,.p_misc_L_6_i()
	 ,.p_misc_L_5_i()
	 ,.p_misc_L_4_i(core_clk_lo)
	 ,.p_misc_L_3_o()
	 ,.p_misc_L_2_i()
	 ,.p_misc_L_1_i()
	 ,.p_misc_L_0_i()

	 ,.p_misc_R_7_i()
	 ,.p_misc_R_6_i()
	 ,.p_misc_R_5_i()
	 ,.p_misc_R_4_i()
	 ,.p_misc_R_3_o()
	 ,.p_misc_R_2_i()
	 ,.p_misc_R_1_i()
	 ,.p_misc_R_0_i()

     ,.p_reset_i(reset_lo)

     ,.p_JTAG_TMS_i()  // unused
     ,.p_JTAG_TDI_i()  // unused
     ,.p_JTAG_TCK_i()  // unused
     ,.p_JTAG_TRST_i() // unused
     ,.p_JTAG_TDO_o()  // unused
	);

  // led

  assign ASIC_LED0 = ~reset_lo;
  assign ASIC_LED1 = ~reset_lo;

endmodule
