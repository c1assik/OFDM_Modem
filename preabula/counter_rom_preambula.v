    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : counter_rom.v
// Create : 2018-12-21 14:59:07
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module counter_rom_preambula
#(parameter ADDR_WIDTH=7)
(   
	input clk, en, reset,ready_in,
	output reg  [ADDR_WIDTH-1:0] addr,
	output reg valid_count
);
  
initial
begin
	addr =0;
	valid_count = 0;
end

        
        always @(clk or reset ) 
        begin
        	if(reset) valid_count <=0;
        	else valid_count <=(en && ready_in)?1'b1: 1'b0;
        end


		always @(posedge clk or posedge reset) 
		begin
			if (reset)
			begin
				addr <=0;
			end
			else if(addr == 7'b1101010) addr <= 0;
				 else if(en && ready_in) addr <= addr + 1; 
					  else addr <= addr;
		end

endmodule