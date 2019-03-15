---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.43 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_si_de_so_bb.vhd,v 1.43 2004/06/09 20:56:55 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
entity asj_fft_si_de_so_bb is
	generic(
						nps : integer :=2048;
						nume : integer :=2;
						bfp  : integer :=1;
						mpr : integer :=16;
						twr : integer :=16;
						fpr : integer :=4;
						mult_type : integer :=0;
						mult_imp  : integer  :=0;
						mram : integer :=1;
						m512 : integer :=0;
						bpr  : integer :=16;
						bpb  : integer :=4;						
						rfs1 : string  :="test_1n2048cos.hex";
						rfs2 : string  :="test_2n2048cos.hex";
						rfs3 : string  :="test_3n2048cos.hex";
						rfc1 : string  :="test_1n2048sin.hex";
						rfc2 : string  :="test_2n2048sin.hex";
						rfc3 : string  :="test_3n2048sin.hex";
						srr  : string  :="AUTO_SHIFT_REGISTER_RECOGNITION=ON"
					);
	port(			clk 						: in std_logic;
						reset 					: in std_logic;
						inv_i						: in std_logic;
						data_real_in   	: in std_logic_vector(mpr-1 downto 0);
						data_imag_in   	: in std_logic_vector(mpr-1 downto 0);
						fft_real_out		: out std_logic_vector(mpr-1 downto 0);
						fft_imag_out		: out std_logic_vector(mpr-1 downto 0);
						exponent_out		: out std_logic_vector(fpr+1 downto 0);
						-- Atlantic Master Sink Interface Signals
						master_sink_sop             : in std_logic;
						master_sink_dav             : in std_logic;
						--master_sink_val             : in std_logic;
						master_sink_ena             : out std_logic;						
						-- Atlantic Master Source Signals
						master_source_dav             : in std_logic;
						master_source_ena             : out std_logic;
						master_source_sop             : out std_logic;
						master_source_eop             : out std_logic
			);
end asj_fft_si_de_so_bb;

architecture transform of asj_fft_si_de_so_bb is

	ATTRIBUTE ALTERA_INTERNAL_OPTION : string;
  ATTRIBUTE ALTERA_INTERNAL_OPTION OF transform : ARCHITECTURE IS srr;


	constant apr : integer :=LOG2_FLOOR(nps)-3; -- apr = log2(nps)-2 fo single engine
	constant apr_mram : integer :=LOG2_FLOOR(nps)-2; -- apr = log2(nps)-2 fo single engine
	constant exp_init_fft : integer :=-1*LOG2_FLOOR(nps); 
	constant twa : integer :=LOG2_FLOOR(nps)-2; 
	constant dpr : integer :=2*mpr;
	constant n_bfly : integer := nps/4;
	constant n_by_16 : integer := nps/16;
	constant log2_n_bfly : integer := LOG2_CEIL(n_bfly);
	constant n_passes : integer := LOG4_CEIL(nps);
	constant n_passes_m1 : integer := LOG4_CEIL(nps)-1;
	constant log2_n_passes: integer := LOG2_CEIL(n_passes);
	constant mid_apr : integer :=apr/2;
	-- last_pass_radix = 0 => radix 4
	-- last_pass_radix = 1 => radix 2
	constant last_pass_radix : integer :=(LOG4_CEIL(nps))-(LOG4_FLOOR(nps));
	constant twid_delay : integer :=7;
	
	constant wr_ad_delay : integer :=18;
	constant rbuspr : integer :=4*mpr;
	constant cbuspr : integer :=8*mpr;
	constant abuspr : integer :=4*apr;
	constant switch_read_data : integer:= 1;
	constant initial_en_np_delay : integer :=12;
	constant wr_en_null : integer :=24;
	constant mem_string : string :="AUTO";
	constant wraddr_cd_en : integer := 3;
	constant arch : integer :=1;
  constant byte_size	: integer :=cbuspr/bpr;
  
  constant which_fsm	: integer :=1;
  
	--- State machine variables
	-- Input Interface Control
	type   fft_s1_state is (IDLE,WAIT_FOR_INPUT,WRITE_INPUT,EARLY_DONE,DONE_WRITING,FFT_PROCESS_A);
	signal fft_s1_cur,fft_s1_next :  fft_s1_state;
	-- State machine variables
	-- Output Interface Control
	type   fft_s2_state is (IDLE,WAIT_FOR_LPP_INPUT,START_LPP,LPP_OUTPUT_RDY,LPP_DONE);
	signal fft_s2_cur,fft_s2_next :  fft_s2_state;
	
	
	
	type complex_data_bus	is array (0 to 3,0 to 1) of std_logic_vector(mpr-1 downto 0);
	type real_data_bus	  is array (0 to 4*nume-1) of std_logic_vector(mpr-1 downto 0);
	type engine_data_bus	is array (0 to 4*nume-1) of std_logic_vector(2*mpr-1 downto 0);
	type address_bus_vec  is array (0 to 3) of std_logic_vector(apr-1 downto 0);
	type address_array    is array (0 to 3) of std_logic_vector(apr-1 downto 0);  
	
	type twiddle_bus is array (0 to 2,0 to 1) of std_logic_vector(twr-1 downto 0);
	type twiddle_address_array is array (0 to twid_delay-1) of std_logic_vector(twa-1 downto 0);
	type wr_address_delay is array (0 to wr_ad_delay) of std_logic_vector(apr-1 downto 0);
	
	type selector_array is array (0 to 3) of std_logic_vector(1 downto 0);
	type sw_r_array is array (0 to 8) of std_logic_vector(1 downto 0);
	type p_array is array (0 to 18) of std_logic_vector(log2_n_passes-1 downto 0);
	
	signal data_in  		: complex_data_bus;
	signal data_in_reg  : complex_data_bus;
	signal data_in_bfp_x  : complex_data_bus;
	signal data_in_bfp_y  : complex_data_bus;
	-----------------------------------------------------------------------------------------------
	-- Direction selector
	signal fft_dirn :	std_logic;
	signal fft_dirn_held :	std_logic;
	signal fft_dirn_held_o :	std_logic;
	signal fft_dirn_held_o2 :	std_logic;
	-----------------------------------------------------------------------------------------------
	-- Registered Core Signals
	-----------------------------------------------------------------------------------------------
	signal data_real_in_reg : std_logic_vector(mpr-1 downto 0);
	signal data_imag_in_reg : std_logic_vector(mpr-1 downto 0);
	signal core_real_in : std_logic_vector(mpr-1 downto 0);
	signal core_imag_in : std_logic_vector(mpr-1 downto 0);
	-----------------------------------------------------------------------------------
	-- BFP Signals
	signal last_bfp_factor : std_logic_vector(3 downto 0) := "1000";
	-- INPUT BFP UNIT I/O
	signal real_bfp_input : std_logic_vector(rbuspr-1 downto 0);
	signal imag_bfp_input : std_logic_vector(rbuspr-1 downto 0);
	signal real_bfp_output : std_logic_vector(rbuspr-1 downto 0);
	signal imag_bfp_output : std_logic_vector(rbuspr-1 downto 0);
	
	
	signal twiddle_data : twiddle_bus;
	signal twiddle_data_x : twiddle_bus;
	signal twiddle_data_y : twiddle_bus;
	signal twiddle_address : twiddle_address_array;
	signal wraddress_tdl : wr_address_delay;
	signal wraddress_a_tdl : wr_address_delay;
	signal wraddress_b_tdl : wr_address_delay;
  --butterfly inputs
  signal dr1i,dr2i,dr3i,dr4i : std_logic_vector(mpr-1 downto 0);
  signal di1i,di2i,di3i,di4i : std_logic_vector(mpr-1 downto 0);
  
  signal dft_r_o             : real_data_bus;
  signal dft_i_o             : real_data_bus;
  
  -- butterfly outputs
  signal dr1o,dr2o,dr3o,dr4o : std_logic_vector(mpr-1 downto 0);
  signal di1o,di2o,di3o,di4o : std_logic_vector(mpr-1 downto 0);
  -- twiddle ROM Outputs
  -- Single Engine Signals
  signal t1r,t2r,t3r 				 : std_logic_vector(twr-1 downto 0);
  signal t1i,t2i,t3i 				 : std_logic_vector(twr-1 downto 0);  
  -- Dual Engine Signals
  signal t1re,t2re,t3re 				 : std_logic_vector(twr-1 downto 0);
  signal t1ro,t2ro,t3ro 				 : std_logic_vector(twr-1 downto 0);
  signal t1ie,t2ie,t3ie 				 : std_logic_vector(twr-1 downto 0);  
  signal t1io,t2io,t3io 				 : std_logic_vector(twr-1 downto 0);  
  
  -- RAM Select
  -- Selects between RAM Block A or B for input buffer
  signal ram_a_not_b          : std_logic;
  signal ram_a_not_b_vec      : std_logic_vector(31 downto 0); 
  signal sel_mux_a_c              : std_logic_vector(log2_n_passes downto 0);
  ----------------------------------------------------------------------
  signal data_rdy 						: std_logic;
  signal data_rdy_vec      		: std_logic_vector(31 downto 0); 
  
  
  -----------------------------------------------------------------------
  signal wraddress_i          : std_logic_vector(abuspr-1 downto 0); 
  signal wraddr_i             : std_logic_vector(apr-1 downto 0); 
  signal wraddr_i_reg         : std_logic_vector(apr-1 downto 0); 
  signal i_ram_real           : std_logic_vector(mpr-1 downto 0);
  signal i_ram_imag           : std_logic_vector(mpr-1 downto 0);
  signal i_ram_data_in        : std_logic_vector(2*mpr-1 downto 0);
  signal i_wren               : std_logic_vector(3 downto 0);
  
  
  signal wraddr               : address_array; 
  signal wraddr_sw            : address_array; 
  signal rdaddr               : address_array; 
  signal rdaddr_sw            : address_array; 
  signal rdaddr_lpp            : address_array; 
  signal rdaddr_lpp_sw            : address_array; 
  signal wraddr_cd            : address_array; 
	signal wraddr_cd_sw            : address_array; 
                                             
  signal wr_addr_o            : address_array; 
  signal rdaddress_i          : std_logic_vector(abuspr-1 downto 0); 
  signal four_rdata_bus_in    : std_logic_vector(rbuspr-1 downto 0);  
  signal four_idata_bus_in    : std_logic_vector(rbuspr-1 downto 0);  
  --signal i_ram_data_in        : engine_data_bus;
  --signal i_ram_data_in_sw     : engine_data_bus;
  
  -- address counters
  signal p_count   	    			: std_logic_vector(log2_n_passes-1 downto 0);
  signal p_cd_en              : std_logic_vector(log2_n_passes-1 downto 0);
	signal p_tdl                : p_array;
	signal k_count							: std_logic_vector(apr-1 downto 0);
	-- switch selects
	signal sw										: std_logic_vector(1 downto 0);
	signal sw_r									: std_logic_vector(1 downto 0);
	signal sw_r_d									: std_logic_vector(1 downto 0);
	signal swd_w									: std_logic_vector(1 downto 0);
	signal swa_w									: std_logic_vector(1 downto 0);
	signal sw_rd_lpp									: std_logic_vector(1 downto 0);
	signal sw_ra_lpp									: std_logic_vector(1 downto 0);
	signal sw_ra_lpp_d									: std_logic_vector(1 downto 0);
	signal sw_w_cd									: std_logic_vector(1 downto 0);
	signal sw_r_tdl             : sw_r_array;
	
	signal butterfly_output     : complex_data_bus;
	
	
	signal slb_x_i              : std_logic_vector(2 downto 0);
	signal slb_x_o              : std_logic_vector(2 downto 0);
	signal slb_y_i              : std_logic_vector(2 downto 0);
	signal slb_y_o              : std_logic_vector(2 downto 0);
	signal slb_last_i           : std_logic_vector(2 downto 0);
	signal dual_eng_slb         : std_logic_vector(3*nume-1 downto 0);
	
	
	-- wren
  signal wren_i       				: std_logic_vector(3 downto 0);
  signal wren_a       				: std_logic_vector(4*nume-1 downto 0);
  signal wren_b       				: std_logic_vector(4*nume-1 downto 0);
  signal wren_c       				: std_logic_vector(4*nume-1 downto 0);
  signal wren_d       				: std_logic_vector(4*nume-1 downto 0);
  signal rden_a       				: std_logic_vector(3 downto 0);
  signal rden_b       				: std_logic_vector(3 downto 0);
  signal rden_c       				: std_logic_vector(3 downto 0);
  signal rden_d       				: std_logic_vector(3 downto 0);
  
  signal wa 									: std_logic;
  signal wa_x 									: std_logic;
  signal wa_y 									: std_logic;
  signal wb 									: std_logic;
  signal wc 									: std_logic;
  signal wd 									: std_logic;
  
  signal ra 									: std_logic;
  signal rb 									: std_logic;
  signal rc 									: std_logic;
  signal rd 									: std_logic;
  
  
  signal lpp_c_en_early 						: std_logic;
  signal lpp_d_en_early 						: std_logic;
  signal lpp_c_addr_en 						: std_logic;
  signal lpp_c_data_en 						: std_logic;
  signal wc_early 						: std_logic;
  signal wd_early 						: std_logic;
  signal lpp_c_en_vec 							: std_logic_vector(10 downto 0);
  signal wc_vec 							: std_logic_vector(8 downto 0);
  
  signal anb_enabled          : std_logic;
  
  -- Last Pass Enable Signals
  signal lpp_wrcnt_en       : std_logic;
  signal lpp_rdcnt_en       : std_logic;
  signal lpp_c_en             : std_logic;
  signal lpp_d_en             : std_logic;
  signal lpp_en             : std_logic;
  
  -- output address counter
  signal output_counter       : std_logic_vector(apr-1 downto 0);
  
  -- assigned addresses to individual memory banks
  signal wraddress_a          : address_array;  
  signal rdaddress_a          : address_array;  
  signal wraddress_b          : address_array;  
  signal rdaddress_b          : address_array;  
  
  
  --signal rdaddress_i_bus : std_logic_vector(4*apr-1 downto 0);   
  --signal wraddress_i_bus : std_logic_vector(4*apr-1 downto 0);   
  --signal i_ram_data_in_bus: std_logic_vector(8*mpr-1 downto 0);  
  --signal i_ram_data_out_bus : std_logic_vector(8*mpr-1 downto 0);
  signal rdaddress_a_bus : std_logic_vector(4*apr-1 downto 0);
  signal wraddress_a_bus : std_logic_vector(4*apr-1 downto 0);
  signal a_ram_data_in_bus_x: std_logic_vector(8*mpr-1 downto 0);
  signal a_ram_data_out_bus_x : std_logic_vector(8*mpr-1 downto 0);
  signal rdaddress_b_bus : std_logic_vector(4*apr-1 downto 0);
  signal wraddress_b_bus : std_logic_vector(4*apr-1 downto 0);
  signal b_ram_data_in_bus_x: std_logic_vector(8*mpr-1 downto 0);
  signal b_ram_data_out_bus_x : std_logic_vector(8*mpr-1 downto 0);
  signal rdaddress_c_bus : std_logic_vector(4*apr-1 downto 0);
  signal wraddress_c_bus : std_logic_vector(4*apr-1 downto 0);
  signal c_ram_data_in_bus_x: std_logic_vector(8*mpr-1 downto 0);
  signal c_ram_data_out_bus_x : std_logic_vector(8*mpr-1 downto 0);
  signal d_ram_data_in_bus_x: std_logic_vector(8*mpr-1 downto 0);
  signal d_ram_data_out_bus_x : std_logic_vector(8*mpr-1 downto 0);
  signal a_ram_data_in_bus_y: std_logic_vector(8*mpr-1 downto 0);
  signal a_ram_data_out_bus_y : std_logic_vector(8*mpr-1 downto 0);
  signal b_ram_data_in_bus_y: std_logic_vector(8*mpr-1 downto 0);
  signal b_ram_data_out_bus_y : std_logic_vector(8*mpr-1 downto 0);
  signal c_ram_data_in_bus_y: std_logic_vector(8*mpr-1 downto 0);
  signal c_ram_data_out_bus_y : std_logic_vector(8*mpr-1 downto 0);
  signal rdaddress_a_bus_ctrl : std_logic_vector(4*apr-1 downto 0);
  signal wraddress_a_bus_ctrl : std_logic_vector(4*apr-1 downto 0);
  
  
  
  signal rdaddress_a_mram : std_logic_vector(apr-1 downto 0);
  signal wraddress_a_mram : std_logic_vector(apr-1 downto 0);
  
  signal byte_enable_i : 	std_logic_vector(bpr-1 downto 0);
  	
  
  -- Block I RAM Data Output
  signal i_ram_data_out    : engine_data_bus;
  signal ram_data_out    : engine_data_bus;
  signal ram_data_out_sw    : engine_data_bus;
  signal ram_data_in    : engine_data_bus;
  signal ram_data_in_sw    : engine_data_bus;
  signal lpp_ram_data_out    : engine_data_bus;
  signal lpp_ram_data_out_sw : engine_data_bus;
  
  signal ram_data_in_sw_debug : complex_data_bus;
  signal ram_data_out_sw_debug : complex_data_bus;
  signal ram_data_out_debug : complex_data_bus;
  signal lpp_ram_data_in_sw_debug : complex_data_bus;
  signal lpp_ram_data_out_sw_debug : complex_data_bus;
  signal lpp_ram_data_out_debug : complex_data_bus;
  signal lpp_ram_data_out_debug_r : real_data_bus;
  signal lpp_ram_data_out_debug_i : real_data_bus;
  
  signal c_ram_data_in_debug_x : complex_data_bus;
  signal c_ram_data_in_debug_y : complex_data_bus;
  signal d_ram_data_out_debug_x : complex_data_bus;
  signal d_ram_data_out_debug_y : complex_data_bus;
  
  
  signal lpp_o_r : real_data_bus;
  signal lpp_o_i : real_data_bus;
  
  signal debugx : std_logic ;
  
  
  signal pass_count : std_logic_vector(log2_n_passes-1 downto 0);
  signal next_pass  : std_logic ;
  signal next_pass_q  : std_logic ;
  signal next_pass_d  : std_logic ;
  signal block_done  : std_logic ;
  signal block_done_d  : std_logic ;
  
  signal blk_exp  : std_logic_vector(fpr+1 downto 0);
  signal blk_exp_accum  : std_logic_vector(fpr+1 downto 0);
  
  signal en_np  : std_logic ;
  signal twad : std_logic_vector(apr-1 downto 0);
  signal twade : std_logic_vector(apr downto 0);
  signal twado : std_logic_vector(apr downto 0);
  signal count :std_logic_vector(1 downto 0);
  
  
  signal data_real_out : std_logic_vector(mpr-1 downto 0);
  signal data_imag_out : std_logic_vector(mpr-1 downto 0);
  signal lpp_data_val : std_logic;
  signal next_blk : std_logic;
  signal next_input_blk : std_logic;
  signal midr2    : std_logic;
  signal midr2_d    : std_logic;
  signal r2_lpp_sel : std_logic_vector(2 downto 0);
  
  
  signal sel_anb_addr : std_logic;
  signal sel_anb_ram  : std_logic;
  signal which_ram_set : std_logic;
  -- output exponent enable
  signal exp_en : std_logic ;
  
  -- output enable
  signal oe : std_logic ;
  signal wr_cd_en_sig : std_logic_vector(2 downto 0);
  
  -- detect if processing can begin
  signal go : std_logic ;
  -- disable writing to memory by deasserting master_sink_ena
  -- this needs to be generated by the writer, but asserted a few cycles before dopne to account
  -- for latency from the fft to the user's system   
  signal dsw : std_logic;
  signal nbc : std_logic_vector(log2_n_passes-1 downto 0) ;
  signal input_sample_counter : std_logic_vector(apr+2 downto 0);
  
  
  signal sop_out : std_logic ;
  signal sop_d : std_logic ;
  signal eop_out : std_logic ;
  signal val_out : std_logic ;
  signal val_o : std_logic ;
  
  -----------------------------------------------------------------------------------------------
  signal master_sink_val : std_logic;
  -----------------------------------------------------------------------------------------------
  
