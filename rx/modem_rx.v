module modem_rx
(
input clk,rst,
input signed [13:0] ADC_A, 
input out_range_A, out_range_B,
output ADC_CLK_A, ADC_CLK_B, ADC_OEA, ADC_OEB,
output signed [31:0] ABS
);



wire clk_40,clk_10;

assign ADC_OEA = 0;
assign ADC_OEB = 0;
assign ADC_CLK_A = clk_40;
assign ADC_CLK_B = clk_40;

reg signed [13:0] data_in;

always@(posedge clk_40)
begin
 if(rst)
  data_in <= 0;
   else data_in <= {~ADC_A[13],ADC_A[12:0]};
end	



wire signed [13:0] data_rem_const;


wire signed [13:0] real_from_mixer, imag_from_mixer;
wire signed [13:0] real_from_filter,imag_from_filter;


initial_rst rstinitial							(
															.clk(clk_10), 
															.rst(rst),
															.tru_rst(tru_rst)
														);


pll pll1 											(
														 .refclk(clk),
														 .rst(rst),
														 .outclk_0(clk_10),
														 .outclk_1(clk_40)
														 );
														 
														 
Remove_const Remove_const_submod				(				
														.clk(clk_40),
														.rst(tru_rst),
														.en(1'b1),
														.Inp(data_in),
														.Outp(data_rem_const)
													);
		
	
			
upconv down_converter 			(
														.rst(tru_rst),
														.clk	(clk_40),
														.data_in(data_rem_const),	
														.down_data_i(real_from_mixer),
														.down_data_q(imag_from_mixer) 
													); 
													
													
filter filter_I                        (
														.clk(clk_40),
													   .clk_enable(1'b1),
														.reset(tru_rst),
														.filter_in(real_from_mixer),
														.filter_out(real_from_filter)
															);
															
filter filter_Q                        (
														.clk(clk_40),
													   .clk_enable(1'b1),
														.reset(tru_rst),
														.filter_in(imag_from_mixer),
														.filter_out(imag_from_filter)
															);
wire signed [13:0] data_usr_I, data_usr_Q;
															
usr usr					(
									.clk(clk_40),
									.rst(tru_rst),
									.data_in_I(real_from_filter),
									.data_in_Q(imag_from_filter),
									.data_out_I(data_usr_I),
									.data_out_Q(data_usr_Q)
									);
															
wire signed [13:0] data_decim_I, data_decim_Q;
				
decim DECIM					(
									.clk_40mhz(clk_40),
									.rst(tru_rst),
									.data_in_I(data_usr_I),
									.data_in_Q(data_usr_Q),
									.data_out_I(data_decim_I),
									.data_out_Q(data_decim_Q)
									);				


Rev_spec Rev_spec1                      (
													  .clk(clk_10),
													  .en(1'b1),
													  .rst(tru_rst),
													  .in_i(data_decim_I),
													  .in_q(data_decim_Q),
													  .out_i(Rev_I),
													  .out_q(Rev_Q)
													  );
	

wire signed [13:0] Rev_I,Rev_Q;	
wire signed [15:0] I_from_Norm,Q_from_Norm;
																

Norm Norm1      
													(
													  .clk(clk_10),
													  .rst(tru_rst),
													  .i_data(Rev_I),
													  .q_data(Rev_Q),
													  .Norm_I(I_from_Norm),
													  .Norm_Q(Q_from_Norm)
													  );
	                         								
																									
	
wire signed [15:0] korr_data_i,korr_data_q;

korr koor1    									
													(
													  .clk_10(clk_10),
													  .clk_40(clk_40),
													  .rst(tru_rst),
													  .i_data(I_from_Norm),
													  .q_data(Q_from_Norm),
													  .o_data_i(korr_data_i),
													  .o_data_q(korr_data_q),
													  .out_i(sop),
													  .ABS(ABS)
											        );
													  
													  
wire sop, sop_from_fft;
wire signed [15:0] fft_data_i,fft_data_q;
wire new_sop,fft_sop;

get_sop get_sop1                         (
														.clk(clk_10),
														.rst(tru_rst),
														.sop(sop),
														.new_sop(new_sop)
														);
												  
assign fft_sop = sop || new_sop;													  
													  
     fft_1024_16 fft_submod 						 (
														.clk(clk_10),
														.reset			(tru_rst),
														.master_sink_dav		(1),
														.master_sink_sop		(new_sop),
														.master_source_dav	(1),
														.inv_i				(1'b0),
														.data_real_in		(korr_data_i),
														.data_imag_in		(korr_data_q),
														.fft_real_out		(fft_data_i),
														.fft_imag_out		(fft_data_q),
														.exponent_out		(),
														.master_sink_ena		(),
														.master_source_sop	(sop_from_fft),
														.master_source_eop	(1),
														.master_source_ena	()   
													   );		
	
wire signed [15:0] eq_data_i,eq_data_q;
wire eq_sop;

equal equal1                             (
														.clk(clk_10),
														.rst(tru_rst),
														.sop(sop_from_fft),
														.i_data(fft_data_i),
														.q_data(fft_data_q),
														.o_data_i(eq_data_i),
														.o_data_q(eq_data_q),
														.out_sop(eq_sop)
														);
																									
demod demod1									  (
														.clk(clk_10), 
														.rst(tru_rst), 
														.sop(eq_sop),
														.i_data(eq_data_i),
														.q_data(eq_data_q),
														.data(data)
														);
wire [1:0] data;														

endmodule
