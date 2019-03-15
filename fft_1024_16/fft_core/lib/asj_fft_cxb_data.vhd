---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.6 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_cxb_data.vhd,v 1.6 2004/03/12 02:39:10 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
library fft_lib;
use fft_lib.fft_pack.all;
-- cross bar switch control of RAM selection for butterfly I/O
-- Switch direction : forward circular
-- Performs fourwayswitch function in MATALB model
--  data        sw        output
--{0,1,2,3}      0       {0,1,2,3}
--{0,1,2,3}      1       {3,0,1,2}
--{0,1,2,3}      2       {2,3,0,1}
--{0,1,2,3}      3       {1,2,3,0}

entity asj_fft_cxb_data is 
generic( mpr  	: integer :=16;
				 xbw    : integer :=4;
				 pipe   : integer :=1
				);
port( 	clk 			: in std_logic;
				--reset   	: in std_logic;
		 		sw_0_in 	: in std_logic_vector(2*mpr-1 downto 0);
		 		sw_1_in 	: in std_logic_vector(2*mpr-1 downto 0);
		 		sw_2_in 	: in std_logic_vector(2*mpr-1 downto 0);
		 		sw_3_in 	: in std_logic_vector(2*mpr-1 downto 0);
		 		ram_sel  	: in std_logic_vector(1 downto 0);
		 	  sw_0_out 	: out std_logic_vector(2*mpr-1 downto 0);
		 	  sw_1_out 	: out std_logic_vector(2*mpr-1 downto 0);
		 	  sw_2_out 	: out std_logic_vector(2*mpr-1 downto 0);
		 	  sw_3_out 	: out std_logic_vector(2*mpr-1 downto 0)
		);

end asj_fft_cxb_data;


architecture syn of asj_fft_cxb_data is 

	 
signal vcc : std_logic;
signal gnd : std_logic;
signal ram_sel_int : std_logic_vector(1 downto 0);

type ram_input_array is array (0 to 7) of std_logic_vector(mpr-1 downto 0);
signal ram_in_reg : ram_input_array;

