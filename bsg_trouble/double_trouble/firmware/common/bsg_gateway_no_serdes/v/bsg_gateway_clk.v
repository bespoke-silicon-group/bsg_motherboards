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
  // internal clocks
  ,output int_core_clk_o
  ,output int_io_master_clk_o
  // external clocks
  ,output ext_core_clk_o
  ,output ext_io_master_clk_o
  ,output ext_lecroy_clk_o
  // serdes clk
  ,output io_master_5x_clk_o
  ,output io_master_strobe_o
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
  localparam pll_mult_lp = 4;

  // 150MHz * (pll_mult_lp/pll_core_clk_divide_lp)
  // if pll_mult_lp=7 and pll_core_clk_divide_lp=42,
  // then (int/ext) core_clk_o are 50MHz
  localparam pll_core_clk_divide_lp = 6;

  // 150Mhz*(pll_mult_lp/pll_mb_clk_divide_lp)
  // if pll_mult_lp=7 and pll_mb_clk_divide_lp=42,
  // then mb_clk_o is 25MHz
  localparam pll_mb_clk_divide_lp = 12;

  wire pll_ext_core_clk_0_deg_lo;
  wire pll_ext_core_clk_180_deg_lo;
  wire pll_mb_clk_lo;


  // For IO Clock

  // 150MHz * (dcm_mult_lp/dcm_io_master_clk_divide_lp)
  // if dcm_mult_lp=7 and dcm_io_master_clk_divide_lp=9,
  // then (int/ext) io_master_clk_o are 66.67MHz
  // if dcm_io_master_clk_divide_lp = 3 (int/ext) io_master_clk are 200 mhz
  // if dcm_io_master_clk_divide_lp = 4 (int/ext) io_master_clk are 150 mhz
  // if dcm_io_master_clk_divide_lp = 6 (int/ext) io_master_clk are 100 mhz
  // if dcm_io_master_clk_divide_lp = 8 (int/ext) io_master_clk are 75 mhz
  localparam pll_io_master_clk_5x_divide_lp = 1;
  localparam pll_io_master_clk_1x_divide_lp = 3;

  wire pll_io_master_clk_5x_lo;
  wire pll_io_master_clk_1x_lo;
  wire pll_io_master_clk_1x_180_lo;
  wire pll_locked_lo;
  wire pll_fb_lo;

  PLL_ADV #
    (.BANDWIDTH("OPTIMIZED")
    ,.CLKFBOUT_MULT(pll_mult_lp)
    ,.CLKFBOUT_PHASE(0.0)
    ,.CLKIN1_PERIOD(6.667)
    ,.CLKIN2_PERIOD(6.667)
    // ext core clk
    ,.CLKOUT0_DIVIDE(pll_io_master_clk_5x_divide_lp)
    ,.CLKOUT0_DUTY_CYCLE(0.5)
    ,.CLKOUT0_PHASE(0.0)
    ,.CLKOUT1_DIVIDE(pll_io_master_clk_1x_divide_lp)
    ,.CLKOUT1_DUTY_CYCLE(0.5)
    ,.CLKOUT1_PHASE(0.0)
    // int core clk
    ,.CLKOUT2_DIVIDE(pll_io_master_clk_1x_divide_lp)
    ,.CLKOUT2_DUTY_CYCLE(0.5)
    ,.CLKOUT2_PHASE(180.0)
    // mb clk
    ,.CLKOUT3_DIVIDE(pll_mb_clk_divide_lp)
    ,.CLKOUT3_DUTY_CYCLE(0.5)
    ,.CLKOUT3_PHASE(0.0)
    // io clk
    ,.CLKOUT4_DIVIDE(pll_core_clk_divide_lp)
    ,.CLKOUT4_DUTY_CYCLE(0.5)
    ,.CLKOUT4_PHASE(0.0)
    ,.CLKOUT5_DIVIDE(pll_core_clk_divide_lp)
    ,.CLKOUT5_DUTY_CYCLE(0.5)
    ,.CLKOUT5_PHASE(180.0)
    ,.COMPENSATION("INTERNAL")
    ,.DIVCLK_DIVIDE(1)
    ,.REF_JITTER(0.100)
    ,.SIM_DEVICE("SPARTAN6"))
  pll
    (.CLKFBDCM()
    ,.CLKFBOUT(pll_fb_lo)
    // io clk
    ,.CLKOUT0(pll_io_master_clk_5x_lo)
    ,.CLKOUT1(pll_io_master_clk_1x_lo)
    ,.CLKOUT2(pll_io_master_clk_1x_180_lo)
    // mb clk
    ,.CLKOUT3(pll_mb_clk_lo)
	// co clk
    ,.CLKOUT4(pll_ext_core_clk_0_deg_lo)
    ,.CLKOUT5(pll_ext_core_clk_180_deg_lo)
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

  wire bufg_io_master_clk_1x_180_lo;

  BUFG bufg_io_master_clk_1x_180
    (.I(pll_io_master_clk_1x_180_lo)
    ,.O(bufg_io_master_clk_1x_180_lo));

  ODDR2 oddr_ext_io_master_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_io_master_clk_1x_lo)
    ,.C1(bufg_io_master_clk_1x_180_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_io_master_clk_o));

  ODDR2 oddr_ext_lecroy_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_io_master_clk_1x_lo)
    ,.C1(bufg_io_master_clk_1x_180_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_lecroy_clk_o));

  // int io master clock
  assign int_io_master_clk_o = bufg_io_master_clk_1x_lo;

  // generate serdes clk and strobe
  wire bufpll_io_master_clk_5x_lo;
  wire bufpll_io_master_clk_strobe_lo;

  BUFPLL #(
    .DIVIDE(5),
    .ENABLE_SYNC("TRUE")
  ) bufpll_io_master_clk (
    .IOCLK(bufpll_io_master_clk_5x_lo),
    .LOCK(),
    .SERDESSTROBE(bufpll_io_master_clk_strobe_lo),
    .GCLK(bufg_io_master_clk_1x_lo),
    .LOCKED(pll_locked_lo),
    .PLLIN(pll_io_master_clk_5x_lo)
  );

  assign io_master_5x_clk_o = bufpll_io_master_clk_5x_lo;
  assign io_master_strobe_o = bufpll_io_master_clk_strobe_lo;

  //ext core clk
  wire bufg_ext_core_clk_0_deg_lo;

  BUFG bufg_ext_core_clk_0_deg
    (.I(pll_ext_core_clk_0_deg_lo)
    ,.O(bufg_ext_core_clk_0_deg_lo));

  wire bufg_ext_core_clk_180_deg_lo;

  BUFG bufg_ext_core_clk_180_deg
    (.I(pll_ext_core_clk_180_deg_lo)
    ,.O(bufg_ext_core_clk_180_deg_lo));

  ODDR2 oddr_ext_core_clk
    (.D0(1'b1)
    ,.D1(1'b0)
    ,.C0(bufg_ext_core_clk_0_deg_lo)
    ,.C1(bufg_ext_core_clk_180_deg_lo)
    ,.CE(1'b1)
    ,.S(1'b0)
    ,.R(1'b0)
    ,.Q(ext_core_clk_o));

  // int core clock
  assign int_core_clk_o = bufg_ext_core_clk_0_deg_lo;

  // mb clock
  BUFG bufg_mb_clk
    (.I(pll_mb_clk_lo)
    ,.O(mb_clk_o));

  assign locked_o = pll_locked_lo;

endmodule
