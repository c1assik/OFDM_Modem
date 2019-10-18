module Rev_spec
(
	input clk, en, rst,
	input signed [13:0] in_i, in_q,
	output reg signed [13:0] out_i, out_q
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
	if (rst)
	begin
	 out_i<=0;
	 out_q<=0;
	end
	else begin
	 out_i <= count ? in_i : (~in_i + 1);
	 out_q <= count ? in_q : (~in_q + 1);
	end
 end


endmodule