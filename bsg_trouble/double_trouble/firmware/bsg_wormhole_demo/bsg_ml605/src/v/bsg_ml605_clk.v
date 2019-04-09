module bsg_ml605_clk
  (input clk_200_mhz_p_i, clk_200_mhz_n_i
  ,output clk_50_mhz_o
  ,output clk_200_mhz_o
  ,output locked_o);

  wire ibufgds_200_mhz;

  // 200 Mhz ml605 osc board
  IBUFGDS #
    (.DIFF_TERM("TRUE")
    ,.IOSTANDARD("LVDS_25"))
  ibufgds_inst
    (.I(clk_200_mhz_p_i) ,.IB(clk_200_mhz_n_i)
    ,.O(ibufgds_200_mhz));

  wire mmcm_fb, bufg_fb;
  wire mmcm_50_mhz, bufg_50_mhz;
  wire mmcm_200_mhz, bufg_200_mhz;

  MMCM_ADV #
    (.BANDWIDTH("OPTIMIZED")
    ,.CLKFBOUT_MULT_F(6)
    ,.CLKFBOUT_PHASE(0.0)
    ,.CLKFBOUT_USE_FINE_PS("FALSE")
    ,.CLKIN1_PERIOD(5)
    ,.CLKIN2_PERIOD(0.0)
    ,.CLKOUT0_DIVIDE_F(6) // 200 MHz
    ,.CLKOUT0_DUTY_CYCLE(0.5)
    ,.CLKOUT0_PHASE(0.0)
    ,.CLKOUT0_USE_FINE_PS("FALSE")
    ,.CLKOUT1_DIVIDE(24) // 50 MHz
    ,.CLKOUT1_DUTY_CYCLE(0.5)
    ,.CLKOUT1_PHASE(0.0)
    ,.CLKOUT1_USE_FINE_PS("FALSE")
    ,.CLKOUT2_DIVIDE(24) // 50 MHz
    ,.CLKOUT2_DUTY_CYCLE(0.5)
    ,.CLKOUT2_PHASE(0.0)
    ,.CLKOUT2_USE_FINE_PS("FALSE")
    ,.CLKOUT3_DIVIDE(120) // 10 MHz
    ,.CLKOUT3_DUTY_CYCLE(0.5)
    ,.CLKOUT3_PHASE(0.0)
    ,.CLKOUT3_USE_FINE_PS("FALSE")
    ,.CLKOUT4_CASCADE("FALSE")
    ,.CLKOUT4_DIVIDE(1)
    ,.CLKOUT4_DUTY_CYCLE(0.5)
    ,.CLKOUT4_PHASE(0.0)
    ,.CLKOUT4_USE_FINE_PS("FALSE")
    ,.CLKOUT5_DIVIDE(1)
    ,.CLKOUT5_DUTY_CYCLE(0.5)
    ,.CLKOUT5_PHASE(0.0)
    ,.CLKOUT5_USE_FINE_PS("FALSE")
    ,.CLKOUT6_DIVIDE(1)
    ,.CLKOUT6_DUTY_CYCLE(0.5)
    ,.CLKOUT6_PHASE(0.0)
    ,.CLKOUT6_USE_FINE_PS("FALSE")
    ,.CLOCK_HOLD("FALSE")
    ,.COMPENSATION("ZHOLD")
    ,.DIVCLK_DIVIDE(1)
    ,.REF_JITTER1(0.0)
    ,.REF_JITTER2(0.0)
    ,.STARTUP_WAIT("FALSE"))
  mmcm_adv_inst
    (.CLKFBOUT(mmcm_fb)
    ,.CLKFBOUTB()
    ,.CLKFBSTOPPED()
    ,.CLKINSTOPPED()
    ,.CLKOUT0(mmcm_200_mhz)
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
    ,.LOCKED(locked_o)
    ,.PSDONE()
    ,.CLKFBIN(bufg_fb)
    ,.CLKIN1(ibufgds_200_mhz)
    ,.CLKIN2()
    ,.CLKINSEL(1'b1)
    ,.DADDR(7'd0)
    ,.DCLK(1'b0)
    ,.DEN(1'b0)
    ,.DI(16'd0)
    ,.DWE(1'b0)
    ,.PSCLK(1'b0)
    ,.PSEN(1'b0)
    ,.PSINCDEC(1'b0)
    ,.PWRDWN(1'b0)
    ,.RST(1'b0));

  BUFG bfb
    (.I(mmcm_fb)
    ,.O(bufg_fb));

  BUFG b50
    (.I(mmcm_50_mhz)
    ,.O(bufg_50_mhz));

  BUFG b200
    (.I(mmcm_200_mhz)
    ,.O(bufg_200_mhz));

  assign clk_50_mhz_o = bufg_50_mhz;
  assign clk_200_mhz_o = bufg_200_mhz;

endmodule
