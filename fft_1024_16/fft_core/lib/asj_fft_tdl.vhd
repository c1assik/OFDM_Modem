---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.7 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_tdl.vhd,v 1.7 2004/04/08 19:48:30 djmoore Exp $ 
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

entity asj_fft_tdl is 
generic( 
				 mpr  	: integer :=16;
				 del    : integer :=6;
				 srr    : string  :="AUTO_SHIFT_REGISTER_RECOGNITION=ON"
				);
port( 	clk 			: in std_logic;
				--reset   	: in std_logic;
		 		data_in 	: in std_logic_vector(mpr-1 downto 0);
		 		data_out 	: out std_logic_vector(mpr-1 downto 0)
		);

end asj_fft_tdl;


architecture syn of asj_fft_tdl is 

	 

type del_array is array (0 to del-1) of std_logic_vector(mpr-1 downto 0);
signal tdl_arr : del_array;


begin


	gen_le : if(srr="AUTO_SHIFT_REGISTER_RECOGNITION=OFF" or del<3) generate
	
		data_out <= tdl_arr(del-1);
		
		tdl : process(clk,data_in,tdl_arr) is
			begin
				if(rising_edge(clk)) then
					for i in del-1 downto 1 loop
						tdl_arr(i)<=tdl_arr(i-1);
					end loop;
					tdl_arr(0) <= data_in;
					end if;
			end process tdl;
	end generate gen_le;
	
	gen_mem : if(srr="AUTO_SHIFT_REGISTER_RECOGNITION=ON" and del>=3) generate
		
		tdl : asj_fft_alt_shift_tdl 
			generic	map
			(
				mpr => mpr,
				depth => del,
				m512 => 1
			)
			port map
			(
				shiftin		=> data_in,
				clock		 	=> clk,
				shiftout	=> data_out,
				taps			=> open
			);
			
	end generate gen_mem;	
		
	
  
end syn;