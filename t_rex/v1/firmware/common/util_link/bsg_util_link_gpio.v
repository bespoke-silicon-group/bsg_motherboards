
`include "bsg_noc_links.vh"

module bsg_util_link_gpio

 #(parameter flit_width_p = "inv"
  ,parameter num_gpio_p   = "inv"
  ,parameter cord_width_p = "inv"
  ,parameter len_width_p  = "inv"
  ,localparam bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(flit_width_p)
  ,localparam lg_num_gpio_lp = `BSG_SAFE_CLOG2(num_gpio_p)
  )

  (input clk_i
  ,input reset_i

  ,output [num_gpio_p-1:0] gpio_o

  ,input  [bsg_ready_and_link_sif_width_lp-1:0] link_i
  ,output [bsg_ready_and_link_sif_width_lp-1:0] link_o
  ) ;

  // Stream link
  `declare_bsg_ready_and_link_sif_s(flit_width_p, bsg_ready_and_link_sif_s);
  bsg_ready_and_link_sif_s link_i_cast, link_o_cast;
  assign link_i_cast = link_i;
  assign link_o      = link_o_cast;

  logic                         link_valid_lo;
  logic [1:0][flit_width_p-1:0] link_data_lo;

  bsg_serial_in_parallel_out_full
 #(.width_p(flit_width_p)
  ,.els_p  (2)
  ) link_sipof
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)

  ,.v_i    (link_i_cast.v)
  ,.ready_o(link_o_cast.ready_and_rev)
  ,.data_i (link_i_cast.data)

  ,.data_o (link_data_lo)
  ,.v_o    (link_valid_lo)
  ,.yumi_i (link_valid_lo)
  );

  // tieoff output link
  assign link_o_cast.v = 1'b0;
  assign link_o_cast.data = '0;

  // gpio reg
  wire [lg_num_gpio_lp-1:0] gpio_sel = link_data_lo[1][lg_num_gpio_lp-1:0];
  wire                      gpio_val = link_data_lo[1][flit_width_p-1];

  logic [num_gpio_p-1:0] gpio_r, gpio_n;
  assign gpio_o = gpio_r;
  
  for (genvar i = 0; i < num_gpio_p; i++)
    assign gpio_n[i] = (i == gpio_sel)? gpio_val : gpio_r[i];

  bsg_dff_reset_en
 #(.width_p    (num_gpio_p)
  ,.reset_val_p({num_gpio_p{1'b1}})
  ) gpio_reg
  (.clk_i  (clk_i         )
  ,.reset_i(reset_i       )
  ,.en_i   (link_valid_lo )
  ,.data_i (gpio_n        )
  ,.data_o (gpio_r        )
  );

endmodule
