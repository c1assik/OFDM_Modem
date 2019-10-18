module upconv (
 
 input clk, rst,
 input signed [13:0] data_in,
 
 output reg signed [13:0] down_data_i, down_data_q

);

reg signed [1:0] coef_sin [3:0];
reg signed [1:0] coef_cos [3:0];
reg [1:0] count;


initial
begin
coef_sin[0] = 2'b00;
coef_sin[1] = 2'b11;
coef_sin[2] = 2'b00;
coef_sin[3] = 2'b01;

coef_cos[0] = 2'b01;
coef_cos[1] = 2'b00;
coef_cos[2] = 2'b11;
coef_cos[3] = 2'b00;

count = 0;

down_data_i = 0;
down_data_q = 0;
end

always @(posedge clk or posedge rst)
begin
	if (rst) count <= 0;
	else count <= count + 1;
end

always @(posedge clk or posedge rst)
begin
	if (rst) 
	begin
		down_data_i <= 0;
		down_data_q <= 0;
	end
	else 
	begin
	down_data_i <= data_in * coef_cos[count];
	down_data_q <= data_in * coef_sin[count];
	end
end

endmodule