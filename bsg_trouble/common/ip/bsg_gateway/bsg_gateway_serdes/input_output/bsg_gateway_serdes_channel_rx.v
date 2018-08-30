//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_gateway_serdes_channel_rx.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_gateway_serdes_channel_rx #

  (parameter width = 4
  // IODELAY tap
  ,parameter tap = 35)

  // clock
  (input raw_clk0_i
  ,output div_clk_o
  
  // Interface to IO Pads
  ,input [7:0] data_input_i
  ,input valid_input_i
  ,output token_output_o
  
  // Interface to common_link
  ,output [7:0] data_input_0_o
  ,output [7:0] data_input_1_o
  ,output valid_input_0_o
  ,output valid_input_1_o
  ,input token_output_i);
  
	// For input and output clocks
	logic ibufg_clk0_lo;
	logic ibufg_clk0_p_lo;
	logic ibufg_clk1_n_lo;
	logic clk0_lo;
	logic clk1_lo;
	logic iodelay_clk0_lo;
	logic iodelay_clk1_lo;
	logic bufio_div_clk_lo;
	
	// For data and valid bits
	logic [7:0] iodelay_data_lo;
	logic iodelay_valid_lo;
	
	// Directly output the token signal
	assign token_output_o = token_output_i;
	
	// Input clock buf
	IBUFG #(
	.IOSTANDARD("SSTL_18_Class_I") // Specify the input I/O standard
	) IBUFG_clk0 (
	.O(ibufg_clk0_lo), // Clock buffer output
	.I(raw_clk0_i) // Clock buffer input (connect directly to top-level port)
	);

	// assign same clock signal on both pos and neg clock
	assign ibufg_clk0_p_lo = ibufg_clk0_lo;
	assign ibufg_clk1_n_lo = ibufg_clk0_lo;
	
	// Iodelay for positive clock
	IODELAY2 #
	(.DATA_RATE("SDR")
	,.SIM_TAPDELAY_VALUE(49)
	,.IDELAY_VALUE(0)
	,.IDELAY2_VALUE(0)
	,.ODELAY_VALUE(0)
	,.IDELAY_MODE("NORMAL")
	,.SERDES_MODE("MASTER")
	,.IDELAY_TYPE("FIXED")
	,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
	,.DELAY_SRC("IDATAIN"))
	iodelay_clk0
	(.IDATAIN(ibufg_clk0_p_lo)
	,.TOUT()
	,.DOUT()
	,.T(1'b1)
	,.ODATAIN(1'b0)
	,.DATAOUT(iodelay_clk0_lo)
	,.DATAOUT2()
	,.IOCLK0(1'b0)
	,.IOCLK1(1'b0)
	,.CLK(1'b0)
	,.CAL(1'b0)
	,.INC(1'b0)
	,.CE(1'b0)
	,.RST(1'b0)
	,.BUSY());
	
	// Iodelay for negative clock
	IODELAY2 #
	(.DATA_RATE("SDR")
	,.SIM_TAPDELAY_VALUE(49)
	,.IDELAY_VALUE(0)
	,.IDELAY2_VALUE(0)
	,.ODELAY_VALUE(0)
	,.IDELAY_MODE("NORMAL")
	,.SERDES_MODE("MASTER")
	,.IDELAY_TYPE("FIXED")
	,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
	,.DELAY_SRC("IDATAIN"))
	iodelay_clk1
	(.IDATAIN(ibufg_clk1_n_lo)
	,.TOUT()
	,.DOUT()
	,.T(1'b1)
	,.ODATAIN(1'b0)
	,.DATAOUT(iodelay_clk1_lo)
	,.DATAOUT2()
	,.IOCLK0(1'b0)
	,.IOCLK1(1'b0)
	,.CLK(1'b0)
	,.CAL(1'b0)
	,.INC(1'b0)
	,.CE(1'b0)
	,.RST(1'b0)
	,.BUSY());
	
	// Bufio for positive clock
	BUFIO2 #(
	.DIVIDE_BYPASS("FALSE"), // Bypass the divider circuitry (TRUE/FALSE)
	.I_INVERT("FALSE"), // Invert clock (TRUE/FALSE)
	.USE_DOUBLER("FALSE") // Use doubler circuitry (TRUE/FALSE)
	)
	BUFIO2_clk0 (
	.DIVCLK(bufio_div_clk_lo), // 1-bit output: Divided clock output
	.IOCLK(clk0_lo), // 1-bit output: I/O output clock
	.SERDESSTROBE(), // 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
	.I(iodelay_clk0_lo) // 1-bit input: Clock input (connect to IBUFG)
	);
	
	// Bufio for negative clock
	BUFIO2 #(
	.DIVIDE_BYPASS("FALSE"), // Bypass the divider circuitry (TRUE/FALSE)
	.I_INVERT("FALSE"), // Invert clock (TRUE/FALSE)
	.USE_DOUBLER("FALSE") // Use doubler circuitry (TRUE/FALSE)
	)
	BUFIO2_clk1 (
	.DIVCLK(), // 1-bit output: Divided clock output
	.IOCLK(clk1_lo), // 1-bit output: I/O output clock
	.SERDESSTROBE(), // 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
	.I(iodelay_clk1_lo) // 1-bit input: Clock input (connect to IBUFG)
	);


	// Divided clock output
	BUFG bufg
	(.I(bufio_div_clk_lo)
	,.O(div_clk_o));

	// For valid bit
	IODELAY2 #
	(.DATA_RATE("SDR")
	,.SIM_TAPDELAY_VALUE(49)
	,.IDELAY_VALUE(tap)
	,.IDELAY2_VALUE(0)
	,.ODELAY_VALUE(0)
	,.IDELAY_MODE("NORMAL")
	,.SERDES_MODE("MASTER")
	,.IDELAY_TYPE("FIXED")
	,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
	,.DELAY_SRC("IDATAIN"))
	iodelay_valid
	(.IDATAIN(valid_input_i)
	,.TOUT()
	,.DOUT()
	,.T(1'b1)
	,.ODATAIN(1'b0)
	,.DATAOUT(iodelay_valid_lo)
	,.DATAOUT2()
	,.IOCLK0(1'b0)
	,.IOCLK1(1'b0)
	,.CLK(1'b0)
	,.CAL(1'b0)
	,.INC(1'b0)
	,.CE(1'b0)
	,.RST(1'b0)
	,.BUSY());

	// Inverse clk1 to get true negative clock
	IDDR2 #(
	.DDR_ALIGNMENT("C0"), // Sets output alignment to "NONE", "C0" or "C1"
	.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
	.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
	.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) valid (
	.Q0(valid_input_1_o), // 1-bit output captured with C0 clock
	.Q1(valid_input_0_o), // 1-bit output captured with C1 clock
	.C0(clk0_lo), // 1-bit clock input
	.C1(~clk1_lo), // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D(iodelay_valid_lo), // 1-bit DDR data input
	.R(1'b0), // 1-bit reset input
	.S(1'b0) // 1-bit set input
	);	
	
	genvar i;

	// For all data bits
	for(i=0;i<8;i=i+1)
	begin: data_loop
	
		IODELAY2 #
		(.DATA_RATE("SDR")
		,.SIM_TAPDELAY_VALUE(49)
		,.IDELAY_VALUE(tap)
		,.IDELAY2_VALUE(0)
		,.ODELAY_VALUE(0)
		,.IDELAY_MODE("NORMAL")
		,.SERDES_MODE("MASTER")
		,.IDELAY_TYPE("FIXED")
		,.COUNTER_WRAPAROUND("STAY_AT_LIMIT")
		,.DELAY_SRC("IDATAIN"))
		iodelay_data
		(.IDATAIN(data_input_i[i])
		,.TOUT()
		,.DOUT()
		,.T(1'b1)
		,.ODATAIN(1'b0)
		,.DATAOUT(iodelay_data_lo[i])
		,.DATAOUT2()
		,.IOCLK0(1'b0)
		,.IOCLK1(1'b0)
		,.CLK(1'b0)
		,.CAL(1'b0)
		,.INC(1'b0)
		,.CE(1'b0)
		,.RST(1'b0)
		,.BUSY());

		// Inverse clk1 to get true negative clock
		IDDR2 #(
		.DDR_ALIGNMENT("C0"), // Sets output alignment to "NONE", "C0" or "C1"
		.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
		.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
		.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
		) data (
		.Q0(data_input_1_o[i]), // 1-bit output captured with C0 clock
		.Q1(data_input_0_o[i]), // 1-bit output captured with C1 clock
		.C0(clk0_lo), // 1-bit clock input
		.C1(~clk1_lo), // 1-bit clock input
		.CE(1'b1), // 1-bit clock enable input
		.D(iodelay_data_lo[i]), // 1-bit DDR data input
		.R(1'b0), // 1-bit reset input
		.S(1'b0) // 1-bit set input
		);

	end
	

endmodule
