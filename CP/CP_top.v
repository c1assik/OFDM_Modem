module CP_top
(
input clk, en, rst,
output signed [13:0] out_i, out_q,
output sop_out
);
wire s;
wire signed [15:0] i, q;
wire s1;
wire signed [15:0] i2, q2;
wire s2;
wire signed [15:0] i3, q3;

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
	 	.out_i(i3),
	 	.out_q(q3),
	 	.sop_out(s2)
	);

Norm c4(
		.clk(clk), 
		.en(en), 
		.rst(rst),  
		.in_sop(s2),
		.in_i(i3), 
		.in_q(q3),
	 	.out_i(out_i),
	 	.out_q(out_q),
	 	.sop_out(sop_out)
);

endmodule