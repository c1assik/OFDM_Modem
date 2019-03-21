module CP_top
(
input clk, en, rst,
output signed [19:0] out_i, out_q,
output sop_out
);
wire s;
wire signed [19:0] i, q;
wire s1;
wire signed [19:0] i2, q2;

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
		.out_i(i2), 
		.out_q(q2),
		.sop_out(s1)
	);

Rev_spec c3(
		.clk(clk), 
		.en(en), 
		.rst(rst),  
		.in_sop(s1),
		.in_i(i2), 
		.in_q(q2),
	 	.out_i(out_i),
	 	.out_q(out_q),
	 	.sop_out(sop_out)
	);

endmodule