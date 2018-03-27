module bsg_asic_clk
  (input core_clk_i
  ,input io_clk_i
  ,output core_clk_o
  ,output io_clk_o);

  BUFIO2 #
    (.DIVIDE(1)
    ,.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("TRUE")
    ,.USE_DOUBLER("FALSE"))
  bufio2_core_clk
    (.I(core_clk_i)
    ,.DIVCLK(core_clk_o)
    ,.IOCLK()
    ,.SERDESSTROBE());

  BUFIO2 #
    (.DIVIDE(1)
    ,.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("TRUE")
    ,.USE_DOUBLER("FALSE"))
  bufio2_io_clk
    (.I(io_clk_i)
    ,.DIVCLK(io_clk_o)
    ,.IOCLK()
    ,.SERDESSTROBE());

endmodule
