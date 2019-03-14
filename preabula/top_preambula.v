    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : toptop.v
// Create : 2018-12-21 14:59:25
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module toptop_preambula(
	input clock, enable, reset, ready_in,
	output signed [15:0] out_i
);
   wire signed [15:0] s1;
   wire ready_in2,valid_rom, valid_bpsk;
   wire [1:0]	Bit_wire;
  // assign ready_in1 = ready_in3 && ready_in2;
   assign out_i = s1;


   	
	build_rom_preambula build_rom1_preambula            (.clock(clock),
														 .enable(enable),
														 .reset(reset),
													     .Bit_ROM(Bit_wire),
													     .ready_in(ready_in),
													     .valid_rom(valid_rom)
		                 								 );
	
	
	
	bpsk bpsk1 					                        (.clk(clock),
												   	     .idata(Bit_wire),
														 .en(enable),
														 .res(reset),
														 .i(s1),
														 .ready_in(ready_in),
														 .ready_out(ready_in2),
														 .valid_rom(valid_rom),
														 .valid_bpsk(valid_bpsk)
													     );

	
	
endmodule