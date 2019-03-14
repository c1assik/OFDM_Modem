    
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
// Author : Miyutin & Petrovsky 
// File   : toptop_tb.v
// Create : 2018-12-21 14:59:11
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------



/** The rom testbenablech */
module top_preambula_tb;

parameter tck = 10; ///< clock tick

reg clock,enable, reset,ready_in; 


wire signed [15:0] out_i;
   wire ready_in2, valid_rom, valid_bpsk;
   wire [1:0]	Bit_wire;
   

  integer outfile, outfile1;
/** The LFSR DUT instance */
toptop_preambula top_inst(clock, enable, reset,ready_in, out_i);
 

initial 
begin
	outfile =$fopen("OFDM_Symbol.txt");
	outfile1 =$fopen("data_Symbol.txt");

	

	$dumpfile("toptop.vcd");
	$dumpvars(0, top_preambula_tb);
	$monitor("%b", clock, enable, reset,ready_in, out_i);
end

// testbenablech actions
initial
begin
	clock = 0;enable =0; reset = 0; ready_in = 1;
	#50  enable =1;
	#1050  reset  =1;
	#1   reset  =0;
	#1200 reset  = 1;
	#100 reset  =0;

	

	

end 

initial 
begin
	#22000$fclose(outfile);
	$fclose(outfile1);
	#1 $finish;	
end

always #(tck/2) clock <= ~clock; // clocking device

integer i = 0;

initial
begin
#2;
 while(i < 2000) begin
 	//$fdisplay(outfile, "%d", i_OFDM,"\t", q_OFDM,"\t", sop);
 	$fdisplay(outfile1, "%d", out_i,"\t");
 	#10;
 	i = i + 1;
 end
  
end
endmodule
