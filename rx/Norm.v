module Norm(

input clk,rst,
input signed [13:0] i_data,q_data,
output signed [15:0] Norm_I,Norm_Q

);
reg signed [15:0] q,i;

initial
begin
	i = 0;
	q = 0;
end

always@(posedge clk or posedge rst) 
begin
if(rst) begin
 i<=0;
 q<=0;
end
 i[15] <= i_data[13];
 i[14] <= i_data[13];
 i[13] <= i_data[13];
 i[12:0] <= i_data[12:0];
 q[15] <= q_data[13];
 q[14] <= q_data[13];
 q[13] <= q_data[13];
 q[12:0] <= q_data[12:0];
end

assign Norm_I = i;
assign Norm_Q = q;

endmodule