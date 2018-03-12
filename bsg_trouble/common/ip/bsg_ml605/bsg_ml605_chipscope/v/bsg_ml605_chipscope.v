//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_chipscope.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_chipscope
  (input clk_i
  ,input [255:0] data_i);

  logic [35:0] control_lo;

  bsg_ml605_chipscope_icon icon
    (.CONTROL0(control_lo));

  bsg_ml605_chipscope_ila ila
    (.CONTROL(control_lo)
    ,.CLK(clk_i)
    ,.TRIG0(data_i));

endmodule
