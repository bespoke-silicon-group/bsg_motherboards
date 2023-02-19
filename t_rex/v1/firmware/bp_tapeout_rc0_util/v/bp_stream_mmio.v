/**
 *  bp_stream_mmio.v
 *
 */

module bp_stream_mmio

  import bp_common_pkg::*;
  import bp_common_aviary_pkg::*;
  import bp_cce_pkg::*;
  import bp_be_pkg::*;
  import bp_be_dcache_pkg::*;

 #(parameter bp_cfg_e cfg_p = e_bp_inv_cfg
  `declare_bp_proc_params(cfg_p)
  ,localparam cce_mshr_width_lp = `bp_cce_mshr_width(num_lce_p, lce_assoc_p, paddr_width_p)
  `declare_bp_me_if_widths(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp)
  
  ,parameter stream_data_width_p = 32
  )

  (input  clk_i
  ,input  reset_i
  
  ,input  [cce_mem_data_cmd_width_lp-1:0]        io_data_cmd_i
  ,input                                    io_data_cmd_v_i
  ,output                                   io_data_cmd_yumi_o
  
  ,output [mem_cce_resp_width_lp-1:0]        io_resp_o
  ,output                                   io_resp_v_o
  ,input                                    io_resp_ready_i
  
  ,input                                    stream_v_i
  ,input  [stream_data_width_p-1:0]         stream_data_i
  ,output                                   stream_ready_o
  
  ,output                                   stream_v_o
  ,output [stream_data_width_p-1:0]         stream_data_o
  ,input                                    stream_yumi_i
  );

  `declare_bp_me_if(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp);
  
  // Temporarily support cce_data_size less than stream_data_width_p only
  // Temporarily support response of 64-bits data only
  bp_cce_mem_data_cmd_s io_data_cmd;
  bp_mem_cce_resp_s     io_resp;
  assign io_data_cmd = io_data_cmd_i;
  
  // streaming out fifo
  logic out_fifo_v_li, out_fifo_ready_lo;
  logic [stream_data_width_p-1:0] out_fifo_data_li;
  
  bsg_two_fifo
 #(.width_p(stream_data_width_p)
  ) out_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.data_i (out_fifo_data_li)
  ,.v_i    (out_fifo_v_li)
  ,.ready_o(out_fifo_ready_lo)
  ,.data_o (stream_data_o)
  ,.v_o    (stream_v_o)
  ,.yumi_i (stream_yumi_i)
  );
  
  // cmd_queue fifo
  logic queue_fifo_v_li, queue_fifo_ready_lo;
  
  assign io_resp.payload       = io_data_cmd.payload;
  assign io_resp.addr          = io_data_cmd.addr;
  assign io_resp.msg_type      = io_data_cmd.msg_type;
  assign io_resp.nc_size       = io_data_cmd.nc_size;
  assign io_resp.non_cacheable = io_data_cmd.non_cacheable;
  
  bsg_fifo_1r1w_small
 #(.width_p(mem_cce_resp_width_lp)
  ,.els_p  (16)
  ) queue_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.data_i (io_resp)
  ,.v_i    (queue_fifo_v_li)
  ,.ready_o(queue_fifo_ready_lo)
  ,.data_o (io_resp_o)
  ,.v_o    (io_resp_v_o)
  ,.yumi_i (io_resp_v_o & io_resp_ready_i)
  );
  
  logic [1:0] state_r, state_n;
  
  always_ff @(posedge clk_i)
    if (reset_i)
      begin
        state_r <= '0;
      end
    else
      begin
        state_r <= state_n;
      end
  
  logic io_data_cmd_yumi_lo;
  assign io_data_cmd_yumi_o = io_data_cmd_yumi_lo;
  
  always_comb
  begin
    state_n = state_r;
    io_data_cmd_yumi_lo = 1'b0;
    queue_fifo_v_li = 1'b0;
    out_fifo_v_li = 1'b0;
    out_fifo_data_li = io_data_cmd.data;
    
    if (state_r == 0)
      begin
        if (io_data_cmd_v_i & out_fifo_ready_lo & queue_fifo_ready_lo)
          begin
            out_fifo_v_li = 1'b1;
            out_fifo_data_li = io_data_cmd.addr;
            state_n = 1;
          end
      end
    else if (state_r == 1)
      begin
        if (io_data_cmd_v_i & out_fifo_ready_lo & queue_fifo_ready_lo)
          begin
            out_fifo_v_li = 1'b1;
            io_data_cmd_yumi_lo = 1'b1;
            queue_fifo_v_li = 1'b1;
            state_n = 0;
          end
      end
  end
  
  // resp fifo
  assign stream_ready_o = 1'b1;

endmodule
