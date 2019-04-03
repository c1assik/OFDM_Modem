module CP_test
(
input clk, en, rst,
output reg sop,
output reg signed [15:0] i, q
);

reg [23:0] n;
initial
begin
	n = 0;
	i = 0;
	q = 0;
end

always @(posedge clk or posedge rst) begin
	n <= n + 1;
end

always @(posedge clk or posedge rst) begin
	if ((n == 200) || (n == 1256)) sop <= 1; else sop <= 0;
	if ((n > 199)) begin
			i <= i + 5;
			q <= q + 1;
		end
end

endmodule