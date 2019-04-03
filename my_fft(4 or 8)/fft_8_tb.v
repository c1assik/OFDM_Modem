module fft_8_tb;

parameter tck = 10; 

reg  clk, en, rst;
reg signed [2+5:0] i_re0, i_re1, i_re2, i_re3,i_re4, i_re5, i_re6, i_re7, i_im0, i_im1, i_im2, i_im3, i_im4, i_im5, i_im6, i_im7;
wire signed [5+5:0] o_re0, o_re1, o_re2, o_re3,o_re4, o_re5, o_re6, o_re7, o_im0, o_im1, o_im2, o_im3, o_im4, o_im5, o_im6, o_im7;

fft_8 top_inst(clk, en, rst, i_re0, i_re1, i_re2, i_re3,i_re4, i_re5, i_re6, i_re7, i_im0, i_im1, i_im2, i_im3, i_im4, i_im5, i_im6, i_im7,
				o_re0, o_re1, o_re2, o_re3,o_re4, o_re5, o_re6, o_re7, o_im0, o_im1, o_im2, o_im3, o_im4, o_im5, o_im6, o_im7);

initial 
begin
	$dumpfile("fft_8.vcd");
	$dumpvars(0, fft_8_tb);
	$monitor("%b",clk, en, rst, i_re0, i_re1, i_re2, i_re3,i_re4, i_re5, i_re6, i_re7, i_im0, i_im1, i_im2, i_im3, i_im4, i_im5, i_im6, i_im7,
				o_re0, o_re1, o_re2, o_re3,o_re4, o_re5, o_re6, o_re7, o_im0, o_im1, o_im2, o_im3, o_im4, o_im5, o_im6, o_im7);
end

initial
begin
	clk = 0;
	en = 1;
	rst = 0;
	i_re0 = 0;	i_re1 = 0;	i_re2 = 0;	i_re3 = 0;	i_re4 = 0;	i_re5 = 0;	i_re6 = 0;	i_re7 = 0;
	i_im0 = 0;	i_im1 = 0;	i_im2 = 0;	i_im3 = 0;	i_im4 = 0;	i_im5 = 0;	i_im6 = 0;	i_im7 = 0;
	#100 	
	i_re0 = 7'b100;	i_re1 = 7'b01100;	i_re2 = 7'b100;	i_re3 = 7'b01100;	i_re4 = 7'b01000;	i_re5 = 7'b100;	i_re6 = 7'b100;	i_re7 = 7'b100;
	i_im0 = 3'b0;	i_im1 = 3'b0;	i_im2 = 3'b0;	i_im3 = 3'b0;	i_im4 = 3'b0;	i_im5 = 3'b0;	i_im6 = 3'b0;	i_im7 = 3'b0;
	#10 	
	i_re0 = 3'b0;	i_re1 = 3'b0;	i_re2 = 3'b0;	i_re3 = 3'b0;	i_re4 = 3'b0;	i_re5 = 3'b0;	i_re6 = 3'b0;	i_re7 = 3'b0;
	i_im0 = 3'b0;	i_im1 = 3'b0;	i_im2 = 3'b0;	i_im3 = 3'b0;	i_im4 = 3'b0;	i_im5 = 3'b0;	i_im6 = 3'b0;	i_im7 = 3'b0;
	#10 	
	i_re0 = 3'b0;	i_re1 = 3'b0;	i_re2 = 3'b0;	i_re3 = 3'b0;	i_re4 = 3'b0;	i_re5 = 3'b0;	i_re6 = 3'b0;	i_re7 = 3'b0;
	i_im0 = 3'b0;	i_im1 = 3'b0;	i_im2 = 3'b0;	i_im3 = 3'b0;	i_im4 = 3'b0;	i_im5 = 3'b0;	i_im6 = 3'b0;	i_im7 = 3'b0;
	#10 	
	i_re0 = 0;	i_re1 = 0;	i_re2 = 0;	i_re3 = 0;	i_re4 = 0;	i_re5 = 0;	i_re6 = 0;	i_re7 = 0;
	i_im0 = 0;	i_im1 = 0;	i_im2 = 0;	i_im3 = 0;	i_im4 = 0;	i_im5 = 0;	i_im6 = 0;	i_im7 = 0;
	#200 $finish;	
end

always #(tck/2) clk <= ~clk; // clocking device

endmodule
