---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version   : $Version: 1.0 $ 
--  revision    : $Revision: 1.7 $ 
--  designer name   : $Author: djmoore $ 
--  company name    : altera corp.
--  company address : 101 innovation drive
--                      san jose, california 95134
--                      u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_1tdp_rom.vhd,v 1.7 2005/03/03 21:33:20 djmoore Exp $ 
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
-- Single Dual Port RAM contains odd and even twiddle factors
-- In the case of M512, due to single port access, the ROMS are broken up into odd and even banks
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 



entity asj_fft_1tdp_rom is
  generic(
            twr : integer :=20;
            twa : integer :=11;
            m512 : integer :=1;
            rfc1 : string :="rm.hex";
            rfc2 : string :="rm.hex";
            rfc3 : string :="rm.hex";
            rfs1 : string :="rm.hex";
            rfs2 : string :="rm.hex";
            rfs3 : string :="rm.hex"
          );
  port(     clk             : in std_logic;
            twade       : in std_logic_vector(twa-1 downto 0);
            twado       : in std_logic_vector(twa-1 downto 0);
            t1r       : out std_logic_vector(twr-1 downto 0);
            t1i       : out std_logic_vector(twr-1 downto 0)
      );
end asj_fft_1tdp_rom;

architecture syn of asj_fft_1tdp_rom is

begin
  

  gen_m512 : if(m512>0) generate
  
    sin_1ne : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs1
          )
    port map(
            address   => twade,
            clock     => clk,
            q   => t1i
    );
    
    sin_1no : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs1
          )
    port map(
            address   => twado,
            clock     => clk,
            q   => t1r
    );

    
  end generate gen_m512;
  
  gen_auto : if(m512=0) generate
  
    
    sin_1n : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 0,
            rf  =>rfs1
          )
    port map(
            address_a   => twade,
            address_b   => twado,
            clock     => clk,
            q_a   => t1i,
            q_b   => t1r
    );
    
  end generate gen_auto;
  
  


end;