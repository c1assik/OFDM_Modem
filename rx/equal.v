module equal (

input clk, rst, sop,
input signed [15:0] i_data,q_data,
output reg signed [15:0] o_data_i,o_data_q,
output reg out_sop

);


reg [1:0] index[1055:0];
reg value[90:0];
reg [14:0] B;
reg [10:0] count;
reg signed [15:0] shift_i[20:0];
reg signed [15:0] shift_q[20:0];
reg shift_sop[31:0];
reg [6:0] count_pilot;






initial
begin
	$readmemb("index.txt", index);
	$readmemb("value.txt", value);
	o_data_i = 0;
	o_data_q = 0;
	out_sop = 0;
	count_pilot = 0;
	count = 11'd0;
	B = 15'd2048;  // pilots
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
			count_pilot <= 0;
		end
			else 
			begin
				count <= count + 1'b1;
				if (index[count] == 2'b01) count_pilot <= count_pilot + 1'b1;
			end 
end			

reg signed [31:0] ocenka_1_i,ocenka_2_i,mid_ocenka_i;
reg signed [31:0] ocenka_1_q,ocenka_2_q,mid_ocenka_q;


reg signed [31:0] NUM_I,NUM_Q,DENUM_I,DENUM_Q;


always @(posedge clk or posedge rst)
begin
if (rst)	
	begin
		ocenka_1_i <= 1'b0;
		ocenka_2_i <= 1'b0;
		ocenka_1_q <= 1'b0;
		ocenka_2_q <= 1'b0;
	end
	else begin
		if (index[count] == 2'b01) begin
			NUM_I[31:31-15] <= i_data ;
			NUM_Q[31:31-15] <= q_data ;
			if (value[count_pilot] == 0) DENUM_I <= (B); 
			else DENUM_I <= (-B);
			if (value[count_pilot] == 0) DENUM_Q <= (B); 
			else DENUM_Q <= (-B);				
			end
			else begin
				NUM_I <= 1;
				NUM_Q <= 1;
				DENUM_I <= 1;
				DENUM_Q <= 1;
			end
		if (O_I != 1 ) begin
			ocenka_1_i <= O_I;
			ocenka_2_i <= ocenka_1_i;
			end
		if (O_Q != 1) begin
			ocenka_1_q <= O_Q;
			ocenka_2_q <= ocenka_1_q;
			end
		mid_ocenka_i <= (ocenka_1_i + ocenka_2_i)/2;
		mid_ocenka_q <= (ocenka_1_q + ocenka_2_q)/2;		
		
	DIV_I[31:31-15] <= shift_i[20] ;
	DIV_Q[31:31-15] <= shift_q[20] ;
	o_data_i <= {I[63],I[16:2]};
	o_data_q <= {Q[63],Q[16:2]};
	out_sop <= shift_sop[31];
	end	
end			

wire signed [63:0] I,Q;
reg signed [31:0] DIV_I,DIV_Q;
wire signed [31:0] O_I,O_Q;
	div divI 										(
															.clock(clk),
															.denom(DENUM_I),
															.numer(NUM_I),
															.quotient(O_I)
														 );



	div divQ 										(
															.clock(clk),
															.denom(DENUM_Q),
															.numer(NUM_Q),
															.quotient(O_Q)
														 );
  
  
  comp_div comp_div1								   (
															.clk(clk),
															.rst(rst),
															.i_data(DIV_I),
															.q_data(DIV_Q),
															.mid_ocenka_i(mid_ocenka_i),
															.mid_ocenka_q(mid_ocenka_q),
															.eq_I(I),
															.eq_Q(Q)
														 );


always @(posedge clk or posedge rst)
begin
	if(rst) begin
  shift_i[0] <= 0;
  shift_q[0] <= 0;
  shift_sop[0] <= 0;
  
  shift_i[1] <= 0;
  shift_i[2] <= 0;
  shift_i[3] <= 0; 
  shift_i[4] <= 0;
  shift_i[5] <= 0;
  shift_i[6] <= 0;  
  shift_i[7] <= 0;
  shift_i[8] <= 0;
  shift_i[9] <= 0;   
  shift_i[10] <= 0;
  shift_i[11] <= 0;
  shift_i[12] <= 0;
  
  shift_q[1] <= 0;
  shift_q[2] <= 0;
  shift_q[3] <= 0; 
  shift_q[4] <= 0;
  shift_q[5] <= 0;
  shift_q[6] <= 0;  
  shift_q[7] <= 0;
  shift_q[8] <= 0;
  shift_q[9] <= 0;   
  shift_q[10] <= 0;
  shift_q[11] <= 0;
  shift_q[12] <= 0; 
 

  shift_sop[1] <= 0;
  shift_sop[2] <= 0;
  shift_sop[3] <= 0; 
  shift_sop[4] <= 0;
  shift_sop[5] <= 0;
  shift_sop[6] <= 0;  
  shift_sop[7] <= 0;
  shift_sop[8] <= 0;
  shift_sop[9] <= 0;
  shift_sop[10] <= 0; 
	end else begin
  shift_i[0] <= i_data;
  shift_q[0] <= q_data;
  shift_sop[0] <= sop; 
 
  shift_q[1] <= shift_q[0];
  shift_q[2] <= shift_q[1];
  shift_q[3] <= shift_q[2];
  shift_q[4] <= shift_q[3];
  shift_q[5] <= shift_q[4];
  shift_q[6] <= shift_q[5];
  shift_q[7] <= shift_q[6];
  shift_q[8] <= shift_q[7];
  shift_q[9] <= shift_q[8];
  shift_q[10] <= shift_q[9];
  shift_q[11] <= shift_q[10];
  shift_q[12] <= shift_q[11];
  shift_q[13] <= shift_q[12];
  shift_q[14] <= shift_q[13];
  shift_q[15] <= shift_q[14];
  shift_q[16] <= shift_q[15];
  shift_q[17] <= shift_q[16];
  shift_q[18] <= shift_q[17];
  shift_q[19] <= shift_q[18];
  shift_q[20] <= shift_q[19];
  
  
  shift_i[1] <= shift_i[0];
  shift_i[2] <= shift_i[1];
  shift_i[3] <= shift_i[2];
  shift_i[4] <= shift_i[3];
  shift_i[5] <= shift_i[4];
  shift_i[6] <= shift_i[5];
  shift_i[7] <= shift_i[6];
  shift_i[8] <= shift_i[7];
  shift_i[9] <= shift_i[8];  
  shift_i[10] <= shift_i[9];
  shift_i[11] <= shift_i[10];
  shift_i[12] <= shift_i[11];
  shift_i[13] <= shift_i[12];
  shift_i[14] <= shift_i[13];
  shift_i[15] <= shift_i[14];
  shift_i[16] <= shift_i[15];
  shift_i[17] <= shift_i[16];
  shift_i[18] <= shift_i[17];
  shift_i[19] <= shift_i[18];
  shift_i[20] <= shift_i[19];
  
 shift_sop[1] <= shift_sop[0];
  shift_sop[2] <= shift_sop[1];
  shift_sop[3] <= shift_sop[2];
  shift_sop[4] <= shift_sop[3];
  shift_sop[5] <= shift_sop[4];
  shift_sop[6] <= shift_sop[5];
  shift_sop[7] <= shift_sop[6];
  shift_sop[8] <= shift_sop[7];
  shift_sop[9] <= shift_sop[8];
  shift_sop[10] <= shift_sop[9];
  shift_sop[11] <= shift_sop[10];
  shift_sop[12] <= shift_sop[11];
  shift_sop[13] <= shift_sop[12];
  shift_sop[14] <= shift_sop[13];
  shift_sop[15] <= shift_sop[14];
  shift_sop[16] <= shift_sop[15];
  shift_sop[17] <= shift_sop[16];
  shift_sop[18] <= shift_sop[17];
  shift_sop[19] <= shift_sop[18];
  shift_sop[20] <= shift_sop[19];
  shift_sop[21] <= shift_sop[20];
  shift_sop[22] <= shift_sop[21];
  shift_sop[23] <= shift_sop[22];
  shift_sop[24] <= shift_sop[23];
  shift_sop[25] <= shift_sop[24];
  shift_sop[26] <= shift_sop[25];
  shift_sop[27] <= shift_sop[26];
  shift_sop[28] <= shift_sop[27];
  shift_sop[29] <= shift_sop[28];
  shift_sop[30] <= shift_sop[29];
  shift_sop[31] <= shift_sop[30];
end
end




endmodule
