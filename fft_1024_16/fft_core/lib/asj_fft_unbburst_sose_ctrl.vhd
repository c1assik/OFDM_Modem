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
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_unbburst_sose_ctrl.vhd,v 1.7 2004/06/03 23:15:35 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Single Output Engine
-- Burst Architecture switch central control
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

entity asj_fft_unbburst_sose_ctrl is
	generic(
						nps : integer :=256;
						mpr : integer :=16;
						apr : integer :=6;
						nume : integer :=1;
						abuspr : integer :=24; --4*apr
						rbuspr : integer :=64; --4*mpr
						cbuspr : integer :=128 --2*4*mpr
					);
	port(			clk 						: in std_logic;
						sel_wraddr_in 	: in std_logic;
						sel_ram_in 			: in std_logic;
						sel_lpp         : in std_logic;
						sel_lpp_nm1     : in std_logic;
						data_rdy        : in std_logic;
						wraddr_i_sw    : in std_logic_vector(apr-1 downto 0);
						wraddr_sw    : in std_logic_vector(nume*apr-1 downto 0);
						rdaddr_sw    : in std_logic_vector(nume*apr-1 downto 0);
						lpp_rdaddr_sw    : in std_logic_vector(apr-1 downto 0);
						ram_data_in_sw  : in std_logic_vector(2*nume*mpr-1 downto 0);
						i_ram_data_in_sw  : in std_logic_vector(2*mpr-1 downto 0);
						a_ram_data_out_bus  : in std_logic_vector(2*nume*mpr-1 downto 0);
						a_ram_data_in_bus  : out std_logic_vector(2*nume*mpr-1 downto 0);
						wraddress_a_bus   : out std_logic_vector(nume*apr-1 downto 0);
						rdaddress_a_bus   : out std_logic_vector(nume*apr-1 downto 0);
						ram_data_out    : out std_logic_vector(2*nume*mpr-1 downto 0)
			);
end asj_fft_unbburst_sose_ctrl;

architecture burst_sw of asj_fft_unbburst_sose_ctrl is

constant reg_a_b : integer :=1;
-- last_pass_radix = 0 => radix 4
-- last_pass_radix = 1 => radix 2
constant last_pass_radix : integer :=(LOG4_CEIL(nps))-(LOG4_FLOOR(nps));
signal lpi_cnt : std_logic_vector(1 downto 0);
signal switch_ram_input : std_logic;
signal real_1  : std_logic_vector(mpr-1 downto 0);
signal real_2  : std_logic_vector(mpr-1 downto 0);

begin
	
	

		
-----------------------------------------------------------------------------------------------
-- Single Output
-----------------------------------------------------------------------------------------------
gen_se_i_buf : if(nume=1) generate

--wraddress_a_bus <=(others=>'0');

input_address : process(clk,sel_wraddr_in,wraddr_sw,wraddr_i_sw) is
		begin
			if(rising_edge(clk)) then
				if(sel_wraddr_in='0') then
				  wraddress_a_bus <= wraddr_i_sw;
				else
				  wraddress_a_bus <= wraddr_sw; 
				end if;
			end if;
		end process input_address;

input_data : process(clk,sel_ram_in) is
		begin
			if(rising_edge(clk)) then
				if(sel_ram_in='0') then
						a_ram_data_in_bus <= i_ram_data_in_sw;
				else
						a_ram_data_in_bus <= ram_data_in_sw;
  			end if;
  		end if;
		end process input_data;
end generate gen_se_i_buf;
-----------------------------------------------------------------------------------------------
-- Dual Ouput
-----------------------------------------------------------------------------------------------
gen_de_i_buf : if(nume=2) generate

input_address : process(clk,sel_wraddr_in,wraddr_sw,wraddr_i_sw) is
		begin
			if(rising_edge(clk)) then
				if(sel_wraddr_in='0') then
				  wraddress_a_bus <= wraddr_i_sw & wraddr_i_sw;
				else
				  wraddress_a_bus <= wraddr_sw; 
				end if;
			end if;
		end process input_address;
-----------------------------------------------------------------------------------------------
-- Every four cycles switch data banks that input data is sent to
-- Allows for LPP serial processing
-----------------------------------------------------------------------------------------------
switch_ram_input <= sel_lpp_nm1 and wraddr_sw(1);

