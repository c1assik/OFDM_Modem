    
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

wire signed [15:0] s1, s2;

wire ready_in3, valid_qam, valid_pilot;
wire index_pilot, sign_pilot, ready_out_pilots;

wire [9:0] addr;
wire valid_addr;
wire [1:0] data_rom;
wire valid_rom;
	   	

		
	counter_rom counter_rom1							(
														.clk(clk),
										 	   			.en(en),
														.rst(rst),
														.addr(addr),
														.ready_in(ready_in3),
														.valid_addr(valid_addr)
									  					);
		
	ROM ROM1										    (
														.clk(clk),
														.en(en),
														.rst(rst),
														.addr(addr),
														.data_rom(data_rom),
														.valid_addr(valid_addr),
														.valid_rom(valid_rom)
														);

		
		
	qam4 qam 					                     	(
														.clk(clk),
														.en(en),
														.rst(rst),
														.data_rom(data_rom),
	 													.valid_rom(valid_rom),
														.i(s1),
														.q(s2),
														.valid_qam(valid_qam)
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
														 .i_OFDM(real_out),
														 .q_OFDM(imag_out),
														 .valid_OFDM(valid_OFDM),
														 .sop(sop_out)
														);





	
endmodule