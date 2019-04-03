    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : ROM.v
// Create : 2018-12-21 14:58:57
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module ROM
(
	input clk, en, rst,
	input [10:0] addr,
	output reg [1:0] data_rom,
	output reg valid_rom
);

reg [1:0] rom [1023:0];

initial
begin
	$readmemb("buf_data.txt", rom);
	valid_rom = 0;
	data_rom = 0;
end

always @(posedge clk or posedge rst) 
begin
	if (rst) 
	begin
		data_rom   <= 0;
		valid_rom  <= 0;
	end
	else if (en) 	
			begin
				valid_rom  <= 1'b1;
		    	data_rom[1:0] <= rom[addr];
        	end
        else valid_rom <= 0;
end

endmodule