input_data : process(clk,sel_ram_in) is
		begin
			if(rising_edge(clk)) then
				if(sel_ram_in='0') then
						a_ram_data_in_bus <= i_ram_data_in_sw & i_ram_data_in_sw;
				else
					if(switch_ram_input='1') then
						a_ram_data_in_bus(4*mpr-1 downto 2*mpr) <= ram_data_in_sw(2*mpr-1 downto 0);
						a_ram_data_in_bus(2*mpr-1 downto 0) <= ram_data_in_sw(4*mpr-1 downto 2*mpr);
					else
						a_ram_data_in_bus <= ram_data_in_sw;
					end if;
  			end if;
  		end if;
		end process input_data;
end generate gen_de_i_buf;
-----------------------------------------------------------------------------------------------
-- Single Output
-----------------------------------------------------------------------------------------------
gen_se_ro : if(nume=1) generate
	sel_ram_data : process(clk) is
		begin
			if(rising_edge(clk)) then
  			ram_data_out <= a_ram_data_out_bus;
  		end if;
		end process sel_ram_data;
		
end generate gen_se_ro;
-----------------------------------------------------------------------------------------------
-- Dual Ouptut
-----------------------------------------------------------------------------------------------
gen_de_ro : if(nume=2) generate

	-----------------------------------------------------------------------------------------------
	-- Radix 4 Last Pass
	-----------------------------------------------------------------------------------------------
	gen_r4_sel : if(last_pass_radix=0) generate
		sel_ram_data : process(clk,lpi_cnt,sel_lpp) is
			begin
				if(rising_edge(clk)) then
					if(sel_lpp='0') then
						ram_data_out <= a_ram_data_out_bus;
						lpi_cnt<="11";
					else
						lpi_cnt<=lpi_cnt+int2ustd(1,2);
						if(lpi_cnt(0)='1') then
							real_1 <= a_ram_data_out_bus(4*mpr-1 downto 3*mpr);
	  					real_2 <= a_ram_data_out_bus(2*mpr-1 downto mpr);
	  					ram_data_out <= a_ram_data_out_bus;
							
						else
							real_1 <= a_ram_data_out_bus(4*mpr-1 downto 3*mpr);
	  					real_2 <= a_ram_data_out_bus(2*mpr-1 downto mpr);
							ram_data_out(4*mpr-1 downto 2*mpr) <=a_ram_data_out_bus(2*mpr-1 downto 0);
							ram_data_out(2*mpr-1 downto 0) <=a_ram_data_out_bus(4*mpr-1 downto 2*mpr);
	
						end if;
	  			end if;	
	  		end if;
		end process sel_ram_data;
	end generate gen_r4_sel;
	-----------------------------------------------------------------------------------------------
	-- Radix 2 Last Pass
	-----------------------------------------------------------------------------------------------
	gen_r2_sel : if(last_pass_radix=1) generate
		sel_ram_data : process(clk,lpi_cnt,sel_lpp) is
			begin
				if(rising_edge(clk)) then
					if(sel_lpp='0') then
						ram_data_out <= a_ram_data_out_bus;
						lpi_cnt<="00";
					else
						lpi_cnt<=lpi_cnt+int2ustd(1,2);
						if(lpi_cnt(1)='0') then
							real_1 <= a_ram_data_out_bus(4*mpr-1 downto 3*mpr);
	  					real_2 <= a_ram_data_out_bus(2*mpr-1 downto mpr);
	  					ram_data_out <= a_ram_data_out_bus;
						
						else
							real_1 <= a_ram_data_out_bus(4*mpr-1 downto 3*mpr);
	  					real_2 <= a_ram_data_out_bus(2*mpr-1 downto mpr);
							ram_data_out(4*mpr-1 downto 2*mpr) <=a_ram_data_out_bus(2*mpr-1 downto 0);
							ram_data_out(2*mpr-1 downto 0) <=a_ram_data_out_bus(4*mpr-1 downto 2*mpr);
	          
						end if;
	  			end if;	
	  		end if;
		end process sel_ram_data;
	end generate gen_r2_sel;
		
end generate gen_de_ro;
-----------------------------------------------------------------------------------------------

		
		
		
	sel_ram_addr : process(clk,sel_lpp) is
		begin
			if(rising_edge(clk)) then
  		 		rdaddress_a_bus <= rdaddr_sw;
  		end if;
		end process sel_ram_addr;

  
end burst_sw;