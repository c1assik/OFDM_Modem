    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Milyutin & Petrovsky 
// File   : build_rom.v
// Create : 2018-12-21 17:19:19
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


module build_rom_preambula	
#(parameter ADDR_WIDTH=7)
(
	input clock, enable,reset, ready_in,
	output [1:0] Bit_ROM,
	output valid_rom, valid_count
);
   wire [ADDR_WIDTH-1:0] addr1;
   wire ready;
	
	counter_rom_preambula counter_rom1_preambula		(.clk(clock),
									 	   				 .en(enable),
														 .reset(reset),
														 .addr(addr1),
														 .ready_in(ready),
														 .valid_count(valid_count)
								  					 	);
	
	ROM_preambula ROM1_preambula					    (.clk(clock),
														 .en(enable),
														 .reset(reset),
														 .addr(addr1),
														 .idata(Bit_ROM),
														 .ready_out(ready),
														 .ready_in(ready_in),
														 .valid_count(valid_count),
														 .valid_rom(valid_rom)
														 );
	

endmodule