begin
		-----------------------------------------------------------------------------------------------
		master_sink_val <= '1';
		-----------------------------------------------------------------------------------------------	
	  
		gen_wr_cd_en_4096 : if(nps<=4096) generate
			wr_cd_en_sig <= "001";
		end generate gen_wr_cd_en_4096;
		
		gen_wr_cd_en_16384 : if(nps>4096) generate
			wr_cd_en_sig <= "001";
		end generate gen_wr_cd_en_16384;
		
	
  	
  	-- Counter Logic
  	-- Defines k,m,p counters
  	ctrl : asj_fft_m_k_counter 
		generic map(
							nps => nps,
							arch => 1,
							nume => nume,
							n_passes => n_passes_m1, --log4(nps) - 1
							log2_n_passes => log2_n_passes, 
							apr => apr, --apr = log2(nps/4)
							cont => 0
						)
		port map(			
							clk 		 => clk,
							reset    => reset,
							stp   	 => master_sink_sop,
							start    => data_rdy_vec(4),
							-- this was next_block
							next_block => next_blk,
							p_count  => p_count,
							k_count	 => k_count,
							next_pass => next_pass_q,
							blk_done  => block_done
				);
				
		--------------------------------------------------------------------------		
		next_pass <= en_np and next_pass_q;
		--next_pass <= next_pass_q;
		
		delay_swd : asj_fft_tdl_bit_rst 
			generic map( 
							 		del   => 10
							)
			port map( 	
									clk 	=> clk,
									reset => reset,								
									data_in 	=> next_pass,
					 				data_out 	=> next_pass_d
					);

				
		enable_next_pass : process(clk,reset,p_tdl(initial_en_np_delay)) is
			begin
				if(rising_edge(clk)) then
					if(reset='1') then
						en_np <='0';
					else
						if(p_tdl(initial_en_np_delay) = int2ustd(1,log2_n_passes)) then
							en_np <= '1';
						elsif(p_tdl(initial_en_np_delay) = int2ustd(0,log2_n_passes)) then
							en_np <= '0';
						end if;
					end if;
				end if;
			end process enable_next_pass;
			
	--en_transform : process(clk,fft_s1_cur,go) is
	--	begin
	--		if(rising_edge(clk)) then
	--			if(fft_s1_cur=IDLE) then
	--				go <='0';
	--			elsif(fft_s1_cur=DONE_WRITING) then
	--			  go <='1';
	--			else
	--				go <= go;
	--			end if;
	--		end if;
	--	end process en_transform;
	
	ram_sel_vec : process(clk,reset,ram_a_not_b,ram_a_not_b_vec,data_rdy,data_rdy_vec) is
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					ram_a_not_b_vec <=(others=>'1');
					data_rdy_vec <=(others=>'0');
				else
					for i in 31 downto 1 loop
						ram_a_not_b_vec(i) <= ram_a_not_b_vec(i-1);
						data_rdy_vec(i) 	 <= data_rdy_vec(i-1);
					end loop;
					ram_a_not_b_vec(0) <= ram_a_not_b;-- and go;
					data_rdy_vec(0) <= data_rdy;-- and go;
				end if;
			end if;
	end process ram_sel_vec;
	
	
	
	
	p_vec : process(clk,reset,p_count,p_tdl) is
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					for i in 18 downto 0 loop
						p_tdl(i) <= (others=>'0');
					end loop;
				else
					for i in 18 downto 1 loop
						p_tdl(i) <= p_tdl(i-1);
					end loop;
					p_tdl(0) <= p_count;
				end if;
			end if;
	end process p_vec;
	
	
	
	-- Enable output buffer reading
	anb_enabled <= ram_a_not_b_vec(26);
	
	-- The p_tdl value for to de-assert wc and wd needs to be constant for only 
	-- N/4 cycles. However, with additional lateny for non-fullly continuos arch
	-- Need to kill last pass indication earlier
	-- Use a new signal p_cd_en 
	--gen_256_pcd : if(nps=128 or nps=256) generate
	--reg_we_window : process(clk,p_tdl) is
	--	begin
	--		if(rising_edge(clk)) then
	--			p_cd_en <= p_tdl(13);
	--		end if;
	--	end process reg_we_window;
	--end generate gen_256_pcd;
	--
	--gen_512_pcd : if(nps=512 or nps=1024) generate
	--reg_we_window : process(clk,p_tdl) is
	--	begin
	--		if(rising_edge(clk)) then
	--			if(p_tdl(13)="100" and p_tdl(11)="100") then
	--				p_cd_en <= "100";
	--			else
	--				p_cd_en <= "000";
	--			end if;
	--		end if;
	--	end process reg_we_window;
	--end generate gen_512_pcd;
	--
	--gen_2048_pcd : if(nps=2048 or nps=4096) generate
	--reg_we_window : process(clk,p_tdl) is
	--	begin
	--		if(rising_edge(clk)) then
	--			if(p_tdl(13)="101" and p_tdl(11)="101") then
	--				p_cd_en <= "101";
	--			else
	--				p_cd_en <= "000";
	--			end if;
	--		end if;
	--	end process reg_we_window;
	--end generate gen_2048_pcd;
	--
	--gen_8192_pcd : if(nps=8192 or nps=16384) generate
	--reg_we_window : process(clk,p_tdl) is
	--	begin
	--		if(rising_edge(clk)) then
	--			if(p_tdl(15)="110" and p_tdl(13)="110") then
	--				p_cd_en <= "110";
	--			else
	--				p_cd_en <= "000";
	--			end if;
	--		end if;
	--	end process reg_we_window;
	--end generate gen_8192_pcd;
	reg_we_window : process(clk,p_tdl) is
	begin                              
		if(rising_edge(clk)) then        
			p_cd_en <= p_tdl(13);          
		end if;                          
	end process reg_we_window;         
	
	sel_we :  asj_fft_wrengen 
	generic map(
						nps => nps,
						arch => arch,
						n_passes => n_passes,
						log2_n_passes => log2_n_passes,
						apr => apr,
						del => 0
					)
	port map(			
						clk 		=> clk,
						reset   => reset,
						p_count => p_cd_en,
						anb     => anb_enabled,
						lpp_c_en=> lpp_c_en_early,
						lpp_d_en=> lpp_d_en_early,
						wc      => wc_early,
						wd      => wd_early
			);
			
			--Delay early write enables for RAM C
			del_wcd : process(clk,reset,wc_early,lpp_c_en_vec,lpp_c_en_early,wc_vec) is
				begin 
				if(rising_edge(clk)) then
						if(reset ='1') then
							for i in 0 to 8 loop
								wc_vec(i) <= '0';
							end loop;
							for i in 0 to 10 loop
								lpp_c_en_vec(i) <= '0';
							end loop;
						else
							for i in 8 downto 1 loop
								wc_vec(i) <= wc_vec(i-1);
							end loop;
							for i in 10 downto 1 loop
								lpp_c_en_vec(i) <= lpp_c_en_vec(i-1);
							end loop;
							wc_vec(0) <= wc_early;
							lpp_c_en_vec(0) <= lpp_c_en_early;
						end if;
					end if;
				end process del_wcd;
				wc <= wc_vec(conv_integer(wr_cd_en_sig));
				
			
			-----------------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------
			
							
			
			wren_c <= ( 7 downto 0 => wc);
			
			
			web_st : process(clk,reset,ram_a_not_b_vec) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
							wren_b <= (7 downto 0 => '0');
						else
							if(ram_a_not_b_vec(1)='0') then
									wren_b(7 downto 0)<= (7 downto 0 => not(ram_a_not_b_vec(1) xor ram_a_not_b_vec(wr_en_null)));
							else
									wren_b(7 downto 0)<=(others=>'0');
							end if;
						end if;
					end if;
				end process web_st;
			
			gen_M4K_input_wren : if(mram=0) generate
				
			wea_st : process(clk,reset,fft_s1_cur,i_wren,which_ram_set) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
							wren_a <= (7 downto 0 => '0');
							which_ram_set <= '0';
						else
							if(fft_s1_cur=WRITE_INPUT or fft_s1_cur=DONE_WRITING or fft_s1_cur=EARLY_DONE) then
								which_ram_set <= not(which_ram_set);
								wren_a(3 downto 0) <= i_wren and (3 downto 0 => not(which_ram_set));
								wren_a(7 downto 4) <= i_wren and (3 downto 0 => (which_ram_set));
							else
								which_ram_set <= '0';
								wren_a(7 downto 0)<=(others=>'0');
						
							end if;
						end if;
					end if;
				end process wea_st;
				
			end generate gen_M4K_input_wren;
			
	
			
			
			
			
				
			-----------------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------
	
	writer : asj_fft_in_write_sgl
	generic map(
						nps => nps,
						arch => arch,
						mram => mram,
						nume=> nume,
						mpr => mpr,
						apr => apr,
						bpr => bpr,
						bpb => bpb
					)
	port map(	
						clk 			=> clk,
						reset 		=> reset,
						stp       => master_sink_sop,
						val       => master_sink_val,
						block_done => block_done,
						data_real_in   	=> core_real_in,
						data_imag_in   	=> core_imag_in,
						wr_address_i    => wraddr_i,
						wren_i          => i_wren,
						byte_enable     => byte_enable_i,
						data_rdy        => data_rdy,
						a_not_b         => ram_a_not_b,
						next_block      => next_blk,
						disable_wr      => dsw,
						data_in_r    		=> i_ram_real,
						data_in_i    		=> i_ram_imag
			);						
			i_ram_data_in	<= i_ram_real & i_ram_imag;			
			
	-----------------------------------------------------------------------------------------		
	gen_sel : process(clk,reset,p_tdl,data_rdy_vec) is
				begin
					if(rising_edge(clk)) then	
						if(reset='1') then
							sel_anb_addr <= '0';
						else
							if(p_tdl(2)=int2ustd(1,log2_n_passes)) then
								sel_anb_addr <= '0';
							else
								sel_anb_addr <= data_rdy_vec(8);
							end if;
						end if;
				 end if;
			end process gen_sel;
			
	delay_sel_anb : asj_fft_tdl_bit
		generic map( 
							 		del   => 2
							)
			port map( 	
									clk 	=> clk,
									data_in 	=> sel_anb_addr,
					 				data_out 	=> sel_anb_ram
					);
			
	
	ccc :  asj_fft_burst_ctrl_de 
	generic map(
						nps => nps,
						mpr => mpr,
						apr => apr,
						abuspr => abuspr, --4*apr
						rbuspr => rbuspr, --4*mpr
						cbuspr => cbuspr --2*4*mpr
					)
	port map(			
						clk 					      => clk,
						sel_anb_in 					=> '0',
						sel_anb_addr 				=> sel_anb_addr,
						sel_anb_ram 				=> sel_anb_ram,
						data_rdy            => data_rdy_vec(5),
						wraddr_i0_sw    		=> wraddr_i,
						wraddr_i1_sw        => wraddr_i,
						wraddr_i2_sw        => wraddr_i,
						wraddr_i3_sw        => wraddr_i,
						wraddr0_sw      		=> wraddr_sw(0),
						wraddr1_sw          => wraddr_sw(1),
						wraddr2_sw          => wraddr_sw(2),
						wraddr3_sw          => wraddr_sw(3),
						rdaddr0_sw      		=> rdaddr_sw(0),
						rdaddr1_sw          => rdaddr_sw(1),
						rdaddr2_sw          => rdaddr_sw(2),
						rdaddr3_sw          => rdaddr_sw(3),
						ram_data_in0_sw_x  		=> ram_data_in_sw(0),
						ram_data_in1_sw_x     => ram_data_in_sw(1),
						ram_data_in2_sw_x     => ram_data_in_sw(2),
						ram_data_in3_sw_x     => ram_data_in_sw(3),
						ram_data_in0_sw_y  		=> ram_data_in_sw(4),
						ram_data_in1_sw_y     => ram_data_in_sw(5),
						ram_data_in2_sw_y     => ram_data_in_sw(6),
						ram_data_in3_sw_y     => ram_data_in_sw(7),
						i_ram_data_in0_sw   => i_ram_data_in,
						i_ram_data_in1_sw   => i_ram_data_in,
						i_ram_data_in2_sw   => i_ram_data_in,
						i_ram_data_in3_sw   => i_ram_data_in,
						a_ram_data_out_bus_x => a_ram_data_out_bus_x,
						b_ram_data_out_bus_x  => b_ram_data_out_bus_x,
						a_ram_data_in_bus_x   => a_ram_data_in_bus_x,
						b_ram_data_in_bus_x   => b_ram_data_in_bus_x,
						a_ram_data_out_bus_y => a_ram_data_out_bus_y,
						b_ram_data_out_bus_y  => b_ram_data_out_bus_y,
						a_ram_data_in_bus_y   => a_ram_data_in_bus_y,
						b_ram_data_in_bus_y   => b_ram_data_in_bus_y,
						wraddress_a_bus     => wraddress_a_bus_ctrl,
						wraddress_b_bus     => wraddress_b_bus,
						rdaddress_a_bus     => rdaddress_a_bus_ctrl,
						rdaddress_b_bus     => rdaddress_b_bus,
						ram_data_out0_x       => ram_data_out(0),
						ram_data_out1_x    		=> ram_data_out(1),
						ram_data_out2_x    		=> ram_data_out(2),
						ram_data_out3_x    		=> ram_data_out(3),
						ram_data_out0_y       => ram_data_out(4),
						ram_data_out1_y    		=> ram_data_out(5),
						ram_data_out2_y    		=> ram_data_out(6),
						ram_data_out3_y    		=> ram_data_out(7)
			);

	
		
		
  	
  			
		---------------------------------------------------------------------------------	
		-- Debug Section
		---------------------------------------------------------------------------------
		gen_dbg :for i in 0 to 3 generate
			ram_data_in_sw_debug(i,0) <= ram_data_in_sw(i)(2*mpr-1 downto mpr);
			ram_data_in_sw_debug(i,1) <= ram_data_in_sw(i)(mpr-1 downto 0);
			ram_data_out_debug(i,0) <= ram_data_out(i)(2*mpr-1 downto mpr);
			ram_data_out_debug(i,1) <= ram_data_out(i)(mpr-1 downto 0);
			ram_data_out_sw_debug(i,0) <= ram_data_out_sw(i)(2*mpr-1 downto mpr);
			ram_data_out_sw_debug(i,1) <= ram_data_out_sw(i)(mpr-1 downto 0);
			lpp_ram_data_out_sw_debug(i,0) <= lpp_ram_data_out_sw(i)(2*mpr-1 downto mpr);
			lpp_ram_data_out_sw_debug(i,1) <= lpp_ram_data_out_sw(i)(mpr-1 downto 0);
			lpp_ram_data_out_debug(i,0) <= lpp_ram_data_out(i)(2*mpr-1 downto mpr);
			lpp_ram_data_out_debug(i,1) <= lpp_ram_data_out(i)(mpr-1 downto 0);
			c_ram_data_in_debug_x(i,0) <= c_ram_data_in_bus_x((8-2*i)*mpr-1 downto (7-2*i)*mpr);
			c_ram_data_in_debug_x(i,1) <= c_ram_data_in_bus_x((7-2*i)*mpr-1 downto (6-2*i)*mpr);
			c_ram_data_in_debug_y(i,0) <= c_ram_data_in_bus_y((8-2*i)*mpr-1 downto (7-2*i)*mpr);
			c_ram_data_in_debug_y(i,1) <= c_ram_data_in_bus_y((7-2*i)*mpr-1 downto (6-2*i)*mpr);
		end generate gen_dbg;
		
		gen_dbg2 :for i in 0 to 7 generate
			lpp_ram_data_out_debug_r(i) <= lpp_ram_data_out(i)(2*mpr-1 downto mpr);
			lpp_ram_data_out_debug_i(i) <= lpp_ram_data_out(i)(mpr-1 downto 0);
		end generate gen_dbg2;
		
		
		---------------------------------------------------------------------------------
		
		
		
		rden_a <= (3 downto 0 => '1');
		rden_b <= (3 downto 0 => '1');
		rden_c <= (3 downto 0 => '1');
		rden_d <= (3 downto 0 => '1');
		
		gen_M4K_input_stage : if(mram=0) generate
		
			rdaddress_a_bus <= rdaddress_a_bus_ctrl;
			wraddress_a_bus <= wraddress_a_bus_ctrl;
		
	  	dat_A_x : asj_fft_4dp_ram
	  	generic map(
							apr => apr,
							mpr => mpr,
							abuspr => abuspr,
							cbuspr => cbuspr,
							rfd    => mem_string
						)
			port map(			
							clk => clk,
							rdaddress => rdaddress_a_bus,
							wraddress	=> wraddress_a_bus,
							data_in		=> a_ram_data_in_bus_x,
							wren      => wren_a(3 downto 0),
							rden      => rden_a,						
							data_out	=> a_ram_data_out_bus_x
				);
    
		    dat_A_y : asj_fft_4dp_ram
		  	generic map(
								apr => apr,
								mpr => mpr,
								abuspr => abuspr,
								cbuspr => cbuspr,
								rfd    => mem_string
							)
				port map(			
								clk => clk,
								rdaddress => rdaddress_a_bus,
								wraddress	=> wraddress_a_bus,
								data_in		=> a_ram_data_in_bus_y,
								wren      => wren_a(7 downto 4),
								rden      => rden_a,						
								data_out	=> a_ram_data_out_bus_y
					);
			
		end generate gen_M4K_input_stage;
		
		gen_Mega_input_stage : if(mram=1) generate
		
			wea_st : process(clk,reset,fft_s1_cur,which_ram_set) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
							which_ram_set <= '1';
							wa_x <='0';
							wa_y <='0';
						else
							if(fft_s1_cur=WRITE_INPUT or fft_s1_cur=DONE_WRITING or fft_s1_cur=EARLY_DONE) then
								which_ram_set <= not(which_ram_set);
								wa_x <=which_ram_set;
								wa_y <=not(which_ram_set);
							else
								which_ram_set <= '1';
								wa_x <='0';
								wa_y <='0';
							end if;
						end if;
					end if;
				end process wea_st;
				
		  
		rdaddress_a_mram <= rdaddress_a_bus_ctrl(apr-1 downto 0);
		wraddress_a_mram <= wraddress_a_bus_ctrl(apr-1 downto 0);
		
		
		dat_A_x : asj_fft_dpi_mram
  	generic map(
									dpr => cbuspr,
									apr => apr, 
									bytesize => byte_size,
									bpr => bpr
		)
		port map
		(
								data		=> a_ram_data_in_bus_x,
								wren		=> wa_x,
								wraddress		=> wraddress_a_mram,
								rdaddress		=> rdaddress_a_mram,
								byteena_a		=> byte_enable_i,
								clock		=> clk,
								q		=> a_ram_data_out_bus_x
		);
		
		
		dat_A_y : asj_fft_dpi_mram
  	generic map(
									dpr => cbuspr,
									apr => apr, 
									bytesize => byte_size,
									bpr => bpr
		)
		port map
		(
								data		=> a_ram_data_in_bus_y,
								wren		=> wa_y,
								wraddress		=> wraddress_a_mram,
								rdaddress		=> rdaddress_a_mram,
								byteena_a		=> byte_enable_i,
								clock		=> clk,
								q		=> a_ram_data_out_bus_y
		);
			
		
		end generate gen_Mega_input_stage;
		
		
			
    
  	dat_B_x : asj_fft_4dp_ram
  	generic map(
						apr => apr,
						mpr => mpr,
						abuspr => abuspr,
						cbuspr => cbuspr,
						rfd    => mem_string
					)
		port map(			
						clk => clk,
						rdaddress => rdaddress_b_bus,
						wraddress	=> wraddress_b_bus,
						data_in		=> b_ram_data_in_bus_x,
						rden      => rden_b,						
						wren      => wren_b(3 downto 0),
						data_out	=> b_ram_data_out_bus_x
			);
			
			
		dat_B_y : asj_fft_4dp_ram
  	generic map(
						apr => apr,
						mpr => mpr,
						abuspr => abuspr,
						cbuspr => cbuspr,
						rfd    => mem_string
					)
		port map(			
						clk => clk,
						rdaddress => rdaddress_b_bus,
						wraddress	=> wraddress_b_bus,
						data_in		=> b_ram_data_in_bus_y,
						rden      => rden_b,						
						wren      => wren_b(7 downto 4),
						data_out	=> b_ram_data_out_bus_y
			);	
			
			
    dat_C_x : asj_fft_4dp_ram
  	generic map(
						apr => apr,
						mpr => mpr,
						abuspr => abuspr,
						cbuspr => cbuspr,
						rfd    => mem_string
					)
		port map(			
						clk => clk,
						rdaddress => rdaddress_c_bus,
						wraddress	=> wraddress_c_bus,
						data_in		=> c_ram_data_in_bus_x,
						wren      => wren_c(3 downto 0),
						rden      => rden_c,						
						data_out	=> c_ram_data_out_bus_x
			);
			
		dat_C_y : asj_fft_4dp_ram
  	generic map(
						apr => apr,
						mpr => mpr,
						abuspr => abuspr,
						cbuspr => cbuspr,
						rfd    => mem_string
					)
		port map(			
						clk => clk,
						rdaddress => rdaddress_c_bus,
						wraddress	=> wraddress_c_bus,
						data_in		=> c_ram_data_in_bus_y,
						wren      => wren_c(7 downto 4),
						rden      => rden_c,						
						data_out	=> c_ram_data_out_bus_y
			);
		
		
		-- Input Buffer Read Side Logic
    -- sw_r is applied to data output from RAM and is a cxb_data_r switch input
    -- if p_count==1 the generated addresses are applied to the input buffer with no switching
    -- otherwise, they are switched by sw_r to a cxb_addr and applied 
    -- to the "working" RAM blocks 
    
    rd_adgen : asj_fft_dataadgen
		generic map(
								nps 					=> nps,
								nume          => nume,
								arch          => 1,
								n_passes 			=> n_passes_m1,
								log2_n_passes => log2_n_passes,
								apr 					=> apr
					)
		port map(			
								clk 					=> clk,
								k_count   	  => k_count,
								p_count       => p_count,
								rd_addr_a			=> rdaddr(0),
								rd_addr_b			=> rdaddr(1),
								rd_addr_c			=> rdaddr(2),
								rd_addr_d			=> rdaddr(3),
								sw_data_read  => sw_r(1 downto 0)
			);
		
			
		
    ram_cxb_rd : asj_fft_cxb_addr 
    
			generic map( 	mpr		=>	apr,
					 					xbw 	=>  4,
					 					pipe	 => 1,
					 					del   => 0
						)
			port map( 	clk 			=> clk,
						--reset   	=> reset,
				 			sw_0_in 	=> rdaddr(0),
				 			sw_1_in 	=> rdaddr(1),
				 			sw_2_in 	=> rdaddr(2),
				 			sw_3_in 	=> rdaddr(3),
				 			ram_sel  	=> sw_r(1 downto 0),
				 	  	sw_0_out 	=> rdaddr_sw(0),
				 	  	sw_1_out 	=> rdaddr_sw(1),
				 	  	sw_2_out 	=> rdaddr_sw(2),
				 	  	sw_3_out 	=> rdaddr_sw(3)
			);
		
		
		get_wr_swtiches :	asj_fft_wrswgen 
			generic map(
									nps => nps,
									cont => 0, 
									arch => 1,
									nume => nume,
									n_passes => n_passes,
									log2_n_passes => log2_n_passes,
									del => 17,
									apr => apr
						)
			port map	(	
									clk 					=> clk,
									k_count   	  => k_count,
									p_count       => p_count,
									sw_data_write => swd_w(1 downto 0),
									sw_addr_write => swa_w(1 downto 0)
				);
	
	-- During processing the addresses to write to memory banks are permutations 
	-- of the rdaddr
	
	ram_cxb_wr : asj_fft_cxb_addr 
		generic map( 	mpr		=>	apr,
				 					xbw 	=>  4,
				 					pipe	 => 1,
				 					del   => 16
					)
		port map( 	clk 			=> clk,
					--reset   	=> reset,
			 			sw_0_in 	=> rdaddr_sw(0),
			 			sw_1_in 	=> rdaddr_sw(1),
			 			sw_2_in 	=> rdaddr_sw(2),
			 			sw_3_in 	=> rdaddr_sw(3),
			 			ram_sel  	=> swa_w(1 downto 0),
			 	  	sw_0_out 	=> wraddr_sw(0),
			 	  	sw_1_out 	=> wraddr_sw(1),
			 	  	sw_2_out 	=> wraddr_sw(2),
			 	  	sw_3_out 	=> wraddr_sw(3)
		);
		
		
	-- data to be written to RAM block is also switched
	gen_se_ram_data_in : if(nume=1) generate
		gse : for i in 0 to 3 generate
			ram_data_in(i) <= (dft_r_o(i) & dft_i_o(i));
		end generate gse;
	end generate gen_se_ram_data_in;
	
	gen_de_ram_data_in : if(nume=2) generate
		gse : for i in 0 to 7 generate
			ram_data_in(i) <= (dft_r_o(i) & dft_i_o(i));
		end generate gse;
	end generate gen_de_ram_data_in;	
		
		gen_write_sw : for i in 0 to nume-1 generate
		
		ram_cxb_wr_data : asj_fft_cxb_data
		generic map( 	mpr		=>	mpr,
				 					xbw 	=>  4,
				 					pipe	 => 1
					)
		port map( 	clk 			=> clk,
					--reset   	=> reset,
			 			sw_0_in 	=> ram_data_in(0+4*i),
			 			sw_1_in 	=> ram_data_in(1+4*i),
			 			sw_2_in 	=> ram_data_in(2+4*i),
			 			sw_3_in 	=> ram_data_in(3+4*i),
			 			ram_sel  	=> swd_w(1 downto 0),
			 	  	sw_0_out 	=> ram_data_in_sw(0+4*i),
			 	  	sw_1_out 	=> ram_data_in_sw(1+4*i),
			 	  	sw_2_out 	=> ram_data_in_sw(2+4*i),
			 	  	sw_3_out 	=> ram_data_in_sw(3+4*i)
		);
  	
  	end generate gen_write_sw;
		
    
  	
 
 		--switch data prior to BFP
 		-- use delayed version of rd_addr switch to account for latency
 		sw_r_d_delay : asj_fft_tdl
		generic map( 
									mpr => 2,
									del => 4+nume-1,
									srr => srr
							)
			port map( 	
									clk 	=> clk,
									data_in 	=> sw_r,
					 				data_out 	=> sw_r_d
					);
	
 		
 		
 			
 		gen_bfly_input_sw : for i in 0 to nume-1 generate
 		
 		ram_cxb_bfp_data : asj_fft_cxb_data_r
		generic map( 	mpr		=>	mpr,
				 					xbw 	=>  4,
				 					pipe	 => 1
					)
		port map( 	clk 			=> clk,
					--reset   	=> reset,
			 			sw_0_in 	=> ram_data_out(0+4*i),
			 			sw_1_in 	=> ram_data_out(1+4*i),
			 			sw_2_in 	=> ram_data_out(2+4*i),
			 			sw_3_in 	=> ram_data_out(3+4*i),
			 			ram_sel  	=> sw_r_d(1 downto 0),
			 	  	sw_0_out 	=> ram_data_out_sw(0+4*i),
			 	  	sw_1_out 	=> ram_data_out_sw(1+4*i),
			 	  	sw_2_out 	=> ram_data_out_sw(2+4*i),
			 	  	sw_3_out 	=> ram_data_out_sw(3+4*i)
		);
  	
  end generate gen_bfly_input_sw;
  
  	gen_bfly_inputs : for i in 0 to 3 generate
		  data_in_bfp_x(i,0) <= ram_data_out_sw(i)(2*mpr-1 downto mpr);
		  data_in_bfp_x(i,1) <= ram_data_out_sw(i)(mpr-1 downto 0);
		  data_in_bfp_y(i,0) <= ram_data_out_sw(i+4)(2*mpr-1 downto mpr);
		  data_in_bfp_y(i,1) <= ram_data_out_sw(i+4)(mpr-1 downto 0);
		end generate gen_bfly_inputs; 
	 
	 
	 butterfly_twiddle_x :	process(clk,reset,t1re,t2re,t3re,t1ie,t2ie,t3ie) is 
    begin
    	if(rising_edge(clk)) then
    		if(reset='1') then
    			for i in 0 to 2 loop
    				twiddle_data_x(i,0) <= '0' & (twr-2 downto 0=>'1');
    				twiddle_data_x(i,1) <= (others=>'0');
    			end loop;
    		else
    			twiddle_data_x(0,0) <= t1re;
			    twiddle_data_x(0,1) <= t1ie;
			    twiddle_data_x(1,0) <= t2re;
			    twiddle_data_x(1,1) <= t2ie;
			    twiddle_data_x(2,0) <= t3re;
			    twiddle_data_x(2,1) <= t3ie;
			  end if;
    	end if;
   end process butterfly_twiddle_x;
   
   butterfly_twiddle_y :	process(clk,reset,t1ro,t2ro,t3ro,t1io,t2io,t3io) is
    begin
    	if(rising_edge(clk)) then
    		if(reset='1') then
    			for i in 0 to 2 loop
    				twiddle_data_y(i,0) <= '0' & (twr-2 downto 0=>'1');
    				twiddle_data_y(i,1) <= (others=>'0');
    			end loop;
    		else
    				twiddle_data_y(0,0) <= t1ro;
				    twiddle_data_y(0,1) <= t1io;
				    twiddle_data_y(1,0) <= t2ro;
				    twiddle_data_y(1,1) <= t2io;
				    twiddle_data_y(2,0) <= t3ro;
				    twiddle_data_y(2,1) <= t3io;
			  end if;
    	end if;
   end process butterfly_twiddle_y;
   
	
	 bfpdft_x : asj_fft_dft_bfp
   generic map (	
   							nps => nps,
   							bfp => bfp,
   							nume => nume,
   							mpr=> mpr,
   							arch => 1,
   							rbuspr => rbuspr,
            		twr=> twr,
            		fpr => fpr,
            		mult_type => mult_type,
            		mult_imp => mult_imp,
            		nstages=> 7,
            		pipe => 1,
            		cont => 0
	 )
   port map(
		 		        clk   		=> clk,
		 		        reset 		=> reset,
		 		        clken     => en_np,
		 		        next_pass => next_pass_d,
		 		        next_blk  => next_blk,
		 		        alt_slb_i   => slb_last_i,
		 		        alt_slb_o   => slb_x_o,
		 		        data_1_real_i => data_in_bfp_x(0,0),
		 				    data_2_real_i => data_in_bfp_x(1,0),
		 				    data_3_real_i => data_in_bfp_x(2,0),
		 				    data_4_real_i => data_in_bfp_x(3,0),
		 				    data_1_imag_i => data_in_bfp_x(0,1),
		 				    data_2_imag_i => data_in_bfp_x(1,1),
		 				    data_3_imag_i => data_in_bfp_x(2,1),
		 				    data_4_imag_i => data_in_bfp_x(3,1),
		 				    twid_1_real	 => twiddle_data_x(0,0),
		 				    twid_2_real	 => twiddle_data_x(1,0),
		 				    twid_3_real	 => twiddle_data_x(2,0),
		 				    twid_1_imag	 => twiddle_data_x(0,1),
		 				    twid_2_imag	 => twiddle_data_x(1,1),
		 				    twid_3_imag	 => twiddle_data_x(2,1),
		 				    data_1_real_o => dft_r_o(0),
		 				    data_2_real_o => dft_r_o(1),
		 				    data_3_real_o => dft_r_o(2),
		 				    data_4_real_o => dft_r_o(3),
		 				    data_1_imag_o => dft_i_o(0),
		 				    data_2_imag_o => dft_i_o(1),
		 				    data_3_imag_o => dft_i_o(2),
		 				    data_4_imag_o => dft_i_o(3)
		);
	
	 bfpdft_y : asj_fft_dft_bfp
   generic map (	           
   							nps => nps,
   							bfp => bfp,
   							nume => nume,
   							mpr=> mpr,
   							arch => 1,
   							rbuspr => rbuspr,
            		twr=> twr,
            		fpr => fpr,
            		mult_type => mult_type,
            		mult_imp => mult_imp,
            		nstages=> 7,
            		pipe => 1,
            		cont => 0
	 )
   port map(
		 		        clk   		=> clk,
		 		        reset 		=> reset,
		 		        clken     => en_np,
		 		        next_pass => next_pass_d,
		 		        next_blk  => next_blk,
		 		        alt_slb_i   => slb_last_i,
		 		        alt_slb_o   => slb_y_o,
		 				    data_1_real_i => data_in_bfp_y(0,0),
		 				    data_2_real_i => data_in_bfp_y(1,0),
		 				    data_3_real_i => data_in_bfp_y(2,0),
		 				    data_4_real_i => data_in_bfp_y(3,0),
		 				    data_1_imag_i => data_in_bfp_y(0,1),
		 				    data_2_imag_i => data_in_bfp_y(1,1),
		 				    data_3_imag_i => data_in_bfp_y(2,1),
		 				    data_4_imag_i => data_in_bfp_y(3,1),
		 				    twid_1_real	 => twiddle_data_y(0,0),
		 				    twid_2_real	 => twiddle_data_y(1,0),
		 				    twid_3_real	 => twiddle_data_y(2,0),
		 				    twid_1_imag	 => twiddle_data_y(0,1),
		 				    twid_2_imag	 => twiddle_data_y(1,1),
		 				    twid_3_imag	 => twiddle_data_y(2,1),
		 				    data_1_real_o => dft_r_o(4),
		 				    data_2_real_o => dft_r_o(5),
		 				    data_3_real_o => dft_r_o(6),
		 				    data_4_real_o => dft_r_o(7),
		 				    data_1_imag_o => dft_i_o(4),
		 				    data_2_imag_o => dft_i_o(5),
		 				    data_3_imag_o => dft_i_o(6),
		 				    data_4_imag_o => dft_i_o(7)
		);
		
	gen_blk_float : if(bfp=1) generate	
		dual_eng_slb <= slb_y_o & slb_x_o;	
	end generate gen_blk_float;
	
	gen_fixed : if(bfp=0) generate	
		dual_eng_slb <= (others=>'0');	
	end generate gen_fixed;	
	
	delay_blk_done : asj_fft_tdl_bit 
			generic map( 
							 		del   => 24
							)
			port map( 	
									clk 	=> clk,
									data_in 	=> block_done,
					 				data_out 	=> block_done_d
					);	
		
	bfpc : asj_fft_bfp_ctrl 
	
  generic map( 
  						 nps => nps,
  						 nume => nume,
    				 	 fpr  => fpr,
    				 	 cont => 0,
    				 	 arch => 1
						)
  port map(
  	     			 clk  => clk,
       				 clken  => en_np,
       				 reset 	=> reset,
       				 next_pass => next_pass_d,
       				 next_blk  => block_done_d,
       				 exp_en    => exp_en,
			 				 alt_slb_i => dual_eng_slb,
       				 alt_slb_o => slb_last_i,
			     		 blk_exp_o => blk_exp
	);
		
	gen_se_twad : if(nume=1) generate
	
	twid_factors : asj_fft_twadgen 
	generic map(
							nps 			=> nps,
							nume      => nume,
							n_passes 	=> n_passes_m1,
							apr 			=> apr,
							log2_n_passes => log2_n_passes,
							tw_delay  => twid_delay
					)
	port map (
							clk 			=> clk,
							k_count   => k_count,
							p_count   => p_count,
							tw_addr		=> twad
			);
	end generate gen_se_twad;		
	
	gen_de_twad : if(nume=2) generate
	
	twid_factors : asj_fft_twadgen_dual
	generic map(
							nps 			=> nps,
							nume      => nume,
							n_passes 	=> n_passes_m1,
							apr 			=> apr+1,
							log2_n_passes => log2_n_passes,
							tw_delay  => twid_delay
					)
	port map (
							clk 			=> clk,
							k_count   => k_count,
							p_count   => p_count,
							tw_addre		=> twade,
							tw_addro		=> twado
			);
	end generate gen_de_twad;		
	
			
	
	gen_3tdp_rom : if (nume=2) generate 
	
	twrom :  asj_fft_3tdp_rom 
	generic map(
						twr => twr,
						twa => twa,
						m512 => m512,
						rfc1 => rfc1,
						rfc2 => rfc2,
						rfc3 => rfc3,
						rfs1 => rfs1,
						rfs2 => rfs2,
						rfs3 => rfs3
					)
	port map(			clk 			=> clk,
						twade   	  => twade,
						twado   	  => twado,
						t1re			=> t1re,
						t2re			=> t2re,
						t3re			=> t3re,
						t1ie			=> t1ie,
						t2ie			=> t2ie,
						t3ie			=> t3ie,
						t1ro			=> t1ro,
						t2ro			=> t2ro,
						t3ro			=> t3ro,
						t1io			=> t1io,
						t2io			=> t2io,
						t3io			=> t3io
			);
		end generate gen_3tdp_rom;
	 
	 ---------------------------------------------------------------------------------------------------
	 
	 
	 
	 ---------------------------------------------------------------------------------------------------
	 -- After second-to-last pass need to write to RAMS C or D
	 -- These addresss generators are small
	 -- To avoid mass switching should just always feed these signals (after switching)
	 -- to the C and D RAM's and use wc and wd to enable writing
	 -- Then just "serially" process the outputs in the LPP
		wraddress_c_bus <= wraddr_sw(0) & wraddr_sw(1) & wraddr_sw(2) & wraddr_sw(3);
  	c_ram_data_in_bus_x <= ram_data_in_sw(0) & ram_data_in_sw(1) & ram_data_in_sw(2) & ram_data_in_sw(3);
  	c_ram_data_in_bus_y <= ram_data_in_sw(4) & ram_data_in_sw(5) & ram_data_in_sw(6) & ram_data_in_sw(7);
  	---------------------------------------------------------------------------------------------------
	  -- Last Pass Processor Read Address Generation
	  ---------------------------------------------------------------------------------------------------
	  -----------------------------------------------------------------------------------------------
	  -- Dual Engine Serial LPP Read Address and Data Switch
	  -----------------------------------------------------------------------------------------------
	  gen_de_lpp_ad : if(nume=2) generate
	  
	  -----------------------------------------------------------------------------------------------
	  -- Dual Engine Radix 4 Serial LPP 
	  -----------------------------------------------------------------------------------------------
	  
	  gen_radix_4_last_pass : if(last_pass_radix=0) generate
	  
		  	gen_lpp_addr : asj_fft_lpprdadgen 
				generic map(
									nps 					=> nps,
									mram          => 0,
									arch          => 1,
									nume          => nume,
									n_passes 			=> n_passes_m1,
									log2_n_passes => log2_n_passes,
									apr  					=> apr
								)
				port map(
									clk 					=> clk,
									reset         => reset,
									lpp_en 				=> lpp_c_en_early,
									data_rdy => data_rdy,
									rd_addr_a			=> rdaddr_lpp(0),
									rd_addr_b			=> rdaddr_lpp(1),
									rd_addr_c			=> rdaddr_lpp(2),
									rd_addr_d			=> rdaddr_lpp(3),
									sw_data_read  => sw_rd_lpp,
									sw_addr_read  => sw_ra_lpp,
									en            => lpp_en
						); 
   
	  
	  
	  		 ram_cxb_rd_lpp : asj_fft_cxb_addr 
					generic map( 	mpr		=>	apr,
							 					xbw 	=>  4,
							 					pipe	 => 1,
							 					del   => 0
								)
					port map( 	clk 			=> clk,
								--reset   	=> reset,
						 			sw_0_in 	=> rdaddr_lpp(0),
						 			sw_1_in 	=> rdaddr_lpp(2),
						 			sw_2_in 	=> rdaddr_lpp(0),
						 			sw_3_in 	=> rdaddr_lpp(2),
						 			ram_sel  	=> sw_ra_lpp,
						 	  	sw_0_out 	=> rdaddr_lpp_sw(0),
						 	  	sw_1_out 	=> rdaddr_lpp_sw(1),
						 	  	sw_2_out 	=> rdaddr_lpp_sw(2),
						 	  	sw_3_out 	=> rdaddr_lpp_sw(3)
					);   
				
			  lpp_c_addr_en <= lpp_c_en_early and lpp_c_en_vec(3);
	 		  lpp_c_data_en <= lpp_c_en_vec(1) and lpp_c_en_vec(6);	
		    
			 	sel_lpp_addr : process(clk, reset, lpp_c_addr_en, rdaddr_lpp_sw) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
								rdaddress_c_bus <= (others=>'0');
		  			else
							if(lpp_c_addr_en = '1' ) then
								rdaddress_c_bus <= rdaddr_lpp_sw(0) & rdaddr_lpp_sw(1) & rdaddr_lpp_sw(2) & rdaddr_lpp_sw(3);
		  				else
		  			  	rdaddress_c_bus <=(others=>'0');
		  				end if;
		  			end if;
		  		end if;
		  	end process sel_lpp_addr;
		 
	  
	  		sel_lpp_data : process(clk, reset, lpp_c_data_en, c_ram_data_out_bus_x,c_ram_data_out_bus_y) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
							for i in 0 to 7 loop
								lpp_ram_data_out(i) <= (others=>'0');
							end loop;
						else
		  				if(lpp_c_data_en = '1') then
								lpp_ram_data_out(0) <= c_ram_data_out_bus_x(8*mpr-1 downto 6*mpr);
		  					lpp_ram_data_out(1) <= c_ram_data_out_bus_x(6*mpr-1 downto 4*mpr);
		  					lpp_ram_data_out(2) <= c_ram_data_out_bus_x(4*mpr-1 downto 2*mpr);
		  					lpp_ram_data_out(3) <= c_ram_data_out_bus_x(2*mpr-1 downto 0);
								lpp_ram_data_out(4) <= c_ram_data_out_bus_y(8*mpr-1 downto 6*mpr);
		  					lpp_ram_data_out(5) <= c_ram_data_out_bus_y(6*mpr-1 downto 4*mpr);
		  					lpp_ram_data_out(6) <= c_ram_data_out_bus_y(4*mpr-1 downto 2*mpr);
		  					lpp_ram_data_out(7) <= c_ram_data_out_bus_y(2*mpr-1 downto 0);
		  				else
								for i in 0 to 7 loop
									lpp_ram_data_out(i) <= (others=>'0');
								end loop;
		  				end if;
		  			end if;
		  		end if;
		  	end process sel_lpp_data;

	    --gen_64 : if(nps=64) generate
	    --	
	  	--	sel_lpp_ram : process(clk,sw_rd_lpp,lpp_ram_data_out) is
	  	--	begin
	  	--		if(rising_edge(clk)) then
	  	--			-- switch between RAM Sub-block outputs
	  	--			case sw_rd_lpp(1 downto 0) is
	  	--				when "00" =>
			--					lpp_ram_data_out_sw(0) <= lpp_ram_data_out(0);
			--					lpp_ram_data_out_sw(1) <= lpp_ram_data_out(1);
			--					lpp_ram_data_out_sw(2) <= lpp_ram_data_out(4);
			--					lpp_ram_data_out_sw(3) <= lpp_ram_data_out(5);	  						
			--				when "01" =>
			--					lpp_ram_data_out_sw(0) <= lpp_ram_data_out(1);
			--					lpp_ram_data_out_sw(1) <= lpp_ram_data_out(2);
			--					lpp_ram_data_out_sw(2) <= lpp_ram_data_out(5);
			--					lpp_ram_data_out_sw(3) <= lpp_ram_data_out(6);	  						
			--				when "10" =>
			--					lpp_ram_data_out_sw(0) <= lpp_ram_data_out(2);
			--					lpp_ram_data_out_sw(1) <= lpp_ram_data_out(3);
			--					lpp_ram_data_out_sw(2) <= lpp_ram_data_out(6);
			--					lpp_ram_data_out_sw(3) <= lpp_ram_data_out(7);	  						
			--				when "11" =>
			--					lpp_ram_data_out_sw(0) <= lpp_ram_data_out(3);
			--					lpp_ram_data_out_sw(1) <= lpp_ram_data_out(0);
			--					lpp_ram_data_out_sw(2) <= lpp_ram_data_out(7);
			--					lpp_ram_data_out_sw(3) <= lpp_ram_data_out(4);	  						
			--				when others =>
			--					lpp_ram_data_out_sw(0) <= (others=>'0');
			--					lpp_ram_data_out_sw(1) <= (others=>'0');
			--					lpp_ram_data_out_sw(2) <= (others=>'0');
			--					lpp_ram_data_out_sw(3) <= (others=>'0');
			--			end case;
			--		end if;
			--	end process sel_lpp_ram;
			--
			--end generate gen_64;
			
			gen_gt64 : if(nps>=64) generate
	    	
	  		sel_lpp_ram : process(clk,sw_rd_lpp,lpp_ram_data_out) is
	  		begin
	  			if(rising_edge(clk)) then
	  				-- switch between RAM Sub-block outputs
	  				case sw_rd_lpp(1 downto 0) is
	  					when "00" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(0);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(4);
								lpp_ram_data_out_sw(2) <= lpp_ram_data_out(1);
								lpp_ram_data_out_sw(3) <= lpp_ram_data_out(5);	  						
							when "01" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(1);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(5);
								lpp_ram_data_out_sw(2) <= lpp_ram_data_out(2);
								lpp_ram_data_out_sw(3) <= lpp_ram_data_out(6);	  						
							when "10" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(2);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(6);
								lpp_ram_data_out_sw(2) <= lpp_ram_data_out(3);
								lpp_ram_data_out_sw(3) <= lpp_ram_data_out(7);	  						
							when "11" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(3);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(7);
								lpp_ram_data_out_sw(2) <= lpp_ram_data_out(0);
								lpp_ram_data_out_sw(3) <= lpp_ram_data_out(4);	  						
							when others =>
								lpp_ram_data_out_sw(0) <= (others=>'0');
								lpp_ram_data_out_sw(1) <= (others=>'0');
								lpp_ram_data_out_sw(2) <= (others=>'0');
								lpp_ram_data_out_sw(3) <= (others=>'0');
						end case;
					end if;
				end process sel_lpp_ram;
			end generate gen_gt64;
			
				
				---------------------------------------------------------------------------------------------------
		-- Last Pass Processor 
	  ---------------------------------------------------------------------------------------------------
	  	lpp :  asj_fft_lpp_serial 
    		generic map(
	    					mpr 				=> mpr,
	    					arch        => 1,
	    				 	apr 				=> apr,
	    				 	nume        => nume,
	             	del  				=> 5
				)
    		port map (
			        	clk   		=> clk,
			         	reset    => reset,
			         	lpp_en   => lpp_en,
			         	data_1_real_i => lpp_ram_data_out_sw(0)(2*mpr-1 downto mpr),
						   	data_2_real_i => lpp_ram_data_out_sw(1)(2*mpr-1 downto mpr),
						   	data_3_real_i => lpp_ram_data_out_sw(2)(2*mpr-1 downto mpr),
						   	data_4_real_i => lpp_ram_data_out_sw(3)(2*mpr-1 downto mpr),
						   	data_1_imag_i => lpp_ram_data_out_sw(0)(mpr-1 downto 0),
							 	data_2_imag_i => lpp_ram_data_out_sw(1)(mpr-1 downto 0),
							 	data_3_imag_i => lpp_ram_data_out_sw(2)(mpr-1 downto 0),
							 	data_4_imag_i => lpp_ram_data_out_sw(3)(mpr-1 downto 0),
					     	data_real_o   => data_real_out,
					     	data_imag_o   => data_imag_out,
					     	data_val      => lpp_data_val
		 		);
		
	end generate gen_radix_4_last_pass;		
	
	-----------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------			
	
	gen_radix_2_last_pass : if(last_pass_radix=1) generate
	
  		gen_lpp_addr : asj_fft_lpprdadr2gen 
				generic map(
									nps => nps,
									nume=> nume,
									mram => 0,
									arch => 1,
									n_passes => n_passes,
									log2_n_passes =>log2_n_passes,
									apr => apr
							)
				port map(			
									clk => clk,
									reset => reset,
									lpp_en => lpp_c_en_early,
									data_rdy => data_rdy,
									--lpp_en => lpp_c_en_vec(2),
									rd_addr_a	=> rdaddr_lpp(0),
									rd_addr_b	=> rdaddr_lpp(1),
									sw_data_read => sw_rd_lpp,
									sw_addr_read => sw_ra_lpp,
									qe_select		 => open,
									en           => lpp_en
					);
			
	  
	  
	  		 ram_cxb_rd_lpp : asj_fft_cxb_addr 
					generic map( 	mpr		=>	apr,
							 					xbw 	=>  4,
							 					pipe	 => 1,
							 					del   => 0
								)
					port map( 	clk 			=> clk,
								--reset   	=> reset,
						 			sw_0_in 	=> rdaddr_lpp(0),
						 			sw_1_in 	=> rdaddr_lpp(2),
						 			sw_2_in 	=> rdaddr_lpp(0),
						 			sw_3_in 	=> rdaddr_lpp(2),
						 			ram_sel  	=> "00",
						 	  	sw_0_out 	=> rdaddr_lpp_sw(0),
						 	  	sw_1_out 	=> rdaddr_lpp_sw(1),
						 	  	sw_2_out 	=> rdaddr_lpp_sw(2),
						 	  	sw_3_out 	=> rdaddr_lpp_sw(3)
					);   
				
		    
		  	lpp_c_addr_en <= lpp_c_en_early and lpp_c_en_vec(3);
	 			lpp_c_data_en <= lpp_c_en_vec(1) and lpp_c_en_vec(6);
	 
			 	sel_lpp_addr : process(clk, reset, lpp_c_addr_en, rdaddr_lpp_sw) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
								rdaddress_c_bus <= (others=>'0');
		  			else
							if(lpp_c_addr_en = '1' ) then
								rdaddress_c_bus <= rdaddr_lpp_sw(0) & rdaddr_lpp_sw(0) & rdaddr_lpp_sw(0) & rdaddr_lpp_sw(0);
		  				else
		  			  	rdaddress_c_bus <=(others=>'0');
		  				end if;
		  			end if;
		  		end if;
		  	end process sel_lpp_addr;
		    
		    
			 	
	  
	  		sel_lpp_data : process(clk, reset, lpp_c_data_en, c_ram_data_out_bus_x,c_ram_data_out_bus_y) is
				begin
					if(rising_edge(clk)) then
						if(reset='1') then
							for i in 0 to 7 loop
								lpp_ram_data_out(i) <= (others=>'0');
							end loop;
		  			else
		  				if(lpp_c_data_en='1') then
		  					lpp_ram_data_out(0) <= c_ram_data_out_bus_x(8*mpr-1 downto 6*mpr);
		  					lpp_ram_data_out(1) <= c_ram_data_out_bus_x(6*mpr-1 downto 4*mpr);
		  					lpp_ram_data_out(2) <= c_ram_data_out_bus_x(4*mpr-1 downto 2*mpr);
		  					lpp_ram_data_out(3) <= c_ram_data_out_bus_x(2*mpr-1 downto 0);
								lpp_ram_data_out(4) <= c_ram_data_out_bus_y(8*mpr-1 downto 6*mpr);
		  					lpp_ram_data_out(5) <= c_ram_data_out_bus_y(6*mpr-1 downto 4*mpr);
		  					lpp_ram_data_out(6) <= c_ram_data_out_bus_y(4*mpr-1 downto 2*mpr);
		  					lpp_ram_data_out(7) <= c_ram_data_out_bus_y(2*mpr-1 downto 0);
		  				else
								for i in 0 to 7 loop
									lpp_ram_data_out(i) <= (others=>'0');
								end loop;
		  				end if;
		  			end if;
		  		end if;
		  	end process sel_lpp_data;

	    
	  
	  		sel_lpp_ram_r2 : process(clk, sw_rd_lpp, lpp_ram_data_out) is
	  		begin
	  			if(rising_edge(clk)) then
	  				-- switch between RAM Sub-block outputs
	  				case sw_rd_lpp(1 downto 0) is
	  					when "00" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(0);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(4);
							when "01" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(1);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(5);
							when "10" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(2);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(6);
							when "11" =>
								lpp_ram_data_out_sw(0) <= lpp_ram_data_out(3);
								lpp_ram_data_out_sw(1) <= lpp_ram_data_out(7);
							when others =>
								lpp_ram_data_out_sw(0) <= (others=>'0');
								lpp_ram_data_out_sw(1) <= (others=>'0');
						end case;
					end if;
				end process sel_lpp_ram_r2;
				
				---------------------------------------------------------------------------------------------------
		-- Last Pass Processor 
	  ---------------------------------------------------------------------------------------------------
	  	lpp_r2 :  asj_fft_lpp_serial_r2
    		generic map(
	    					mpr 				=> mpr,
	    					arch        => 1,
	    				 	apr 				=> apr,
	    				 	nume        => nume,
	             	del  				=> 5
				)
    		port map (
			        	clk   		=> clk,
			         	reset    => reset,
			         	lpp_en   => lpp_en,
			         	data_1_real_i => lpp_ram_data_out_sw(0)(2*mpr-1 downto mpr),
						   	data_2_real_i => lpp_ram_data_out_sw(1)(2*mpr-1 downto mpr),
						   	data_1_imag_i => lpp_ram_data_out_sw(0)(mpr-1 downto 0),
							 	data_2_imag_i => lpp_ram_data_out_sw(1)(mpr-1 downto 0),
					     	data_real_o   => data_real_out,
					     	data_imag_o   => data_imag_out,
					     	data_val      => lpp_data_val
		 		);
		
		end generate gen_radix_2_last_pass;					
		
  	
