    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : ROM.v
// Create : 2018-12-21 14:58:57
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module ROM_preambula
#(parameter DATA_WIDTH=1, parameter ADDR_WIDTH=7
)
(

	input clk, en, reset,ready_in,
	input [ADDR_WIDTH-1:0] addr,
	input valid_count,
	output reg [1:0] idata,
	output wire ready_out,
	output reg valid_rom
);


	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
	//reg [(DATA_WIDTH-1):0] idata;// idata register

	initial
	begin
		$readmemb("preambula.txt", rom);
		valid_rom          = 0;
		idata              = 0;
	end



		always @(posedge clk or posedge reset) 
		begin
			if (reset ) 
			begin
				idata      <=0;
				valid_rom  <=0;
			end
			else if (en && ready_in && valid_count) 	
			begin
				valid_rom  <= 1'b1;
			    idata[1:0] <= rom[addr];
	        end
	        else valid_rom <=0;
		end

assign ready_out           = ready_in;
endmodule
