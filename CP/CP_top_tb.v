module CP_top_tb;

parameter tck = 10; ///< clock tick

reg clk, en, rst;
wire signed [19:0] out_i, out_q;

CP_top top_inst(clk, en, rst, out_i, out_q);
 
initial 
begin
	$dumpfile("CP_top.vcd");
	$dumpvars(0, CP_top_tb);
	$monitor("%b", clk, en, rst, out_i, out_q);
end

initial
begin
	clk = 1; en = 0; rst = 0;  
	#100000 $finish;	
end

always #(tck/2) clk <= ~clk; // clocking device

endmodule
