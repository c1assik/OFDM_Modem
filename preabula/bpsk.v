    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : qam.v
// Create : 2018-12-21 15:51:45
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
    

module bpsk(

	input clk, res, en, ready_in,
	input valid_rom,
	input [1:0] idata,
	output reg ready_out, 
	output reg valid_bpsk,
	output reg signed [15:0] i
	);


	reg [14:0] A;
	reg error;

	initial
	 begin
	 error = 0;
	 i = 0;
	 A = 0;
	 A = ~A;
	end
	
 always@(posedge clk or posedge res)
  begin
  if(res) begin
  	valid_bpsk<=0;
  	i<=0;
    end
  else if(en && ready_in && valid_rom) begin
		valid_bpsk <=1'b1;
        i <= idata ? A : -A;     
  end
  else valid_bpsk <=1'b0;
  end

  always @(posedge clk or posedge res) begin
  	if (res) begin
  		error <= 0;
  		ready_out <= 0;
  	end
  	else begin
  		ready_out <= (error) ? 0 : 1;
  	end
  end
	
 endmodule  
