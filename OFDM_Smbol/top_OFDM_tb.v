    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : toptop_tb.v
// Create : 2018-12-21 14:59:11
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------



/** The rom testbenablech */
module toptop_ofdm_tb;

parameter tck = 10; ///< clock tick

reg clock,enable, reset,ready_in;
wire signed [15:0] i_OFDM, q_OFDM;
wire valid_OFDM,sop;


/** The LFSR DUT instance */
top_OFDM top_inst(clock, enable, reset,ready_in,i_OFDM, q_OFDM,valid_OFDM, sop);
 

initial 
begin
	$dumpfile("ofdm_final.vcd");
	$dumpvars(0, toptop_ofdm_tb);
	$monitor("%b", clock, enable, reset,ready_in,i_OFDM, q_OFDM,sop);
end

// testbenablech actions
initial
begin
	clock = 0;enable =1; reset = 0; ready_in = 1; 
	#3000 reset =1;
	#10 reset =0;
	#22000 $finish;	
end

always #(tck/2) clock <= ~clock; // clocking device

endmodule
