//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie.v
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

module bsg_ml605_pcie #
  (parameter channel_p = 2)
  // clk
  (input clk_i
  // data in
  ,input [channel_p - 1 : 0] valid_i
  ,input [31:0] data_i [channel_p - 1 : 0]
  ,output [channel_p - 1 : 0] ready_o
  // data out
  ,output [channel_p - 1 : 0] valid_o
  ,output [31:0] data_o [channel_p - 1 : 0]
  ,input [channel_p - 1 : 0] yumi_i
  // ctrl
  ,output reset_o
  // status register
  ,input [31:0] status_register_i
  // pcie clock
  ,input PCIE_250M_MGT1_P, PCIE_250M_MGT1_N
  // pcie reset
  ,input PCIE_PERST_B_LS
  // pcie data in
  ,input PCIE_RX0_P, PCIE_RX0_N
  ,input PCIE_RX1_P, PCIE_RX1_N
  ,input PCIE_RX2_P, PCIE_RX2_N
  ,input PCIE_RX3_P, PCIE_RX3_N
  // pcie data out
  ,output PCIE_TX0_P, PCIE_TX0_N
  ,output PCIE_TX1_P, PCIE_TX1_N
  ,output PCIE_TX2_P, PCIE_TX2_N
  ,output PCIE_TX3_P, PCIE_TX3_N);

  logic trn_clk;
  logic pcie_reset_lo;

  logic [channel_p - 1 : 0] pcie_valid_lo;
  logic [32*channel_p - 1 : 0] pcie_data_lo;
  logic [channel_p - 1 : 0] buffer_ready_lo;

  logic [channel_p - 1 : 0] buffer_valid_lo;
  logic [32*channel_p - 1 : 0] buffer_data_lo;
  logic [channel_p - 1 : 0] pcie_ready_lo;

  bsg_ml605_pcie_async_fifo #
    (.channel_p(channel_p))
  async_fifo_inst
    // core clk
    (.core_clk_i(clk_i)
    // core reset
    ,.core_reset_i(pcie_reset_lo)
    // core data in
    ,.core_valid_i(valid_i)
    ,.core_data_i(data_i)
    ,.core_ready_o(ready_o)
    // core data out
    ,.core_valid_o(valid_o)
    ,.core_data_o(data_o)
    ,.core_yumi_i(yumi_i)
    // pcie clk
    ,.pcie_clk_i(trn_clk)
    // pcie reset
    ,.pcie_reset_i(pcie_reset_lo)
    // pcie data in
    ,.pcie_valid_i(pcie_valid_lo)
    ,.pcie_data_i(pcie_data_lo)
    ,.pcie_ready_o(buffer_ready_lo)
    // pcie data out
    ,.pcie_valid_o(buffer_valid_lo)
    ,.pcie_data_o(buffer_data_lo)
    ,.pcie_ready_i(pcie_ready_lo));

  //-------------------------------------------------------
  // PCI Express IP
  //-------------------------------------------------------

  // Transaction (TRN) Interface

  wire trn_reset_n;
  wire trn_lnk_up_n;

  // TX

  wire [5:0] trn_tbuf_av;

  wire trn_tcfg_req_n;
  wire trn_terr_drop_n;
  wire trn_tdst_rdy_n;

  wire [63:0] trn_td;

  wire trn_trem_n;
  wire trn_tsof_n;
  wire trn_teof_n;
  wire trn_tsrc_rdy_n;
  wire trn_tsrc_dsc_n;
  wire trn_terrfwd_n;
  wire trn_tcfg_gnt_n;
  wire trn_tstr_n;

  // RX

  wire [63:0] trn_rd;

  wire trn_rrem_n;
  wire trn_rsof_n;
  wire trn_reof_n;
  wire trn_rsrc_rdy_n;
  wire trn_rsrc_dsc_n;
  wire trn_rerrfwd_n;

  wire [6:0] trn_rbar_hit_n;
  wire trn_rdst_rdy_n;
  wire trn_rnp_ok_n;

  // Flow Control
  wire [11:0] trn_fc_cpld;
  wire [7:0] trn_fc_cplh;
  wire [11:0] trn_fc_npd;
  wire [7:0] trn_fc_nph;
  wire [11:0] trn_fc_pd;
  wire [7:0] trn_fc_ph;
  wire [2:0] trn_fc_sel;

  // Configuration (CFG) Interface

  wire [31:0] cfg_do;

  wire cfg_rd_wr_done_n;

  wire [31:0] cfg_di;
  wire [3:0] cfg_byte_en_n;
  wire [9:0] cfg_dwaddr;

  wire cfg_wr_en_n;
  wire cfg_rd_en_n;
  wire cfg_err_cor_n;
  wire cfg_err_ur_n;
  wire cfg_err_ecrc_n;
  wire cfg_err_cpl_timeout_n;
  wire cfg_err_cpl_abort_n;
  wire cfg_err_cpl_unexpect_n;
  wire cfg_err_posted_n;
  wire cfg_err_locked_n;

  wire [47:0] cfg_err_tlp_cpl_header;

  wire cfg_err_cpl_rdy_n;
  wire cfg_interrupt_n;
  wire cfg_interrupt_rdy_n;
  wire cfg_interrupt_assert_n;

  wire [7:0] cfg_interrupt_di;
  wire [7:0] cfg_interrupt_do;
  wire [2:0] cfg_interrupt_mmenable;

  wire cfg_interrupt_msienable;
  wire cfg_interrupt_msixenable;
  wire cfg_interrupt_msixfm;
  wire cfg_turnoff_ok_n;
  wire cfg_to_turnoff_n;
  wire cfg_trn_pending_n;
  wire cfg_pm_wake_n;

  wire [7:0] cfg_bus_number;
  wire [4:0] cfg_device_number;
  wire [2:0] cfg_function_number;

  wire [15:0] cfg_status;
  wire [15:0] cfg_command;
  wire [15:0] cfg_dstatus;
  wire [15:0] cfg_dcommand;
  wire [15:0] cfg_lstatus;
  wire [15:0] cfg_lcommand;
  wire [15:0] cfg_dcommand2;

  wire [2:0] cfg_pcie_link_state_n;
  wire [63:0] cfg_dsn;

  // Physical Layer Control and Status (PL) Interface

  wire [2:0] pl_initial_link_width;
  wire [1:0] pl_lane_reversal_mode;

  wire pl_link_gen2_capable;
  wire pl_link_partner_gen2_supported;
  wire pl_link_upcfg_capable;

  wire [5:0] pl_ltssm_state;

  wire pl_received_hot_rst;
  wire pl_sel_link_rate;

  wire [1:0] pl_sel_link_width;

  wire pl_directed_link_auton;

  wire [1:0] pl_directed_link_change;

  wire pl_directed_link_speed;

  wire [1:0] pl_directed_link_width;

  wire pl_upstream_prefer_deemph;

  FDCP #
    (.INIT(1'b1))
  trn_lnk_up_n_int_i
    (.Q (trn_lnk_up_n)
    ,.D (trn_lnk_up_n_int1)
    ,.C (trn_clk)
    ,.CLR (1'b0)
    ,.PRE (1'b0));

  FDCP #
    (.INIT(1'b1))
  trn_reset_n_i
    (.Q (trn_reset_n)
    ,.D (trn_reset_n_int1)
    ,.C (trn_clk)
    ,.CLR (1'b0)
    ,.PRE (1'b0));

  // pcie clock

  wire ibufds_gtxe1_pcie_clk_lo;

  IBUFDS_GTXE1 ibufds_gtxe1_pcie_clk_inst
    (.I(PCIE_250M_MGT1_P) ,.IB(PCIE_250M_MGT1_N)
    ,.O(ibufds_gtxe1_pcie_clk_lo));

  wire [3:0] pci_exp_txp_lo;

  assign {PCIE_TX3_P
         ,PCIE_TX2_P
         ,PCIE_TX1_P
         ,PCIE_TX0_P} = pci_exp_txp_lo;

  wire [3:0] pci_exp_txn_lo;

  assign {PCIE_TX3_N
         ,PCIE_TX2_N
         ,PCIE_TX1_N
         ,PCIE_TX0_N} = pci_exp_txn_lo;

  wire [3:0] pci_exp_rxp_li = {PCIE_RX3_P
                              ,PCIE_RX2_P
                              ,PCIE_RX1_P
                              ,PCIE_RX0_P};

  wire [3:0] pci_exp_rxn_li = {PCIE_RX3_N
                              ,PCIE_RX2_N
                              ,PCIE_RX1_N
                              ,PCIE_RX0_N};

  logic ibuf_pcie_perst_lo;

  IBUF pcie_reset_n_ibuf
    (.I(PCIE_PERST_B_LS)
    ,.O(ibuf_pcie_perst_lo));

`ifdef SIMULATION
  v6_pcie_v1_7 #
    (.PL_FAST_TRAIN("FALSE"))
  core
`else
  v6_pcie_v1_7 core
`endif

    //-------------------------------------------------------
    // 1. PCI Express (pci_exp) Interface
    //-------------------------------------------------------

    // TX
    (.pci_exp_txp(pci_exp_txp_lo)
    ,.pci_exp_txn(pci_exp_txn_lo)

    // RX
    ,.pci_exp_rxp(pci_exp_rxp_li)
    ,.pci_exp_rxn(pci_exp_rxn_li)

    //-------------------------------------------------------
    // 2. Transaction (TRN) Interface
    //-------------------------------------------------------

    // COMMON
    ,.trn_clk(trn_clk)
    ,.trn_reset_n(trn_reset_n_int1)
    ,.trn_lnk_up_n(trn_lnk_up_n_int1)

    // TX
    ,.trn_tbuf_av(trn_tbuf_av)
    ,.trn_tcfg_req_n(trn_tcfg_req_n)
    ,.trn_terr_drop_n(trn_terr_drop_n)
    ,.trn_tdst_rdy_n(trn_tdst_rdy_n)
    ,.trn_td(trn_td)
    ,.trn_trem_n(trn_trem_n)
    ,.trn_tsof_n(trn_tsof_n)
    ,.trn_teof_n(trn_teof_n)
    ,.trn_tsrc_rdy_n(trn_tsrc_rdy_n)
    ,.trn_tsrc_dsc_n(trn_tsrc_dsc_n)
    ,.trn_terrfwd_n(trn_terrfwd_n)
    ,.trn_tcfg_gnt_n(trn_tcfg_gnt_n)
    ,.trn_tstr_n(trn_tstr_n)

    // RX
    ,.trn_rd(trn_rd)
    ,.trn_rrem_n(trn_rrem_n)
    ,.trn_rsof_n(trn_rsof_n)
    ,.trn_reof_n(trn_reof_n)
    ,.trn_rsrc_rdy_n(trn_rsrc_rdy_n)
    ,.trn_rsrc_dsc_n(trn_rsrc_dsc_n)
    ,.trn_rerrfwd_n(trn_rerrfwd_n)
    ,.trn_rbar_hit_n(trn_rbar_hit_n)
    ,.trn_rdst_rdy_n(trn_rdst_rdy_n)
    ,.trn_rnp_ok_n(trn_rnp_ok_n)

    // FLOW CONTROL
    ,.trn_fc_cpld(trn_fc_cpld)
    ,.trn_fc_cplh(trn_fc_cplh)
    ,.trn_fc_npd(trn_fc_npd)
    ,.trn_fc_nph(trn_fc_nph)
    ,.trn_fc_pd(trn_fc_pd)
    ,.trn_fc_ph(trn_fc_ph)
    ,.trn_fc_sel(trn_fc_sel)

    //-------------------------------------------------------
    // 3. Configuration (CFG) Interface
    //-------------------------------------------------------

    ,.cfg_do(cfg_do)
    ,.cfg_rd_wr_done_n(cfg_rd_wr_done_n)
    ,.cfg_di(cfg_di)
    ,.cfg_byte_en_n(cfg_byte_en_n)
    ,.cfg_dwaddr(cfg_dwaddr)
    ,.cfg_wr_en_n(cfg_wr_en_n)
    ,.cfg_rd_en_n(cfg_rd_en_n)
    ,.cfg_err_cor_n(cfg_err_cor_n)
    ,.cfg_err_ur_n(cfg_err_ur_n)
    ,.cfg_err_ecrc_n(cfg_err_ecrc_n)
    ,.cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n)
    ,.cfg_err_cpl_abort_n(cfg_err_cpl_abort_n)
    ,.cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n)
    ,.cfg_err_posted_n(cfg_err_posted_n)
    ,.cfg_err_locked_n(cfg_err_locked_n)
    ,.cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header)
    ,.cfg_err_cpl_rdy_n(cfg_err_cpl_rdy_n)
    ,.cfg_interrupt_n(cfg_interrupt_n)
    ,.cfg_interrupt_rdy_n(cfg_interrupt_rdy_n)
    ,.cfg_interrupt_assert_n(cfg_interrupt_assert_n)
    ,.cfg_interrupt_di(cfg_interrupt_di)
    ,.cfg_interrupt_do(cfg_interrupt_do)
    ,.cfg_interrupt_mmenable(cfg_interrupt_mmenable)
    ,.cfg_interrupt_msienable(cfg_interrupt_msienable)
    ,.cfg_interrupt_msixenable(cfg_interrupt_msixenable)
    ,.cfg_interrupt_msixfm(cfg_interrupt_msixfm)
    ,.cfg_turnoff_ok_n(cfg_turnoff_ok_n)
    ,.cfg_to_turnoff_n(cfg_to_turnoff_n)
    ,.cfg_trn_pending_n(cfg_trn_pending_n)
    ,.cfg_pm_wake_n(cfg_pm_wake_n)
    ,.cfg_bus_number(cfg_bus_number)
    ,.cfg_device_number(cfg_device_number)
    ,.cfg_function_number(cfg_function_number)
    ,.cfg_status(cfg_status)
    ,.cfg_command(cfg_command)
    ,.cfg_dstatus(cfg_dstatus)
    ,.cfg_dcommand(cfg_dcommand)
    ,.cfg_lstatus(cfg_lstatus)
    ,.cfg_lcommand(cfg_lcommand)
    ,.cfg_dcommand2(cfg_dcommand2)
    ,.cfg_pcie_link_state_n(cfg_pcie_link_state_n)
    ,.cfg_dsn(cfg_dsn)
    ,.cfg_pmcsr_pme_en()
    ,.cfg_pmcsr_pme_status()
    ,.cfg_pmcsr_powerstate()

    //-------------------------------------------------------
    // 4. Physical Layer Control and Status (PL) Interface
    //-------------------------------------------------------

    ,.pl_initial_link_width(pl_initial_link_width)
    ,.pl_lane_reversal_mode(pl_lane_reversal_mode)
    ,.pl_link_gen2_capable(pl_link_gen2_capable)
    ,.pl_link_partner_gen2_supported(pl_link_partner_gen2_supported)
    ,.pl_link_upcfg_capable(pl_link_upcfg_capable)
    ,.pl_ltssm_state(pl_ltssm_state)
    ,.pl_received_hot_rst(pl_received_hot_rst)
    ,.pl_sel_link_rate(pl_sel_link_rate)
    ,.pl_sel_link_width(pl_sel_link_width)
    ,.pl_directed_link_auton(pl_directed_link_auton)
    ,.pl_directed_link_change(pl_directed_link_change)
    ,.pl_directed_link_speed(pl_directed_link_speed)
    ,.pl_directed_link_width(pl_directed_link_width)
    ,.pl_upstream_prefer_deemph(pl_upstream_prefer_deemph)

    //-------------------------------------------------------
    // 5. System  (SYS) Interface
    //-------------------------------------------------------

    ,.sys_clk(ibufds_gtxe1_pcie_clk_lo)
    ,.sys_reset_n(ibuf_pcie_perst_lo));

  pcie_app_v6 #
    (.channel_p(channel_p))
  app

    //-------------------------------------------------------
    // 1. Transaction (TRN) Interface
    //-------------------------------------------------------

    // COMMON
    (.trn_clk(trn_clk)
    ,.trn_reset_n(trn_reset_n_int1)
    ,.trn_lnk_up_n(trn_lnk_up_n_int1)

    // TX
    ,.trn_tbuf_av(trn_tbuf_av)
    ,.trn_tcfg_req_n(trn_tcfg_req_n)
    ,.trn_terr_drop_n(trn_terr_drop_n)
    ,.trn_tdst_rdy_n(trn_tdst_rdy_n)
    ,.trn_td(trn_td)
    ,.trn_trem_n(trn_trem_n)
    ,.trn_tsof_n(trn_tsof_n)
    ,.trn_teof_n(trn_teof_n)
    ,.trn_tsrc_rdy_n(trn_tsrc_rdy_n)
    ,.trn_tsrc_dsc_n(trn_tsrc_dsc_n)
    ,.trn_terrfwd_n(trn_terrfwd_n)
    ,.trn_tcfg_gnt_n(trn_tcfg_gnt_n)
    ,.trn_tstr_n(trn_tstr_n)

    // RX
    ,.trn_rd(trn_rd)
    ,.trn_rrem_n(trn_rrem_n)
    ,.trn_rsof_n(trn_rsof_n)
    ,.trn_reof_n(trn_reof_n)
    ,.trn_rsrc_rdy_n(trn_rsrc_rdy_n)
    ,.trn_rsrc_dsc_n(trn_rsrc_dsc_n)
    ,.trn_rerrfwd_n(trn_rerrfwd_n)
    ,.trn_rbar_hit_n(trn_rbar_hit_n)
    ,.trn_rdst_rdy_n(trn_rdst_rdy_n)
    ,.trn_rnp_ok_n(trn_rnp_ok_n)

    // FLOW CONTROL
    ,.trn_fc_cpld(trn_fc_cpld)
    ,.trn_fc_cplh(trn_fc_cplh)
    ,.trn_fc_npd(trn_fc_npd)
    ,.trn_fc_nph(trn_fc_nph)
    ,.trn_fc_pd(trn_fc_pd)
    ,.trn_fc_ph(trn_fc_ph)
    ,.trn_fc_sel(trn_fc_sel)

    //-------------------------------------------------------
    // 2. Configuration (CFG) Interface
    //-------------------------------------------------------

    ,.cfg_do(cfg_do)
    ,.cfg_rd_wr_done_n(cfg_rd_wr_done_n)
    ,.cfg_di(cfg_di)
    ,.cfg_byte_en_n(cfg_byte_en_n)
    ,.cfg_dwaddr(cfg_dwaddr)
    ,.cfg_wr_en_n(cfg_wr_en_n)
    ,.cfg_rd_en_n(cfg_rd_en_n)
    ,.cfg_err_cor_n(cfg_err_cor_n)
    ,.cfg_err_ur_n(cfg_err_ur_n)
    ,.cfg_err_ecrc_n(cfg_err_ecrc_n)
    ,.cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n)
    ,.cfg_err_cpl_abort_n(cfg_err_cpl_abort_n)
    ,.cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n)
    ,.cfg_err_posted_n(cfg_err_posted_n)
    ,.cfg_err_locked_n(cfg_err_locked_n)
    ,.cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header)
    ,.cfg_err_cpl_rdy_n(cfg_err_cpl_rdy_n)
    ,.cfg_interrupt_n(cfg_interrupt_n)
    ,.cfg_interrupt_rdy_n(cfg_interrupt_rdy_n)
    ,.cfg_interrupt_assert_n(cfg_interrupt_assert_n)
    ,.cfg_interrupt_di(cfg_interrupt_di)
    ,.cfg_interrupt_do(cfg_interrupt_do)
    ,.cfg_interrupt_mmenable(cfg_interrupt_mmenable)
    ,.cfg_interrupt_msienable(cfg_interrupt_msienable)
    ,.cfg_interrupt_msixenable(cfg_interrupt_msixenable)
    ,.cfg_interrupt_msixfm(cfg_interrupt_msixfm)
    ,.cfg_turnoff_ok_n(cfg_turnoff_ok_n)
    ,.cfg_to_turnoff_n(cfg_to_turnoff_n)
    ,.cfg_trn_pending_n(cfg_trn_pending_n)
    ,.cfg_pm_wake_n(cfg_pm_wake_n)
    ,.cfg_bus_number(cfg_bus_number)
    ,.cfg_device_number(cfg_device_number)
    ,.cfg_function_number(cfg_function_number)
    ,.cfg_status(cfg_status)
    ,.cfg_command(cfg_command)
    ,.cfg_dstatus(cfg_dstatus)
    ,.cfg_dcommand(cfg_dcommand)
    ,.cfg_lstatus(cfg_lstatus)
    ,.cfg_lcommand(cfg_lcommand)
    ,.cfg_dcommand2(cfg_dcommand2)
    ,.cfg_pcie_link_state_n(cfg_pcie_link_state_n)
    ,.cfg_dsn(cfg_dsn)

    //-------------------------------------------------------
    // 3. Physical Layer Control and Status (PL) Interface
    //-------------------------------------------------------

    ,.pl_initial_link_width(pl_initial_link_width)
    ,.pl_lane_reversal_mode(pl_lane_reversal_mode)
    ,.pl_link_gen2_capable(pl_link_gen2_capable)
    ,.pl_link_partner_gen2_supported(pl_link_partner_gen2_supported)
    ,.pl_link_upcfg_capable(pl_link_upcfg_capable)
    ,.pl_ltssm_state(pl_ltssm_state)
    ,.pl_received_hot_rst(pl_received_hot_rst)
    ,.pl_sel_link_rate(pl_sel_link_rate)
    ,.pl_sel_link_width(pl_sel_link_width)
    ,.pl_directed_link_auton(pl_directed_link_auton)
    ,.pl_directed_link_change(pl_directed_link_change)
    ,.pl_directed_link_speed(pl_directed_link_speed)
    ,.pl_directed_link_width(pl_directed_link_width)
    ,.pl_upstream_prefer_deemph(pl_upstream_prefer_deemph)

    //-------------------------------------------------------
    // BSG interface
    //-------------------------------------------------------

    // reset out
    ,.reset_o(pcie_reset_lo)
    // status register
    ,.status_register_i(status_register_i)
    // data in
    ,.valid_i(buffer_valid_lo)
    ,.data_i(buffer_data_lo)
    ,.ready_o(pcie_ready_lo)
    // data out
    ,.valid_o(pcie_valid_lo)
    ,.data_o(pcie_data_lo)
    ,.ready_i(buffer_ready_lo));

  assign reset_o = pcie_reset_lo;

endmodule
