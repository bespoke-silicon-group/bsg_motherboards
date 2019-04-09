module bsg_asic_clk
  (input core_clk_i
  ,input io_clk_i
  ,output core_clk_o
  ,output io_clk_o);
  
  logic core_clk_lo;
  logic io_clk_lo;

  BUFIO2 #
    (.DIVIDE(1)
    ,.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("FALSE")
    ,.USE_DOUBLER("FALSE"))
  bufio2_core_clk
    (.I(core_clk_i)
    ,.DIVCLK(core_clk_lo)
    ,.IOCLK()
    ,.SERDESSTROBE());

  BUFIO2 #
    (.DIVIDE(1)
    ,.I_INVERT("FALSE")
    ,.DIVIDE_BYPASS("FALSE")
    ,.USE_DOUBLER("FALSE"))
  bufio2_io_clk
    (.I(io_clk_i)
    ,.DIVCLK(io_clk_lo)
    ,.IOCLK()
    ,.SERDESSTROBE());
    
  BUFG bufg_core_clk
    (.I(core_clk_lo)
    ,.O(core_clk_o));
    
  BUFG bufg_io_clk
    (.I(io_clk_lo)
    ,.O(io_clk_o));

endmodule
