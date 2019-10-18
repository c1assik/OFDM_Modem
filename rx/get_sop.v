module get_sop(

input clk, rst, sop,
output reg new_sop
);



reg [10:0] count_sop;
reg [10:0] count_symbol;

always@(posedge clk or posedge rst)
begin
if (rst) begin count_sop <= 0; count_symbol <= 0; end
 else if (sop) begin count_sop <= 1; count_symbol <= 0; end
	else if (count_sop < 11'd1055) count_sop <= count_sop + 1'b1;
		else if (count_sop == 11'd1055 && count_symbol == 6'd30) count_symbol <= 40;
			else if (count_sop == 11'd1055) begin count_sop <= 0; count_symbol <= count_symbol + 1; end
end

always@(posedge clk or posedge rst)
begin
if (rst) new_sop <= 0;
 else begin if (count_sop == 11'd1055 && count_symbol < 35)
   new_sop <= 1'b1;
	else new_sop =0;
	end
end

endmodule

