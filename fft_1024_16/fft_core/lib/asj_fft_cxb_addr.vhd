---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.5 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_cxb_addr.vhd,v 1.5 2003/07/16 14:54:19 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
library fft_lib;
use fft_lib.fft_pack.all;
-- cross bar switch control of RAM selection for butterfly inputs/outputs

entity asj_fft_cxb_addr is 
generic( mpr  	: integer :=16;
				 xbw    : integer :=4;
				 pipe   : integer :=1;
				 del    : integer :=6
				);
port( 	clk 			: in std_logic;
				--reset   	: in std_logic;
		 		sw_0_in 	: in std_logic_vector(mpr-1 downto 0);
		 		sw_1_in 	: in std_logic_vector(mpr-1 downto 0);
		 		sw_2_in 	: in std_logic_vector(mpr-1 downto 0);
		 		sw_3_in 	: in std_logic_vector(mpr-1 downto 0);
		 		ram_sel  	: in std_logic_vector(1 downto 0);
		 	  sw_0_out 	: out std_logic_vector(mpr-1 downto 0);
		 	  sw_1_out 	: out std_logic_vector(mpr-1 downto 0);
		 	  sw_2_out 	: out std_logic_vector(mpr-1 downto 0);
		 	  sw_3_out 	: out std_logic_vector(mpr-1 downto 0)
		);

end asj_fft_cxb_addr;


architecture syn of asj_fft_cxb_addr is 

	 
signal vcc : std_logic;
signal gnd : std_logic;
signal ram_sel_int : std_logic_vector(1 downto 0);

type ram_input_array is array (0 to 3) of std_logic_vector(mpr-1 downto 0);
signal ram_in_reg : ram_input_array;

type wr_addr_delay  is array (0 to del-1) of std_logic_vector(mpr-1 downto 0);
signal sw_0_arr,sw_1_arr,sw_2_arr,sw_3_arr : wr_addr_delay;
signal sw_0_in_d : std_logic_vector(mpr-1 downto 0);
signal sw_1_in_d : std_logic_vector(mpr-1 downto 0);
signal sw_2_in_d : std_logic_vector(mpr-1 downto 0);
signal sw_3_in_d : std_logic_vector(mpr-1 downto 0);


begin
	gnd <= '0';
	vcc <= '1';

	ram_sel_int <= ram_sel;
	
	sw_0_out <= ram_in_reg(0);
	sw_1_out <= ram_in_reg(1);
	sw_2_out <= ram_in_reg(2);
	sw_3_out <= ram_in_reg(3);
	
	gen_no_tdl_output : if(del=0) generate
	
		sw_0_in_d <= sw_0_in;
		sw_1_in_d <= sw_1_in;
		sw_2_in_d <= sw_2_in;
		sw_3_in_d <= sw_3_in;
	
	end generate gen_no_tdl_output;
	
	gen_tdl_output : if(del/=0) generate
	
	sw_0_in_d <= sw_0_arr(del-1);
	sw_1_in_d <= sw_1_arr(del-1);
	sw_2_in_d <= sw_2_arr(del-1);
	sw_3_in_d <= sw_3_arr(del-1);

	tdl : process(clk,ram_in_reg) is
		begin
			if(rising_edge(clk)) then
				for i in del-1 downto 1 loop
					sw_0_arr(i)<=sw_0_arr(i-1);
					sw_1_arr(i)<=sw_1_arr(i-1);
					sw_2_arr(i)<=sw_2_arr(i-1);
					sw_3_arr(i)<=sw_3_arr(i-1);
				end loop;
				sw_0_arr(0) <= sw_0_in;
				sw_1_arr(0) <= sw_1_in;
				sw_2_arr(0) <= sw_2_in;
				sw_3_arr(0) <= sw_3_in;
			end if;
		end process tdl;
	
	end generate gen_tdl_output;
	
	
  gen_crossbar_registered : if(pipe=1) generate
  -- output
	
  
  reg_cxb : process(clk,ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  	if(rising_edge(clk)) then
  			case ram_sel_int is
  	  		when "00"=>
  	  			ram_in_reg(0) <= sw_0_in_d;
  	  			ram_in_reg(1) <= sw_1_in_d;
  	  			ram_in_reg(2) <= sw_2_in_d;
  	  			ram_in_reg(3) <= sw_3_in_d;
  	  		when "01"=>               
  	  			ram_in_reg(0) <= sw_3_in_d;
  	  			ram_in_reg(1) <= sw_0_in_d;
  	  			ram_in_reg(2) <= sw_1_in_d;
  	  			ram_in_reg(3) <= sw_2_in_d;
  	  		when "10"=>               
  	  			ram_in_reg(0) <= sw_2_in_d;
  	  			ram_in_reg(1) <= sw_3_in_d;
  	  			ram_in_reg(2) <= sw_0_in_d;
  	  			ram_in_reg(3) <= sw_1_in_d;
  	  		when "11"=>               
  	  			ram_in_reg(0) <= sw_1_in_d;
  	  			ram_in_reg(1) <= sw_2_in_d;
  	  			ram_in_reg(2) <= sw_3_in_d;
  	  			ram_in_reg(3) <= sw_0_in_d;
  	  		when others =>            
  	  			ram_in_reg(1) <= sw_0_in_d;
  	  			ram_in_reg(2) <= sw_1_in_d;
  	  			ram_in_reg(3) <= sw_2_in_d;
  	  			ram_in_reg(0) <= sw_3_in_d;
  	  	end case;
		end if;
	end process reg_cxb;	  	  	
	end generate gen_crossbar_registered;

  gen_crossbar_unregistered : if(pipe=0) generate
  
  
  
  reg_cxb : process(ram_sel_int,sw_0_in,sw_1_in,sw_2_in,sw_3_in) is
  begin
  	case ram_sel_int is
  		when "00"=>
  			ram_in_reg(0) <= sw_0_in_d;
  			ram_in_reg(1) <= sw_1_in_d;
  			ram_in_reg(2) <= sw_2_in_d;
  			ram_in_reg(3) <= sw_3_in_d;
  		when "01"=>
  			ram_in_reg(0) <= sw_3_in_d;
  			ram_in_reg(1) <= sw_0_in_d;
  			ram_in_reg(2) <= sw_1_in_d;
  			ram_in_reg(3) <= sw_2_in_d;
  		when "10"=>
  			ram_in_reg(0) <= sw_2_in_d;
  			ram_in_reg(1) <= sw_3_in_d;
  			ram_in_reg(2) <= sw_0_in_d;
  			ram_in_reg(3) <= sw_1_in_d;
  		when "11"=>
  			ram_in_reg(0) <= sw_1_in_d;
  			ram_in_reg(1) <= sw_2_in_d;
  			ram_in_reg(2) <= sw_3_in_d;
  			ram_in_reg(3) <= sw_0_in_d;
  		when others => 
  			ram_in_reg(1) <= sw_0_in_d;
  			ram_in_reg(2) <= sw_1_in_d;
  			ram_in_reg(3) <= sw_2_in_d;
  			ram_in_reg(0) <= sw_3_in_d;
  	end case;
	end process reg_cxb;	  	  	
  end generate gen_crossbar_unregistered;
  

end syn;