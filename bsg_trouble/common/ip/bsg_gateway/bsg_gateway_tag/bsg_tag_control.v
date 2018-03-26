
//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_tag_control.v
//
// Author: Paul Gao
//------------------------------------------------------------

module bsg_tag_control

	(input reset_i
	,input enable_i
	,input clk_i
	// Command data
	,input [31:0] data_i
	// microblaze control
	,input valid_mb_i
	,input mb_control_i
	,input mb_io_isDiv_i
	,input mb_core_isDiv_i
	// IO clock control
	,output logic [1:0] io_set_o
	,output logic io_reset_o
	// CORE clock control
	,output logic [1:0] core_set_o
	,output logic core_reset_o
	// tag enable control
	,output logic tag_tms_o);

	reg [1:0] io_set_r, io_set_n;
	reg io_reset_r, io_reset_n;
	reg [1:0] core_set_r, core_set_n;
	reg core_reset_r, core_reset_n;
	reg tag_tms_r, tag_tms_n;
	
	assign io_set_o = io_set_r;
	assign io_reset_o = io_reset_r;
	assign core_set_o = core_set_r;
	assign core_reset_o = core_reset_r;
	assign tag_tms_o = tag_tms_r;
	
	always @(posedge clk_i)
	begin
		if (reset_i) begin
			io_set_r <= 2'b11;
			io_reset_r <= 1'b0;
			core_set_r <= 2'b11;
			core_reset_r <= 1'b0;
			tag_tms_r <= 1'b0;
		end else begin
			io_set_r <= io_set_n;
			io_reset_r <= io_reset_n;
			core_set_r <= core_set_n;
			core_reset_r <= core_reset_n;
			tag_tms_r <= tag_tms_n;
		end
	end
	
	always_comb
	begin
		io_set_n = io_set_r;
		io_reset_n = io_reset_r;
		core_set_n = core_set_r;
		core_reset_n = core_reset_r;
		tag_tms_n = tag_tms_r;
		if (enable_i == 1'b1)
		begin
		
			if (mb_control_i&valid_mb_i) begin
				io_set_n = (mb_io_isDiv_i)? 2'b01 : 2'b00;
				core_set_n = (mb_core_isDiv_i)? 2'b01 : 2'b00;
			end else begin
				if (data_i[31])
					io_set_n[1] = 1'b1;
				if (data_i[30])
					io_set_n[1] = 1'b0;
				if (data_i[29])
					io_set_n[0] = 1'b1;
				if (data_i[28])
					io_set_n[0] = 1'b0;
				if (data_i[27])
					io_reset_n = 1'b1;
				if (data_i[26])
					io_reset_n = 1'b0;
				if (data_i[25])
					core_set_n[1] = 1'b1;
				if (data_i[24])
					core_set_n[1] = 1'b0;
				if (data_i[23])
					core_set_n[0] = 1'b1;
				if (data_i[22])
					core_set_n[0] = 1'b0;
				if (data_i[21])
					core_reset_n = 1'b1;
				if (data_i[20])
					core_reset_n = 1'b0;
				if (data_i[19])
					tag_tms_n = 1'b1;
				if (data_i[18])
					tag_tms_n = 1'b0;
			end
		end
	end
	
endmodule
