module demod(

input clk, rst, sop,
input signed [15:0] i_data,q_data,
output reg [1:0] data, d_reg
);

reg [1:0] index[1055:0];
reg [10:0] count;
reg [1:0] reg_data [5127:0];
reg [15:0] count_written;
reg [1:0] count_0_1;
reg [15:0] count_read;

initial
begin
	$readmemb("index.txt", index);
	data = 0;
	count = 0;
	count_0_1 = 0;
	count_written = 0;
	count_read = 0;
end

always @(posedge clk or posedge rst)
begin
if (rst)	
	begin
		count <= 1'b0;
	end
	else if (sop) 
		begin
			count <= 1'b1;
		end
			else if (count < 11'd1024) count <= count + 1'b1; 
					else count <= 11'd1025; 
end	

always @(posedge clk or posedge rst)
begin
if (rst)	begin
	count_0_1 <= 0;
	count_written <= 0;
	data <= 1'b0;
end else if (index[count] == 2'b10)
		begin
			if (i_data > 0) data[1] <= 0; else data[1] <= 1;
 			if (q_data > 0) data[0] <= 0; else data[0] <= 1;
			if (count_0_1 == 0) begin
				if (count_written < 15'd5127) begin
					if (i_data > 0) reg_data[count_written][1] <= 0; else reg_data[count_written][1] <= 1;
					if (q_data > 0) reg_data[count_written][0] <= 0; else reg_data[count_written][0] <= 1;
					count_written <= count_written + 1;
				end else if (count_written == 15'd5127) begin
					count_0_1 <= 1;
					count_written <= count_written + 1;
					if (i_data > 0) reg_data[count_written][1] <= 0; else reg_data[count_written][1] <= 1;
					if (q_data > 0) reg_data[count_written][0] <= 0; else reg_data[count_written][0] <= 1;
				end else count_written <= 15'd5300;
			end
		end 
		else data <= 2'd0;		 
end	

always @(posedge clk or posedge rst)
begin
if (rst)	count_read <= 0;
else if (count_0_1 == 1) begin
			d_reg <= reg_data[count_read];
			count_read <= count_read + 1;
		end	 
end	

endmodule
