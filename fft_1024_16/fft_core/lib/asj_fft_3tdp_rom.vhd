---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.13 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_3tdp_rom.vhd,v 1.13 2005/03/03 22:01:04 djmoore Exp $ 
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
-- 3-bank Dual Port ROM used in all Dual-Engine variations to use the doubled bandwidth for M4K
-- For cases where the ROM is distributed across M512, and ROM is single port, the access is split across 
-- two individual banks (odd and even) with single port access to each
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- NB: Mapping is a little confusing, for legacy reasons in the GUI code, 
-- that can and should be corrected.
-- m512 = {0,1,2,3} : m512 = 0 => 100% M4K 0% M512
--                    m512 = 1 => 0% M4K  100% M512
-- And just when you thought that made sense:
--                    m512 = 2 => 33% M4K  66% M512
--                    m512 = 3 => 66% M4K  33% M512
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

entity asj_fft_3tdp_rom is
	generic(
						twr : integer :=16;
						twa : integer :=11;
						m512 : integer :=3;
						rfc1 : string :="rm.hex";
						rfc2 : string :="rm.hex";
						rfc3 : string :="rm.hex";
						rfs1 : string :="rm.hex";
						rfs2 : string :="rm.hex";
						rfs3 : string :="rm.hex"
					);
	port(			clk 						: in std_logic;
						twade   	  : in std_logic_vector(twa-1 downto 0);
						twado   	  : in std_logic_vector(twa-1 downto 0);
						t1re				: out std_logic_vector(twr-1 downto 0);
						t2re				: out std_logic_vector(twr-1 downto 0);
						t3re				: out std_logic_vector(twr-1 downto 0);
						t1ie				: out std_logic_vector(twr-1 downto 0);
						t2ie				: out std_logic_vector(twr-1 downto 0);
						t3ie				: out std_logic_vector(twr-1 downto 0);
						t1ro				: out std_logic_vector(twr-1 downto 0);
						t2ro				: out std_logic_vector(twr-1 downto 0);
						t3ro				: out std_logic_vector(twr-1 downto 0);
						t1io				: out std_logic_vector(twr-1 downto 0);
						t2io				: out std_logic_vector(twr-1 downto 0);
						t3io				: out std_logic_vector(twr-1 downto 0)
			);
end asj_fft_3tdp_rom;

architecture syn of asj_fft_3tdp_rom is
constant merge : integer :=0;
type twiddle_data_bus	is array (0 to 2) of std_logic_vector(2*twr-1 downto 0);
signal odd_value : twiddle_data_bus;
signal even_value : twiddle_data_bus;
	


begin
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- gen_auto : 100%M4K (All Dual Port ROMs
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	gen_auto : if(m512=0) generate
		
		sin_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfs1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1ie,
						q_b		=> t1io
		);
		
    sin_2n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfs2
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t2ie,
						q_b		=> t2io
		);
		
    sin_3n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfs3
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t3ie,
						q_b		=> t3io
		);
		
		cos_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfc1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1re,
						q_b		=> t1ro
		);
		
    cos_2n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfc2
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t2re,
						q_b		=> t2ro
		);
		
    cos_3n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => m512,
						rf  =>rfc3
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t3re,
						q_b		=> t3ro
		);
	end generate gen_auto;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- gen_m512 : 100%M512 (All Single Port ROMs)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	
	gen_m512 : if(m512=1) generate
	
		sin_1ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs1
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t1ie
			);
	
		sin_1no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs1
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t1io
			);
			
		sin_2ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs2
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t2ie
			);
	
		sin_2no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs2
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t2io
			);
		
		sin_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3ie
			);
	
		sin_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfs3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3io
			);	
			
		cos_1ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc1
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t1re
			);
	
		cos_1no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc1
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t1ro
			);
			
		cos_2ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc2
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t2re
			);
	
		cos_2no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc2
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t2ro
			);
		
		cos_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3re
			);
	
		cos_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => m512,
							rf  =>rfc3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3ro
			);		
		end generate gen_m512;
	-----------------------------------------------------------------------------------------------
	-- gen_M4K_sgl
	-- 1 ROM Bank in M4K/AUTO
	-- 2 ROM Banks in M512
	-----------------------------------------------------------------------------------------------	
	gen_M4K_sgl : if(m512=2) generate
	
		sin_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfs1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1ie,
						q_b		=> t1io
		);

			
		sin_2ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs2
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t2ie
			);
	
		sin_2no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs2
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t2io
			);
		
		sin_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3ie
			);
	
		sin_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3io
			);	
			
		cos_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfc1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1re,
						q_b		=> t1ro
		);
			
		cos_2ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc2
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t2re
			);
	
		cos_2no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc2
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t2ro
			);
		
		cos_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3re
			);
	
		cos_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3ro
			);		
		end generate gen_M4K_sgl;
	
	-----------------------------------------------------------------------------------------------
	-- gen_M4K_dbl
	-- 2 ROM Banks in M4K/AUTO
	-- 1 ROM Banks in M512
	-----------------------------------------------------------------------------------------------
	
	gen_M4K_dbl : if(m512=3) generate
	
		sin_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfs1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1ie,
						q_b		=> t1io
		);

			
		sin_2n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfs2
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t2ie,
						q_b		=> t2io
		);
		
		sin_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3ie
			);
	
		sin_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfs3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3io
			);	
			
		cos_1n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfc1
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t1re,
						q_b		=> t1ro
		);
			
		cos_2n : asj_fft_twid_rom_tdp 
		generic map(
						twa => twa,
						twr => twr,
						m512 => 0,
						rf  =>rfc2
					)
		port map(
						address_a		=> twade,
						address_b		=> twado,
						clock		  => clk,
						q_a		=> t2re,
						q_b		=> t2ro
		);
		
		cos_3ne : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc3
						)
			port map(
							address		=> twade,
							clock		  => clk,
							q		=> t3re
			);
	
		cos_3no : twid_rom 
			generic map(
							twa => twa,
							twr => twr,
							m512 => 1,
							rf  =>rfc3
						)
			port map(
							address		=> twado,
							clock		  => clk,
							q		=> t3ro
			);		
		end generate gen_M4K_dbl;

end;