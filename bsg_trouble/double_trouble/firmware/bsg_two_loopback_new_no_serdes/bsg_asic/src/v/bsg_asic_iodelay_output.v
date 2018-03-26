//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_fmc.v
//
// Author: Zihou Gao - zig053@eng.ucsd.edu
//------------------------------------------------------------

module bsg_asic_iodelay_output

  #(parameter tap_i = 0)
  (input bit_i
  ,output bit_o);

  IODELAY2 #(
    .COUNTER_WRAPAROUND("WRAPAROUND"), // "STAY_AT_LIMIT" or "WRAPAROUND"
    .DATA_RATE("DDR"), // "SDR" or "DDR"
    .DELAY_SRC("ODATAIN"), // "IO", "ODATAIN" or "IDATAIN"
    .IDELAY2_VALUE(0), // Delay value when IDELAY_MODE="PCI" (0-255)
    .IDELAY_MODE("NORMAL"), // "NORMAL" or "PCI"
    .IDELAY_TYPE("FIXED"), // "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX" or "DIFF_PHASE_DETECTOR"
    .IDELAY_VALUE(0), // Amount of taps for fixed input delay (0-255)
    .ODELAY_VALUE(tap_i), // Amount of taps fixed output delay (0-255)
    .SERDES_MODE("NONE"), // "NONE", "MASTER" or "SLAVE"
    .SIM_TAPDELAY_VALUE(50) // Per tap delay used for simulation in ps
  )
  IODELAY2_data (
    .BUSY(), // 1-bit output: Busy output after CAL
    .DATAOUT(), // 1-bit output: Delayed data output to ISERDES/input register
    .DATAOUT2(), // 1-bit output: Delayed data output to general FPGA fabric
    .DOUT(bit_o), // 1-bit output: Delayed data output
    .TOUT(), // 1-bit output: Delayed 3-state output
    .CAL(1'b0), // 1-bit input: Initiate calibration input
    .CE(1'b0), // 1-bit input: Enable INC input
    .CLK(1'b0), // 1-bit input: Clock input
    .IDATAIN(1'b0), // 1-bit input: Data input (connect to top-level port or I/O buffer)
    .INC(1'b0), // 1-bit input: Increment / decrement input
    .IOCLK0(1'b0), // 1-bit input: Input from the I/O clock network
    .IOCLK1(1'b0), // 1-bit input: Input from the I/O clock network
    .ODATAIN(bit_i), // 1-bit input: Output data input from output register or OSERDES2.
    .RST(1'b0), // 1-bit input: Reset to zero or 1/2 of total delay period
    .T(1'b0) // 1-bit input: 3-state input signal
  );

endmodule
