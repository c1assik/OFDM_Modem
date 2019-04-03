module top_Symbol_tb;

parameter tck = 10; 

reg clk, en, rst, ready_in,
wire signed [15:0] out_q, out_i,
wire valid_qam

top_Symbol top_inst(clk, en, rst, ready_in, out_q, out_i, valid_qam);
 

initial 
begin
	$dumpfile("test.vcd");
	$dumpvars(0, top_Symbol_tb);
	$monitor(clk, en, rst, ready_in, out_q, out_i, valid_qam);
end

initial
begin
	clk = 0; 
	en = 0;
	rst = 0; 
	ready_in = 0;
	#50 
	en = 1;
	#50 
	ready_in = 1;
	#50000
	$finish;	
end

always #(tck/2) clk <= ~clk; // clocking device

endmodule

