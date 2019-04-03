module fft_4
(
	input clk, en, rst,
	input signed [2+5:0]  i_reA, i_reB, i_reC, i_reD,i_imA, i_imB, i_imC, i_imD,

	output reg signed [4+5:0] o_re0, o_re1, o_re2, o_re3,o_im0, o_im1, o_im2, o_im3
);

reg signed [3+5:0] sum_imAC, sum_imBD, diff_imAC, diff_imBD, sum_reAC, sum_reBD, diff_reAC, diff_reBD;

initial
begin
	o_re0 = 0;
	o_re1 = 0;
	o_re2 = 0;
	o_re3 = 0;
	o_im0 = 0;
	o_im1 = 0;
	o_im2 = 0;
	o_im3 = 0;
	sum_imAC = 0;
	sum_imBD = 0;
	diff_imAC = 0;
	diff_imBD = 0;
    sum_reAC = 0;
	sum_reBD = 0;
	diff_reAC = 0;
	diff_reBD = 0;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
	begin
		o_re0 <= 0;
		o_re1 <= 0;
		o_re2 <= 0;
		o_re3 <= 0;
		o_im0 <= 0;
		o_im1 <= 0;
		o_im2 <= 0;
		o_im3 <= 0;
		sum_imAC <= 0;
		sum_imBD <= 0;
		diff_imAC <= 0;
		diff_imBD <= 0;
		sum_reAC <= 0;
		sum_reBD <= 0;
		diff_reAC <= 0;
		diff_reBD <= 0;
	end
	else if (en) 
	begin
		o_re0 <= sum_reAC + sum_reBD;
		o_re1 <= diff_reAC + diff_imBD;
		o_re2 <= sum_reAC - sum_reBD;
		o_re3 <= diff_reAC - diff_imBD;

		o_im0 <= sum_imAC + sum_imBD;
		o_im1 <= diff_imAC + diff_reBD;
		o_im2 <= sum_imAC - sum_imBD;
		o_im3 <= diff_imAC - diff_reBD;

		sum_imAC <= i_imA + i_imC;
		sum_imBD <= i_imB + i_imD;
		diff_imAC <= i_imA - i_imC;
		diff_imBD <= i_imB - i_imD;
		sum_reAC <= i_reA + i_reC;
		sum_reBD <= i_reB + i_reD;
		diff_reAC <= i_reA - i_reC;
		diff_reBD <= i_reB - i_reD;
	end
end

endmodule