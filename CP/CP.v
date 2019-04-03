module CP
(
input clk, en, rst, in_sop,
input signed [15:0] in_i, in_q,
output signed [15:0] out_i, out_q,
output reg sop_out
);

reg [9:0] w_count;
reg [9:0] r_count;
reg s_trigger;
reg CP_beg;

reg [31:0] r_data;
reg [31:0] ram [0:1023];

initial
begin
	w_count = 0;
	r_count = 0;
	s_trigger = 0;
	CP_beg = 0;
	sop_out = 0;
end


always @(posedge clk or posedge rst) begin
	if (rst) 
		w_count <= 0;
	else if ((in_sop) || (s_trigger)) 
			w_count <= (w_count == 16'd1023) ? 0 : w_count + 1'd1;
end

always @ (posedge clk or posedge rst)
	begin
		if (rst)
				r_count <= 10'd0;
		else if ((CP_beg) && (w_count != 10'd992))
			r_count <= (r_count == 10'd1023) ? 0 : r_count + 1'd1;
		else if (w_count == 10'd992) r_count <= 10'd992;																										 
	end

always @ (posedge clk or posedge rst)
	begin
		if (rst)
				sop_out <= 0;
		else  if (w_count == 10'd993) sop_out <= 1; else sop_out <= 0; 																									 
	end


always @ (posedge clk or posedge rst)
	begin
		if (rst)
			CP_beg <= 1'b0;
		else if (w_count == 10'd991)
			CP_beg <= 1'b1;	
	end

always @(posedge clk or posedge rst) begin
	if (rst)
		s_trigger <= 0;
	else if (in_sop == 1'b1) s_trigger <= 1'b1;
		 else if (w_count == 10'd1023) s_trigger <= 1'b0;
end

always @ (posedge clk) begin
	 if (s_trigger||in_sop)
	 begin
		ram[w_count] <= {in_i, in_q};
	 end
	 r_data <= ram[r_count];
end

assign out_q = r_data[15:0];
assign out_i = r_data[31:16];

endmodule
