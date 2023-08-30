/**
 *  bp_nbf_to_cce_mem.v
 *
 */

module bp_nbf_to_cce_mem

  import bp_common_pkg::*;
  import bp_common_aviary_pkg::*;
  import bp_cce_pkg::*;
  
 #(parameter bp_cfg_e cfg_p = e_bp_inv_cfg
  `declare_bp_proc_params(cfg_p)
  ,localparam cce_mshr_width_lp = `bp_cce_mshr_width(num_lce_p, lce_assoc_p, paddr_width_p)
  `declare_bp_me_if_widths(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp)
  
  ,localparam byte_width_lp = 8
  ,localparam block_offset_lp = `BSG_SAFE_CLOG2(cce_block_width_p/byte_width_lp)
  )

  (input  clk_i
  ,input  reset_i
  
  ,input  [cce_mem_data_cmd_width_lp-1:0]        io_data_cmd_i
  ,input                                    io_data_cmd_v_i
  ,output                                   io_data_cmd_yumi_o
  
  ,output [mem_cce_resp_width_lp-1:0]        io_resp_o
  ,output                                   io_resp_v_o
  ,input                                    io_resp_ready_i
  
  ,output [cce_mem_data_cmd_width_lp-1:0]        mem_data_cmd_o
  ,output                                   mem_data_cmd_v_o
  ,input                                    mem_data_cmd_yumi_i
  
  ,input  [mem_cce_resp_width_lp-1:0]        mem_resp_i
  ,input                                    mem_resp_v_i
  ,output                                   mem_resp_ready_o
  );
  
  // response input not used
  wire unused_resp = &{mem_resp_i, mem_resp_v_i};
  assign mem_resp_ready_o = 1'b1;
  
  // bp_cce packet
  `declare_bp_me_if(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp);
  
  bp_cce_mem_data_cmd_s io_data_cmd, mem_data_cmd;
  bp_mem_cce_resp_s     io_resp;
  logic io_data_cmd_yumi_lo, mem_data_cmd_v_lo;
  
  assign io_data_cmd    = io_data_cmd_i;
  assign mem_data_cmd_o = mem_data_cmd;
  
  assign io_data_cmd_yumi_o = io_data_cmd_yumi_lo;
  assign mem_data_cmd_v_o   = mem_data_cmd_v_lo;
  
  // Handle io response
  assign io_resp.payload       = io_data_cmd.payload;
  assign io_resp.addr          = io_data_cmd.addr;
  assign io_resp.msg_type      = io_data_cmd.msg_type;
  assign io_resp.nc_size       = io_data_cmd.nc_size;
  assign io_resp.non_cacheable = io_data_cmd.non_cacheable;
  
  logic io_resp_fifo_ready_lo;
  
  bsg_two_fifo
 #(.width_p(mem_cce_resp_width_lp)
  ) resp_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.data_i (io_resp)
  ,.v_i    (io_data_cmd_yumi_o)
  ,.ready_o(io_resp_fifo_ready_lo)
  ,.data_o (io_resp_o)
  ,.v_o    (io_resp_v_o)
  ,.yumi_i (io_resp_v_o & io_resp_ready_i)
  );
  
  logic [3:0] state_r, state_n;
  logic [cce_block_width_p-1:0] words_r, words_n;
  logic [paddr_width_p-1:0] addr_r, addr_n;
  
  always_ff @(posedge clk_i)
  begin
    if (reset_i)
      begin
        state_r <= '0;
        words_r <= '0;
        addr_r  <= '0;
      end
    else
      begin
        state_r <= state_n;
        words_r <= words_n;
        addr_r  <= addr_n;
      end
  end
  
  wire [block_offset_lp-1:0] io_data_cmd_byte_idx = io_data_cmd.addr[block_offset_lp-1:0];
 
 // combinational
  always_comb 
  begin
    
    state_n = state_r;
    words_n = words_r;
    addr_n  = addr_r;
    
    io_data_cmd_yumi_lo          = 1'b0;
    mem_data_cmd_v_lo            = 1'b0;
    mem_data_cmd.data            = words_r;
    mem_data_cmd.payload       = '0;
    mem_data_cmd.addr          = {addr_r[paddr_width_p-1:block_offset_lp], (block_offset_lp)'(0)};
    mem_data_cmd.msg_type      = e_lce_req_type_wr;
    mem_data_cmd.nc_size       = e_lce_nc_req_8;
    mem_data_cmd.non_cacheable = e_lce_req_cacheable;
    
    if (state_r == 0)
      begin
        if (io_data_cmd_v_i)
          begin
            addr_n = io_data_cmd.addr;
            words_n = '0;
            state_n = 1;
          end
      end
    else if (state_r == 1)
      begin
        if (io_data_cmd_v_i)
          begin
            if (io_data_cmd.addr[paddr_width_p-1:block_offset_lp] != addr_r[paddr_width_p-1:block_offset_lp])
              begin
                state_n = 2;
              end
            else if (io_resp_fifo_ready_lo)
              begin
                if (io_data_cmd.non_cacheable == e_lce_req_non_cacheable)
                  begin
                    case (io_data_cmd.nc_size)
                      e_lce_nc_req_4 : words_n[byte_width_lp*io_data_cmd_byte_idx+:byte_width_lp*4 ] = io_data_cmd.data[0+:byte_width_lp*4 ];
                      e_lce_nc_req_8 : words_n[byte_width_lp*io_data_cmd_byte_idx+:byte_width_lp*8 ] = io_data_cmd.data[0+:byte_width_lp*8 ];
                      default:;
                    endcase
                  end
                else
                  begin
                    words_n[byte_width_lp*io_data_cmd_byte_idx+:byte_width_lp*64] = io_data_cmd.data[0+:byte_width_lp*64];
                  end
                io_data_cmd_yumi_lo = 1'b1;
              end
          end
      end
    else if (state_r == 2)
      begin
        mem_data_cmd_v_lo = 1'b1;
        if (mem_data_cmd_yumi_i)
          begin
            state_n = 0;
          end
      end
    
  end

endmodule
