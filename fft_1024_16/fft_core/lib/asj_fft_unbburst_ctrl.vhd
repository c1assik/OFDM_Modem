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
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_unbburst_ctrl.vhd,v 1.2 2003/07/16 14:54:18 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
entity asj_fft_unbburst_ctrl is
	generic(
						nps : integer :=256;
						mpr : integer :=16;
						apr : integer :=6;
						abuspr : integer :=24; --4*apr
						rbuspr : integer :=64; --4*mpr
						cbuspr : integer :=128 --2*4*mpr
					);
	port(			clk 						: in std_logic;
						sel_wraddr_in 	: in std_logic;
						sel_ram_in 			: in std_logic;
						sel_lpp         : in std_logic;
						data_rdy        : in std_logic;
						wraddr_i0_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr_i1_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr_i2_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr_i3_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr0_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr1_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr2_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr3_sw    : in std_logic_vector(apr-1 downto 0);
						rdaddr0_sw    : in std_logic_vector(apr-1 downto 0);
						rdaddr1_sw    : in std_logic_vector(apr-1 downto 0);
						rdaddr2_sw    : in std_logic_vector(apr-1 downto 0);
						rdaddr3_sw    : in std_logic_vector(apr-1 downto 0);
						lpp_rdaddr0_sw    : in std_logic_vector(apr-1 downto 0);
						lpp_rdaddr1_sw    : in std_logic_vector(apr-1 downto 0);
						lpp_rdaddr2_sw    : in std_logic_vector(apr-1 downto 0);
						lpp_rdaddr3_sw    : in std_logic_vector(apr-1 downto 0);
						ram_data_in0_sw  : in std_logic_vector(2*mpr-1 downto 0);
						ram_data_in1_sw  : in std_logic_vector(2*mpr-1 downto 0);
						ram_data_in2_sw  : in std_logic_vector(2*mpr-1 downto 0);
						ram_data_in3_sw  : in std_logic_vector(2*mpr-1 downto 0);
						i_ram_data_in0_sw  : in std_logic_vector(2*mpr-1 downto 0);
						i_ram_data_in1_sw  : in std_logic_vector(2*mpr-1 downto 0);
						i_ram_data_in2_sw  : in std_logic_vector(2*mpr-1 downto 0);
						i_ram_data_in3_sw  : in std_logic_vector(2*mpr-1 downto 0);
						a_ram_data_out_bus  : in std_logic_vector(cbuspr-1 downto 0);
						a_ram_data_in_bus  : out std_logic_vector(cbuspr-1 downto 0);
						wraddress_a_bus   : out std_logic_vector(abuspr-1 downto 0);
						rdaddress_a_bus   : out std_logic_vector(abuspr-1 downto 0);
						ram_data_out0    : out std_logic_vector(2*mpr-1 downto 0);
						ram_data_out1    : out std_logic_vector(2*mpr-1 downto 0);
						ram_data_out2    : out std_logic_vector(2*mpr-1 downto 0);
						ram_data_out3    : out std_logic_vector(2*mpr-1 downto 0)
						
			);
end asj_fft_unbburst_ctrl;

architecture burst_sw of asj_fft_unbburst_ctrl is

constant reg_a_b : integer :=1;

begin
	
	
input_address : process(clk,sel_wraddr_in,wraddr0_sw,wraddr1_sw,wraddr2_sw,wraddr3_sw,wraddr_i0_sw,wraddr_i1_sw,wraddr_i2_sw,wraddr_i3_sw) is
		begin
			if(rising_edge(clk)) then
				if(sel_wraddr_in='0') then
				  wraddress_a_bus <= wraddr_i0_sw & wraddr_i1_sw & wraddr_i2_sw & wraddr_i3_sw;
				else
				  wraddress_a_bus <= wraddr0_sw & wraddr1_sw & wraddr2_sw & wraddr3_sw; 
				end if;
			end if;
		end process input_address;
		
		
input_data : process(clk,sel_ram_in) is
		begin
			if(rising_edge(clk)) then
				if(sel_ram_in='0') then
						a_ram_data_in_bus <= i_ram_data_in0_sw & i_ram_data_in1_sw & i_ram_data_in2_sw & i_ram_data_in3_sw;
				else
						a_ram_data_in_bus <= ram_data_in0_sw & ram_data_in1_sw & ram_data_in2_sw & ram_data_in3_sw;
  			end if;
  		end if;
		end process input_data;
		
		
		
sel_ram_data : process(clk) is
		begin
			if(rising_edge(clk)) then
  			ram_data_out0 <= a_ram_data_out_bus(8*mpr-1 downto 6*mpr);
  			ram_data_out1 <= a_ram_data_out_bus(6*mpr-1 downto 4*mpr);
  			ram_data_out2 <= a_ram_data_out_bus(4*mpr-1 downto 2*mpr);
  			ram_data_out3 <= a_ram_data_out_bus(2*mpr-1 downto 0);
  		end if;
		end process sel_ram_data;
		
	sel_ram_addr : process(clk,sel_lpp) is
		begin
			if(rising_edge(clk)) then
				if(sel_lpp='0') then
  		 		rdaddress_a_bus <= rdaddr0_sw & rdaddr1_sw & rdaddr2_sw & rdaddr3_sw;
  		 	else
  		 		rdaddress_a_bus <= lpp_rdaddr0_sw & lpp_rdaddr1_sw & lpp_rdaddr2_sw & lpp_rdaddr3_sw;
  		 	end if;
  		end if;
		end process sel_ram_addr;

  
end burst_sw;