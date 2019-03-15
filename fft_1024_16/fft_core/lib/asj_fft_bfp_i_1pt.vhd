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
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_bfp_i_1pt.vhd,v 1.4 2005/03/23 19:12:44 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- 


entity asj_fft_bfp_i_1pt is
    generic (
    	mpr : integer := 16;
    	fpr : integer :=4;
    	rbuspr : integer :=64 -- 4*mpr
		);
    port (
         clk   		: in std_logic;
         --reset 		: in std_logic;
         real_bfp_0_in : in std_logic_vector(mpr-1 downto 0); 
         real_bfp_1_in : in std_logic_vector(mpr-1 downto 0); 
         real_bfp_2_in : in std_logic_vector(mpr-1 downto 0); 
         real_bfp_3_in : in std_logic_vector(mpr-1 downto 0); 
         imag_bfp_0_in : in std_logic_vector(mpr-1 downto 0); 
         imag_bfp_1_in : in std_logic_vector(mpr-1 downto 0); 
         imag_bfp_2_in : in std_logic_vector(mpr-1 downto 0); 
         imag_bfp_3_in : in std_logic_vector(mpr-1 downto 0); 
         lut_in : in std_logic_vector(2 downto 0);
         real_bfp_0_out : out std_logic_vector(mpr-1 downto 0); 
         real_bfp_1_out : out std_logic_vector(mpr-1 downto 0); 
         real_bfp_2_out : out std_logic_vector(mpr-1 downto 0); 
         real_bfp_3_out : out std_logic_vector(mpr-1 downto 0); 
         imag_bfp_0_out : out std_logic_vector(mpr-1 downto 0); 
         imag_bfp_1_out : out std_logic_vector(mpr-1 downto 0); 
         imag_bfp_2_out : out std_logic_vector(mpr-1 downto 0); 
         imag_bfp_3_out : out std_logic_vector(mpr-1 downto 0)
		     );
end asj_fft_bfp_i_1pt;

architecture input_bfp of asj_fft_bfp_i_1pt is
	
	function sgn_ex(inval : std_logic_vector; w : integer; b : integer) return std_logic_vector is
	-- sign extend input std_logic_vector of width w by b bits
	variable temp :   std_logic_vector(w+b-1 downto 0);
	begin
		temp(w+b-1 downto w-1):=(w+b-1 downto w-1 => inval(w-1));
		temp(w-2 downto 0) := inval(w-2 downto 0);
	return temp;
	end	sgn_ex;
	
	function int2ustd(value : integer; width : integer) return std_logic_vector is 
	-- convert integer to unsigned std_logicvector
	variable temp :   std_logic_vector(width-1 downto 0);
	begin
	if (width>0) then 
			temp:=conv_std_logic_vector(conv_unsigned(value, width ), width);
	end if ;
	return temp;
	end int2ustd;
	
	type bfp_input_bus is array (0 to 3) of std_logic_vector(mpr-1 downto 0);
	signal r_array_in, i_array_in : bfp_input_bus;
	signal r_array_out, i_array_out : bfp_input_bus;
	
	-- Takes last calculated scaling from bpf_o and applies it to next block read from memory
	-- before permutation
	
	begin
	-- Unscaled Input
		r_array_in(0) <= real_bfp_0_in;
		r_array_in(1) <= real_bfp_1_in;
		r_array_in(2) <= real_bfp_2_in;
		r_array_in(3) <= real_bfp_3_in;
		i_array_in(0) <= imag_bfp_0_in;
		i_array_in(1) <= imag_bfp_1_in;
		i_array_in(2) <= imag_bfp_2_in;
		i_array_in(3) <= imag_bfp_3_in;
	-- Scaled Output	
		real_bfp_0_out <= r_array_out(0);
		real_bfp_1_out <= r_array_out(1);
		real_bfp_2_out <= r_array_out(2);
		real_bfp_3_out <= r_array_out(3);
		imag_bfp_0_out <= i_array_out(0);
		imag_bfp_1_out <= i_array_out(1);
		imag_bfp_2_out <= i_array_out(2);
		imag_bfp_3_out <= i_array_out(3);
-----------------------------------------------------------------------------------------------------
-- Block floating point scaling  (4-bit)
gen_4bit_bfp : if(fpr=4) generate
-----------------------------------------------------------------------------------------------------
-- Block floating point scaling  (4-bit) with pipeline
	apply_gain : process(clk,lut_in,i_array_in,r_array_in) is
	begin
		if(rising_edge(clk)) then
			case lut_in(2 downto 0) is
				when "000" =>
					for k in 0 to 3 loop
							r_array_out(k) <= r_array_in(k)(mpr-1 downto 0);
							i_array_out(k) <= i_array_in(k)(mpr-1 downto 0);
						end loop;
				when "001" =>
					for k in 0 to 3 loop
							r_array_out(k) <= r_array_in(k)(mpr-2 downto 0) & '0';
							i_array_out(k) <= i_array_in(k)(mpr-2 downto 0) & '0';
						end loop;
				when "010" =>
					for k in 0 to 3 loop
							r_array_out(k) <= r_array_in(k)(mpr-3 downto 0) & "00";
							i_array_out(k) <= i_array_in(k)(mpr-3 downto 0) & "00";
						end loop;
				when "011" =>
					for k in 0 to 3 loop
							r_array_out(k) <= r_array_in(k)(mpr-4 downto 0) & "000";
							i_array_out(k) <= i_array_in(k)(mpr-4 downto 0) & "000";
						end loop;
				when "100" =>
					for k in 0 to 3 loop
							r_array_out(k) <= r_array_in(k)(mpr-5 downto 0) & "0000";
							i_array_out(k) <= i_array_in(k)(mpr-5 downto 0) & "0000";
						end loop;
				when others =>
					for k in 0 to 3 loop
							r_array_out(k) <= (mpr-1 downto 0 => 'X');
							i_array_out(k) <= (mpr-1 downto 0 => 'X');
						end loop;
						
			end case;
		end if;
	end process apply_gain;

end generate gen_4bit_bfp;


  
  
end;