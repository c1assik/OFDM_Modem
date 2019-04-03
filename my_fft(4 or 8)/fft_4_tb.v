module fft_4_tb;

parameter tck = 10; 

reg  clk, en, rst;
reg signed [2+5:0] i_reA, i_reB, i_reC, i_reD,i_imA, i_imB, i_imC, i_imD;
wire signed [4+5:0] o_re0, o_re1, o_re2, o_re3,o_im0, o_im1, o_im2, o_im3;

fft_4 top_inst(clk, en, rst,i_reA, i_reB, i_reC, i_reD,i_imA, i_imB, i_imC, i_imD,o_re0, o_re1, o_re2, o_re3,o_im0, o_im1, o_im2, o_im3);
 

initial 
begin
	$dumpfile("fft_4.vcd");
	$dumpvars(0, fft_4_tb);
	$monitor("%b",clk, en, rst,"%d",i_reA, i_reB, i_reC, i_reD,i_imA, i_imB, i_imC, i_imD,,o_re0, o_re1, o_re2, o_re3,o_im0, o_im1, o_im2, o_im3);
end

initial
begin
	clk = 0;
	en = 1;
	rst = 0;
	i_reA = 0;
	i_reB = 0;
	i_reC = 0;
	i_reD = 0;
	i_imA = 0;
	i_imB = 0;
	i_imC = 0;
	i_imD = 0;
	#100 i_reA = 3'd3;
	i_reB = 3'd2;
	i_reC = 3'd1;
	i_reD = 3'd3;
	#10 i_reA = 3'd0;
	i_reB = 3'd0;
	i_reC = 3'd0;
	i_reD = 3'd0;
	#2000 $finish;	
end

always #(tck/2) clk <= ~clk; // clocking device

endmodule
