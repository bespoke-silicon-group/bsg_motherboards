/**
 *  bsg_serial_in_parallel_out_full.v
 *
 *  This is a simpler version of bsg_serial_in_parallel_out.
 *  Output is only valid, when the output vector is fully assembled.
 *
 *  @author tommy
 */

module bsg_serial_in_parallel_out_full
  #(parameter width_p="inv"
    , parameter els_p="inv"
    , parameter msb_then_lsb_p = 0
    , localparam counter_width_lp=`BSG_SAFE_CLOG2(els_p+1)
    , localparam lg_els_lp=`BSG_SAFE_CLOG2(els_p)
    , localparam terminate_cnt_lp = (msb_then_lsb_p == 0)? els_p : (1<<counter_width_lp)-1
    , localparam init_cnt_lp = (msb_then_lsb_p == 0)? 0 : els_p-1
  )
  (
    input clk_i
    , input reset_i
    
    , input v_i
    , output logic ready_o
    , input [width_p-1:0] data_i

    , output logic [els_p-1:0][width_p-1:0]  data_o
    , output logic v_o
    , input yumi_i
  );

  logic [els_p-1:0][width_p-1:0] data_r;

  assign data_o = data_r;
 
  // counter
  //
  logic [counter_width_lp-1:0] count_lo;
  logic clear_li;
  logic up_li;
  
  if (msb_then_lsb_p == 0) begin: lsb_first

  bsg_counter_clear_up #(
    .max_val_p(els_p)
    ,.init_val_p(0)
  ) counter (
    .clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.clear_i(clear_li)
    ,.up_i(up_li)

    ,.count_o(count_lo)
  ); 
  
  end else begin: msb_first
  
  always_ff @(posedge clk_i)
    if (reset_i | clear_li) 
        count_lo <= init_cnt_lp;
    else 
        count_lo <= count_lo - up_li;
  
  end

  always_comb begin
    if (count_lo == terminate_cnt_lp) begin
      v_o = 1'b1;
      ready_o = 1'b0;
      clear_li = yumi_i;
      up_li = 1'b0;
    end
    else begin
      v_o = 1'b0;
      ready_o = 1'b1;
      clear_li = 1'b0;
      up_li = v_i;
    end
  end

  always_ff @ (posedge clk_i) begin
    if (v_i & ready_o) begin
      data_r[count_lo[0+:lg_els_lp]] <= data_i;
    end
  end

endmodule
