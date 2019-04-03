module Norm
(
	input clk, en, rst, in_sop,
	input signed [15:0] in_i, in_q,
	output reg signed [13:0] out_i, out_q,
	output reg sop_out
);

always @(posedge clk) begin
	sop_out <= in_sop;
	out_i <= {in_i[15],in_i[12:0]};
	out_q <= {in_q[15],in_q[12:0]};
end

endmodule