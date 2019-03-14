    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : qam.v
// Create : 2018-12-21 15:51:45
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
    

module qam4
(
	input clk, en, rst,
	input valid_rom,
	input [1:0] data_rom,
	
	output reg valid_qam,
	output reg signed [15:0] i,q
);

reg [14:0] A;

initial
begin
	i = 0;
	q = 0;
	A = 15'd23_170;
end
	
always@(posedge clk or posedge rst)
begin
	if(rst) 
	begin
		valid_qam <= 0;
		i <= 0;
		q <= 0;
	end
	else if(en && valid_rom) 
	begin
		valid_qam <= 1'b1;
    	case (data_rom)
	   	2'b00:	begin
						i <= A;
						q <= A;
				end
	   	2'b10:	begin
						i <= -A;
						q <= A;
				end
	   	2'b01:	begin
						i <= A;
						q <= -A;
				end
	   	2'b11:	begin
						i <= -A;
						q <= -A;
				end
	  	endcase	
  	end
  		 else valid_qam <= 1'b0;
 end

endmodule  