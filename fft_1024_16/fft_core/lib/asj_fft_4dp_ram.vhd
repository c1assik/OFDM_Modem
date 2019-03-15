---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.11 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_4dp_ram.vhd,v 1.11 2005/03/03 21:56:55 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- asj_fft_4dp_ram : Quad bank of Dual Port ROMS (Implemented in M4K/MRAM). 
-- This is the standard internal memory config for all Quad-Output Engine architectures. 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 


entity asj_fft_4dp_ram is
	generic(
						apr : integer :=10;
						mpr : integer :=16;
						abuspr : integer :=40; --4*apr
						cbuspr : integer :=128; -- 4 * 2 * mpr
						rfd  : string :="AUTO"
						
					);
	port(			clk 						: in std_logic;
						rdaddress   	  : in std_logic_vector(abuspr-1 downto 0);
						wraddress				: in std_logic_vector(abuspr-1 downto 0);
						data_in				  : in std_logic_vector(cbuspr-1 downto 0);
						wren            : in std_logic_vector(3 downto 0);
						rden            : in std_logic_vector(3 downto 0);
						data_out				: out std_logic_vector(cbuspr-1 downto 0)
			);
end asj_fft_4dp_ram;

architecture syn of asj_fft_4dp_ram is

type address_bus is array (0 to 3) of std_logic_vector(apr-1 downto 0);
type complex_data_bus is array (0 to 3) of std_logic_vector(2*mpr-1 downto 0);
--constant rfd : string :="M-RAM";
constant dpr : integer := 2*mpr;

signal rd_address, wr_address : address_bus;
signal input_data, output_data : complex_data_bus;
signal wren_a : std_logic_vector(3 downto 0);
signal rden_a : std_logic_vector(3 downto 0);

begin
	
		gen_rams : for i in 0 to 3 generate
			rd_address(i) <= rdaddress(((4-i)*apr)-1 downto (3-i)*apr);
			wr_address(i) <= wraddress(((4-i)*apr)-1 downto (3-i)*apr);
			input_data(i) <= data_in(((8-2*i)*mpr)-1 downto (6-2*i)*mpr);
			data_out(((8-2*i)*mpr)-1 downto (6-2*i)*mpr)<=output_data(i)(2*mpr-1 downto 0);
			wren_a(i) <= wren(i);
			rden_a(i) <= rden(i);
	  	dat_A : asj_fft_data_ram
  		generic map(
        				apr => apr,
        				dpr => dpr,
        				rfd => rfd
	      				)
    	port map(
            		rdaddress => rd_address(i),
            		data      => input_data(i),
            		wraddress => wr_address(i),
            		wren      => wren_a(i),
            		rden      => rden_a(i),
            		clock     => clk,
            		q         => output_data(i)
            );
            
    	end generate gen_rams;

end;