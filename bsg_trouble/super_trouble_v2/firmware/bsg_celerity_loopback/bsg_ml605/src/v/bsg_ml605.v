module bsg_ml605
# (parameter channel_width_p=8
  ,parameter ring_bytes_p=10
  ,parameter ring_width_p=ring_bytes_p*channel_width_p
  ,parameter nodes_p=1
  ,parameter celerity_nodes_p=7
  ,parameter rocket_index_p=0
  ,parameter dcdc_index_p=5
  `ifdef bsg_dcdc
  ,parameter test_index_p=dcdc_index_p
  `endif
  `ifdef bsg_mitm
  ,parameter test_index_p=rocket_index_p
  `endif
  ,parameter boot_index_p=6)
  
  (input SYSCLK_P, SYSCLK_N
  ,input CPU_RESET
  // led
  ,output GPIO_LED_0
  ,output GPIO_LED_1
  ,output GPIO_LED_2
  ,output GPIO_LED_3
  ,output GPIO_LED_4
  ,output GPIO_LED_5
  ,output GPIO_LED_6
  ,output GPIO_LED_7
  // fmc gateway reset out
  ,output FMC_LPC_LA20_P, FMC_LPC_LA20_N
  // fmc ml605 reset in
  ,input FMC_LPC_LA23_P, FMC_LPC_LA23_N
  // fmc tx clk out
  ,output FMC_LPC_LA17_CC_P, FMC_LPC_LA17_CC_N
  // fmc tx data out
  ,output FMC_LPC_LA31_P, FMC_LPC_LA31_N
  ,output FMC_LPC_LA33_P, FMC_LPC_LA33_N
  ,output FMC_LPC_LA30_P, FMC_LPC_LA30_N
  ,output FMC_LPC_LA32_P, FMC_LPC_LA32_N
  ,output FMC_LPC_LA28_P, FMC_LPC_LA28_N
  ,output FMC_LPC_LA25_P, FMC_LPC_LA25_N
  ,output FMC_LPC_LA29_P, FMC_LPC_LA29_N
  ,output FMC_LPC_LA26_P, FMC_LPC_LA26_N
  ,output FMC_LPC_LA21_P, FMC_LPC_LA21_N
  ,output FMC_LPC_LA27_P, FMC_LPC_LA27_N
  ,output FMC_LPC_LA22_P, FMC_LPC_LA22_N
  // fmc rx clk out
  ,output FMC_LPC_CLK0_M2C_P, FMC_LPC_CLK0_M2C_N
  // fmc rx clk in
  ,input FMC_LPC_CLK1_M2C_P, FMC_LPC_CLK1_M2C_N
  // fmc rx data in
  ,input FMC_LPC_LA00_CC_P, FMC_LPC_LA00_CC_N
  ,input FMC_LPC_LA16_P, FMC_LPC_LA16_N
  ,input FMC_LPC_LA15_P, FMC_LPC_LA15_N
  ,input FMC_LPC_LA13_P, FMC_LPC_LA13_N
  ,input FMC_LPC_LA11_P, FMC_LPC_LA11_N
  ,input FMC_LPC_LA10_P, FMC_LPC_LA10_N
  ,input FMC_LPC_LA14_P, FMC_LPC_LA14_N
  ,input FMC_LPC_LA09_P, FMC_LPC_LA09_N
  ,input FMC_LPC_LA04_P, FMC_LPC_LA04_N
  ,input FMC_LPC_LA07_P, FMC_LPC_LA07_N
  ,input FMC_LPC_LA08_P, FMC_LPC_LA08_N);

  // clock

  wire clk_50_mhz, clk_200_mhz;

  bsg_ml605_clk clk
    (.clk_200_mhz_p_i(SYSCLK_P) ,.clk_200_mhz_n_i(SYSCLK_N)
    ,.clk_50_mhz_o(clk_50_mhz)
    ,.clk_200_mhz_o(clk_200_mhz)
    ,.locked_o());

  // node

  wire [celerity_nodes_p-1:0] fsb_reset;
  wire [celerity_nodes_p-1:0] fsb_en;

  wire [celerity_nodes_p-1:0] fsb_valid;
  wire [ring_width_p-1:0] fsb_data [celerity_nodes_p-1:0];
  wire [celerity_nodes_p-1:0] fsb_ready;

  wire [celerity_nodes_p-1:0] node_valid;
  wire [ring_width_p-1:0] node_data [celerity_nodes_p-1:0];
  wire [celerity_nodes_p-1:0] node_yumi;

  wire finish_lo, success_lo, timeout_lo, error_lo;
  logic boot_done_lo;
  logic delayed_boot_lo;
  logic [15:0] boot_counter_lo;
  
  always @(posedge clk_50_mhz) begin
	if (boot_done_lo == 0) begin
		boot_counter_lo <= 1;
		delayed_boot_lo <= 0;
	end else begin
		boot_counter_lo <= boot_counter_lo + 1;
		if ((boot_counter_lo != 0) && (delayed_boot_lo == 0)) begin
			delayed_boot_lo <= 0;
		end else begin
			delayed_boot_lo <= 1;
		end
	end
  end
  
  genvar i;

	`ifdef bsg_mitm
	
	for (i=0; i<5; i++) begin
		if (i==rocket_index_p) begin
			
			bsg_test_node_MITM #
			(.ring_width_p(ring_width_p)
			,.enable_MITM_p(1))
			MITM
			( .clk_i   (clk_50_mhz)
			 ,.reset_i ((~delayed_boot_lo) | fsb_reset[i])

			 // control
			 ,.en_i    (fsb_en[i])
			 ,.done_o  (finish_lo)
			 ,.error_o (error_lo)
			 // in
			 ,.v_i(fsb_valid[i])
			 ,.data_i(fsb_data[i])
			 ,.ready_o(fsb_ready[i])
			 // out
			 ,.v_o(node_valid[i])
			 ,.data_o(node_data[i])
			 ,.yumi_i(node_yumi[i])

			 // input from master
			 , .from_master_v_i    ()
			 , .from_master_data_i ()
			 , .from_master_ready_o()
			 
			 // output to master
			 , .to_master_v_o      ()
			 , .to_master_data_o   ()
			 , .to_master_yumi_i   ()
			 );
			 
			 assign success_lo = ~error_lo;
			
		end else begin
			assign node_valid[i] = 1'b0;
			assign fsb_ready[i] = 1'b1;
			assign node_data[i] = 0;
		end
	end
	
	`else 
	// Disable the 5 rocket nodes in fsb
	for (i=0; i<5; i++) begin
		assign node_valid[i] = 1'b0;
		assign fsb_ready[i] = 1'b1;
		assign node_data[i] = 0;
	end
	`endif
  
	`ifdef bsg_dcdc
	
	bsg_manycore_node_master
	#(.ring_width_p(ring_width_p)
	,.client_id_p(dcdc_index_p))
	node
	(.clk_i(clk_50_mhz)
	,.reset_i(~boot_done_lo)
	// control
	,.en_i(fsb_en[dcdc_index_p])
	// input channel
    ,.v_i(fsb_valid[dcdc_index_p])
    ,.data_i(fsb_data[dcdc_index_p])
    ,.ready_o(fsb_ready[dcdc_index_p])
	// output channel
    ,.v_o(node_valid[dcdc_index_p])
    ,.data_o(node_data[dcdc_index_p])
    ,.yumi_i(node_yumi[dcdc_index_p])
	
	,.finish_lo(finish_lo)
	,.success_lo(success_lo)
	,.timeout_lo(timeout_lo)
	);
	
	`else	
	assign fsb_ready[dcdc_index_p] = 1'b1;
	assign node_valid[dcdc_index_p] = 1'b0;
	assign node_data[dcdc_index_p] = 0;
	`endif
	
  // fsb boot node (node[6])
  bsg_test_node_master #
    (.ring_width_p(80))
  boot
    (.clk_i(clk_50_mhz)
    ,.reset_i(fsb_reset[boot_index_p])
    // control
    ,.en_i(fsb_en[boot_index_p])
    ,.done_o(boot_done_lo)
    // out
    ,.v_o(node_valid[boot_index_p])
    ,.data_o(node_data[boot_index_p])
    ,.yumi_i(node_yumi[boot_index_p])
    // not used
    ,.v_i()
    ,.data_i()
    ,.ready_o());

  // data check

  wire [63:0] data_check;

  test_bsg_data_gen #
    (.channel_width_p(8)
    ,.num_channels_p(8))
  check
    (.clk_i(clk_50_mhz)
    ,.reset_i(~boot_done_lo)
    ,.yumi_i(fsb_valid[test_index_p])
    ,.o(data_check));

