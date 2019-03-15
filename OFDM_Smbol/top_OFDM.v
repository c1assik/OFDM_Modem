    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : toptop.v
// Create : 2018-12-21 14:59:25
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


module top_OFDM(
	input clk, en, rst, ready_in,
	output signed [15:0] real_out, imag_out,
	output valid_OFDM,sop_out
);

wire signed [15:0] s1, s2, data_real, data_imag;
wire sop

wire ready_in3, valid_qam, valid_pilot;
wire index_pilot, sign_pilot, ready_out_pilots;
	
	OFDM OFDM_subcarrier_mux1		      		        (
														 .clk(clk),
									 					 .en(en),
														 .rst(rst),
														 .ready_in(ready_in),
														 .valid_qam(valid_qam),
														 .valid_pilot(valid_pilot),
														 .i(s1),
														 .q(s2),
														 .index_pilot(index_pilot),
														 .sign_pilot(sign_pilot),							 
														 .ready_out_ROM(ready_in3),
														 .ready_out_pilots(ready_out_pilots),
														 .i_OFDM(data_real),
														 .q_OFDM(data_imag),
														 .valid_OFDM(valid_OFDM),
														 .sop(sop)
														);



	fft_1024_16 fft_submod 							    (
														.clk(clk),
														.reset			(reset),
														.master_sink_dav		(),
														.master_sink_sop		(sop),
														.master_source_dav	(),
														.inv_i				(1'b1),
														.data_real_in		(data_real),
														.data_imag_in		(data_imag),
														.fft_real_out		(real_out),
														.fft_imag_out		(imag_out),
														.exponent_out		(),
														.master_sink_ena		(),
														.master_source_sop	(sop_out),
														.master_source_eop	(),
														.master_source_ena	()   
													   );





	pilots pilots1					                 	(	
														 .clk(clk),													    
														 .en(en),
														 .rst(rst),
														 .ready_in(ready_out_pilots),
														 .index_pilot(index_pilot),
														 .sign_pilot(sign_pilot),
														 .valid_pilot(valid_pilot)
													    );


	top_Symbol top_Symbol1 								(
														 .clk(clk),
														 .en(en),
														 .rst(rst),
														 .ready_in(ready_in3),
														 .out_i(s1),
														 .out_q(s2),
														 .valid_qam(valid_qam)
													    );
	
	
endmodule