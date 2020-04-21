
//
// bsg_m_axi_lite_to_fifo.v
//
//

module bsg_m_axi_lite_to_fifo

 #(parameter addr_width_p = 32
  ,parameter data_width_p = 32
  ,parameter buffer_size_p = 32
  ,parameter num_repeater_nodes_p = 0

  ,localparam buffer_counter_width_lp = `BSG_WIDTH(buffer_size_p)
  )
  
  (input pcie_clk_i
  ,input pcie_reset_i
  
  // read address
  ,input  [addr_width_p-1:0] araddr_i
  ,input  [2:0]              arprot_i
  ,output                    arready_o
  ,input                     arvalid_i
  // read data
  ,output [data_width_p-1:0] rdata_o
  ,input                     rready_i
  ,output [1:0]              rresp_o
  ,output                    rvalid_o
  // write address
  ,input  [addr_width_p-1:0] awaddr_i
  ,input  [2:0]              awprot_i
  ,output                    awready_o
  ,input                     awvalid_i
  // write data
  ,input  [data_width_p-1:0] wdata_i
  ,output                    wready_o
  ,input  [3:0]              wstrb_i
  ,input                     wvalid_i
  // write response
  ,input                     bready_i
  ,output [1:0]              bresp_o
  ,output                    bvalid_o
  
  ,input                     clk_i
  ,input                     reset_i
  // fifo output
  ,output                    v_o
  ,output [addr_width_p-1:0] addr_o
  ,output [data_width_p-1:0] data_o
  ,input                     yumi_i
  // fifo input
  ,input                     v_i
  ,input  [data_width_p-1:0] data_i
  ,output                    ready_o
  );
  
  
  /************************ repeater nodes ************************/
  
  logic v_lo, yumi_li, v_li, ready_lo;
  logic [data_width_p-1:0] data_li, data_lo;
  logic [addr_width_p-1:0] addr_lo;
  
  logic [num_repeater_nodes_p:0] rep_v_lo, rep_ready_li, rep_v_li, rep_ready_lo;
  logic [num_repeater_nodes_p:0][data_width_p-1:0] rep_data_li, rep_data_lo;
  logic [num_repeater_nodes_p:0][addr_width_p-1:0] rep_addr_lo;
  
  for (genvar i = 0; i < num_repeater_nodes_p; i++)
  begin: repeater
    bsg_two_fifo
   #(.width_p(addr_width_p+data_width_p))
    A_to_B
    (.clk_i  (clk_i)
    ,.reset_i(reset_i)
    ,.v_i    (rep_v_lo[i])
    ,.data_i ({rep_addr_lo[i], rep_data_lo[i]})
    ,.ready_o(rep_ready_li[i])
    ,.v_o    (rep_v_lo[i+1])
    ,.data_o ({rep_addr_lo[i+1], rep_data_lo[i+1]})
    ,.yumi_i (rep_v_lo[i+1] & rep_ready_li[i+1])
    );

    bsg_two_fifo
   #(.width_p(data_width_p))
    B_to_A
    (.clk_i  (clk_i)
    ,.reset_i(reset_i)
    ,.v_i    (rep_v_li[i+1])
    ,.data_i (rep_data_li[i+1])
    ,.ready_o(rep_ready_lo[i+1])
    ,.v_o    (rep_v_li[i])
    ,.data_o (rep_data_li[i])
    ,.yumi_i (rep_v_li[i] & rep_ready_lo[i])
    );
  end
  
  // A side stitching
  assign rep_v_lo    [0] = v_lo;
  assign rep_addr_lo [0] = addr_lo;
  assign rep_data_lo [0] = data_lo;
  assign yumi_li         = rep_v_lo[0] & rep_ready_li[0];

  assign v_li            = rep_v_li[0];
  assign data_li         = rep_data_li[0];
  assign rep_ready_lo[0] = ready_lo;
  
  // B side stitching
  assign v_o = rep_v_lo[num_repeater_nodes_p];
  assign addr_o = rep_addr_lo[num_repeater_nodes_p];
  assign data_o = rep_data_lo[num_repeater_nodes_p];
  assign rep_ready_li[num_repeater_nodes_p] = yumi_i;
  
  assign rep_v_li[num_repeater_nodes_p] = v_i;
  assign rep_data_li[num_repeater_nodes_p] = data_i;
  assign ready_o = rep_ready_lo[num_repeater_nodes_p];
  
  
  /************************ axi_lite read ************************/
  
  logic buffer_async_fifo_v_lo, buffer_async_fifo_ready_li;
  logic [data_width_p-1:0] buffer_async_fifo_data_lo;
  
  logic buffer_async_fifo_full_lo;
  assign ready_lo = ~buffer_async_fifo_full_lo;
  
  bsg_async_fifo
 #(.lg_size_p(8)
  ,.width_p  (data_width_p)
  ) buffer_async_fifo
  (.w_clk_i  (clk_i)
  ,.w_reset_i(reset_i)
  ,.w_enq_i  (v_li & ready_lo)
  ,.w_data_i (data_li)
  ,.w_full_o (buffer_async_fifo_full_lo)

  ,.r_clk_i  (pcie_clk_i)
  ,.r_reset_i(pcie_reset_i)
  ,.r_deq_i  (buffer_async_fifo_v_lo & buffer_async_fifo_ready_li)
  ,.r_data_o (buffer_async_fifo_data_lo)
  ,.r_valid_o(buffer_async_fifo_v_lo)
  );
  
  // data buffer
  logic buffer_fifo_v_lo, buffer_fifo_yumi_li;
  logic [data_width_p-1:0] buffer_fifo_data_lo;
  
  bsg_fifo_1r1w_small 
 #(.width_p(data_width_p)
  ,.els_p  (buffer_size_p)
  ) buffer_fifo
  (.clk_i  (pcie_clk_i)
  ,.reset_i(pcie_reset_i)
  ,.ready_o(buffer_async_fifo_ready_li)
  ,.data_i (buffer_async_fifo_data_lo)
  ,.v_i    (buffer_async_fifo_v_lo)
  ,.v_o    (buffer_fifo_v_lo)
  ,.data_o (buffer_fifo_data_lo)
  ,.yumi_i (buffer_fifo_yumi_li)
  );
  
  // data_buffer counter
  logic [buffer_counter_width_lp-1:0] buffer_counter_lo;
  
  bsg_counter_up_down 
 #(.max_val_p (buffer_size_p)
  ,.init_val_p(0)
  ,.max_step_p(1)
  ) buffer_counter
  (.clk_i  (pcie_clk_i)
  ,.reset_i(pcie_reset_i)
  ,.up_i   (buffer_async_fifo_v_lo & buffer_async_fifo_ready_li)
  ,.down_i (buffer_fifo_yumi_li)
  ,.count_o(buffer_counter_lo)
  );
  
  // read response
  logic [data_width_p-1:0] read_fifo_data_li;
  assign rresp_o = 2'b00; // 2'b00 means OKAY
  
  bsg_fifo_1r1w_small 
 #(.width_p(data_width_p)
  ,.els_p  (4)
  ) read_fifo
  (.clk_i  (pcie_clk_i)
  ,.reset_i(pcie_reset_i)
  ,.ready_o(arready_o)
  ,.data_i (read_fifo_data_li)
  ,.v_i    (arvalid_i)
  ,.v_o    (rvalid_o)
  ,.data_o (rdata_o)
  ,.yumi_i (rvalid_o & rready_i)
  );
  
  always_comb
  begin
    buffer_fifo_yumi_li = 1'b0;
    read_fifo_data_li = data_width_p'(32'hdeadbeef);
    if (araddr_i == '0)
        read_fifo_data_li = {'0, buffer_counter_lo};
    else
        if (buffer_fifo_v_lo)
          begin
            buffer_fifo_yumi_li = arvalid_i & arready_o;
            read_fifo_data_li = buffer_fifo_data_lo;
          end
  end


  /************************ axi_lite write ************************/

  // address and data fifo
  logic addr_fifo_v_lo, data_fifo_v_lo;
  assign v_lo = addr_fifo_v_lo & data_fifo_v_lo;
  
  logic data_fifo_ready_lo, b_fifo_ready_lo;
  assign wready_o = data_fifo_ready_lo & b_fifo_ready_lo;
  
  // write response
  assign bresp_o = 2'b00; // 2'b00 means OKAY
  
  bsg_fifo_1r1w_small 
 #(.width_p(1)
  ,.els_p  (4)
  ) b_fifo
  (.clk_i  (pcie_clk_i)
  ,.reset_i(pcie_reset_i)
  ,.ready_o(b_fifo_ready_lo)
  ,.data_i ('0)
  ,.v_i    (wvalid_i & wready_o)
  ,.v_o    (bvalid_o)
  ,.data_o ()
  ,.yumi_i (bvalid_o & bready_i)
  );
  
  logic addr_async_fifo_full_lo, data_async_fifo_full_lo;
  assign awready_o = ~addr_async_fifo_full_lo;
  assign data_fifo_ready_lo = ~data_async_fifo_full_lo;
  
  bsg_async_fifo
 #(.lg_size_p(8)
  ,.width_p  (addr_width_p)
  ) addr_async_fifo
  (.w_clk_i  (pcie_clk_i)
  ,.w_reset_i(pcie_reset_i)
  ,.w_enq_i  (awvalid_i & awready_o)
  ,.w_data_i (awaddr_i)
  ,.w_full_o (addr_async_fifo_full_lo)

  ,.r_clk_i  (clk_i)
  ,.r_reset_i(reset_i)
  ,.r_deq_i  (yumi_li)
  ,.r_data_o (addr_lo)
  ,.r_valid_o(addr_fifo_v_lo)
  );
  
  bsg_async_fifo
 #(.lg_size_p(8)
  ,.width_p  (data_width_p)
  ) data_async_fifo
  (.w_clk_i  (pcie_clk_i)
  ,.w_reset_i(pcie_reset_i)
  ,.w_enq_i  (wvalid_i & wready_o)
  ,.w_data_i (wdata_i)
  ,.w_full_o (data_async_fifo_full_lo)

  ,.r_clk_i  (clk_i)
  ,.r_reset_i(reset_i)
  ,.r_deq_i  (yumi_li)
  ,.r_data_o (data_lo)
  ,.r_valid_o(data_fifo_v_lo)
  );

endmodule