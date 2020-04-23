
`include "bsg_noc_links.vh"

module bsg_uart_axil_s_to_fifo

 #(parameter addr_width_p     = "inv"
  ,parameter data_width_p     = "inv"
  ,parameter uart_data_bits_p = "inv"
  ,parameter buffer_size_p    = "inv"
  
  ,localparam bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(uart_data_bits_p)  
  )
  
  (input clk_i
  ,input reset_i
  
  ,output logic [addr_width_p-1:0]     araddr_o
  ,input                               arready_i
  ,output logic                        arvalid_o

  ,output logic [addr_width_p-1:0]     awaddr_o
  ,input                               awready_i
  ,output logic                        awvalid_o

  ,output logic                        bready_o
  ,input        [1:0]                  bresp_i
  ,input                               bvalid_i

  ,input        [data_width_p-1:0]     rdata_i
  ,output logic                        rready_o
  ,input        [1:0]                  rresp_i
  ,input                               rvalid_i

  ,output logic [data_width_p-1:0]     wdata_o
  ,input                               wready_i
  ,output logic [data_width_p/8-1:0]   wstrb_o
  ,output logic                        wvalid_o

  ,input  [bsg_ready_and_link_sif_width_lp-1:0] link_i
  ,output [bsg_ready_and_link_sif_width_lp-1:0] link_o
  );

  `declare_bsg_ready_and_link_sif_s(uart_data_bits_p, bsg_ready_and_link_sif_s);
  bsg_ready_and_link_sif_s link_i_cast, link_o_cast;
  
  assign link_i_cast = link_i;
  assign link_o      = link_o_cast;


  /************************ buffer fifo ************************/

  // rx fifo
  logic rx_fifo_v_li, rx_fifo_ready_lo;
  logic [uart_data_bits_p-1:0] rx_fifo_data_li;
  
  bsg_fifo_1r1w_small 
 #(.width_p(uart_data_bits_p)
  ,.els_p  (buffer_size_p)
  ) rx_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.ready_o(rx_fifo_ready_lo)
  ,.data_i (rx_fifo_data_li)
  ,.v_i    (rx_fifo_v_li)
  ,.v_o    (link_o_cast.v)
  ,.data_o (link_o_cast.data)
  ,.yumi_i (link_o_cast.v & link_i_cast.ready_and_rev)
  );
  
  // tx fifo
  logic tx_fifo_v_lo, tx_fifo_yumi_li;
  logic [uart_data_bits_p-1:0] tx_fifo_data_lo;
  
  bsg_fifo_1r1w_small 
 #(.width_p(uart_data_bits_p)
  ,.els_p  (buffer_size_p)
  ) tx_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.ready_o(link_o_cast.ready_and_rev)
  ,.data_i (link_i_cast.data)
  ,.v_i    (link_i_cast.v)
  ,.v_o    (tx_fifo_v_lo)
  ,.data_o (tx_fifo_data_lo)
  ,.yumi_i (tx_fifo_yumi_li)
  );


  /************************ state machine ************************/
  
  typedef enum logic [3:0] {
    RESET
   ,INIT
   ,STAT_READ
   ,STAT_RESP
   ,RX_READ
   ,RX_RESP
   ,TX_WRITE
   ,TX_ACK
  } state_e;
  
  state_e state_r, state_n;
  logic [7:0] stat_r, stat_n;
  
  always_ff @(posedge clk_i)
  begin
    if (reset_i)
      begin
        state_r <= RESET;
        stat_r  <= '0;
      end
    else
      begin
        state_r <= state_n;
        stat_r  <= stat_n;
      end
  end
  
  always_comb
  begin
    
    state_n = state_r;
    stat_n = stat_r;
    
    rx_fifo_v_li = 1'b0;
    rx_fifo_data_li = rdata_i[uart_data_bits_p-1:0];
    tx_fifo_yumi_li = 1'b0;
    
    araddr_o = '0;
    arvalid_o = 1'b0;
    awaddr_o = '0;
    awvalid_o = 1'b0;
    bready_o = 1'b1;
    rready_o = 1'b1;
    wdata_o = data_width_p'(tx_fifo_data_lo);
    wstrb_o = '1;
    wvalid_o = 1'b0;
    
    case (state_r)
    
    RESET:
      begin
        state_n = INIT;
      end
    INIT:
      begin
        state_n = STAT_READ;
      end
    STAT_READ:
      begin
        araddr_o = 4'h8;
        arvalid_o = 1'b1;
        if (arready_i)
          begin
            state_n = STAT_RESP;
          end
      end
    STAT_RESP:
      begin
        if (rvalid_i)
          begin
            stat_n = rdata_i[7:0];
            state_n = RX_READ;
          end
      end
    RX_READ:
      begin
        if (~stat_r[0] | ~rx_fifo_ready_lo)
          begin
            state_n = TX_WRITE;
          end
        else
          begin
            araddr_o = 4'h0;
            arvalid_o = 1'b1;
            if (arready_i)
              begin
                state_n = RX_RESP;
              end
          end
      end
    RX_RESP:
      begin
        rready_o = rx_fifo_ready_lo;
        rx_fifo_v_li = rvalid_i;
        if (rvalid_i & rready_o)
          begin
            state_n = TX_WRITE;
          end
      end
    TX_WRITE:
      begin
        if (stat_r[3] | ~tx_fifo_v_lo)
          begin
            state_n = STAT_READ;
          end
        else
          begin
            awaddr_o = 4'h4;
            awvalid_o = 1'b1;
            wvalid_o = 1'b1;
            if (awready_i & wready_i)
              begin
                tx_fifo_yumi_li = 1'b1;
                state_n = TX_ACK;
              end
          end
      end
    TX_ACK:
      begin
        if (bvalid_i)
          begin
            state_n = STAT_READ;
          end
      end
    default:
      begin
      end
    
    endcase
    
  end

endmodule
