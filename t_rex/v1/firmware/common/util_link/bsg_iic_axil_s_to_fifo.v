
`include "bsg_noc_links.vh"

module bsg_iic_axil_s_to_fifo

 #(parameter addr_width_p     = "inv"
  ,parameter data_width_p     = "inv"
  ,parameter iic_data_bits_p  = "inv"
  ,parameter buffer_size_p    = "inv"
  ,parameter cord_width_p     = "inv"
  ,parameter len_width_p      = "inv"
  
  ,localparam bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(iic_data_bits_p)  
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

  ,input        [cord_width_p-1:0]     dest_cord_i
  
  ,input  [bsg_ready_and_link_sif_width_lp-1:0] link_i
  ,output [bsg_ready_and_link_sif_width_lp-1:0] link_o
  );

  `declare_bsg_ready_and_link_sif_s(iic_data_bits_p, bsg_ready_and_link_sif_s);
  bsg_ready_and_link_sif_s link_i_cast, link_o_cast;
  
  assign link_i_cast = link_i;
  assign link_o      = link_o_cast;


  /************************ buffer fifo ************************/

  // rx fifo
  logic rx_fifo_v_li, rx_fifo_ready_lo;
  logic [iic_data_bits_p-1:0] rx_fifo_data_li;
  
  bsg_fifo_1r1w_small 
 #(.width_p(iic_data_bits_p)
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
  logic tx_sipod_v_lo, tx_sipod_ready_li;
  logic [2**len_width_p-1:0][iic_data_bits_p-1:0] tx_sipod_data_lo;
  
  bsg_serial_in_parallel_out_dynamic                           
 #(.width_p  (iic_data_bits_p)
  ,.max_els_p(2**len_width_p)
  ) tx_sipod
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)

  ,.v_i        (link_i_cast.v)
  ,.len_i      (link_i_cast.data[cord_width_p+:len_width_p])
  ,.data_i     (link_i_cast.data)
  ,.ready_o    (link_o_cast.ready_and_rev)
  ,.len_ready_o()

  ,.v_o        (tx_sipod_v_lo)
  ,.data_o     (tx_sipod_data_lo)
  ,.yumi_i     (tx_sipod_v_lo & tx_sipod_ready_li)
  );
  
  logic tx_fifo_v_lo, tx_fifo_yumi_li;
  logic [iic_data_bits_p-1:0] tx_fifo_data_lo;
  
  bsg_parallel_in_serial_out_dynamic
 #(.width_p  (iic_data_bits_p)
  ,.max_els_p(2**len_width_p - 1)
  ) tx_pisod
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  
  ,.v_i    (tx_sipod_v_lo)
  ,.len_i  (tx_sipod_data_lo[0][cord_width_p+:len_width_p] - (len_width_p)'(1))
  ,.data_i (tx_sipod_data_lo[2**len_width_p-1:1])
  ,.ready_o(tx_sipod_ready_li)

  ,.v_o    (tx_fifo_v_lo)
  ,.len_v_o()
  ,.data_o (tx_fifo_data_lo)
  ,.yumi_i (tx_fifo_yumi_li)
  );


  /************************ state machine ************************/
  
  typedef enum logic [3:0] {
    RESET
   ,INIT
   ,STAT_READ
   ,STAT_RESP
   ,TX_FIFO_HDR
   ,TX_ADDR_WRITE
   ,TX_DATA_WRITE
   ,RX_FIFO_HDR
   ,RX_FIFO_ACK
   ,RX_STAT_READ
   ,RX_STAT_RESP
   ,RX_READ
   ,RX_RESP
  } state_e;
  
  state_e state_r, state_n;
  logic [7:0] counter_r, counter_n;
  logic is_read_r, is_read_n;
  logic repeated_start_r, repeated_start_n;
  
  always_ff @(posedge clk_i)
  begin
    if (reset_i)
      begin
        state_r <= RESET;
        counter_r <= '0;
        is_read_r <= 1'b0;
        repeated_start_r <= 1'b0;
      end
    else
      begin
        state_r <= state_n;
        counter_r <= counter_n;
        is_read_r <= is_read_n;
        repeated_start_r <= repeated_start_n;
      end
  end
  
  always_comb
  begin
    
    state_n = state_r;
    counter_n = counter_r;
    is_read_n = is_read_r;
    repeated_start_n = repeated_start_r;
    
    rx_fifo_v_li = 1'b0;
    rx_fifo_data_li = rdata_i[iic_data_bits_p-1:0];
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
        case (counter_r)
        0:
          begin
            awaddr_o = 9'h120;
            wdata_o = data_width_p'(4'hF);
          end
        1:
          begin
            awaddr_o = 9'h100;
            wdata_o = data_width_p'(7'b0000010);
          end
        2:
          begin
            awaddr_o = 9'h100;
            wdata_o = data_width_p'(7'b0000010);
          end
        3:
          begin
            awaddr_o = 9'h100;
            wdata_o = data_width_p'(7'b0000001);
          end
        default:
          begin
          end
        endcase
        awvalid_o = 1'b1;
        wvalid_o = 1'b1;
        if (awready_i & wready_i)
          begin
            counter_n = counter_r + 1;
            if (counter_r == 3)
              begin
                counter_n = '0;
                state_n = STAT_READ;
              end
          end
      end
    STAT_READ:
      begin
        araddr_o = 9'h104;
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
            if (~rdata_i[2] & rdata_i[6] & rdata_i[7])
              begin
                state_n = TX_FIFO_HDR;
              end
            else
              begin
                state_n = STAT_READ;
              end
          end
      end
    TX_FIFO_HDR:
      begin
        if (tx_fifo_v_lo)
          begin
            counter_n = tx_fifo_data_lo[cord_width_p+:len_width_p];
            repeated_start_n = tx_fifo_data_lo[0];
            tx_fifo_yumi_li = 1'b1;
            state_n = TX_ADDR_WRITE;
          end
      end
    TX_ADDR_WRITE:
      begin
        if (tx_fifo_v_lo)
          begin
            awaddr_o = 9'h108;
            wdata_o[iic_data_bits_p] = 1'b1;
            awvalid_o = 1'b1;
            wvalid_o = 1'b1;
            is_read_n = tx_fifo_data_lo[0];
            if (awready_i & wready_i)
              begin
                tx_fifo_yumi_li = 1'b1;
                counter_n = counter_r - 1;
                state_n = TX_DATA_WRITE;
              end
          end
      end
    TX_DATA_WRITE:
      begin
        if (tx_fifo_v_lo)
          begin
            awaddr_o = 9'h108;
            awvalid_o = 1'b1;
            wvalid_o = 1'b1;
            if (awready_i & wready_i)
              begin
                tx_fifo_yumi_li = 1'b1;
                counter_n = counter_r - 1;
                if (counter_r == 1)
                  begin
                    wdata_o[iic_data_bits_p+1] = ~repeated_start_r;
                    state_n = RX_FIFO_HDR;
                    counter_n = (is_read_r)? tx_fifo_data_lo : '0;
                  end
              end
          end
      end
    RX_FIFO_HDR:
      begin
        rx_fifo_v_li = 1'b1;
        rx_fifo_data_li = (is_read_r)? 
                          {len_width_p'(counter_r), dest_cord_i}
                        : {len_width_p'(1'b1), dest_cord_i};
        if (rx_fifo_ready_lo)
          begin
            state_n = (is_read_r)? RX_STAT_READ : RX_FIFO_ACK;
          end
      end
    RX_FIFO_ACK:
      begin
        rx_fifo_v_li = 1'b1;
        rx_fifo_data_li = iic_data_bits_p'(8'h66);
        if (rx_fifo_ready_lo)
          begin
            state_n = (repeated_start_r)? TX_FIFO_HDR : STAT_READ;
          end
      end
    RX_STAT_READ:
      begin
        araddr_o = 9'h104;
        arvalid_o = 1'b1;
        if (arready_i)
          begin
            state_n = RX_STAT_RESP;
          end
      end
    RX_STAT_RESP:
      begin
        if (rvalid_i)
          begin
            state_n = (rdata_i[6])? RX_STAT_READ : RX_READ;
          end
      end
    RX_READ:
      begin
        araddr_o = 9'h10C;
        arvalid_o = 1'b1;
        if (arready_i)
          begin
            state_n = RX_RESP;
          end
      end
    RX_RESP:
      begin
        rready_o = rx_fifo_ready_lo;
        rx_fifo_v_li = rvalid_i;
        if (rvalid_i & rready_o)
          begin
            counter_n = counter_r - 1;
            state_n = (counter_r == 1)? ((repeated_start_r)? TX_FIFO_HDR : STAT_READ) : RX_STAT_READ;
          end
      end
    default:
      begin
      end
    
    endcase
    
  end

endmodule
