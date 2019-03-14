    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : counter_rom.v
// Create : 2018-12-21 14:59:07
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module counter_rom
#(
	parameter ADDR_WIDTH = 11
)
(   
	input clk, en, rst, ready_in,
	output reg [ADDR_WIDTH - 1 : 0] addr,
	output reg valid_addr
);
  
initial
begin
	addr = 0;
	valid_addr = 0;
end

        
        always @(clk or rst) 
        begin
        	if (rst) valid_addr <= 0;
        	else valid_addr <= (en && ready_in) ? 1'b1 : 1'b0;
        end


		always @(posedge clk or posedge rst) 
		begin
			if (rst)
			begin
				addr <= 0;
			end
			else if(addr == 11'b11001101111) addr <= 0;
				 else if(en && ready_in) addr <= addr + 1; 
					  else addr <= addr;
		end

endmodule

