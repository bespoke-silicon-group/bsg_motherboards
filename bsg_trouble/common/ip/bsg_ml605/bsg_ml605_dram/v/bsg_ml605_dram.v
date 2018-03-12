//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_dram.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//------------------------------------------------------------

`include "bsg_defines.v"

module bsg_ml605_dram #
  (parameter REFCLK_FREQ             = 200
                                      // # = 200 when design frequency <= 533 MHz
                                      //   = 300 when design frequency > 533 MHz.
  ,parameter IODELAY_GRP             = "IODELAY_MIG"
                                      // It is associated to a set of IODELAYs with
                                      // an IDELAYCTRL that have same IODELAY CONTROLLER
                                      // clock frequency.
  ,parameter MMCM_ADV_BANDWIDTH      = "OPTIMIZED"
                                      // MMCM programming algorithm
  ,parameter CLKFBOUT_MULT_F         = 6
                                      // write PLL VCO multiplier.
  ,parameter DIVCLK_DIVIDE           = 1  // ML605 200MHz input clock (VCO = 1200MHz)use "2" for 400MHz SMA
                                      // write PLL VCO divisor.
  ,parameter CLKOUT_DIVIDE           = 3  //400MHz clock
                                      // VCO output divisor for fast (memory) clocks.
  ,parameter nCK_PER_CLK             = 2
                                      // # of memory CKs per fabric clock.
                                      // # = 2 1.
  ,parameter tCK                     = 2500
                                      // memory tCK paramter.
                                      // # = Clock Period.
  ,parameter DEBUG_PORT              = "OFF"
                                      // # = "ON" Enable debug signals/controls.
                                      //   = "OFF" Disable debug signals/controls.
  ,parameter SIM_BYPASS_INIT_CAL     = "OFF"
                                      // # = "OFF" -  Complete memory init &
                                      //              calibration sequence
                                      // # = "SKIP" - Skip memory init &
                                      //              calibration sequence
                                      // # = "FAST" - Skip memory init & use
                                      //              abbreviated calib sequence
  ,parameter nCS_PER_RANK            = 1
                                      // # of unique CS outputs per Rank for
                                      // phy.
  ,parameter DQS_CNT_WIDTH           = 3
                                      // # = ceil(log2(DQS_WIDTH)).
  ,parameter RANK_WIDTH              = 1
                                      // # = ceil(log2(RANKS)).
  ,parameter BANK_WIDTH              = 3
                                      // # of memory Bank Address bits.
  ,parameter CK_WIDTH                = 1
                                      // # of CK/CK# outputs to memory.
  ,parameter CKE_WIDTH               = 1
                                      // # of CKE outputs to memory.
  ,parameter COL_WIDTH               = 10
                                      // # of memory Column Address bits.
  ,parameter CS_WIDTH                = 1
                                      // # of unique CS outputs to memory.
  ,parameter DM_WIDTH                = 8
                                      // # of Data Mask bits.
  ,parameter DQ_WIDTH                = 64
                                      // # of Data (DQ) bits.
  ,parameter DQS_WIDTH               = 8
                                      // # of DQS/DQS# bits.
  ,parameter ROW_WIDTH               = 15
                                      // # of memory Row Address bits.
  ,parameter BURST_MODE              = "4"
                                      // Burst Length (Mode Register 0).
                                      // # = "8" "4" "OTF".
  ,parameter BM_CNT_WIDTH            = 2
                                      // # = ceil(log2(nBANK_MACHS)).
  ,parameter ADDR_CMD_MODE           = "1T"
                                      // # = "2T" "1T".
  ,parameter ORDERING                = "STRICT"
                                      // # = "NORM" "STRICT".
  ,parameter WRLVL                   = "ON"
                                      // # = "ON" - DDR3 SDRAM
                                      //   = "OFF" - DDR2 SDRAM.
  ,parameter PHASE_DETECT            = "ON"
                                      // # = "ON" "OFF".
  ,parameter RTT_NOM                 = "60"
                                      // RTT_NOM (ODT) (Mode Register 1).
                                      // # = "DISABLED" - RTT_NOM disabled
                                      //   = "120" - RZQ/2
                                      //   = "60"  - RZQ/4
                                      //   = "40"  - RZQ/6.
  ,parameter RTT_WR                  = "OFF"
                                      // RTT_WR (ODT) (Mode Register 2).
                                      // # = "OFF" - Dynamic ODT off
                                      //   = "120" - RZQ/2
                                      //   = "60"  - RZQ/4
  ,parameter OUTPUT_DRV              = "HIGH"
                                      // Output Driver Impedance Control (Mode Register 1).
                                      // # = "HIGH" - RZQ/7
                                      //   = "LOW" - RZQ/6.
  ,parameter REG_CTRL                = "OFF"
                                      // # = "ON" - RDIMMs
                                      //   = "OFF" - Components SODIMMs UDIMMs.
  ,parameter nDQS_COL0               = 3
                                      // Number of DQS groups in I/O column #1.
  ,parameter nDQS_COL1               = 5
                                      // Number of DQS groups in I/O column #2.
  ,parameter nDQS_COL2               = 0
                                      // Number of DQS groups in I/O column #3.
  ,parameter nDQS_COL3               = 0
                                      // Number of DQS groups in I/O column #4.
  ,parameter DQS_LOC_COL0            = 24'h020100
                                      // DQS groups in column #1.
  ,parameter DQS_LOC_COL1            = 40'h0706050403
                                      // DQS groups in column #2.
  ,parameter DQS_LOC_COL2            = 0
                                      // DQS groups in column #3.
  ,parameter DQS_LOC_COL3            = 0
                                      // DQS groups in column #4.
  ,parameter tPRDI                   = 1_000_000
                                      // memory tPRDI paramter.
  ,parameter tREFI                   = 7800000
                                      // memory tREFI paramter.
  ,parameter tZQI                    = 128_000_000
                                      // memory tZQI paramter.
  ,parameter ADDR_WIDTH              = 29
                                      // # = RANK_WIDTH + BANK_WIDTH
                                      //     + ROW_WIDTH + COL_WIDTH;
  ,parameter ECC                     = "OFF"
  ,parameter ECC_TEST                = "OFF"
  ,parameter TCQ                     = 100)
  (input clk_i
  ,input clk_200_mhz_i
  ,input reset_i
  // ctrl
  ,output phy_init_done_o
  ,output pll_lock_o
  // in
  ,input valid_i
  ,input [31:0] data_i
  ,output thanks_o
  // out
  ,output valid_o
  ,output [31:0] data_o
  ,input thanks_i
  // ddr3
  ,inout [DQ_WIDTH-1:0] DDR3_DQ
  ,output [ROW_WIDTH-1:0] DDR3_ADDR
  ,output [BANK_WIDTH-1:0] DDR3_BA
  ,output DDR3_RAS_N
  ,output DDR3_CAS_N
  ,output DDR3_WE_N
  ,output DDR3_RESET_N
  ,output [(CS_WIDTH*nCS_PER_RANK)-1:0] DDR3_CS_N
  ,output [(CS_WIDTH*nCS_PER_RANK)-1:0] DDR3_ODT
  ,output [CKE_WIDTH-1:0] DDR3_CKE
  ,output [DM_WIDTH-1:0] DDR3_DM
  ,inout [DQS_WIDTH-1:0] DDR3_DQS_P
  ,inout [DQS_WIDTH-1:0] DDR3_DQS_N
  ,output [CK_WIDTH-1:0] DDR3_CK_P
  ,output [CK_WIDTH-1:0] DDR3_CK_N);

  // xilinx ip parameters

  localparam SYSCLK_PERIOD  = tCK * nCK_PER_CLK;
  localparam DATA_WIDTH     = 64;
  localparam PAYLOAD_WIDTH  = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam APP_DATA_WIDTH = PAYLOAD_WIDTH * 4;
  localparam APP_MASK_WIDTH = APP_DATA_WIDTH / 8;

  // xilinx ip signals

  wire                                iodelay_ctrl_rdy;
  wire                                clk_mem;
  wire                                clk_rd_base;
  wire                                pd_PSDONE;
  wire                                pd_PSEN;
  wire                                pd_PSINCDEC;
  wire  [(BM_CNT_WIDTH)-1:0]          bank_mach_next;
  wire [3:0]                          app_ecc_multiple_err_i;
  wire                                app_sz;
  wire                                app_rdy;
  wire                                app_wdf_end;
  wire                                app_wdf_rdy;


  wire [5*DQS_WIDTH-1:0]              dbg_cpt_first_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_second_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_tap_cnt;
  wire                                dbg_dec_cpt;
  wire                                dbg_dec_rd_dqs;
  wire                                dbg_dec_rd_fps;
  wire [5*DQS_WIDTH-1:0]              dbg_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_dqs_tap_cnt;
  wire                                dbg_inc_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_inc_dec_sel;
  wire                                dbg_inc_rd_dqs;
  wire                                dbg_inc_rd_fps;
  wire                                dbg_ocb_mon_off;
  wire                                dbg_pd_off;
  wire                                dbg_pd_maintain_off;
  wire                                dbg_pd_maintain_0_only;
  wire [4:0]                          dbg_rd_active_dly;
  wire [3*DQS_WIDTH-1:0]              dbg_rd_bitslip_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_rd_clkdly_cnt;
  wire [4*DQ_WIDTH-1:0]               dbg_rddata;
  wire [1:0]                          dbg_rdlvl_done;
  wire [1:0]                          dbg_rdlvl_err;
  wire [1:0]                          dbg_rdlvl_start;
  wire [DQS_WIDTH-1:0]                dbg_wl_dqs_inverted;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dqs_tap_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_wr_calib_clk_delay;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dq_tap_set;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dqs_tap_set;
  wire                                dbg_wr_tap_set_en;
  wire                                dbg_idel_up_all;
  wire                                dbg_idel_down_all;
  wire                                dbg_idel_up_cpt;
  wire                                dbg_idel_down_cpt;
  wire                                dbg_idel_up_rsync;
  wire                                dbg_idel_down_rsync;
  wire                                dbg_sel_all_idel_cpt;
  wire                                dbg_sel_all_idel_rsync;
  wire                                dbg_pd_inc_cpt;
  wire                                dbg_pd_dec_cpt;
  wire                                dbg_pd_inc_dqs;
  wire                                dbg_pd_dec_dqs;
  wire                                dbg_pd_disab_hyst;
  wire                                dbg_pd_disab_hyst_0;
  wire                                dbg_wrlvl_done;
  wire                                dbg_wrlvl_err;
  wire                                dbg_wrlvl_start;
  wire [4:0]                          dbg_tap_cnt_during_wrlvl;
  wire [19:0]                         dbg_rsync_tap_cnt;
  wire [255:0]                        dbg_phy_pd;
  wire [255:0]                        dbg_phy_read;
  wire [255:0]                        dbg_phy_rdlvl;
  wire [255:0]                        dbg_phy_top;
  wire [3:0]                          dbg_pd_msb_sel;
  wire [DQS_WIDTH-1:0]                dbg_rd_data_edge_detect;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_rsync;
  wire [DQS_CNT_WIDTH-1:0]            dbg_pd_byte_sel;

  // async fifo signals for clock domain crossing

  logic fwr_valid_lo;
  logic [255:0] fwr_data_lo;
  logic [(APP_DATA_WIDTH/8) - 1 : 0] fwr_mask_lo;
  logic fwr_deq_li;

  logic fac_valid_lo;
  logic [30:0] fac_addr_lo;
  logic [2:0] fac_cmd_lo;
  logic fac_deq_li;

  logic [30:0] app_addr_li;
  logic [2:0] app_cmd_li;
  logic app_en_li;

  assign fwr_deq_li = (fac_cmd_lo == 3'b000) ? fwr_valid_lo & app_wdf_rdy & app_rdy & fac_valid_lo : 1'b0;
  assign fac_deq_li = (fac_cmd_lo == 3'b001) ? fac_valid_lo & app_rdy & app_wdf_rdy : fac_valid_lo & app_rdy & app_wdf_rdy & fwr_valid_lo;

  assign {app_addr_li, app_cmd_li} = fac_deq_li ? {fac_addr_lo, fac_cmd_lo} : '0;
  assign app_en_li = fac_deq_li;

  // dram ctrl 50MHz

  logic memc_phy_init_done_lo;

  logic ctrl_wr_valid_lo;
  logic [APP_DATA_WIDTH - 1 : 0] ctrl_wr_data_lo;
  logic [APP_MASK_WIDTH - 1 : 0] ctrl_wr_mask_lo;
  logic fwr_full_lo;

  logic ctrl_addr_cmd_valid_lo;
  logic [30:0] ctrl_addr_lo;
  logic [2:0] ctrl_cmd_lo;
  logic fac_full_lo;

  logic frd_valid_lo;
  logic [APP_DATA_WIDTH - 1 : 0] frd_data_lo;

  bsg_ml605_dram_ctrl #
    (.dq_width_p(APP_DATA_WIDTH)
    ,.dq_mask_width_p(APP_MASK_WIDTH))
  ctrl_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // phy status
    ,.phy_init_done_i(memc_phy_init_done_lo)
    // in
    ,.valid_i(valid_i)
    ,.data_i(data_i)
    ,.thanks_o(thanks_o)
    // out
    ,.valid_o(valid_o)
    ,.data_o(data_o)
    ,.thanks_i(thanks_i)
    // addr/cmd out
    ,.app_af_wren(ctrl_addr_cmd_valid_lo)
    ,.app_af_addr(ctrl_addr_lo)
    ,.app_af_cmd(ctrl_cmd_lo)
    ,.app_af_afull(fac_full_lo)
    // wr out
    ,.app_wdf_wren(ctrl_wr_valid_lo)
    ,.app_wdf_data(ctrl_wr_data_lo)
    ,.app_wdf_mask_data(ctrl_wr_mask_lo)
    ,.app_wdf_afull(fwr_full_lo)
    // rd in
    ,.rd_data_valid(frd_valid_lo)
    ,.rd_data_fifo_out(frd_data_lo));

  // clock domain crossing between 50MHz and 200MHz

  logic clk_200_mhz_lo;
  logic memc_reset_lo;

  // fifo wr

  bsg_async_fifo #
    (.lg_size_p(3)
    ,.width_p(APP_DATA_WIDTH + (APP_DATA_WIDTH/8))) // 256 + 32
  fwr_inst
    // 50Mhz wr in
    (.w_clk_i(clk_i)
    ,.w_reset_i(reset_i)
    ,.w_enq_i(ctrl_wr_valid_lo)
    ,.w_data_i({ctrl_wr_data_lo, ctrl_wr_mask_lo})
    ,.w_full_o(fwr_full_lo)
    // 200Mhz wr out
    ,.r_clk_i(clk_200_mhz_lo)
    ,.r_reset_i(memc_reset_lo)
    ,.r_valid_o(fwr_valid_lo)
    ,.r_data_o({fwr_data_lo, fwr_mask_lo})
    ,.r_deq_i(fwr_deq_li));

  // fifo addr/cmd

  bsg_async_fifo #
    (.lg_size_p(3)
    ,.width_p(31 + 3)) // addr + cmd
  fac_inst
    // 50Mhz addr/cmd in
    (.w_clk_i(clk_i)
    ,.w_reset_i(reset_i)
    ,.w_enq_i(ctrl_addr_cmd_valid_lo)
    ,.w_data_i({ctrl_addr_lo, ctrl_cmd_lo})
    ,.w_full_o(fac_full_lo)
    // 200Mhz addr/cmd out
    ,.r_clk_i(clk_200_mhz_lo)
    ,.r_reset_i(memc_reset_lo)
    ,.r_valid_o(fac_valid_lo)
    ,.r_data_o({fac_addr_lo, fac_cmd_lo})
    ,.r_deq_i(fac_deq_li));

  // fifo rd

  wire app_rd_data_valid;
  wire [255:0] app_rd_data;

  bsg_async_fifo #
    (.lg_size_p(4) // Still not sure why Q used different amount compare to wr
    ,.width_p(256))
  frd_inst
    // 200Mhz rd in
    (.w_clk_i(clk_200_mhz_lo)
    ,.w_reset_i(memc_reset_lo)
    ,.w_enq_i(app_rd_data_valid)
    ,.w_data_i(app_rd_data)
    ,.w_full_o()
    // 50Mhz rd out
    ,.r_clk_i(clk_i)
    ,.r_reset_i(reset_i)
    ,.r_valid_o(frd_valid_lo)
    ,.r_data_o(frd_data_lo)
    ,.r_deq_i(frd_valid_lo));

  // xilinx ip below

  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_200_mhz_i),
     .RST    (reset_i)
     );

  infrastructure #
    (
     .TCQ                (TCQ),
     .CLK_PERIOD         (SYSCLK_PERIOD),
     .nCK_PER_CLK        (nCK_PER_CLK),
     .MMCM_ADV_BANDWIDTH (MMCM_ADV_BANDWIDTH),
     .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
     .DIVCLK_DIVIDE      (DIVCLK_DIVIDE),
     .CLKOUT_DIVIDE      (CLKOUT_DIVIDE),
     .RST_ACT_LOW        (0)
     )
    u_infrastructure
      (
       .clk_mem          (clk_mem),             // 400 MHz
       .clk              (clk_200_mhz_lo), // 200 MHz
       .clk_rd_base      (clk_rd_base),         // 400 MHz
       .pll_lock_o       (pll_lock_o),
       .rstdiv0          (memc_reset_lo),
       .mmcm_clk         (clk_200_mhz_i),
       .sys_rst          (1'b0), // we don't really want to reset PLL
       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),
       .PSDONE           (pd_PSDONE),
       .PSEN             (pd_PSEN),
       .PSINCDEC         (pd_PSINCDEC)
       );

  memc_ui_top #
  (
   .ADDR_CMD_MODE        (ADDR_CMD_MODE),
   .BANK_WIDTH           (BANK_WIDTH),
   .CK_WIDTH             (CK_WIDTH),
   .CKE_WIDTH            (CKE_WIDTH),
   .nCK_PER_CLK          (nCK_PER_CLK),
   .COL_WIDTH            (COL_WIDTH),
   .CS_WIDTH             (CS_WIDTH),
   .DM_WIDTH             (DM_WIDTH),
   .nCS_PER_RANK         (nCS_PER_RANK),
   .DEBUG_PORT           (DEBUG_PORT),
   .IODELAY_GRP          (IODELAY_GRP),
   .DQ_WIDTH             (DQ_WIDTH),
   .DQS_WIDTH            (DQS_WIDTH),
   .DQS_CNT_WIDTH        (DQS_CNT_WIDTH),
   .ORDERING             (ORDERING),
   .OUTPUT_DRV           (OUTPUT_DRV),
   .PHASE_DETECT         (PHASE_DETECT),
   .RANK_WIDTH           (RANK_WIDTH),
   .REFCLK_FREQ          (REFCLK_FREQ),
   .REG_CTRL             (REG_CTRL),
   .ROW_WIDTH            (ROW_WIDTH),
   .RTT_NOM              (RTT_NOM),
   .RTT_WR               (RTT_WR),
   .SIM_BYPASS_INIT_CAL  (SIM_BYPASS_INIT_CAL),
   .WRLVL                (WRLVL),
   .nDQS_COL0            (nDQS_COL0),
   .nDQS_COL1            (nDQS_COL1),
   .nDQS_COL2            (nDQS_COL2),
   .nDQS_COL3            (nDQS_COL3),
   .DQS_LOC_COL0         (DQS_LOC_COL0),
   .DQS_LOC_COL1         (DQS_LOC_COL1),
   .DQS_LOC_COL2         (DQS_LOC_COL2),
   .DQS_LOC_COL3         (DQS_LOC_COL3),
   .tPRDI                (tPRDI),
   .tREFI                (tREFI),
   .tZQI                 (tZQI),
   .BURST_MODE           (BURST_MODE),
   .BM_CNT_WIDTH         (BM_CNT_WIDTH),
   .tCK                  (tCK),
   .ADDR_WIDTH           (ADDR_WIDTH),
   .TCQ                  (TCQ),
   .ECC                  (ECC),
   .ECC_TEST             (ECC_TEST),
   .PAYLOAD_WIDTH        (PAYLOAD_WIDTH),
   .APP_DATA_WIDTH       (APP_DATA_WIDTH),
   .APP_MASK_WIDTH       (APP_MASK_WIDTH)
   )
  u_memc_ui_top
  (
   .clk                              (clk_200_mhz_lo),
   .clk_mem                          (clk_mem),
   .clk_rd_base                      (clk_rd_base),
   .rst                              (memc_reset_lo),
   .ddr_addr                         (DDR3_ADDR),
   .ddr_ba                           (DDR3_BA),
   .ddr_cas_n                        (DDR3_CAS_N),
   .ddr_ck_n                         (DDR3_CK_N),
   .ddr_ck                           (DDR3_CK_P),
   .ddr_cke                          (DDR3_CKE),
   .ddr_cs_n                         (DDR3_CS_N),
   .ddr_dm                           (DDR3_DM),
   .ddr_odt                          (DDR3_ODT),
   .ddr_ras_n                        (DDR3_RAS_N),
   .ddr_reset_n                      (DDR3_RESET_N),
   .ddr_parity                       (),
   .ddr_we_n                         (DDR3_WE_N),
   .ddr_dq                           (DDR3_DQ),
   .ddr_dqs_n                        (DDR3_DQS_N),
   .ddr_dqs                          (DDR3_DQS_P),
   .pd_PSEN                          (pd_PSEN),
   .pd_PSINCDEC                      (pd_PSINCDEC),
   .pd_PSDONE                        (pd_PSDONE),
   .phy_init_done                    (memc_phy_init_done_lo),
   .bank_mach_next                   (bank_mach_next),
   .app_ecc_multiple_err             (app_ecc_multiple_err_i),
   .app_rd_data                      (app_rd_data),
   .app_rd_data_end                  (app_rd_data_end),
   .app_rd_data_valid                (app_rd_data_valid),
   .app_rdy                          (app_rdy),
   .app_wdf_rdy                      (app_wdf_rdy),
   .app_addr                         (app_addr_li[ADDR_WIDTH-1:0]),
   .app_cmd                          (app_cmd_li),
   .app_en                           (app_en_li),
   .app_hi_pri                       (1'b0),
   .app_sz                           (1'b1),
   .app_wdf_data                     (fwr_data_lo),
   .app_wdf_end                      (fwr_deq_li),
   .app_wdf_mask                     (fwr_mask_lo),
   .app_wdf_wren                     (fwr_deq_li),
   .app_correct_en                   (1'b1),
   .dbg_wr_dqs_tap_set               (dbg_wr_dqs_tap_set),
   .dbg_wr_dq_tap_set                (dbg_wr_dq_tap_set),
   .dbg_wr_tap_set_en                (dbg_wr_tap_set_en),
   .dbg_wrlvl_start                  (dbg_wrlvl_start),
   .dbg_wrlvl_done                   (dbg_wrlvl_done),
   .dbg_wrlvl_err                    (dbg_wrlvl_err),
   .dbg_wl_dqs_inverted              (dbg_wl_dqs_inverted),
   .dbg_wr_calib_clk_delay           (dbg_wr_calib_clk_delay),
   .dbg_wl_odelay_dqs_tap_cnt        (dbg_wl_odelay_dqs_tap_cnt),
   .dbg_wl_odelay_dq_tap_cnt         (dbg_wl_odelay_dq_tap_cnt),
   .dbg_rdlvl_start                  (dbg_rdlvl_start),
   .dbg_rdlvl_done                   (dbg_rdlvl_done),
   .dbg_rdlvl_err                    (dbg_rdlvl_err),
   .dbg_cpt_tap_cnt                  (dbg_cpt_tap_cnt),
   .dbg_cpt_first_edge_cnt           (dbg_cpt_first_edge_cnt),
   .dbg_cpt_second_edge_cnt          (dbg_cpt_second_edge_cnt),
   .dbg_rd_bitslip_cnt               (dbg_rd_bitslip_cnt),
   .dbg_rd_clkdly_cnt                (dbg_rd_clkdly_cnt),
   .dbg_rd_active_dly                (dbg_rd_active_dly),
   .dbg_pd_off                       (dbg_pd_off),
   .dbg_pd_maintain_off              (dbg_pd_maintain_off),
   .dbg_pd_maintain_0_only           (dbg_pd_maintain_0_only),
   .dbg_inc_cpt                      (dbg_inc_cpt),
   .dbg_dec_cpt                      (dbg_dec_cpt),
   .dbg_inc_rd_dqs                   (dbg_inc_rd_dqs),
   .dbg_dec_rd_dqs                   (dbg_dec_rd_dqs),
   .dbg_inc_dec_sel                  (dbg_inc_dec_sel),
   .dbg_inc_rd_fps                   (dbg_inc_rd_fps),
   .dbg_dec_rd_fps                   (dbg_dec_rd_fps),
   .dbg_dqs_tap_cnt                  (dbg_dqs_tap_cnt),
   .dbg_dq_tap_cnt                   (dbg_dq_tap_cnt),
   .dbg_rddata                       (dbg_rddata)
   );

  assign phy_init_done_o = memc_phy_init_done_lo;

  // xilinx disable debug port

  assign dbg_wr_dqs_tap_set     = 'b0;
  assign dbg_wr_dq_tap_set      = 'b0;
  assign dbg_wr_tap_set_en      = 1'b0;
  assign dbg_pd_off             = 1'b0;
  assign dbg_pd_maintain_off    = 1'b0;
  assign dbg_pd_maintain_0_only = 1'b0;
  assign dbg_ocb_mon_off        = 1'b0;
  assign dbg_inc_cpt            = 1'b0;
  assign dbg_dec_cpt            = 1'b0;
  assign dbg_inc_rd_dqs         = 1'b0;
  assign dbg_dec_rd_dqs         = 1'b0;
  assign dbg_inc_dec_sel        = 'b0;
  assign dbg_inc_rd_fps         = 1'b0;
  assign dbg_pd_msb_sel         = 'b0 ;
  assign dbg_sel_idel_cpt       = 'b0 ;
  assign dbg_sel_idel_rsync     = 'b0 ;
  assign dbg_pd_byte_sel        = 'b0 ;
  assign dbg_dec_rd_fps         = 1'b0;

endmodule
