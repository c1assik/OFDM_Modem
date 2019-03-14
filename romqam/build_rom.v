    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Milyutin & Petrovsky 
// File   : build_rom.v
// Create : 2018-12-21 17:19:19
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


module build_rom
#(
	parameter ADDR_WIDTH=11
)
(
	input clk, en, rst, ready_in,
	output [1:0] data_rom,
	output valid_rom
);

wire [ADDR_WIDTH-1:0] addr;
wire valid_addr;
	
counter_rom counter_rom1							(
													.clk(clk),
									 	   			.en(en),
													.rst(rst),
													.addr(addr),
													.ready_in(ready_in),
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

endmodule
