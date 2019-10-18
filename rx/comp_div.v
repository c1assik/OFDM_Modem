module comp_div(

input clk, rst,
input signed [31:0] i_data,q_data,
input signed [31:0] mid_ocenka_i, mid_ocenka_q,

output signed [63:0] eq_I, eq_Q


);

reg signed [64:0] Real, Imag;
reg signed [64:0] Denom;

always@(posedge clk or posedge rst)
begin
 if (rst) begin
  Real<= 0;
  Imag<= 0;
 end else begin
	Real <= i_data * mid_ocenka_i + q_data * mid_ocenka_q;
	Imag <= q_data * mid_ocenka_i - i_data * mid_ocenka_q;
 end
end



always@(posedge clk or posedge rst)
begin
 if (rst) begin
  Denom<= 0;
 end else begin
	Denom <= mid_ocenka_i * mid_ocenka_i + mid_ocenka_q * mid_ocenka_q;
 end
end
wire signed [63:0] Denom64, Real64, Imag64;

assign Denom64 = {Denom[64],Denom[63:0]};
assign Real64 = {Real[64],Real[63:0]};
assign Imag64 = {Imag[64],Imag[63:0]};

	div65 div1 										(
															.clock(clk),
															.denom(Denom64),
															.numer(Real64),
															.quotient(eq_I)
														 );
														 
	div65 div2										(
															.clock(clk),
															.denom(Denom64),
															.numer(Imag64),
															.quotient(eq_Q)
														 );
														 
endmodule														 