// MBT 7/25/2014
// async pointer
//
// Modified by Paul Gao to support incrementing 2 credits in 1 cycle
//
// In this design, there are two clock domains. The first
// clock domain (w_) increments the grey-coded pointer; and the
// clock domain (r_) reads the grey-coded pointer.
//
// w_: signals in "receive credits" clock domain
// r_: signals in "spend credits" clock domain
//

// RESET: both resets must be asserted and w_ clock most be posedge toggled
// at least once; and the r_ clock posedge toggled at least three times after that.
// This will be a sufficient number of clocks to pass through the synchronizers.

module bsg_async_ptr_gray_serdes #(parameter lg_size_p = -1
                            ,parameter use_negedge_for_launch_p=0)
   (
    input w_clk_i
    , input w_reset_i
	// Support two increment signals
    , input w_inc_0_i
	, input w_inc_1_i 
    , input r_clk_i
    , output [lg_size_p-1:0] w_ptr_binary_r_o     // ptr value; binary
    , output [lg_size_p-1:0] w_ptr_gray_r_o       // same; gray coded; value before synchronizers
    , output [lg_size_p-1:0] w_ptr_gray_r_rsync_o // value after  synchronizers
    );

   logic [lg_size_p-1:0] w_ptr_r,      w_ptr_n;
   logic [lg_size_p-1:0] w_ptr_p1_r,   w_ptr_p1_n;
   logic [lg_size_p-1:0] w_ptr_p2_r,   w_ptr_p2_n;
   logic [lg_size_p-1:0] w_ptr_p3, w_ptr_p4;
   logic [lg_size_p-1:0] w_ptr_gray_n, w_ptr_gray_r, w_ptr_gray_r_rsync;

	always_comb begin
		w_ptr_p4 = w_ptr_p2_r + 2;
		w_ptr_p3 = w_ptr_p1_r + 2;
		w_ptr_p2_n = w_ptr_p2_r;
		w_ptr_p1_n = w_ptr_p1_r;
		w_ptr_n = w_ptr_r;
		w_ptr_gray_n = w_ptr_gray_r;
		if (w_inc_0_i^w_inc_1_i) begin
			w_ptr_p2_n = w_ptr_p3;
			w_ptr_p1_n = w_ptr_p2_r;
			w_ptr_n = w_ptr_p1_r;
			w_ptr_gray_n = (w_ptr_p1_r >> 1) ^ w_ptr_p1_r;
		end
		if (w_inc_0_i&w_inc_1_i) begin
			w_ptr_p2_n = w_ptr_p4;
			w_ptr_p1_n = w_ptr_p3;
			w_ptr_n = w_ptr_p2_r;
			w_ptr_gray_n = (w_ptr_p2_r >> 1) ^ w_ptr_p2_r;
		end
	end
	
   // pointer, in binary
   // feature wish: pass in negedge or posedge as parameter!
generate
   if (use_negedge_for_launch_p)
     begin
        always @(negedge w_clk_i)
          if (w_reset_i)
            begin
               w_ptr_r    <= 0;
               w_ptr_p1_r <= 1;
			   w_ptr_p2_r <= 2;
            end
          else
            begin
               w_ptr_r    <= w_ptr_n;
               w_ptr_p1_r <= w_ptr_p1_n;
			   w_ptr_p2_r <= w_ptr_p2_n;
            end
     end
   else
     begin
        always @(posedge w_clk_i)
          if (w_reset_i)
            begin
               w_ptr_r    <= 0;
               w_ptr_p1_r <= 1;
			   w_ptr_p2_r <= 2;
            end
          else
            begin
               w_ptr_r    <= w_ptr_n;
               w_ptr_p1_r <= w_ptr_p1_n;
			   w_ptr_p2_r <= w_ptr_p2_n;
            end
     end
endgenerate

   assign w_ptr_binary_r_o = w_ptr_r;

   // synchronize the grey coded pointer across clock domains
   // we use these to send pointers across clock boundaries
   // this includes both launch flops and synchronization flops
   // these should be abutted in physical design

   bsg_launch_sync_sync #(.width_p(lg_size_p)
                          ,.use_negedge_for_launch_p(use_negedge_for_launch_p)) ptr_sync
     (
      .iclk_i(w_clk_i)
      ,.iclk_reset_i(w_reset_i)
      ,.oclk_i(r_clk_i)
      ,.iclk_data_i(w_ptr_gray_n)
      ,.iclk_data_o(w_ptr_gray_r)
      ,.oclk_data_o(w_ptr_gray_r_rsync)
      );

   // fixme: probably wise to put a dont_touch'ed buffer cell on the launch flop.
   assign w_ptr_gray_r_o       = w_ptr_gray_r;
   assign w_ptr_gray_r_rsync_o = w_ptr_gray_r_rsync;

endmodule
