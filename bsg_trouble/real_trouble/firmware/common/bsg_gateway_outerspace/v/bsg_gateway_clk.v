//------------------------------------------------------------
// File: bsg_gateway_clk.v
//
// - PLL_ADV generates the following clocks:
//     * ext_core_clk_o
//     * int_core_clk_o
//     * mb_clk_o
//
// - DCM_CLKGEN generates the following clocks:
//     * ext_io_master_clk_o
//     * int_io_master_clk_o
//
// - Both PLL_ADV and DCM_CLKGEN uses the 150MHz clock coming
//   from the oscillator in doubletrouble.
//
// - Check pll_*_lp and dcm_*_lp local parameters for tweaking
//   clocks
//------------------------------------------------------------

module bsg_gateway_clk
  (input clk_150_mhz_p_i, clk_150_mhz_n_i
  // microblaze clock
  ,output mb_clk_o
  ,output tag_tck_o
  // internal clocks
  ,output int_core_clk_o
  ,output int_fast_core_clk_o
  ,output int_io_master_clk_o
  ,output int_io_2x_clk_o
  // serdes clk
  ,output [3:0] io_serdes_clk_o
  ,output [3:0] io_strobe_o
  // external clk
  ,output ext_core_clk_o
  ,output ext_io_clk_o
  ,output ext_fsb_clk_o
  ,output ext_op_clk_o
  // locked
  ,output locked_o);

  wire ibufgds_clk_150_mhz_lo;

  IBUFGDS #
    (.DIFF_TERM("TRUE"))
  ibufgds
    (.I(clk_150_mhz_p_i) ,.IB(clk_150_mhz_n_i)
    ,.O(ibufgds_clk_150_mhz_lo));

  // 150Mhz * pll_mult_lp
  // if pll_mult_lp=7 then pll-internal-clock is 1050MHz
  localparam pll_mult_lp = 7;

  // For IO Clock

  // 150MHz * (dcm_mult_lp/dcm_io_master_clk_divide_lp)
  // if dcm_mult_lp=7 and dcm_io_master_clk_divide_lp=9,
  // then (int/ext) io_master_clk_o are 66.67MHz
  localparam pll_core_clk_divide_lp = 7;
  localparam pll_fast_core_clk_divide_lp = 5;
  localparam pll_io_master_clk_1x_divide_lp = 10;
  localparam pll_io_master_clk_2x_divide_lp = 5;
  localparam pll_io_serdes_clk_divide_lp = 1;

  wire pll_ext_core_clk_0_deg_lo;
  wire pll_fast_core_clk_lo;
  wire pll_io_serdes_clk_lo;
  wire pll_io_master_clk_1x_lo;
  wire pll_io_master_clk_2x_lo;
  wire pll_locked_lo;
  wire pll_fb_lo;

  PLL_ADV #
    (.BANDWIDTH("OPTIMIZED")
    ,.CLKFBOUT_MULT(pll_mult_lp)
    ,.CLKFBOUT_PHASE(0.0)
    ,.CLKIN1_PERIOD(6.667)
    ,.CLKIN2_PERIOD(6.667)
    // ext core clk
    ,.CLKOUT0_DIVIDE(pll_io_serdes_clk_divide_lp)
    ,.CLKOUT0_DUTY_CYCLE(0.5)
    ,.CLKOUT0_PHASE(0.0)
    ,.CLKOUT1_DIVIDE(pll_io_master_clk_1x_divide_lp)
    ,.CLKOUT1_DUTY_CYCLE(0.5)
    ,.CLKOUT1_PHASE(0.0)
    // int core clk
    ,.CLKOUT2_DIVIDE()
    ,.CLKOUT2_DUTY_CYCLE(0.5)
    ,.CLKOUT2_PHASE(0.0)
    // mb clk
    ,.CLKOUT3_DIVIDE(pll_io_master_clk_2x_divide_lp)
    ,.CLKOUT3_DUTY_CYCLE(0.5)
    ,.CLKOUT3_PHASE(0.0)
    // io clk
    ,.CLKOUT4_DIVIDE(pll_core_clk_divide_lp)
    ,.CLKOUT4_DUTY_CYCLE(0.5)
    ,.CLKOUT4_PHASE(0.0)
    ,.CLKOUT5_DIVIDE(pll_fast_core_clk_divide_lp)
    ,.CLKOUT5_DUTY_CYCLE(0.5)
    ,.CLKOUT5_PHASE(0.0)
    ,.COMPENSATION("INTERNAL")
    ,.DIVCLK_DIVIDE(1)
    ,.REF_JITTER(0.100)
    ,.SIM_DEVICE("SPARTAN6"))
  pll
    (.CLKFBDCM()
    ,.CLKFBOUT(pll_fb_lo)
    // io clk
    ,.CLKOUT0(pll_io_serdes_clk_lo)
    ,.CLKOUT1(pll_io_master_clk_1x_lo)
    ,.CLKOUT2()
    // mb clk
    ,.CLKOUT3(pll_io_master_clk_2x_lo)
	// co clk
    ,.CLKOUT4(pll_ext_core_clk_0_deg_lo)
    ,.CLKOUT5(pll_fast_core_clk_lo)
    ,.CLKOUTDCM0()
    ,.CLKOUTDCM1()
    ,.CLKOUTDCM2()
    ,.CLKOUTDCM3()
    ,.CLKOUTDCM4()
    ,.CLKOUTDCM5()
    ,.DO()
    ,.DRDY()
    ,.LOCKED(pll_locked_lo)
    ,.CLKFBIN(pll_fb_lo)
    ,.CLKIN1(ibufgds_clk_150_mhz_lo)
    ,.CLKIN2(1'b0)
    ,.CLKINSEL(1'b1)
    ,.DADDR(5'b00000)
    ,.DCLK(1'b0)
    ,.DEN(1'b0)
    ,.DI(16'h0000)
    ,.DWE(1'b0)
    ,.RST(1'b0)
    ,.REL(1'b0));

  // ext io master clock
  wire bufg_io_master_clk_1x_lo;

  BUFG bufg_io_master_clk_1x
    (.I(pll_io_master_clk_1x_lo)
    ,.O(bufg_io_master_clk_1x_lo));
	
  wire bufg_io_master_clk_2x_lo;

  BUFG bufg_io_master_clk_2x
    (.I(pll_io_master_clk_2x_lo)
    ,.O(bufg_io_master_clk_2x_lo));

  // int io master clock
  assign int_io_master_clk_o = bufg_io_master_clk_1x_lo;
  assign int_io_2x_clk_o = bufg_io_master_clk_2x_lo;
  
  
  //ext core clk
  wire bufg_ext_core_clk_0_deg_lo;

  BUFG bufg_ext_core_clk_0_deg
    (.I(pll_ext_core_clk_0_deg_lo)
    ,.O(bufg_ext_core_clk_0_deg_lo));
	
  wire bufg_fast_core_clk_lo;

  BUFG bufg_fast_core_clk
    (.I(pll_fast_core_clk_lo)
    ,.O(bufg_fast_core_clk_lo));

  // int core clock
  assign int_core_clk_o = bufg_ext_core_clk_0_deg_lo;
  assign int_fast_core_clk_o = bufg_fast_core_clk_lo;
  
  // generate serdes clk and strobe
  logic [3:0] bufpll_io_serdes_clk_lo;
  logic [3:0] bufpll_io_strobe_lo;
	
  genvar i;
  for (i=0; i<4; i++) begin
	  BUFPLL #(
		.DIVIDE(5),
		.ENABLE_SYNC("TRUE")
	  ) bufpll_io_serdes_clk (
		.IOCLK(bufpll_io_serdes_clk_lo[i]),
		.LOCK(),
		.SERDESSTROBE(bufpll_io_strobe_lo[i]),
		.GCLK(bufg_io_master_clk_2x_lo),
		.LOCKED(pll_locked_lo),
		.PLLIN(pll_io_serdes_clk_lo)
	  );
  end
  
  assign io_serdes_clk_o = bufpll_io_serdes_clk_lo;
  assign io_strobe_o = bufpll_io_strobe_lo;

  // Generation of tag/mb clock
  
  localparam dcm_mult_lp = 4;
  localparam dcm_mb_clk_divide_lp = 12;

  logic dcm_mb_clk_0_deg_lo;
  logic dcm_mb_clk_180_deg_lo;
  logic dcm_locked_lo;  
  
  DCM_CLKGEN #
    (.CLKFX_MULTIPLY(dcm_mult_lp)
    ,.CLKFX_DIVIDE(dcm_mb_clk_divide_lp)
    ,.SPREAD_SPECTRUM("NONE")
    ,.STARTUP_WAIT("FALSE")
    ,.CLKIN_PERIOD(6.667))
  dcm
    (.CLKIN(ibufgds_clk_150_mhz_lo)
    ,.RST(1'b0)
    ,.FREEZEDCM(1'b0)
    // output
    ,.CLKFX(dcm_mb_clk_0_deg_lo)
    ,.CLKFX180(dcm_mb_clk_180_deg_lo)
    ,.LOCKED(dcm_locked_lo)
    ,.CLKFXDV()
    ,.PROGDONE()
    ,.STATUS()
    // inputs
    ,.PROGDATA()
    ,.PROGEN()
    ,.PROGCLK());

  // external tag clock
  wire bufg_mb_clk_0_deg_lo;

  BUFG bufg_mb_clk_0_deg
    (.I(dcm_mb_clk_0_deg_lo)
    ,.O(bufg_mb_clk_0_deg_lo));

  ODDR2 oddr_mb_clk
    (.D0(1'b0)
    ,.D1(1'b1)
    ,.C0(bufg_mb_clk_0_deg_lo)
    ,.C1(~bufg_mb_clk_0_deg_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(tag_tck_o));

  // int mb clock
  assign mb_clk_o = bufg_mb_clk_0_deg_lo;  
  
  ODDR2 oddr_ext_core_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_fast_core_clk_lo)
    ,.C1(~bufg_fast_core_clk_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_core_clk_o));

  ODDR2 oddr_ext_io_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_fast_core_clk_lo)
    ,.C1(~bufg_fast_core_clk_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_io_clk_o));
    
  ODDR2 oddr_ext_fsb_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_fast_core_clk_lo)
    ,.C1(~bufg_fast_core_clk_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_fsb_clk_o));
    
  ODDR2 oddr_ext_op_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_fast_core_clk_lo)
    ,.C1(~bufg_fast_core_clk_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_op_clk_o));
   
  
  assign locked_o = pll_locked_lo & dcm_locked_lo;

endmodule
