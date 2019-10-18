	module down_converter
#	(
		parameter	data_width			= 14				
	)

(

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
//															PORTS DECLARATIONS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------



	input 	logic 								iclk			,
	input 	logic 								irst			,
	
	input 	logic	signed	[data_width-1:0] 			in_data_ADC		,
	
	output 	logic	signed	[data_width-1:0] 			zero_IF_data_Re		,
	output 	logic	signed	[data_width-1:0] 			zero_IF_data_Im		
	
);	
	logic	signed	[data_width+1:0] 			cos		;
	logic	signed	[data_width+1:0] 			sin		;
	logic	signed	[data_width:0] 			out_cos	;
	logic	signed	[data_width:0] 			out_sin	;
	logic	signed	[data_width-1:0] 			in_data_ADC_reg;
	
	always@ (posedge iclk or posedge irst)
		if (irst)
		begin
			in_data_ADC_reg <= 0;
		end	
		else
		begin
		
			in_data_ADC_reg <= in_data_ADC ;
		
		end
	
	Oscillator Oscillator_RX
(
	.reset				(irst) 			,	
	.clk				(iclk) 			,	
	.ena				(1'b1) 			,	
	.increment_Phase	(32'h40000000) 	,	// 16 MHz	32'h3BBBBBBC
	.in_Re				(14'd28136) 	,	//7024
	.in_Im				(14'd28136) 	,	
	.out_cos			(cos) 			,
	.out_sin			(sin) 			,	
	.noise_out			() 	
); 
	
	defparam	Oscillator_RX.Accum_Width = 32;		
	defparam	Oscillator_RX.Magnitude_Resolution = 16;	
	defparam	Oscillator_RX.Dither = "'0'";
	defparam	Oscillator_RX.Dither_shift = 13;	

	
		always@ (posedge iclk or posedge irst)
		if (irst)
		begin
			out_cos <= 0;
			out_sin <= 0;
		end	
		else
		begin
		
			out_cos <= cos[data_width:0]				;
			out_sin <= -sin[data_width:0]				;	
		end
	
	

logic	signed	[data_width*2:0] 			zero_IF_data_Re_r	;
logic	signed	[data_width*2:0] 			zero_IF_data_Im_r	;

//-------------------------------------------MULTIPLIERS-------------------


	always@ (posedge iclk or posedge irst)
		if (irst)
		begin
			zero_IF_data_Re_r <= 0;
			zero_IF_data_Im_r <= 0;
		end	
		else
		begin
			zero_IF_data_Re_r <= in_data_ADC_reg * out_cos;
			zero_IF_data_Im_r <= in_data_ADC_reg * out_sin;
		end


assign zero_IF_data_Re 	= zero_IF_data_Re_r[data_width*2-1:14]		;
assign zero_IF_data_Im 	= zero_IF_data_Im_r[data_width*2-1:14]		;

endmodule











