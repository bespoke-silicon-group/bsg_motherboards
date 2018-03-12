//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_ddr3_model.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_ddr3_model
  (input RESET
  ,inout [63:0] DDR3_DQ
  ,inout [7:0] DDR3_DQS_P
  ,inout [7:0] DDR3_DQS_N
  ,input DDR3_RESET_N
  ,input [0:0] DDR3_CK_P
  ,input [0:0] DDR3_CK_N
  ,input [0:0] DDR3_CKE
  ,input [0:0] DDR3_CS_N
  ,input DDR3_RAS_N
  ,input DDR3_CAS_N
  ,input DDR3_WE_N
  ,input [7:0] DDR3_DM
  ,input [2:0] DDR3_BA
  ,input [14:0] DDR3_ADDR
  ,input [0:0] DDR3_ODT);

  localparam real TPROP_DQS         = 0.00;  // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD      = 0.00;  // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL    = 0.00;  // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA    = 0.00;  // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD = 0.00;  // Delay for data signal during Read operation

  localparam MEMORY_WIDTH = 16;
  localparam nCS_PER_RANK = 1;
  localparam CK_WIDTH = 1;
  localparam CKE_WIDTH = 1;
  localparam CS_WIDTH = 1;
  localparam DM_WIDTH = 8;
  localparam DQ_WIDTH = 64;
  localparam DQS_WIDTH = 8;
  localparam BANK_WIDTH = 3;
  localparam ROW_WIDTH = 15;
  localparam NUM_COMP = DQ_WIDTH/MEMORY_WIDTH;

  // dq - bidirectional

  wire [DQ_WIDTH - 1 : 0] ddr3_dq_dly;

  genvar j;
  generate
    for (j = 0; j < DQ_WIDTH; j++) begin

      wiredelay #
        (.Delay_g(TPROP_PCB_DATA)
        ,.Delay_rd(TPROP_PCB_DATA_RD))
      u_delay_dq
        (.A(DDR3_DQ[j])
        ,.B(ddr3_dq_dly[j])
        ,.reset(~RESET));

    end
  endgenerate

  // dqs - bidirectional

  wire [DQS_WIDTH - 1 : 0] ddr3_dqs_p_dly;
  wire [DQS_WIDTH - 1 : 0] ddr3_dqs_n_dly;

  genvar k;
  generate
    for (k = 0; k < DQS_WIDTH; k++) begin

      wiredelay #
        (.Delay_g(TPROP_DQS)
        ,.Delay_rd(TPROP_DQS_RD))
      u_delay_dqs_p
        (.A(DDR3_DQS_P[k]),
         .B(ddr3_dqs_p_dly[k]),
         .reset(~RESET));

      wiredelay #
        (.Delay_g(TPROP_DQS)
        ,.Delay_rd(TPROP_DQS_RD))
      u_delay_dqs_n
        (.A(DDR3_DQS_N[k])
        ,.B(ddr3_dqs_n_dly[k])
        ,.reset(~RESET));
    end
  endgenerate

  // one way

  logic ddr3_reset_n_dly;
  logic [CK_WIDTH - 1 : 0] ddr3_ck_p_dly;
  logic [CK_WIDTH - 1 : 0] ddr3_ck_n_dly;
  logic [CKE_WIDTH - 1 : 0] ddr3_cke_dly;
  logic [(CS_WIDTH*nCS_PER_RANK) - 1 : 0] ddr3_cs_n_dly;
  logic ddr3_ras_n_dly;
  logic ddr3_cas_n_dly;
  logic ddr3_we_n_dly;
  logic [BANK_WIDTH - 1 : 0] ddr3_ba_dly;
  logic [ROW_WIDTH - 1 : 0] ddr3_addr_dly;
  logic [(CS_WIDTH*nCS_PER_RANK) - 1 : 0] ddr3_odt_dly;
  logic [DM_WIDTH - 1 : 0] ddr3_dm_dly_tmp;

  always_comb begin
    ddr3_reset_n_dly <= #(TPROP_PCB_CTRL) DDR3_RESET_N;
    ddr3_ck_p_dly <= #(TPROP_PCB_CTRL) DDR3_CK_P;
    ddr3_ck_n_dly <= #(TPROP_PCB_CTRL) DDR3_CK_N;
    ddr3_cke_dly <= #(TPROP_PCB_CTRL) DDR3_CKE;
    ddr3_cs_n_dly <= #(TPROP_PCB_CTRL) DDR3_CS_N;
    ddr3_ras_n_dly <= #(TPROP_PCB_CTRL) DDR3_RAS_N;
    ddr3_cas_n_dly <= #(TPROP_PCB_CTRL) DDR3_CAS_N;
    ddr3_we_n_dly <= #(TPROP_PCB_CTRL) DDR3_WE_N;
    ddr3_ba_dly <= #(TPROP_PCB_CTRL) DDR3_BA;
    ddr3_addr_dly <= #(TPROP_PCB_CTRL) DDR3_ADDR;
    ddr3_odt_dly <= #(TPROP_PCB_CTRL) DDR3_ODT;
    ddr3_dm_dly_tmp <= #(TPROP_PCB_DATA) DDR3_DM;
  end

  wire [DM_WIDTH - 1 : 0] ddr3_dm_dly;

  assign ddr3_dm_dly = ddr3_dm_dly_tmp;

  genvar r,i;
  generate
    for (r = 0; r < CS_WIDTH; r++) begin
      for (i = 0; i < NUM_COMP; i++) begin

        ddr3_model u_comp_ddr3
          (.rst_n(ddr3_reset_n_dly)
          ,.ck(ddr3_ck_p_dly[(i*MEMORY_WIDTH)/72])
          ,.ck_n(ddr3_ck_n_dly[(i*MEMORY_WIDTH)/72])
          ,.cke(ddr3_cke_dly[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
          ,.cs_n(ddr3_cs_n_dly[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
          ,.ras_n(ddr3_ras_n_dly)
          ,.cas_n(ddr3_cas_n_dly)
          ,.we_n(ddr3_we_n_dly)
          ,.dm_tdqs(ddr3_dm_dly[(2*(i+1)-1):(2*i)])
          ,.ba(ddr3_ba_dly)
          ,.addr(ddr3_addr_dly)
          ,.dq(ddr3_dq_dly[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)])
          ,.dqs(ddr3_dqs_p_dly[(2*(i+1)-1):(2*i)])
          ,.dqs_n(ddr3_dqs_n_dly[(2*(i+1)-1):(2*i)])
          ,.odt(ddr3_odt_dly[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
          ,.tdqs_n  ());

      end
    end
  endgenerate

endmodule
