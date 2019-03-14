    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : toptop.v
// Create : 2018-12-21 14:59:25
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module top_Symbol
(
	input clk, en, rst, ready_in,
	output signed [15:0] out_q, out_i,
	output valid_qam
);

wire [1:0] data_rom1;
wire valid_rom1, ready_out1;
   	
build_rom build_rom1            					
														(
														.clk(clk),
														.en(en),
														.rst(rst),													     
													    .ready_in(ready_in),
													    .data_rom(data_rom1),
													    .valid_rom(valid_rom1)
		                 								);
	
	
	
qam4 qam 					                     
														(
														.clk(clk),
													    .en(en),
														.rst(rst),
														.data_rom(data_rom1),
 														.valid_rom(valid_rom1),
														.i(out_i),
														.q(out_q),
														.valid_qam(valid_qam)
												     	);
	
endmodule