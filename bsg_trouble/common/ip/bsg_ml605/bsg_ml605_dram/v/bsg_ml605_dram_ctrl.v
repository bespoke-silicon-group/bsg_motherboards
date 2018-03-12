//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_dram_ctrl.v
//
// Copyright MBT 2010.
// Modified by Qiaoshi 2012
//
// 2016 Luis' update:
//   * Interface renamed
//   * mbt_fifo replaced by bsg_fifo_1r1w_large
//   * recore_credit_tracker replaced by bsg_counter_up_down
//------------------------------------------------------------

module bsg_ml605_dram_ctrl #
  (parameter dq_width_p = 64
  ,parameter dq_mask_width_p = 8)
  (input clk_i
  ,input reset_i
  // phy
  ,input phy_init_done_i
  // in
  ,input valid_i
  ,input [31:0] data_i
  ,output thanks_o
  // out
  ,output valid_o
  ,output [31:0] data_o
  ,input thanks_i
   // addr/cmd
  ,output app_af_wren
  ,output [30:0] app_af_addr
  ,output [2:0] app_af_cmd
  ,input app_af_afull
  // wr
  ,output app_wdf_wren
  ,output [dq_width_p-1:0] app_wdf_data
  ,output [dq_mask_width_p-1:0] app_wdf_mask_data
  ,input app_wdf_afull
  // rd
  ,input rd_data_valid
  ,input [dq_width_p-1:0] rd_data_fifo_out);

  localparam kCacheLineSizeInWords = 8;
  localparam kUserFieldCacheLineRead  = 4'b0000;		// Cache-line Read (Addr)
  localparam kUserFieldDmaReadNorth   = 4'b0001;		// DMA Read - North		// Final Bit will be 101
  localparam kUserFieldDmaReadWest	  = 4'b0010;		// DMA Read - West		// Final Bit will be 010
  localparam kUserFieldCacheLineWrite = 4'b0100;		// Cache-line Write (Addr, 8 Words)
  localparam kUserFieldEscape		  = 4'b0101;		// doesn't implement  // Escape (next word is commanc)
  localparam kUserFieldCacheLineWriteMask = 4'b0111;
  localparam kUserFieldDmaTaggedReadReply	= 4'b1000;	// DMA tagged Read Reply (multi session)
  localparam kUserFieldMDNRelay		  = 4'b1101;		// MDN Relay
  localparam kUserFieldSystemMonitorService = 4'b1110;	// System Monitor Service (external)

  // The length of the mdnportrelay
  localparam LengthMdnPortRelay	  = 4'b1001;		// I am not sure!!!
  localparam outstanding_reads_p = 8;


  reg			valid_o_dram;
  reg	[31:0]	data_o_dram;
  reg			valid_o_relay;
  reg	[31:0]	data_o_relay;

  //
  //reg	[($clog2(LengthMdnPortRelay + 1)-1):0]	mdnportrelay_input_counter_w;
  //reg	[($clog2(LengthMdnPortRelay + 1)-1):0]	mdnportrelay_input_counter_r;
  reg  [4:0]   mdnportrelay_input_counter_w;
  reg  [4:0]   mdnportrelay_input_counter_r;

  reg		mdnportrelay_in;

  logic valid_lo;

  assign valid_lo = mdnportrelay_in ? valid_o_relay : valid_o_dram;
  assign valid_o = valid_lo;

  assign data_o =  mdnportrelay_in ? data_o_relay : data_o_dram;

  always_ff @(posedge clk_i)
      if(reset_i) mdnportrelay_input_counter_r <= LengthMdnPortRelay;
      else      mdnportrelay_input_counter_r <= mdnportrelay_input_counter_w;

  typedef struct packed {
                          bit [2:0] fbits;
                          bit [4:0] length;
                          bit [3:0] user;
                          bit [4:0] origY;
                          bit [4:0] origX;
                          bit [4:0] absY;
                          bit [4:0] absX;
                          } raw_dynamic_packet_s;

   enum logic [6:0] {sHeaderWait           = 7'b000_0001,
                     sAddressWait          = 7'b000_0010,
                     sWriteDataWait        = 7'b000_0100,
                     sWriteGetMask         = 7'b000_1000,
                     sWriteGetTag          = 7'b001_0000,
                     sWriteFinalize        = 7'b010_0000,
                     sTransferMdnPortRelay = 7'b100_0000} request_state_r, request_state_next;

   enum logic [2:0] {sWait                 = 3'b001,
                     sTagTransfer          = 3'b010,
                     sDataTransfer         = 3'b100} reply_state_r, reply_state_next;

   // the write signal, one cycle before we assert it
   // allows write timing to line up with the data_r
   reg app_wdf_wren_r, app_wdf_wren_next;
   assign app_wdf_wren = app_wdf_wren_r;

   always_ff @(posedge clk_i)
    if (reset_i) app_wdf_wren_r <= 1'b0;
    else       app_wdf_wren_r <= app_wdf_wren_next;

   always_ff @(posedge clk_i)
     if (reset_i) request_state_r <= sHeaderWait;
     else       request_state_r <= request_state_next;


   wire         fifo_valid_i;
   wire [31:0]  fifo_data_i;
   reg          fifo_thanks_i;

   // input fifo

   bsg_fifo_1r1w_large #
     (.width_p(32)
     ,.els_p(8))
   in_fifo
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     // in
     ,.v_i(valid_i)
     ,.data_i(data_i)
     ,.ready_o()
     // out
     ,.v_o(fifo_valid_i)
     ,.data_o(fifo_data_i)
     ,.yumi_i(fifo_thanks_i));

   // could be registered if it's a slow path
   assign thanks_o = fifo_thanks_i;

   raw_dynamic_packet_s header_r, header_next;
   reg [31:0]         addr_r, mask_r, addr_next;
   reg                header_r_en, header_r_rst, addr_r_en, mask_r_en, mask_r_reset_en, data_r_en;

   reg [kCacheLineSizeInWords-1:0] receive_count_r, receive_count_next, receive_count_clear;
   wire [kCacheLineSizeInWords*32-1:0] data_r_agg;

   reg [2:0] app_af_cmd_r,      app_af_cmd_next;

   reg      hdr_fifo_valid_in;
   wire     hdr_fifo_full;
   reg      app_af_addr_bypass;

   reg		dr_finalRF_N;
   reg		dr_finalRF_W;

   assign header_next = fifo_data_i;
   assign addr_next   = fifo_data_i;

   // connection for the tag_fifo
   reg                  tag_fifo_enque;
   reg                  tag_fifo_deque;
   reg  [31:0]          tag_fifo_data_out;
   wire                 tag_fifo_empty;
   reg                  tag_fifo_full;
   reg                  tag_fifo_valid_out;


   always @(posedge clk_i) if (header_r_en) header_r    <= header_next;
   always @(posedge clk_i)
       if(reset_i) begin
           addr_r <= 31'b0;
       end
       else begin
           if(addr_r_en) begin
               addr_r <= addr_next;
           end
       end
   reg                app_af_wren_wire;

   assign app_af_cmd = app_af_cmd_next;
   assign app_af_wren = app_af_wren_wire;

   assign app_wdf_mask_data = mask_r;
   assign app_wdf_data = data_r_agg;

   // fixme: not totally sure that this is right --
   assign app_af_addr = {2'b0,app_af_addr_bypass ? addr_next[31:5] : addr_r[31:5], 2'b00}; // app_af_addr is in terms of 64-bit chunks = 8 bytes;
                                                        // e.g. drop last three bits ( [2:0] )
                                                        // then the low two bits are zero because of burst length of 4
   always @(posedge clk_i) app_af_cmd_r <= app_af_cmd_next;

   wire                    out_space_avail;
   // generate a block of registers to hold the data for a cache line.
   // note: the semantics of the DRAM require that we have all of the data
   // before we attempt to write it; hence why we burn so many registers on this

   genvar                           i;
   generate
      for (i = 0; i < kCacheLineSizeInWords; i++) begin: data_buf
        reg [31:0] data_r;
          always @(posedge clk_i) begin
            // if we are updating the data array, and this particular element is activated
            if (data_r_en & receive_count_r[i])
              data_r <= fifo_data_i;
          end
          assign data_r_agg[(i+1)*32-1:i*32] = data_r;
      end // block: data_buf
   endgenerate


   always_ff @(posedge clk_i)
     if (mask_r_reset_en)
       mask_r <= { (dq_mask_width_p) { 1'b0 } };
     else begin
       if (mask_r_en)
         mask_r <= ~fifo_data_i[dq_mask_width_p-1:0];
     end

   always_ff @(posedge clk_i)
        if (reset_i | receive_count_clear) receive_count_r <= { { ($clog2(kCacheLineSizeInWords)-1) { 1'b0} }, 1'b1};
        else                             receive_count_r <= receive_count_next;

   reg    dma_read;
   assign dma_read = dr_finalRF_N | dr_finalRF_W;
   // state machine for incoming traffic

   always_comb  begin
        // default is stay in same state
        request_state_next = request_state_r;
        fifo_thanks_i = 1'b0;
        header_r_en   = 1'b0;
        addr_r_en     = 1'b0;
        data_r_en     = 1'b0;
        mask_r_en     = 1'b0;
        mask_r_reset_en = 1'b0;
        app_af_cmd_next = app_af_cmd_r;
        app_af_wren_wire = 1'b0;
        app_wdf_wren_next = 1'b0;
        //data_lower_next = data_lower_r;
        hdr_fifo_valid_in = 1'b0;
        receive_count_clear = 1'b0;
        app_af_addr_bypass = 1'b0;

		// These two control the final bit in the response data
		dr_finalRF_N = 1'b0;
		dr_finalRF_W = 1'b0;

		mdnportrelay_input_counter_w = LengthMdnPortRelay;
		mdnportrelay_in = 1'b0;
		valid_o_relay = 1'b0;
		data_o_relay = 32'h0000_0000;

        // tag_fifo enque
        tag_fifo_enque = 1'b0;

        receive_count_next = receive_count_r;

        unique case (request_state_r)
          sHeaderWait:
            begin
            //$write("headerwait requested address %d\n",addr_r);
            // fixme: I don't know if these app_ full signals
            // indicate <=12 words avail, or == 12 avail
            // right now I am being very conservative, and only proceed if all is clear
            // these fifos appear to be relatively huge, so this seems reasonable

            if (fifo_valid_i & ~app_wdf_afull & ~app_af_afull & ~hdr_fifo_full & phy_init_done_i & (~tag_fifo_full))
		 begin
                 fifo_thanks_i = 1'b1;
                 header_r_en = 1'b1;         // we latch in the header

                 // In this cycle, we only could use header_next to get the opcode of this request, we can use header_r next cycle
                 if(header_next.user == kUserFieldMDNRelay) begin
	if(reply_state_next == sWait) begin
		request_state_next = sTransferMdnPortRelay;
		mdnportrelay_input_counter_w = header_next.length;
                        header_r_en = 1'b0;
		mdnportrelay_in = 1'b1;
	end
	else begin
		request_state_next = sHeaderWait;
		fifo_thanks_i = 1'b0;
		header_r_en = 1'b0;
	end
	//mdnportrelay_in = 1'b1;
                 end
                 else begin
	request_state_next = sAddressWait;
                 end
                 mask_r_reset_en = 1'b1;     // set mask to default value

                 // we get these lined up for next cycle

		 // mbt: note, the value of app_af_cmd_next is undefined
		 // if the header field does not match one of the items
		 // below, since the unique case does not have a default clause.
                 //
		 // this should be okay because app_af_cmd is simply a
		 // variable that we are setting to be passed to a subsequent state.
		 // if the subsequent state does not enque the app_af_cmd to the dram
		 // (which it would not if it's not listed here)
		 // it's okay if it's not set to a valid value.

                 unique case (header_next.user)
                   kUserFieldCacheLineWrite:       app_af_cmd_next = 3'b000;
                   kUserFieldCacheLineWriteMask:   app_af_cmd_next = 3'b000;
                   kUserFieldCacheLineRead:        app_af_cmd_next = 3'b001;
                   kUserFieldDmaReadNorth:         app_af_cmd_next = 3'b001;
                   kUserFieldDmaReadWest:          app_af_cmd_next = 3'b001;
                   kUserFieldMDNRelay:             app_af_cmd_next = 3'b001;   // mbt: probably don't need, since dram is not accessed.
                endcase
              end
            end

          sTransferMdnPortRelay:
          begin
            mdnportrelay_in = 1'b1;
            if(mdnportrelay_input_counter_r == 1'b1) begin
		if(fifo_valid_i & out_space_avail) begin
                  request_state_next = sHeaderWait;
                  valid_o_relay = 1'b1;
                  data_o_relay = fifo_data_i;
                  fifo_thanks_i = 1'b1;
                end
                else begin
                  valid_o_relay = 1'b0;
                  mdnportrelay_input_counter_w = mdnportrelay_input_counter_r;
                end
	end
	else begin
		if(fifo_valid_i & out_space_avail) begin
			fifo_thanks_i = 1'b1;
			valid_o_relay = 1'b1;
			data_o_relay = fifo_data_i;
			mdnportrelay_input_counter_w = mdnportrelay_input_counter_r - 1'b1;
		end
		else begin
		    valid_o_relay = 1'b0;
                    mdnportrelay_input_counter_w = mdnportrelay_input_counter_r;
		end
	end
          end

          sAddressWait:
            begin
            if (~app_af_afull & phy_init_done_i) begin
            $write("addresswait requested address %d\n",addr_r);
            if (fifo_valid_i)
              begin
                 fifo_thanks_i = 1'b1;
                 addr_r_en = 1'b1;
                 // fixme: only if we detect a write
                 unique case (header_r.user)

					kUserFieldCacheLineWriteMask:  request_state_next = sWriteGetMask;
	kUserFieldCacheLineWrite:      request_state_next = sWriteDataWait;
	// poof! so fast, we get that request out right away!
	kUserFieldCacheLineRead:
	begin
	app_af_wren_wire = 1'b1;
	// note: app_af_cmd_r set in previous cycle
	// the address is coming in from fifo on this cycle, so we bypass it
	app_af_addr_bypass = 1'b1;

	// enque header for sending response
	// works off of header_r, written on last cycle
	hdr_fifo_valid_in = 1'b1;
	request_state_next = sHeaderWait;
	end
                    kUserFieldDmaReadNorth:	// DMA Read - North		// Final Bit will be 101
						begin
							app_af_wren_wire = 1'b1;
							app_af_addr_bypass = 1'b1;
							hdr_fifo_valid_in = 1'b1;
							request_state_next = sWriteGetTag;
							dr_finalRF_N = 1'b1;
						end
					kUserFieldDmaReadWest:
						begin
							app_af_wren_wire = 1'b1;
							app_af_addr_bypass = 1'b1;
							hdr_fifo_valid_in = 1'b1;
							request_state_next = sWriteGetTag;
							dr_finalRF_W = 1'b1;
						end
                   default:
                        request_state_next = sHeaderWait;

                 endcase
              end
              end
            end // case: sAddressWait

          sWriteGetTag:
            if(fifo_valid_i & phy_init_done_i)
              begin
                fifo_thanks_i = 1'b1;
                tag_fifo_enque = 1'b1;
                request_state_next = sHeaderWait;
              end

          sWriteGetMask:
	        if (fifo_valid_i & phy_init_done_i)
	          begin
			    fifo_thanks_i = 1'b1;
			    mask_r_en = 1'b1;
			    request_state_next = sWriteDataWait;
	          end

          sWriteDataWait:
            if (fifo_valid_i & ~app_af_afull & ~app_wdf_afull & phy_init_done_i)
              begin
                 fifo_thanks_i = 1'b1;
                 data_r_en = 1'b1;

                   // if the receive_count is at the max
                   if (receive_count_r[kCacheLineSizeInWords-1])
                     begin
                        receive_count_clear = 1'b1;
                        request_state_next = sHeaderWait;
                        app_af_wren_wire = 1'b1;            // write command packet into command fifo
                        app_wdf_wren_next = 1'b1;  // write second 4 words into data fifo on next cycle
                     end

                 // increment one-hot encoded count
                 receive_count_next = { receive_count_r[kCacheLineSizeInWords-2:0], 1'b0};
              end // case: sWriteDataWait

           default:
            begin
                request_state_next = sHeaderWait;
            end
      endcase
     end

// *******************************************************************************
//
// handle DRAM --> network traffic (read replies)

   localparam reply_packet_numwords_p = 9; // I am not sure!!!

// sender
// FIFO to hold return headers
// depth = 2

   // fixme: implement header enque logic

   raw_dynamic_packet_s hdr_fifo_data_in;


   //assign hdr_fifo_data_in.fbits = 3'b0;
   assign hdr_fifo_data_in.fbits = dr_finalRF_W ? 3'b010 : (dr_finalRF_N ? 3'b101 : 3'b000);
   assign hdr_fifo_data_in.length = dma_read ? (reply_packet_numwords_p) : (reply_packet_numwords_p - 1'b1);
   assign hdr_fifo_data_in.user = dma_read ? 4'b1000 : 4'b0;
   assign hdr_fifo_data_in.origY = header_r.absY;
   assign hdr_fifo_data_in.origX = header_r.absX;
   assign hdr_fifo_data_in.absY = header_r.origY;
   assign hdr_fifo_data_in.absX = header_r.origX;


   wire [31:0] hdr_fifo_data_out;
   wire        hdr_fifo_valid_out;
   reg         hdr_fifo_deque;

   // hdr fifo

   logic hdr_fifo_ready_lo;

   bsg_fifo_1r1w_large #
     (.width_p(32)
     ,.els_p(outstanding_reads_p + 1))
   hdr_fifo
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     // in
     ,.v_i(hdr_fifo_valid_in)
     ,.data_i(hdr_fifo_data_in)
     ,.ready_o(hdr_fifo_ready_lo)
     // out
     ,.v_o(hdr_fifo_valid_out)
     ,.data_o(hdr_fifo_data_out)
     ,.yumi_i(hdr_fifo_deque));

   assign hdr_fifo_full = ~hdr_fifo_ready_lo;

   // tag fifo

   logic tag_fifo_ready_lo;

   bsg_fifo_1r1w_large #
     (.width_p(32)
     ,.els_p(outstanding_reads_p + 1))
   tag_fifo
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     // in
     ,.v_i(tag_fifo_enque)
     ,.data_i(fifo_data_i)
     ,.ready_o(tag_fifo_ready_lo)
     // out
     ,.v_o(tag_fifo_valid_out)
     ,.data_o(tag_fifo_data_out)
     ,.yumi_i(tag_fifo_deque));

   assign tag_fifo_full = ~tag_fifo_ready_lo;
   assign tag_fifo_empty = ~tag_fifo_valid_out;

   // FIFO to hold requested data

   wire [dq_width_p-1:0]  data_out_fifo_dout;
   wire                   data_out_fifo_valid;
   reg                    data_out_fifo_deque;

   wire                   data_out_fifo_empty;
   wire                   data_out_fifo_full;

   // this FIFO captures the read response packets from the DRAM

   logic rd_fifo_ready_lo;

   bsg_fifo_1r1w_large #
     (.width_p(dq_width_p)
     ,.els_p(outstanding_reads_p + 1))
   rd_fifo
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     // in
     ,.v_i(rd_data_valid)
     ,.data_i(rd_data_fifo_out)
     ,.ready_o(rd_fifo_ready_lo)
     // out
     ,.v_o(data_out_fifo_valid)
     ,.data_o(data_out_fifo_dout)
     ,.yumi_i(data_out_fifo_deque));

   assign data_out_fifo_full = ~rd_fifo_ready_lo;
   assign data_out_fifo_empty = ~data_out_fifo_valid;

   always @(posedge clk_i)
     if (reset_i) reply_state_r <= sWait;
     else       reply_state_r <= reply_state_next;

  // credit counter
  //
  // max_val_p -> number of credits
  // init_val_p -> start with max credits

  logic [2:0] credit_cnt_lo;

  bsg_counter_up_down #
    (.max_val_p(4)
    ,.init_val_p(4))
  credit_cnt_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.up_i(thanks_i)
    ,.down_i(valid_lo)
    ,.count_o(credit_cnt_lo));

  assign out_space_avail = (| credit_cnt_lo);

   // fix me; could parameterize later
   reg [$clog2(reply_packet_numwords_p)-1:0]               big_mux_sel_r, big_mux_sel_next;
   wire [$clog2(reply_packet_numwords_p)-1:0]              big_mux_sel_plus_1 = big_mux_sel_r + 1'b1;

   always @(posedge clk_i)
     if (reset_i)
       big_mux_sel_r <= { $clog2(reply_packet_numwords_p) { 1'b0 } };
     else
       big_mux_sel_r <= big_mux_sel_next;

   wire  [31:0]  data_o_dram_mux;

   DW01_mux_any #(.A_width((reply_packet_numwords_p)*32),
                  .SEL_width($clog2(reply_packet_numwords_p)),
                  .MUX_width(32))
   big_mux (.A({data_out_fifo_dout, hdr_fifo_data_out }),
            .SEL(big_mux_sel_r),
            .MUX(data_o_dram_mux));

   reg              tag_select;
   assign data_o_dram = tag_select ? tag_fifo_data_out : data_o_dram_mux;

   // simple transfer engine that iterates through a fix format packet
   always @(*)
     begin
       reply_state_next = reply_state_r;
       valid_o_dram = 1'b0;
       big_mux_sel_next = big_mux_sel_r;
       hdr_fifo_deque = 1'b0;
       data_out_fifo_deque = 1'b0;
       tag_fifo_deque = 1'b0;
       tag_select = 1'b0;

       unique case (reply_state_r)
         sWait:
           begin
//         note: this implementation without data_out_fifo_valid2 assumes that the DRAM will always
//         follow up with the second 4 words on the next cycle
//         this is part of the DDR2 spec; but if we change the design, we will have to fix it
           if (hdr_fifo_valid_out & data_out_fifo_valid & out_space_avail & (!mdnportrelay_in)) begin
             if(hdr_fifo_data_out[23:20] == 4'b1000) begin
               if(!tag_fifo_empty) begin
                 reply_state_next = sTagTransfer;
                 valid_o_dram = 1'b1;
                 big_mux_sel_next = big_mux_sel_plus_1;
               end
               else begin
                 reply_state_next = sWait;
               end
             end
             else begin
               reply_state_next = sDataTransfer;
               valid_o_dram = 1'b1;
               big_mux_sel_next = big_mux_sel_plus_1;
             end
           end
         end
         sTagTransfer:
           begin
             if (out_space_avail) begin
               valid_o_dram = 1'b1;
               tag_select = 1'b1;
               tag_fifo_deque = 1'b1;
               reply_state_next = sDataTransfer;
             end
           end
         sDataTransfer:
           if (out_space_avail)
             begin
               valid_o_dram = 1'b1;

               // if we've transferred everything
                if (big_mux_sel_next == (reply_packet_numwords_p - 1))
                 begin
                   big_mux_sel_next = { $clog2(reply_packet_numwords_p) { 1'b0 } };
                   // deque transactions from fifos
                   hdr_fifo_deque = 1'b1;
                   data_out_fifo_deque = 1'b1;
                   reply_state_next = sWait;
                 end
               else
                 big_mux_sel_next = big_mux_sel_plus_1;
             end
       endcase // case (reply_state_r)
     end

endmodule
