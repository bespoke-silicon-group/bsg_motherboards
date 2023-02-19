
module bp_stream_host

  import bp_common_pkg::*;
  import bp_common_aviary_pkg::*;
  import bp_cce_pkg::*;
  import bp_be_pkg::*;
  import bp_be_dcache_pkg::*;
  
 #(parameter bp_cfg_e cfg_p = e_bp_inv_cfg
  `declare_bp_proc_params(cfg_p)
  ,localparam cce_mshr_width_lp = `bp_cce_mshr_width(num_lce_p, lce_assoc_p, paddr_width_p)
  `declare_bp_me_if_widths(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp)
  
  ,parameter stream_addr_width_p = 32
  ,parameter stream_data_width_p = 32
  ,parameter clear_freeze_p = 0
  )

  (input                                        clk_i
  ,input                                        reset_i
  ,output                                       prog_done_o

  ,input  [cce_mem_data_cmd_width_lp-1:0]            io_data_cmd_i
  ,input                                        io_data_cmd_v_i
  ,output                                       io_data_cmd_yumi_o

  ,output [mem_cce_resp_width_lp-1:0]            io_resp_o
  ,output                                       io_resp_v_o
  ,input                                        io_resp_ready_i
  
  ,output [cce_mem_data_cmd_width_lp-1:0]            io_data_cmd_o
  ,output                                       io_data_cmd_v_o
  ,input                                        io_data_cmd_yumi_i
  
  ,input  [mem_cce_resp_width_lp-1:0]            io_resp_i
  ,input                                        io_resp_v_i
  ,output                                       io_resp_ready_o
  
  ,input                                        stream_v_i
  ,input  [stream_addr_width_p-1:0]             stream_addr_i
  ,input  [stream_data_width_p-1:0]             stream_data_i
  ,output                                       stream_yumi_o
  
  ,output                                       stream_v_o
  ,output [stream_data_width_p-1:0]             stream_data_o
  ,input                                        stream_ready_i
  );
  
  `declare_bp_me_if(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp);
  
  // AXI-Lite address map
  //
  // Host software should send data to specific addresses for 
  // specific purposes
  //
  logic nbf_v_li, mmio_v_li;
  logic nbf_ready_lo, mmio_ready_lo;;
  
  assign nbf_v_li  = stream_v_i & (stream_addr_i == 32'h00000010);
  assign mmio_v_li = stream_v_i & (stream_addr_i == 32'h00000020);
  
  assign stream_yumi_o = (nbf_v_li & nbf_ready_lo) | (mmio_v_li & mmio_ready_lo);
  
  // nbf loader
  bp_stream_nbf_loader
 #(.cfg_p(cfg_p)
  ,.stream_data_width_p(stream_data_width_p)
  ,.clear_freeze_p(clear_freeze_p)
  ) nbf_loader
  (.clk_i          (clk_i)
  ,.reset_i        (reset_i)
  ,.done_o         (prog_done_o)

  ,.io_data_cmd_o       (io_data_cmd_o)
  ,.io_data_cmd_v_o     (io_data_cmd_v_o)
  ,.io_data_cmd_yumi_i  (io_data_cmd_yumi_i)

  ,.io_resp_i      (io_resp_i)
  ,.io_resp_v_i    (io_resp_v_i)
  ,.io_resp_ready_o (io_resp_ready_o)

  ,.stream_v_i     (nbf_v_li)
  ,.stream_data_i  (stream_data_i)
  ,.stream_ready_o (nbf_ready_lo)
  );
  
  // mmio
  bp_stream_mmio
 #(.cfg_p(cfg_p)
  ,.stream_data_width_p(stream_data_width_p)
  ) mmio
  (.clk_i           (clk_i)
  ,.reset_i         (reset_i)

  ,.io_data_cmd_i        (io_data_cmd_i)
  ,.io_data_cmd_v_i      (io_data_cmd_v_i)
  ,.io_data_cmd_yumi_o   (io_data_cmd_yumi_o)

  ,.io_resp_o       (io_resp_o)
  ,.io_resp_v_o     (io_resp_v_o)
  ,.io_resp_ready_i (io_resp_ready_i)

  ,.stream_v_i      (mmio_v_li)
  ,.stream_data_i   (stream_data_i)
  ,.stream_ready_o  (mmio_ready_lo)
  
  ,.stream_v_o      (stream_v_o)
  ,.stream_data_o   (stream_data_o)
  ,.stream_yumi_i   (stream_v_o & stream_ready_i)
  );

endmodule

