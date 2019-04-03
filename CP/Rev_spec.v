module Rev_spec
(
	input clk, en, rst, in_sop,
	input signed [15:0] in_i, in_q,
	output reg signed [15:0] out_i, out_q,
	output reg sop_out
);

reg count;

initial
begin
	count = 0;
end

always @(posedge clk or posedge rst) begin
	if (rst) count <= 0;
	else count <= ~count;
end

always @(posedge clk) begin
	sop_out <= in_sop;
	out_i <= count ? in_i : (~in_i + 1);
	out_q <= count ? in_q : (~in_q + 1);
end

endmodule