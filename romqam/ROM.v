    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : ROM.v
// Create : 2018-12-21 14:58:57
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module ROM
#(
	parameter DATA_WIDTH =2,
	parameter ADDR_WIDTH=11
)
(

	input clk, en, rst,
	input [ADDR_WIDTH-1:0] addr,
	input valid_addr,
	output reg [1:0] data_rom,
	output reg valid_rom
);


reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];
//reg [(DATA_WIDTH-1):0] idata;// idata register

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
	else if (en && valid_addr) 	
			begin
				valid_rom  <= 1'b1;
		    	data_rom[1:0] <= rom[addr];
        	end
        else valid_rom <= 0;
end

endmodule
