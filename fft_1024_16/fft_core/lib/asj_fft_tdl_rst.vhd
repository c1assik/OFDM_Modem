---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.4 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_tdl_rst.vhd,v 1.4 2004/04/08 19:48:30 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
library fft_lib;
use fft_lib.fft_pack.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

-- TDL For delay register chains

entity asj_fft_tdl_rst is 
generic( 
				 mpr  	: integer :=16;
				 del    : integer :=6
				);
port( 	clk 			: in std_logic;
				reset   	: in std_logic;
		 		data_in 	: in std_logic_vector(mpr-1 downto 0);
		 		data_out 	: out std_logic_vector(mpr-1 downto 0)
		);

end asj_fft_tdl_rst;


architecture syn of asj_fft_tdl_rst is 

	 

type del_array is array (0 to del-1) of std_logic_vector(mpr-1 downto 0);
signal tdl_arr : del_array;



begin

	
	data_out <= tdl_arr(del-1);
	
	tdl : process(clk,reset,data_in,tdl_arr) is
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					for i in del-1 downto 0 loop
						tdl_arr(i)<=(others=>'0');
					end loop;
				else
					for i in del-1 downto 1 loop
						tdl_arr(i)<=tdl_arr(i-1);
					end loop;
					tdl_arr(0) <= data_in;
				end if;
			end if;
		end process tdl;
	
	
	
  
end syn;