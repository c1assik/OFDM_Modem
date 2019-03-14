    
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
	output signed [15:0] I_OFDM, Q_OFDM,
	output valid_OFDM,sop
);

wire signed [15:0] s1, s2;

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
														 .i_OFDM(I_OFDM),
														 .q_OFDM(Q_OFDM),
														 .valid_OFDM(valid_OFDM),
														 .sop(sop)
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