begin
	gnd <= '0';
	vcc <= '1';

	ram_sel_int <= ram_sel;
	
	
  
  gen_crossbar_registered_dual_mux : if(pipe=1) generate
  
  sw_0_out <= ram_in_reg(0) & ram_in_reg(4);
	sw_1_out <= ram_in_reg(1) & ram_in_reg(5);
	sw_2_out <= ram_in_reg(2) & ram_in_reg(6);
	sw_3_out <= ram_in_reg(3) & ram_in_reg(7);
	
  
  reg_cxb_r : process(clk,ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  	if(rising_edge(clk)) then
  			case ram_sel_int is
  	  		when "00"=>
  	  			ram_in_reg(0) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_3_in(2*mpr-1 downto mpr);
  	  		when "01"=>
  	  			ram_in_reg(0) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_2_in(2*mpr-1 downto mpr);
					when "10"=>
  	  			ram_in_reg(0) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_1_in(2*mpr-1 downto mpr);
  	  		when "11"=>
  	  			ram_in_reg(0) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_0_in(2*mpr-1 downto mpr);

  	  		when others => 
  	  			ram_in_reg(0) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_2_in(2*mpr-1 downto mpr);
  	  	end case;
		end if;
	end process reg_cxb_r;	  	  	
	
	reg_cxb_i : process(clk,ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  	if(rising_edge(clk)) then
  			case ram_sel_int is
  	  		when "00"=>
  	  			ram_in_reg(4) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_3_in(mpr-1 downto 0);
  	  		when "01"=>
  	  			ram_in_reg(4) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_2_in(mpr-1 downto 0);
  	  		when "10"=>
  	  			ram_in_reg(4) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_1_in(mpr-1 downto 0);
  	  		when "11"=>
  	  			ram_in_reg(4) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_0_in(mpr-1 downto 0);
  	  		when others => 
  	  			ram_in_reg(4) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_3_in(mpr-1 downto 0);
  	  	end case;
		end if;
	end process reg_cxb_i;	  	  	

	
  end generate gen_crossbar_registered_dual_mux;

  gen_crossbar_unregistered_dual_mux : if(pipe=0) generate
  
  sw_0_out <= ram_in_reg(0) & ram_in_reg(4);
	sw_1_out <= ram_in_reg(1) & ram_in_reg(5);
	sw_2_out <= ram_in_reg(2) & ram_in_reg(6);
	sw_3_out <= ram_in_reg(3) & ram_in_reg(7);
	
  
  reg_cxb_r : process(clk,ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  			case ram_sel_int is
  	  		when "00"=>
  	  			ram_in_reg(0) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_3_in(2*mpr-1 downto mpr);
  	  		when "01"=>
  	  			ram_in_reg(0) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_2_in(2*mpr-1 downto mpr);
					when "10"=>
  	  			ram_in_reg(0) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_1_in(2*mpr-1 downto mpr);
  	  		when "11"=>
  	  			ram_in_reg(0) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_2_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_0_in(2*mpr-1 downto mpr);

  	  		when others => 
  	  			ram_in_reg(0) <= sw_3_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(1) <= sw_0_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(2) <= sw_1_in(2*mpr-1 downto mpr);
  	  			ram_in_reg(3) <= sw_2_in(2*mpr-1 downto mpr);
  	  	end case;
	end process reg_cxb_r;	  	  	
	
	reg_cxb_i : process(clk,ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  			case ram_sel_int is
  	  		when "00"=>
  	  			ram_in_reg(4) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_3_in(mpr-1 downto 0);
  	  		when "01"=>
  	  			ram_in_reg(4) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_2_in(mpr-1 downto 0);
  	  		when "10"=>
  	  			ram_in_reg(4) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_1_in(mpr-1 downto 0);
  	  		when "11"=>
  	  			ram_in_reg(4) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_3_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_0_in(mpr-1 downto 0);
  	  		when others => 
  	  			ram_in_reg(4) <= sw_0_in(mpr-1 downto 0);
  	  			ram_in_reg(5) <= sw_1_in(mpr-1 downto 0);
  	  			ram_in_reg(6) <= sw_2_in(mpr-1 downto 0);
  	  			ram_in_reg(7) <= sw_3_in(mpr-1 downto 0);
  	  	end case;
	end process reg_cxb_i;	  	  	

	
  end generate gen_crossbar_unregistered_dual_mux;

  
--  gen_crossbar_unregistered : if(pipe=0) generate
--  
--  ram_0_in <= ram_in_reg(0);
--	ram_1_in <= ram_in_reg(1);
--	ram_2_in <= ram_in_reg(2);
--	ram_3_in <= ram_in_reg(3);
--	
--  
--  reg_cxb : process(ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
--  begin
--  	case ram_sel_int is
--  		when "00"=>
--  			ram_in_reg(0) <= sw_0_in;
--  			ram_in_reg(1) <= sw_1_in;
--  			ram_in_reg(2) <= sw_2_in;
--  			ram_in_reg(3) <= sw_3_in;
--  		when "01"=>
--  			ram_in_reg(3) <= sw_0_in;
--  			ram_in_reg(0) <= sw_1_in;
--  			ram_in_reg(1) <= sw_2_in;
--  			ram_in_reg(2) <= sw_3_in;
--  		when "10"=>
--  			ram_in_reg(2) <= sw_0_in;
--  			ram_in_reg(3) <= sw_1_in;
--  			ram_in_reg(0) <= sw_2_in;
--  			ram_in_reg(1) <= sw_3_in;
--  		when "11"=>
--  			ram_in_reg(1) <= sw_0_in;
--  			ram_in_reg(2) <= sw_1_in;
--  			ram_in_reg(3) <= sw_2_in;
--  			ram_in_reg(0) <= sw_3_in;
--  		when others => 
--  			ram_in_reg(1) <= sw_0_in;
--  			ram_in_reg(2) <= sw_1_in;
--  			ram_in_reg(3) <= sw_2_in;
--  			ram_in_reg(0) <= sw_3_in;
--  	end case;
--	end process reg_cxb;	  	  	
--  end generate gen_crossbar_unregistered;
  

end syn;