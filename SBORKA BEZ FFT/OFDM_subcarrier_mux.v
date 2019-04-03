    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : OFDM_subcarrier_mux.v
// Create : 2018-12-21 14:58:43
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module OFDM
#(
	parameter OFDM_SIZE   = 1024,
	parameter Num_Carrier = 412*2)
(

input clk, en, rst, ready_in, valid_qam, valid_pilot,
input signed [15:0] i,q,
input index_pilot, sign_pilot,

output reg  [10:0] count,
output reg ready_out_ROM,ready_out_pilots,
output reg signed [15:0] i_OFDM, q_OFDM,
output reg valid_OFDM,
output reg sop
);

reg indexCarrier;
reg signed [15:0] pilot_value;
reg pilot1, pilot2,pilot3;   // delay for pilots, 2 ticks


initial
 begin
  pilot_value           = 16'd32_767;
 end

//wire indexCarrier;
reg [10:0] mid_ofdm;
reg [10:0] Left_index;
reg [10:0] Right_index;

initial
begin
valid_OFDM              = 0;
sop                     = 0;
indexCarrier            = 0;
ready_out_ROM           = 0;
i_OFDM                 = 0;
q_OFDM                 = 0;
mid_ofdm               = (OFDM_SIZE >> 1) - 1;                     
Left_index             = mid_ofdm - (Num_Carrier >> 1);   
Right_index            = mid_ofdm + (Num_Carrier >> 1);  
count                  = 0;
pilot1          <= 0;
pilot2          <= 0;  
pilot3       	<= 0;
end

always@(posedge clk or posedge rst)
begin 												                	
	if (rst) 														   
	begin                                       			   	      
		pilot1          <= 0;
		pilot2          <= 0;  
		pilot3       	<= 0;
	end                                                      
	else 
	begin 
	pilot1              <= index_pilot;
	pilot2              <= pilot1;
	pilot3              <= pilot2;          
	end                                                       						    
end

always @(posedge clk or posedge rst) 
begin 												                	
	if (rst) 														   
	begin                                       			   	      
		count           <=0; 
		valid_OFDM         <= 0;                                                                                             
	end                                                      
	else 
	begin 
		if(en && ready_in) 
		begin     								                   
			if(count == 10'b1111111111) count <= 0;                         
			else count  <= count + 1;    
			sop         <= (count == 0) ? 1 : 0;
			valid_OFDM          <= 1;                        
		end                                                       						    
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
	 i_OFDM             <= 0;
     q_OFDM             <= 0;
	end
	else if (en && ready_in && valid_pilot ) begin
	 i_OFDM             <= (pilot3) ? (sign_pilot ? (~pilot_value + 1) : pilot_value) : ((indexCarrier && valid_qam) ?  i : 0);
     q_OFDM             <= (pilot3) ? 0 : ((indexCarrier && valid_qam) ?  q : 0);
	end 
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
     ready_out_ROM      <= 0;
     ready_out_pilots   <= 0;
     indexCarrier       <= 0;
	end
	else if (en && ready_in) begin
	 ready_out_pilots  <= 1'b1;
     ready_out_ROM     <= index_pilot ? 1'b0 : (((count < Left_index -2'b10) || (count == mid_ofdm-2'b11) || (count > Right_index-2'b10)) ? 0 : 1'b1);
     indexCarrier      <= ((count < Left_index ) || (count == mid_ofdm) || (count > Right_index)) ? 0 : 1'b1;   
	end
end

endmodule
