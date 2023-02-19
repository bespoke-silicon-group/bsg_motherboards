/**
 *  bp_stream_nbf_loader.v
 *
 */

module bp_stream_nbf_loader

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
  ,parameter clear_freeze_p = 0

  ,parameter nbf_opcode_width_p = 8
  ,parameter nbf_addr_width_p = 40 // hard-coded
  ,parameter nbf_data_width_p = dword_width_p
  
  ,localparam nbf_width_lp = nbf_opcode_width_p + nbf_addr_width_p + nbf_data_width_p
  ,localparam nbf_num_flits_lp = `BSG_CDIV(nbf_width_lp, stream_data_width_p)
  )

  (input  clk_i
  ,input  reset_i
  ,output done_o
  
  ,output [cce_mem_data_cmd_width_lp-1:0]        io_data_cmd_o
  ,output                                   io_data_cmd_v_o
  ,input                                    io_data_cmd_yumi_i
  
  ,input  [mem_cce_resp_width_lp-1:0]        io_resp_i
  ,input                                    io_resp_v_i
  ,output                                   io_resp_ready_o
  
  ,input                                    stream_v_i
  ,input  [stream_data_width_p-1:0]         stream_data_i
  ,output                                   stream_ready_o
  );
  
  // response network not used
  wire unused_resp = &{io_resp_i, io_resp_v_i};
  assign io_resp_ready_o = 1'b1;
  
  // nbf credit counter
  logic [`BSG_WIDTH(16)-1:0] credit_count_lo;
  wire credits_full_lo  = (credit_count_lo == 16);
  wire credits_empty_lo = (credit_count_lo == '0);
  
  bsg_flow_counter
 #(.els_p  (16)
  ) nbf_counter
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.v_i    (io_data_cmd_yumi_i)
  ,.ready_i(1'b1)
  ,.yumi_i (io_resp_v_i)
  ,.count_o(credit_count_lo)
  );

  // bp_nbf packet
  typedef struct packed {
    logic [nbf_opcode_width_p-1:0] opcode;
    logic [nbf_addr_width_p-1:0]   addr;
    logic [nbf_data_width_p-1:0]   data;
  } bp_nbf_s;

  // bp_cce packet
  `declare_bp_me_if(paddr_width_p, cce_block_width_p, num_lce_p, lce_assoc_p, cce_mshr_width_lp);
  bp_cce_mem_data_cmd_s io_data_cmd;
  bp_mem_cce_resp_s     io_resp;
  logic io_data_cmd_v_lo;
  
  assign io_data_cmd_o = io_data_cmd;
  assign io_resp = io_resp_i;
  assign io_data_cmd_v_o = io_data_cmd_v_lo;

  // read nbf file
  logic incoming_nbf_v_lo, incoming_nbf_yumi_li;
  logic [nbf_num_flits_lp-1:0][stream_data_width_p-1:0] incoming_nbf;
  
  bsg_serial_in_parallel_out_full
 #(.width_p(stream_data_width_p)
  ,.els_p  (nbf_num_flits_lp)
  ) sipo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.v_i    (stream_v_i)
  ,.ready_o(stream_ready_o)
  ,.data_i (stream_data_i)
  ,.data_o (incoming_nbf)
  ,.v_o    (incoming_nbf_v_lo)
  ,.yumi_i (incoming_nbf_yumi_li)
  );
  
  bp_nbf_s curr_nbf;
  assign curr_nbf = nbf_width_lp'(incoming_nbf);
  
  // assemble cce cmd packet
  always_comb
  begin

  end
  
  logic [31:0] counter_r, counter_n;
  logic [1:0] state_r, state_n;
  
  assign done_o = (state_r == 3) & credits_empty_lo;
  
  wire [paddr_width_p-1:0] freeze_addr = '0;
 
 // combinational
  always_comb 
  begin
  
    io_data_cmd.data = curr_nbf.data;
    io_data_cmd.payload = '0;
    io_data_cmd.addr = curr_nbf.addr;
    io_data_cmd.msg_type = e_lce_req_type_wr;
    io_data_cmd.non_cacheable = e_lce_req_non_cacheable;
    
    case (curr_nbf.opcode)
      2: io_data_cmd.nc_size = e_lce_nc_req_4;
      3: io_data_cmd.nc_size = e_lce_nc_req_8;
      default: io_data_cmd.nc_size = e_lce_nc_req_4;
    endcase
  
    state_n = state_r;
    counter_n = counter_r;
    io_data_cmd_v_lo = 1'b0;
    incoming_nbf_yumi_li = 1'b0;
    
    if (state_r == 0)
      begin
        if (~reset_i)
          begin
            io_data_cmd_v_lo = ~credits_full_lo;
            io_data_cmd.data = '0;
            io_data_cmd.addr = counter_r;
            io_data_cmd.nc_size = e_lce_nc_req_8;
            if (io_data_cmd_yumi_i)
              begin
                counter_n = counter_r + 32'h8;
                if (counter_r == 32'h84000000)
                  begin
                    counter_n = '0;
                    state_n = 1;
                  end
              end
          end
      end
    else if (state_r == 1)
      begin
        if (incoming_nbf_v_lo) 
          begin
            io_data_cmd_v_lo = ~credits_full_lo;
            incoming_nbf_yumi_li = io_data_cmd_yumi_i;
            if (curr_nbf.opcode == 8'hFF)
              begin
                if (clear_freeze_p == 0)
                  begin
                    io_data_cmd.addr = 32'h00000000;
                    io_data_cmd.nc_size = e_lce_nc_req_8;
                    io_data_cmd.data = '0;
                    if (io_data_cmd_yumi_i)
                      begin
                        state_n = 3;
                      end
                  end
                else
                  begin
                    io_data_cmd_v_lo = 1'b0;
                    incoming_nbf_yumi_li = 1'b0;
                    state_n = 2;
                  end
              end
          end
      end
    else if (state_r == 2)
      begin
        io_data_cmd_v_lo = ~credits_full_lo;
        io_data_cmd.data = '0;
        io_data_cmd.addr = freeze_addr;
        io_data_cmd.nc_size = e_lce_nc_req_8;
        if (io_data_cmd_yumi_i)
          begin
            counter_n = counter_r + 32'd1;
            if (counter_r == num_core_p-1)
              begin
                counter_n = '0;
                state_n = 3;
              end
          end
      end
      
  end

  // sequential
  always_ff @(posedge clk_i)
    if (reset_i) 
      begin
        state_r <= '0;
        counter_r <= 32'h80000000;
      end
    else 
      begin
        state_r <= state_n;
        counter_r <= counter_n;
      end

endmodule
