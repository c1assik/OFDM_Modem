---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.2 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_tdl_bit_rst.vhd,v 1.2 2004/04/08 19:48:30 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
library fft_lib;
use fft_lib.fft_pack.all;
-- TDL For single-bit delay register chains

entity asj_fft_tdl_bit_rst is 
generic( 
				 del    : integer :=2
				);
port( 	clk 			: in std_logic;
				reset   	: in std_logic;
		 		data_in 	: in std_logic;
		 		data_out 	: out std_logic
		);

end asj_fft_tdl_bit_rst;


architecture syn of asj_fft_tdl_bit_rst is 

constant counter_based 	: integer := 1;
constant log2_del 			: integer := LOG2_CEIL(del);

signal tdl_bit 	: std_logic;
signal tdl_arr 	: std_logic_vector(del-1 downto 0);


begin

	gen_no_del : if(del=0) generate
		data_out <= data_in;
	end generate gen_no_del;
	
	gen_del : if(del>0) generate
	
	data_out <= tdl_arr(del-1);
	
	tdl : process(clk,data_in,tdl_arr) is
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					for i in del-1 downto 0 loop
						tdl_arr(i)<='0';
					end loop;
				else
					for i in del-1 downto 1 loop
						tdl_arr(i)<=tdl_arr(i-1);
					end loop;
					tdl_arr(0) <= data_in;
				end if;
			end if;
		end process tdl;
	
	end generate gen_del;



	
  
end syn;