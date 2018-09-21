module bsg_zedboard_clk
  (input clk_100_mhz_i
  ,output clk_50_mhz_o
  ,output clk_200_mhz_o
  ,output locked_o);

  logic mmcm_fb, bufg_fb;
  logic mmcm_50_mhz, bufg_50_mhz;
  logic mmcm_200_mhz, bufg_200_mhz;

  MMCME2_ADV #
    (.BANDWIDTH("OPTIMIZED")
    ,.CLKFBOUT_MULT_F(10)
    ,.CLKFBOUT_PHASE(0.0)
    ,.CLKIN1_PERIOD(10)
    ,.CLKIN2_PERIOD(0.0)
    ,.CLKOUT0_DIVIDE_F(5) // 200 MHz
    ,.CLKOUT1_DIVIDE(20) // 50 MHz
    ,.CLKOUT2_DIVIDE(1)
    ,.CLKOUT3_DIVIDE(1)
    ,.CLKOUT4_DIVIDE(1)
    ,.CLKOUT5_DIVIDE(1)
    ,.CLKOUT6_DIVIDE(1)
    ,.CLKOUT0_DUTY_CYCLE(0.5)
    ,.CLKOUT1_DUTY_CYCLE(0.5)
    ,.CLKOUT2_DUTY_CYCLE(0.5)
    ,.CLKOUT3_DUTY_CYCLE(0.5)
    ,.CLKOUT4_DUTY_CYCLE(0.5)
    ,.CLKOUT5_DUTY_CYCLE(0.5)
    ,.CLKOUT6_DUTY_CYCLE(0.5)
    ,.CLKOUT0_PHASE(0.0)
    ,.CLKOUT1_PHASE(0.0)
    ,.CLKOUT2_PHASE(0.0)
    ,.CLKOUT3_PHASE(0.0)
    ,.CLKOUT4_PHASE(0.0)
    ,.CLKOUT5_PHASE(0.0)
    ,.CLKOUT6_PHASE(0.0)
    ,.CLKOUT4_CASCADE("FALSE")
    ,.COMPENSATION("ZHOLD")
    ,.DIVCLK_DIVIDE(1)
    ,.REF_JITTER1(0.0)
    ,.REF_JITTER2(0.0)
    ,.STARTUP_WAIT("FALSE")
    ,.SS_EN("FALSE")
    ,.SS_MODE("CENTER_HIGH")
    ,.SS_MOD_PERIOD(10000)
    ,.CLKFBOUT_USE_FINE_PS("FALSE")
    ,.CLKOUT0_USE_FINE_PS("FALSE")
    ,.CLKOUT1_USE_FINE_PS("FALSE")
    ,.CLKOUT2_USE_FINE_PS("FALSE")
    ,.CLKOUT3_USE_FINE_PS("FALSE")
    ,.CLKOUT4_USE_FINE_PS("FALSE")
    ,.CLKOUT5_USE_FINE_PS("FALSE")
    ,.CLKOUT6_USE_FINE_PS("FALSE"))
  mmcme2_adv_inst
    (.CLKOUT0(mmcm_200_mhz)
    ,.CLKOUT0B()
    ,.CLKOUT1(mmcm_50_mhz)
    ,.CLKOUT1B()
    ,.CLKOUT2()
    ,.CLKOUT2B()
    ,.CLKOUT3()
    ,.CLKOUT3B()
    ,.CLKOUT4()
    ,.CLKOUT5()
    ,.CLKOUT6()
    ,.DO()
    ,.DRDY()
    ,.PSDONE()
    ,.DADDR(7'd0)
    ,.DCLK(1'b0)
    ,.DEN(1'b0)
    ,.DI(16'd0)
    ,.DWE(1'b0)
    ,.CLKFBOUT(mmcm_fb)
    ,.CLKFBOUTB()
    ,.CLKFBSTOPPED()
    ,.CLKINSTOPPED()
    ,.LOCKED(locked_o)
    ,.CLKIN1(clk_100_mhz_i)
    ,.CLKIN2(1'b0)
    ,.CLKINSEL(1'b1)
    ,.PWRDWN(1'b0)
    ,.RST(1'b0)
    ,.PSCLK(1'b0)
    ,.PSEN(1'b0)
    ,.PSINCDEC(1'b0)
    ,.CLKFBIN(bufg_fb));

  BUFG bufg_fb_inst
    (.I(mmcm_fb)
    ,.O(bufg_fb));

  BUFG bufg_50_mhz_inst
    (.I(mmcm_50_mhz)
    ,.O(clk_50_mhz_o));

  BUFG bufg_200_mhz_inst
    (.I(mmcm_200_mhz)
    ,.O(clk_200_mhz_o));

endmodule