end generate gen_de_lpp_ad;
  	

	
  	 
		
	  
	 	
	 -----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------
		
		
		process(clk,reset,data_real_out,data_imag_out,oe,fft_dirn_held_o,val_out,sop_out,eop_out) 
		   begin
		   	if(rising_edge(clk)) then
		   		if(reset='1') then
		   			fft_real_out<=(others=>'0');
		   			fft_imag_out<=(others=>'0');
		   			master_source_ena         <= '0';
		   			master_source_sop         <= '0'; 
		   			master_source_eop         <= '0'; 
		   		else
		   			if(oe='1') then
		   				if(fft_dirn_held_o='0') then
		   					fft_real_out<=data_real_out;
		   					fft_imag_out<=data_imag_out;
		   				else
		   					fft_real_out<=data_imag_out;
		   					fft_imag_out<=data_real_out;
		   				end if;
		   				master_source_ena <= val_out;
		   				master_source_sop <= sop_out;
		   				master_source_eop <= eop_out;
		   			else
			   			fft_real_out<=(others=>'0');
			   			fft_imag_out<=(others=>'0');
			   			master_source_ena         <= '0';
		  	 			master_source_sop         <= '0'; 
		   				master_source_eop         <= '0'; 
		   			end if;
		   		end if;
		   	end if;
		end process;
		-----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------
		-- Block Floating Point
		-----------------------------------------------------------------------------------------------   
		gen_blk_float_out : if(bfp=1) generate
		
			flt_exp : process(clk,reset,oe,blk_exp) is
			   begin
			   	if(rising_edge(clk)) then
			   		if(reset='1') then
			   			exponent_out <= (others=>'0');
			   		else
			   			if(oe='1') then
			   				exponent_out <= blk_exp(fpr+1 downto 0);
			   			else
			   				exponent_out <= (others=>'0');
			   			end if;
			   		end if;
			   	end if;
			   end process flt_exp;
			  
		end generate gen_blk_float_out;
		-----------------------------------------------------------------------------------------------
		-- Fixed Point
		-----------------------------------------------------------------------------------------------
		gen_fixed_out : if(bfp=0) generate
		  exponent_out <=(others=>'0');
		end generate gen_fixed_out;  		
		-----------------------------------------------------------------------------------------------  	
		oe_ctrl: process(clk,fft_s2_cur,sop_d) is
		   begin
		   	if(rising_edge(clk)) then
		   		case fft_s2_cur is
		   		when IDLE=>
		   			oe <='0';
		   			sop_out <= '0';
		   			eop_out <= '0';
		   			val_out <= '0';
		   		when WAIT_FOR_LPP_INPUT=>
		   			oe <='0';
		   			sop_out <= '0';
		   			eop_out <= '0';
		   			val_out <= '0';
		   		when START_LPP=>
		   			oe <='0';
		   			sop_out <= sop_d;
		   			eop_out <= '0';
		   			val_out <= '0';
		   		when LPP_OUTPUT_RDY=>
		   			oe <='1';
		   			sop_out <= sop_d;
		   			eop_out <= '0';
		   			val_out <= '1';
		   		 when LPP_DONE =>
		   			oe <='1';
		   			sop_out <= '0';
		   			eop_out <= '1';
		   			val_out <= '1';
		   		 when others =>
		   			oe <='0';
		   			sop_out <= '0';
		   			eop_out <= '0';
		   			val_out <= '0';
		   		end case;
		   	end if;
		   end process oe_ctrl;
		   
		
		delay_sop : asj_fft_tdl_bit_rst
		generic map( 
							 		del   => 7-2*last_pass_radix
							)
			port map( 	
									clk 	=> clk,
									reset => reset,								
									data_in 	=> lpp_en,
					 				data_out 	=> sop_d
					);
	
		   		
		exp_en_ctrl: process(clk,lpp_en) is
		   begin
		   	  if(rising_edge(clk)) then
		   			exp_en <=lpp_en;
		   		end if;
		   end process exp_en_ctrl;
		   
		
		
		--IDLE,WAIT_FOR_LPP_INPUT,START_LPP,LPP_OUTPUT_RDY
		fsm_2 : process(clk,reset,lpp_en,master_source_dav,lpp_data_val,fft_s2_cur) is
		  	begin
		  		if(rising_edge(clk)) then
		  			if(reset='1') then
		  				fft_s2_cur <= IDLE;
		  			else
				  		case fft_s2_cur is
				  			when IDLE =>
				  			  fft_s2_cur <= WAIT_FOR_LPP_INPUT;
				  			when WAIT_FOR_LPP_INPUT =>
				  				if(lpp_en='1' and master_source_dav='1') then
				  					fft_s2_cur <= START_LPP;
				  				else
				  					fft_s2_cur <= WAIT_FOR_LPP_INPUT;
				  				end if;
				  			when START_LPP =>
				  				if(lpp_data_val='1') then
				  					fft_s2_cur <= LPP_OUTPUT_RDY;
				  				end if;
				  			when LPP_OUTPUT_RDY =>
				  				if(lpp_data_val='0') then
				  					fft_s2_cur <=LPP_DONE;
				  				end if;
				  			when LPP_DONE =>
				  					fft_s2_cur <=WAIT_FOR_LPP_INPUT;
				  			when others =>
				  				fft_s2_cur <= IDLE;
				  		end case;
				  	end if;
		  	 end if;
		  	end process fsm_2;
		  
		  
		   
		   
		  
		
		
		   
		-----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------   
		
		-- Registering here to enable registered muxing based on dirn
		-- This implies that two levels of delay must be removed from
		-- in_write_sgl
		
			
		is_data_valid : process(clk,reset,master_sink_val,data_real_in,data_imag_in,data_real_in_reg,data_imag_in_reg) is
			begin
				if(rising_edge(clk)) then
					if(reset='1') then
						data_real_in_reg <= (others=>'0');
						data_imag_in_reg <= (others=>'0');
					else
						if(master_sink_val='1') then
							data_real_in_reg <= data_real_in;
							data_imag_in_reg <= data_imag_in;			
						else
							data_real_in_reg <= data_real_in_reg;
							data_imag_in_reg <= data_imag_in_reg;			
						end if;
					end if;
				end if;
		end process is_data_valid;		

		i_dirn_mux : process(clk,fft_dirn,data_real_in,data_imag_in,data_real_in_reg,data_imag_in_reg) is
			begin
				if(rising_edge(clk)) then
					if(reset='1') then
						core_real_in <=(others=>'0');
						core_imag_in <=(others=>'0');
					elsif(fft_dirn='0') then
						core_real_in <=data_real_in_reg;
						core_imag_in <=data_imag_in_reg;
					else
						core_real_in <=data_imag_in_reg;
						core_imag_in <=data_real_in_reg;
					end if;
				end if;
			end process i_dirn_mux;
			
		regfftdirni : process(clk,master_sink_sop,inv_i,fft_dirn,fft_dirn_held) is
			begin
				if(rising_edge(clk)) then
					if(master_sink_sop='1') then
						fft_dirn <= inv_i;
					else
						fft_dirn <= fft_dirn;
					end if;
				end if;
			end process regfftdirni;
			
		regfftdirnit : process(clk,fft_s2_cur,fft_dirn_held,fft_dirn_held_o) is
			begin
				if(rising_edge(clk)) then
					if(fft_s1_cur=DONE_WRITING) then
		   			fft_dirn_held <= fft_dirn;
		   		else
		   			fft_dirn_held <= fft_dirn_held;
					end if;
				end if;
			end process regfftdirnit;
			
		regfftdirno : process(clk,fft_s2_cur,fft_dirn_held,fft_dirn_held_o) is
			begin
				if(rising_edge(clk)) then
					if(reset='1') then
						fft_dirn_held_o <= '0';
					else
		   			if(fft_s2_cur=START_LPP) then
		   				fft_dirn_held_o <= fft_dirn_held;
		   			else
		   				fft_dirn_held_o <= fft_dirn_held_o;
						end if;
					end if;
				end if;
			end process regfftdirno;
						
		del_input_blk_indicator : if(nps>1024) generate
						
		delay_next_block : asj_fft_tdl_bit
		generic map( 
							 		del   => 1
							)
			port map( 	
									clk 	=> clk,
									data_in 	=> next_blk,
					 				data_out 	=> next_input_blk
					);
		
	end generate del_input_blk_indicator;
		
	no_del_input_blk : if(nps<=1024) generate
						
		delay_next_block : asj_fft_tdl_bit
		generic map( 
							 		del   => 1
							)
			port map( 	
									clk 	=> clk,
									data_in 	=> next_blk,
					 				data_out 	=> next_input_blk
					);
		
	end generate no_del_input_blk;
						
										
	
	gen_nbc_128 : if(nps=64 or nps=128 or nps=256) generate
		nbc <= "01";
	end generate gen_nbc_128;
	
	gen_nbc_512 : if(nps=512 or nps=1024) generate
		nbc <= "001";
	end generate gen_nbc_512;
	
	gen_nbc_2048 : if(nps=2048 or nps=4096) generate
		nbc <= "001";
	end generate gen_nbc_2048;
	
	gen_nbc_8192 : if(nps=8192 or nps=16384) generate
		nbc <= "001";
	end generate gen_nbc_8192;
	
	gen_nbc_32768 : if(nps=32768 or nps=65536) generate
		nbc <= "001";
	end generate gen_nbc_32768;
		
	-----------------------------------------------------------------------------------------------
	gen_fsm_1 : if(which_fsm=1) generate   
		
		ena_gen : process(clk,fft_s1_cur,master_sink_dav) is
			begin
				if(rising_edge(clk)) then
					if(reset='1') then
						master_sink_ena <='0';
					else
						case fft_s1_cur is
							when IDLE =>
								if(master_sink_dav='1') then
									master_sink_ena <='1';
								else
									master_sink_ena <='0';
								end if;
							when WAIT_FOR_INPUT =>		
								master_sink_ena <='1';
							when WRITE_INPUT =>	
								master_sink_ena <='1';
							when EARLY_DONE	=>
								master_sink_ena <='0';
							when DONE_WRITING =>	
								master_sink_ena <='0';
							when FFT_PROCESS_A =>
								master_sink_ena <='0';
							when others =>
								master_sink_ena <='1';
						end case;
					end if;
				end if;
			end process ena_gen;		   
    fsm_1 : process(clk,master_sink_val,master_sink_dav,reset,master_sink_sop,fft_s1_cur,next_input_blk,next_blk,next_pass,p_count,dsw,nbc) is
		  	begin
		  		if(rising_edge(clk)) then
		  			if(reset='1') then
		  				fft_s1_cur <= IDLE;
		  			else
			  			case fft_s1_cur is
				  			when IDLE =>
				  				if(master_sink_dav='1') then
				  			  	fft_s1_cur <= WAIT_FOR_INPUT;
				  			  end if;
				  			when WAIT_FOR_INPUT =>
				  				if(master_sink_sop='1' and master_sink_val='1') then
				  					fft_s1_cur <= WRITE_INPUT;				  					
				  				end if;
				  			when WRITE_INPUT =>
				  				if(dsw='1') then
				  					fft_s1_cur <= EARLY_DONE;
				  				end if;
				  			when EARLY_DONE =>
				  				if(next_blk='1') then
				  					fft_s1_cur <= DONE_WRITING;
				  				end if;
				  			when DONE_WRITING =>
				  				if(next_input_blk='1') then
				  					fft_s1_cur <= FFT_PROCESS_A;
				  				end if;
				  			when FFT_PROCESS_A =>
				  				if(next_pass='1' and p_count=nbc) then
				  					fft_s1_cur <=IDLE;
				  				end if;
				  			when others =>
				  				fft_s1_cur <= IDLE;
				  		end case;
				  	end if;
				  end if;
		  	end process fsm_1;
	end generate gen_fsm_1;	  
	-----------------------------------------------------------------------------------------------
	gen_fsm_2 : if(which_fsm=2) generate   
		   
		ena_gen : process(clk,fft_s1_cur,master_sink_dav) is
			begin
				if(rising_edge(clk)) then
					case fft_s1_cur is
						when IDLE =>
							if(master_sink_dav='1') then
								master_sink_ena <='1';
							else
								master_sink_ena <='0';
							end if;
						when WAIT_FOR_INPUT =>		
							master_sink_ena <='1';
						when WRITE_INPUT =>	
							master_sink_ena <='1';
						when EARLY_DONE	=>
							master_sink_ena <='0';
						when DONE_WRITING =>	
							master_sink_ena <='0';
						when FFT_PROCESS_A =>
							master_sink_ena <='0';
						when others =>
							master_sink_ena <='1';
					end case;
				end if;
			end process ena_gen;
		
		fsm_1 : process(clk,reset,master_sink_sop,master_sink_dav,master_sink_val,fft_s1_cur,dsw,next_blk,next_input_blk,next_pass,p_count,nbc) is
			begin
					if(rising_edge(clk)) then
		  			if(reset='1') then
		  				fft_s1_cur <= IDLE;
		  			else
			  			case fft_s1_cur is
					  		when IDLE =>
					  			if(master_sink_dav='1') then
					  		  	fft_s1_cur <= WAIT_FOR_INPUT;
					  		  end if;
					  		when WAIT_FOR_INPUT =>
					  			if(master_sink_sop='1' and master_sink_val='1') then
					  				fft_s1_cur <= WRITE_INPUT;
					  			end if;
					  		when WRITE_INPUT =>
					  			--if(dsw='1') then
					  			--	fft_s1_cur <= EARLY_DONE;
					  			--end if;
					  			if(input_sample_counter=int2ustd(2**(apr+3)-3, apr+3)) then
					  				fft_s1_cur <= EARLY_DONE;
					  			end if;
					  		when EARLY_DONE =>
									if(input_sample_counter=int2ustd(2**(apr+3)-1, apr+3) and master_sink_val='1') then
					  				fft_s1_cur <= DONE_WRITING;
					  			end if;
					  		when DONE_WRITING =>
					  			if(next_input_blk='1') then
					  				fft_s1_cur <= FFT_PROCESS_A;
					  			end if;
					  		when FFT_PROCESS_A =>
					  			if(next_pass='1' and p_count=nbc) then
					  				fft_s1_cur <=IDLE;
					  			end if;
					  		when others =>
					  			fft_s1_cur <= IDLE;
					  	end case;
						end if;
				  end if;
		  	end process fsm_1;
		  	
		  loader : process(clk,fft_s1_cur) is
		 		begin
		 			if(rising_edge(clk)) then	                                
		 				if(fft_s1_cur=WRITE_INPUT or fft_s1_cur=EARLY_DONE) then
		 					if(master_sink_val='1') then
		 						input_sample_counter <= input_sample_counter + int2ustd(1,apr+3);
							else                                          
								input_sample_counter <= input_sample_counter;
							end if;
						elsif(fft_s1_cur=WAIT_FOR_INPUT) then
								input_sample_counter <= int2ustd(1,apr+3);
						else
								input_sample_counter <= (others=>'0');
						end if;
					end if;
			 end process loader;
		end generate gen_fsm_2;
		-----------------------------------------------------------------------------------------------
		      
  				
		  		
  
end transform;