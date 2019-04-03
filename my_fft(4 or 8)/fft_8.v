module fft_8
(
	input clk, en, rst,
	input signed [2+5:0] i_re0, i_re1, i_re2, i_re3,i_re4, i_re5, i_re6, i_re7, i_im0, i_im1, i_im2, i_im3, i_im4, i_im5, i_im6, i_im7,
	
	output reg signed [5+5:0] o_re0, o_re1, o_re2, o_re3,o_re4, o_re5, o_re6, o_re7, o_im0, o_im1, o_im2, o_im3, o_im4, o_im5, o_im6, o_im7
);

wire signed [4+5:0] A_r, B_r, C_r, D_r, E_r, F_r, H_r, G_r, A_i, B_i, C_i, D_i, E_i, F_i, H_i, G_i;
reg signed [7+5:0] W8 = 7'd90;
reg signed [5+5:0] reg_buff_r [7:0];
reg signed [5+5:0] reg_buff_i [7:0];
reg signed [12+5:0] reg_buff_r1 [7:0];
reg signed [12+5:0] reg_buff_i1 [7:0];



initial
begin
	o_re0 = 0;	o_re1 = 0;	o_re2 = 0;	o_re3 = 0;	o_re4 = 0;	o_re5 = 0;	o_re6 = 0;	o_re7 = 0;
	o_im0 = 0; 	o_im1 = 0;	o_im2 = 0;	o_im3 = 0;	o_im4 = 0;	o_im5 = 0;	o_im6 = 0;	o_im7 = 0;
end

fft_4 fft_4_1 	(
				.clk(clk), 
				.en(en),
				.rst(rst),
				.i_reA(i_re0), 
				.i_reB(i_re1), 
				.i_reC(i_re2), 
				.i_reD(i_re3),
				.i_imA(i_im0), 
				.i_imB(i_im1), 
				.i_imC(i_im2), 
				.i_imD(i_im3),
				.o_re0(A_r), 
				.o_re1(B_r), 
				.o_re2(C_r), 
				.o_re3(D_r),
				.o_im0(A_i), 
				.o_im1(B_i), 
				.o_im2(C_i), 
				.o_im3(D_i)
	);

fft_4 fft_4_2	 (
				.clk(clk), 
				.en(en),
				.rst(rst),
				.i_reA(i_re4), 
				.i_reB(i_re5), 
				.i_reC(i_re6), 
				.i_reD(i_re7),
				.i_imA(i_im4), 
				.i_imB(i_im5), 
				.i_imC(i_im6), 
				.i_imD(i_im7),
				.o_re0(E_r), 
				.o_re1(F_r), 
				.o_re2(H_r), 
				.o_re3(G_r),
				.o_im0(E_i), 
				.o_im1(F_i), 
				.o_im2(H_i), 
				.o_im3(G_i)
	);

always @(posedge clk or posedge rst) begin
	if (rst) begin
		o_re0 = 0;	o_re1 = 0;	o_re2 = 0;	o_re3 = 0;	o_re4 = 0;	o_re5 = 0;	o_re6 = 0;	o_re7 = 0;
		o_im0 = 0; 	o_im1 = 0;	o_im2 = 0;	o_im3 = 0;	o_im4 = 0;	o_im5 = 0;	o_im6 = 0;	o_im7 = 0;		
	end
	else if (en) begin
		reg_buff_r[0] = A_r;
		reg_buff_r[1] = B_r; 
		reg_buff_r[2] = C_r;
		reg_buff_r[3] = D_r;
		reg_buff_r[4] = E_r;
		reg_buff_r[5] = F_r + F_i;
		reg_buff_r[6] = H_r;
		reg_buff_r[7] = G_i - G_r;

		reg_buff_i[0] = A_i;
		reg_buff_i[1] = B_i;
		reg_buff_i[2] = C_i;
		reg_buff_i[3] = D_i;
		reg_buff_i[4] = E_i;
		reg_buff_i[5] = F_i - F_r;
		reg_buff_i[6] = H_i;
		reg_buff_i[7] = -G_i - G_r;

		reg_buff_r1[0] = reg_buff_r[0];
		reg_buff_r1[1] = reg_buff_r[1] << 7;
		reg_buff_r1[2] = reg_buff_r[2];
		reg_buff_r1[3] = reg_buff_r[3] << 7;
		reg_buff_r1[4] = reg_buff_r[4];
		reg_buff_r1[5] = reg_buff_r[5] * W8;
		reg_buff_r1[6] = reg_buff_r[6];
		reg_buff_r1[7] = reg_buff_r[7] * W8;

		reg_buff_i1[0] = reg_buff_i[0];
		reg_buff_i1[1] = reg_buff_i[1] << 7;
		reg_buff_i1[2] = reg_buff_i[2];
		reg_buff_i1[3] = reg_buff_i[3] << 7;
		reg_buff_i1[4] = reg_buff_i[4];
		reg_buff_i1[5] = reg_buff_i[5] * W8;
		reg_buff_i1[6] = reg_buff_i[6];
		reg_buff_i1[7] = reg_buff_i[7] * W8;

		o_re0 <= reg_buff_r1[0] + reg_buff_r1[4];
		o_re1 <= (reg_buff_r1[1] + reg_buff_r1[5]) >> 7;
		o_re2 <= reg_buff_r1[2] + reg_buff_i1[6];
		o_re3 <= (reg_buff_r1[3] + reg_buff_r1[7]) >> 7;
		o_re4 <= reg_buff_r1[0] - reg_buff_r1[4];
		o_re5 <= (reg_buff_r1[1] - reg_buff_r1[5]) >> 7;
		o_re6 <= reg_buff_r1[2] - reg_buff_i1[6];
		o_re7 <= (reg_buff_r1[3] - reg_buff_r1[7]) >> 7;
		o_im0 <= reg_buff_i1[0] + reg_buff_i1[4];
		o_im1 <= (reg_buff_i1[1] - reg_buff_i1[5]) >> 7;
		o_im2 <= reg_buff_i1[2] + reg_buff_r1[6];
		o_im3 <= (reg_buff_i1[3] - reg_buff_i1[7]) >> 7;
		o_im4 <= reg_buff_i1[0] - reg_buff_i1[4];
		o_im5 <= (reg_buff_i1[1] + reg_buff_i1[5]) >> 7;
		o_im6 <= reg_buff_i1[2] - reg_buff_r1[6];
		o_im7 <= (reg_buff_i1[3] + reg_buff_i1[7]) >> 7;
	end
end

endmodule