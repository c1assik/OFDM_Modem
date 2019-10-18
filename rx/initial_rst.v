module initial_rst
(	
	input clk, rst,
	output reg tru_rst
);

reg indikate;
reg [10:0] count_rst;


initial
begin
	indikate = 0;
	count_rst = 0;
end


always @(posedge clk or posedge rst)
begin 
	if(rst) begin
		indikate <= 0;
		count_rst <= 0;
	end
	else begin
		if (count_rst < 11'd1024) begin
				count_rst <= count_rst + 1;
				indikate <= 1'b0;
		end	
		else begin 
				count_rst <= 11'd1025;
				indikate <= 1'b1;
		end
		if (indikate == 1'b1) tru_rst <= 1'b0; else tru_rst <= 1'b1;
	end
end

endmodule