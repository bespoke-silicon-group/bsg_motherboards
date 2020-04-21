/**
 *  mc_stream_mmio.v
 *
 */

module mc_stream_mmio

 #(parameter x_cord_width_p      = "inv"
  ,parameter y_cord_width_p      = "inv"
  ,parameter addr_width_p        = "inv"
  ,parameter data_width_p        = "inv"
  ,parameter load_id_width_p     = "inv"
  ,parameter stream_data_width_p = "inv"
  ,parameter data_mask_width_lp  = (data_width_p >> 3)
  )

  (input                            clk_i
  ,input                            reset_i

  ,input                            v_i
  ,input  [data_width_p-1:0]        data_i
  ,input  [data_mask_width_lp-1:0]  mask_i
  ,input  [addr_width_p-1:0]        addr_i
  ,input                            we_i
  ,input  [x_cord_width_p-1:0]      src_x_cord_i
  ,input  [y_cord_width_p-1:0]      src_y_cord_i
  ,output logic                     yumi_o

  ,output logic [data_width_p-1:0]  data_o
  ,output logic                     v_o

  ,input                            stream_v_i
  ,input  [stream_data_width_p-1:0] stream_data_i
  ,output                           stream_ready_o

  ,output                           stream_v_o
  ,output [stream_data_width_p-1:0] stream_data_o
  ,input                            stream_yumi_i
  );

  // streaming out piso
  logic piso_v_li, piso_ready_lo;
  assign piso_v_li = yumi_o;

  bsg_parallel_in_serial_out 
 #(.width_p(stream_data_width_p)
  ,.els_p  (`BSG_CDIV(96, stream_data_width_p))
  ) piso
  (.clk_i  (clk_i  )
  ,.reset_i(reset_i)
  ,.valid_i(piso_v_li)
  ,.data_i ({32'(data_i) ,32'(addr_i) ,8'(mask_i), 8'(we_i), 8'(src_y_cord_i), 8'(src_x_cord_i)})
  ,.ready_o(piso_ready_lo)
  ,.valid_o(stream_v_o)
  ,.data_o (stream_data_o)
  ,.yumi_i (stream_yumi_i)
  );
  
  // queue fifo
  logic queue_fifo_v_li, queue_fifo_ready_lo;
  logic queue_fifo_v_lo, queue_fifo_yumi_li;
  logic we_lo;
  
  assign queue_fifo_v_li = yumi_o;
  assign queue_fifo_yumi_li = v_o;
  
  bsg_fifo_1r1w_small
 #(.width_p(1)
  ,.els_p  (16)
  ) queue_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.data_i (we_i)
  ,.v_i    (queue_fifo_v_li)
  ,.ready_o(queue_fifo_ready_lo)
  ,.data_o (we_lo)
  ,.v_o    (queue_fifo_v_lo)
  ,.yumi_i (queue_fifo_yumi_li)
  );
  
  // resp sipo
  logic sipo_v_lo, sipo_yumi_li;
  logic [data_width_p-1:0] sipo_data_lo;
  
  assign sipo_yumi_li = v_o & sipo_v_lo;
  
  bsg_serial_in_parallel_out_full
 #(.width_p(stream_data_width_p)
  ,.els_p  (data_width_p/stream_data_width_p)
  ) stream_sipo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.v_i    (stream_v_i)
  ,.ready_o(stream_ready_o)
  ,.data_i (stream_data_i)
  ,.data_o (sipo_data_lo)
  ,.v_o    (sipo_v_lo)
  ,.yumi_i (sipo_yumi_li)
  );
  
  assign yumi_o = v_i & piso_ready_lo & queue_fifo_ready_lo;
  assign v_o    = queue_fifo_v_lo & (we_lo | sipo_v_lo);
  assign data_o = (queue_fifo_v_lo & ~we_lo)? sipo_data_lo : '0;

endmodule