`ifndef SIMULATION

  // chipscope

  bsg_ml605_chipscope cs
    (.clk_i(clk_50_mhz)
    ,.data_i({'0
             ,~boot_done_lo
             ,fsb_valid[test_index_p]
             ,fsb_ready[test_index_p]
             ,fsb_data[test_index_p]
             ,data_check}));

`else

  always @(posedge clk_50_mhz)
    if (fsb_valid[test_index_p] == 1'b1)
      $display("SENT:%16x RECEIVED:%16x", data_check, fsb_data[test_index_p]);

`endif

  // fsb

  wire dt_calib_reset;

  wire                    c_valid;
  wire [ring_width_p-1:0] c_data;
  wire                    c_yumi;

  wire                    asm_valid;
  wire [ring_width_p-1:0] asm_data;
  wire                    asm_ready;

  wire                    fmc_valid;
  wire [ring_width_p-1:0] fmc_data;
  wire                    fmc_ready;
  
  bsg_fsb #
    (.width_p(80)
    ,.nodes_p(celerity_nodes_p)
    ,.enabled_at_start_vec_p({celerity_nodes_p{1'b1}})
    ,.snoop_vec_p({celerity_nodes_p{1'b0}}))
  fsb
    (.clk_i(clk_50_mhz)
    ,.reset_i(dt_calib_reset)
    // asm in
    ,.asm_v_i(fmc_valid)
	`ifdef bsg_mitm
    ,.asm_data_i((fmc_data&80'h0FFFFFFFFFFFFFFFFFFF)|(rocket_index_p<<76))
	`else
	,.asm_data_i(fmc_data)
	`endif
    ,.asm_yumi_o(fmc_ready)
    // asm out
    ,.asm_v_o(asm_valid)
    ,.asm_data_o(asm_data)
    ,.asm_ready_i(asm_ready)
    // node ctrl
    ,.node_reset_r_o(fsb_reset)
    ,.node_en_r_o(fsb_en)
    // node in
    ,.node_v_i(node_valid)
    ,.node_data_i(node_data)
    ,.node_yumi_o(node_yumi)
    // node out
    ,.node_v_o(fsb_valid)
    ,.node_data_o(fsb_data)
    ,.node_ready_i(fsb_ready));

/*
  bsg_two_fifo #
    (.width_p(ring_width_p))
  c
    (.clk_i(clk_50_mhz)
    ,.reset_i(dt_calib_reset)
    // in
    ,.v_i(fmc_valid)
    ,.data_i(fmc_data)
    ,.ready_o(fmc_ready)
    // out
    ,.v_o(c_valid)
    ,.data_o(c_data)
    ,.yumi_i(c_yumi));
*/	

  // fmc

  bsg_ml605_fmc fmc
    (.clk_i(clk_50_mhz)
    // data in
    ,.valid_i(asm_valid)
    ,.data_i(asm_data)
    ,.ready_o(asm_ready)
    // data out
    ,.valid_o(fmc_valid)
    ,.data_o(fmc_data)
    ,.ready_i(fmc_ready)
    // double trouble reset in
    ,.dt_reset_i(CPU_RESET)
    // double trouble calib reset out
    ,.dt_calib_reset_o(dt_calib_reset)
    // fmc clk for ml605 and gateway
    ,.fmc_clk_i(clk_200_mhz)
    ,.fmc_clk_div_i(clk_50_mhz)
    ,.fmc_clk_200_mhz_i(clk_200_mhz)
    // fmc gateway reset out
    ,.FMC_LPC_LA20_P(FMC_LPC_LA20_P) ,.FMC_LPC_LA20_N(FMC_LPC_LA20_N)
    // fmc ml605 reset in
    ,.FMC_LPC_LA23_P(FMC_LPC_LA23_P) ,.FMC_LPC_LA23_N(FMC_LPC_LA23_N)
    // fmc tx clk out
    ,.FMC_LPC_LA17_CC_P(FMC_LPC_LA17_CC_P) ,.FMC_LPC_LA17_CC_N(FMC_LPC_LA17_CC_N)
    // fmc tx data out
    ,.FMC_LPC_LA31_P(FMC_LPC_LA31_P) ,.FMC_LPC_LA31_N(FMC_LPC_LA31_N)
    ,.FMC_LPC_LA33_P(FMC_LPC_LA33_P) ,.FMC_LPC_LA33_N(FMC_LPC_LA33_N)
    ,.FMC_LPC_LA30_P(FMC_LPC_LA30_P) ,.FMC_LPC_LA30_N(FMC_LPC_LA30_N)
    ,.FMC_LPC_LA32_P(FMC_LPC_LA32_P) ,.FMC_LPC_LA32_N(FMC_LPC_LA32_N)
    ,.FMC_LPC_LA28_P(FMC_LPC_LA28_P) ,.FMC_LPC_LA28_N(FMC_LPC_LA28_N)
    ,.FMC_LPC_LA25_P(FMC_LPC_LA25_P) ,.FMC_LPC_LA25_N(FMC_LPC_LA25_N)
    ,.FMC_LPC_LA29_P(FMC_LPC_LA29_P) ,.FMC_LPC_LA29_N(FMC_LPC_LA29_N)
    ,.FMC_LPC_LA26_P(FMC_LPC_LA26_P) ,.FMC_LPC_LA26_N(FMC_LPC_LA26_N)
    ,.FMC_LPC_LA21_P(FMC_LPC_LA21_P) ,.FMC_LPC_LA21_N(FMC_LPC_LA21_N)
    ,.FMC_LPC_LA27_P(FMC_LPC_LA27_P) ,.FMC_LPC_LA27_N(FMC_LPC_LA27_N)
    ,.FMC_LPC_LA22_P(FMC_LPC_LA22_P) ,.FMC_LPC_LA22_N(FMC_LPC_LA22_N)
    // fmc rx clk out
    ,.FMC_LPC_CLK0_M2C_P(FMC_LPC_CLK0_M2C_P) ,.FMC_LPC_CLK0_M2C_N(FMC_LPC_CLK0_M2C_N)
    // fmc rx clk in
    ,.FMC_LPC_CLK1_M2C_P(FMC_LPC_CLK1_M2C_P) ,.FMC_LPC_CLK1_M2C_N(FMC_LPC_CLK1_M2C_N)
    // fmc rx data in
    ,.FMC_LPC_LA00_CC_P(FMC_LPC_LA00_CC_P) ,.FMC_LPC_LA00_CC_N(FMC_LPC_LA00_CC_N)
    ,.FMC_LPC_LA16_P(FMC_LPC_LA16_P) ,.FMC_LPC_LA16_N(FMC_LPC_LA16_N)
    ,.FMC_LPC_LA15_P(FMC_LPC_LA15_P) ,.FMC_LPC_LA15_N(FMC_LPC_LA15_N)
    ,.FMC_LPC_LA13_P(FMC_LPC_LA13_P) ,.FMC_LPC_LA13_N(FMC_LPC_LA13_N)
    ,.FMC_LPC_LA11_P(FMC_LPC_LA11_P) ,.FMC_LPC_LA11_N(FMC_LPC_LA11_N)
    ,.FMC_LPC_LA10_P(FMC_LPC_LA10_P) ,.FMC_LPC_LA10_N(FMC_LPC_LA10_N)
    ,.FMC_LPC_LA14_P(FMC_LPC_LA14_P) ,.FMC_LPC_LA14_N(FMC_LPC_LA14_N)
    ,.FMC_LPC_LA09_P(FMC_LPC_LA09_P) ,.FMC_LPC_LA09_N(FMC_LPC_LA09_N)
    ,.FMC_LPC_LA04_P(FMC_LPC_LA04_P) ,.FMC_LPC_LA04_N(FMC_LPC_LA04_N)
    ,.FMC_LPC_LA07_P(FMC_LPC_LA07_P) ,.FMC_LPC_LA07_N(FMC_LPC_LA07_N)
    ,.FMC_LPC_LA08_P(FMC_LPC_LA08_P) ,.FMC_LPC_LA08_N(FMC_LPC_LA08_N));

  // led

  assign {GPIO_LED_7
         ,GPIO_LED_6} = (dt_calib_reset == 1'b1)? 4'hF : 4'h0;

  assign {GPIO_LED_5
         ,GPIO_LED_4} = (fsb_reset[test_index_p] == 1'b0 && fsb_en[test_index_p] == 1'b1)? 4'hF : 4'h0;

  assign GPIO_LED_3 = finish_lo;	
  assign GPIO_LED_2 = success_lo;
  assign GPIO_LED_1 = timeout_lo;

endmodule
