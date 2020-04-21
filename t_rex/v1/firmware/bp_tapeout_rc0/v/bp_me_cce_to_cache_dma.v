// 
// bp_me_cce_to_cache_dma.v
// 
// Paul Gao   02/2020
//  
//

`include "bsg_cache_dma_pkt.vh"

module bp_me_cce_to_cache_dma

  import bp_cce_pkg::*;
  import bp_common_pkg::*;
  import bp_common_aviary_pkg::*;
  
  import bsg_cache_pkg::*;
  
 #(parameter bp_cfg_e cfg_p = e_bp_inv_cfg
  `declare_bp_proc_params(cfg_p)
  ,localparam cce_mshr_width_lp = `bp_cce_mshr_width(num_lce_p, lce_assoc_p, paddr_width_p)
  `declare_bp_me_if_widths(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp)
  
  ,localparam block_size_in_words_lp = cce_block_width_p / dword_width_p
  ,localparam block_offset_width_lp = `BSG_SAFE_CLOG2(cce_block_width_p >> 3)
  ,localparam bsg_cache_dma_pkt_width_lp = `bsg_cache_dma_pkt_width(paddr_width_p)
  )
  
  (// Cache DMA side
   input                                           clk_i
  ,input                                           reset_i
  // Sending address and write_en               
  ,output       [bsg_cache_dma_pkt_width_lp-1:0]   dma_pkt_o
  ,output                                          dma_pkt_v_o
  ,input                                           dma_pkt_yumi_i
  // Sending cache block                                          
  ,output       [dword_width_p-1:0]                dma_data_o
  ,output                                          dma_data_v_o
  ,input                                           dma_data_yumi_i
  // Receiving cache block                                        
  ,input        [dword_width_p-1:0]                dma_data_i
  ,input                                           dma_data_v_i
  ,output                                          dma_data_ready_o
  // Cmd input
  ,input        [cce_mem_cmd_width_lp-1:0]         mem_cmd_i
  ,input                                           mem_cmd_v_i
  ,output                                          mem_cmd_yumi_o
  
  ,input        [cce_mem_data_cmd_width_lp-1:0]         mem_data_cmd_i
  ,input                                           mem_data_cmd_v_i
  ,output                                          mem_data_cmd_yumi_o
  // Resp output
  ,output       [mem_cce_resp_width_lp-1:0]         mem_resp_o
  ,output                                          mem_resp_v_o
  ,input                                           mem_resp_ready_i
  
  ,output       [mem_cce_data_resp_width_lp-1:0]         mem_data_resp_o
  ,output                                          mem_data_resp_v_o
  ,input                                           mem_data_resp_ready_i
  );
  
  genvar i;
  localparam fifo_depth_lp = 16;
  localparam data_resp_fifo_width_lp = mem_cce_data_resp_width_lp - cce_block_width_p;
  
  /********************* Packet definition *********************/
  
  // Define cache DMA packet
  `declare_bsg_cache_dma_pkt_s(paddr_width_p);
  
  // cce
  `declare_bp_me_if(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp);
  
  
  /********************* Resp queue fifo *********************/
  
  // Stores CCE packet header information
  logic resp_fifo_valid_li, resp_fifo_ready_lo;
  bp_mem_cce_resp_s resp_fifo_data_li;
  
  bsg_fifo_1r1w_small
 #(.width_p(mem_cce_resp_width_lp)
  ,.els_p  (fifo_depth_lp)
  ) resp_fifo
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  ,.ready_o(resp_fifo_ready_lo)
  ,.data_i (resp_fifo_data_li )
  ,.v_i    (resp_fifo_valid_li)
  ,.v_o    (mem_resp_v_o)
  ,.data_o (mem_resp_o)
  ,.yumi_i (mem_resp_v_o & mem_resp_ready_i)
  );
  
  logic data_resp_fifo_valid_li, data_resp_fifo_ready_lo;
  logic [data_resp_fifo_width_lp-1:0] data_resp_fifo_data_li;
  
  logic data_resp_fifo_valid_lo, data_resp_fifo_yumi_li;
  logic [data_resp_fifo_width_lp-1:0] data_resp_fifo_data_lo;
  
  bsg_fifo_1r1w_small
 #(.width_p(data_resp_fifo_width_lp)
  ,.els_p  (fifo_depth_lp)
  ) data_resp_fifo
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  ,.ready_o(data_resp_fifo_ready_lo)
  ,.data_i (data_resp_fifo_data_li )
  ,.v_i    (data_resp_fifo_valid_li)
  ,.v_o    (data_resp_fifo_valid_lo)
  ,.data_o (data_resp_fifo_data_lo)
  ,.yumi_i (data_resp_fifo_yumi_li)
  );
  
  
  /********************* cce -> cache_dma *********************/
  
  // dma pkt fifo
  logic dma_pkt_fifo_valid_li, dma_pkt_fifo_ready_lo;
  bsg_cache_dma_pkt_s dma_pkt_fifo_data_li;
  
  bsg_two_fifo
 #(.width_p(bsg_cache_dma_pkt_width_lp)
  ) dma_pkt_fifo
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  ,.ready_o(dma_pkt_fifo_ready_lo)
  ,.data_i (dma_pkt_fifo_data_li )
  ,.v_i    (dma_pkt_fifo_valid_li)
  ,.v_o    (dma_pkt_v_o          )
  ,.data_o (dma_pkt_o            )
  ,.yumi_i (dma_pkt_yumi_i       )
  );
  
  // dma data piso
  logic dma_data_fifo_valid_li, dma_data_fifo_ready_lo;
  logic [cce_block_width_p-1:0] dma_data_fifo_data_li;
  
  bsg_parallel_in_serial_out 
 #(.width_p(dword_width_p)
  ,.els_p  (block_size_in_words_lp)
  ) dma_data_piso
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  ,.valid_i(dma_data_fifo_valid_li)
  ,.data_i (dma_data_fifo_data_li)
  ,.ready_o(dma_data_fifo_ready_lo)
  ,.valid_o(dma_data_v_o)
  ,.data_o (dma_data_o)
  ,.yumi_i (dma_data_yumi_i)
  );
  
  // input mem cmd
  bp_cce_mem_cmd_s mem_cmd_li;
  bp_cce_mem_data_cmd_s mem_data_cmd_li;
  logic mem_cmd_yumi_lo, mem_data_cmd_yumi_lo;
  
  assign mem_cmd_li = mem_cmd_i;
  assign mem_cmd_yumi_o = mem_cmd_yumi_lo;
  assign mem_data_cmd_li = mem_data_cmd_i;
  assign mem_data_cmd_yumi_o = mem_data_cmd_yumi_lo;
  
  // combinational logics
  always_comb 
  begin
  
    mem_cmd_yumi_lo = 1'b0;
    mem_data_cmd_yumi_lo = 1'b0;
    dma_pkt_fifo_valid_li = 1'b0;
    dma_data_fifo_valid_li = 1'b0;
    resp_fifo_valid_li = 1'b0;
    data_resp_fifo_valid_li = 1'b0;
    
    dma_pkt_fifo_data_li.write_not_read = 1'b1;
    // WARNING: Zeroing out low address bits for full cache block requests
    dma_pkt_fifo_data_li.addr = {mem_data_cmd_li.addr[paddr_width_p-1:block_offset_width_lp], (block_offset_width_lp)'(0)};
    dma_data_fifo_data_li = mem_data_cmd_li.data;
    
    resp_fifo_data_li.payload       = mem_data_cmd_li.payload;
    resp_fifo_data_li.addr          = mem_data_cmd_li.addr;
    resp_fifo_data_li.msg_type      = mem_data_cmd_li.msg_type;
    resp_fifo_data_li.nc_size       = mem_data_cmd_li.nc_size;
    resp_fifo_data_li.non_cacheable = mem_data_cmd_li.non_cacheable;
    
    data_resp_fifo_data_li = {mem_cmd_li.payload, mem_cmd_li.addr, mem_cmd_li.msg_type, mem_cmd_li.nc_size, mem_cmd_li.non_cacheable};
    
    if (dma_pkt_fifo_ready_lo & resp_fifo_ready_lo & data_resp_fifo_ready_lo)
      begin
        if (mem_data_cmd_v_i)
          begin
            if (dma_data_fifo_ready_lo)
              begin
                dma_pkt_fifo_valid_li = 1'b1;
                resp_fifo_valid_li = 1'b1;
                dma_data_fifo_valid_li = 1'b1;
                mem_data_cmd_yumi_lo = 1'b1;
              end
          end
        else if (mem_cmd_v_i)
          begin
            dma_pkt_fifo_data_li.write_not_read = 1'b0;
            // WARNING: Zeroing out low address bits for full cache block requests
            dma_pkt_fifo_data_li.addr = {mem_cmd_li.addr[paddr_width_p-1:block_offset_width_lp], (block_offset_width_lp)'(0)};
            dma_pkt_fifo_valid_li = 1'b1;
            data_resp_fifo_valid_li = 1'b1;
            mem_cmd_yumi_lo = 1'b1;
          end
      end
  
  end
  
  
  /********************* cache_dma -> cce *********************/
  
  // dma data sipof
  logic dma_data_fifo_valid_lo, dma_data_fifo_yumi_li;
  logic [cce_block_width_p-1:0] dma_data_fifo_data_lo;
  
  bsg_serial_in_parallel_out_full
 #(.width_p(dword_width_p         )
  ,.els_p  (block_size_in_words_lp)
  ) dma_data_sipof
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  
  ,.v_i    (dma_data_v_i)
  ,.ready_o(dma_data_ready_o)
  ,.data_i (dma_data_i)

  ,.data_o (dma_data_fifo_data_lo )
  ,.v_o    (dma_data_fifo_valid_lo)
  ,.yumi_i (dma_data_fifo_yumi_li)
  );
  
  // mem resp output
  bp_mem_cce_data_resp_s mem_data_resp_lo;
  logic mem_data_resp_v_lo;
  
  assign mem_data_resp_o = mem_data_resp_lo;
  assign mem_data_resp_v_o = mem_data_resp_v_lo;
  
  // combinational logics
  always_comb
  begin
  
    mem_data_resp_v_lo = 1'b0;
    dma_data_fifo_yumi_li = 1'b0;
    data_resp_fifo_yumi_li = 1'b0;
    
    {mem_data_resp_lo.payload, mem_data_resp_lo.addr, mem_data_resp_lo.msg_type, mem_data_resp_lo.nc_size, mem_data_resp_lo.non_cacheable} = data_resp_fifo_data_lo;
    mem_data_resp_lo.data = dma_data_fifo_data_lo;
    
    if (~reset_i & data_resp_fifo_valid_lo)
      begin
        if (dma_data_fifo_valid_lo)
          begin
            mem_data_resp_v_lo = 1'b1;
            if (mem_data_resp_ready_i)
              begin
                data_resp_fifo_yumi_li = 1'b1;
                dma_data_fifo_yumi_li = 1'b1;
              end
          end
      end
    
  end
  
endmodule
