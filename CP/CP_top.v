module CP_top
(
input clk, en, rst,
output signed [19:0] out_i, out_q
);
wire s;
wire signed [19:0] i, q;

CP_test c1(
		.clk(clk),
		.en(en), 
		.rst(rst),
 		.sop(s),
		.i(i), 
		.q(q)
);

CP c2(
		.clk(clk), 
		.en(en), 
		.rst(rst), 
		.in_sop(s),
		.in_i(i), 
		.in_q(q),
		.out_i(out_i), 
		.out_q(out_q)
	);

endmodule