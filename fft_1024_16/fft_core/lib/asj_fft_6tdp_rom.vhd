---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version   : $Version: 1.0 $ 
--  revision    : $Revision: 1.10 $ 
--  designer name   : $Author: djmoore $ 
--  company name    : altera corp.
--  company address : 101 innovation drive
--                      san jose, california 95134
--                      u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_6tdp_rom.vhd,v 1.10 2005/03/03 22:01:04 djmoore Exp $ 
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

-----------------------------------------------------------------------------------------------
-- Special 6-bank ROM  for 4 Quad-Output Engines in parallel
-- Each ROM holds alternating values of sine and cosine for n=1,2,3
-- Resource sharing "tricks" (read temporary storage)employed for cases 
-- where access to same banks is required during the same cycle
-----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- NB: M512 Mapping is a little confusing, for legacy reasons in the GUI code, 
-- that can and should be corrected.
-- m512 = {0,1,2,3} : m512 = 0 => 100% M4K 0% M512
--                    m512 = 1 => 0% M4K  100% M512
-- And just when you thought that made sense:
--                    m512 = 2 => 33% M4K  66% M512
--                    m512 = 3 => 66% M4K  33% M512
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
entity asj_fft_6tdp_rom is
  generic(
            twr : integer :=16;
            twa : integer :=10;
            m512 : integer :=3;
            rfc1e : string :="test_1ne256cos.hex";
            rfc2e : string :="test_2ne256cos.hex";
            rfc3e : string :="test_3ne256cos.hex";
            rfs1e : string :="test_1ne256sin.hex";
            rfs2e : string :="test_2ne256sin.hex";
            rfs3e : string :="test_3ne256sin.hex";
            rfc1o : string :="test_1ne256cos.hex";
            rfc2o : string :="test_2no256cos.hex";
            rfc3o : string :="test_3no256cos.hex";
            rfs1o : string :="test_1no256sin.hex";
            rfs2o : string :="test_2no256sin.hex";
            rfs3o : string :="test_3no256sin.hex"
          );
  port(     clk             : in std_logic;
            twade_0       : in std_logic_vector(twa-1 downto 0);
            twade_1       : in std_logic_vector(twa-1 downto 0);
            twado_0       : in std_logic_vector(twa-1 downto 0);
            twado_1       : in std_logic_vector(twa-1 downto 0);
            t1w       : out std_logic_vector(2*twr-1 downto 0);
            t2w       : out std_logic_vector(2*twr-1 downto 0);
            t3w       : out std_logic_vector(2*twr-1 downto 0);
            t1x       : out std_logic_vector(2*twr-1 downto 0);
            t2x       : out std_logic_vector(2*twr-1 downto 0);
            t3x       : out std_logic_vector(2*twr-1 downto 0);
            t1y       : out std_logic_vector(2*twr-1 downto 0);
            t2y       : out std_logic_vector(2*twr-1 downto 0);
            t3y       : out std_logic_vector(2*twr-1 downto 0);
            t1z       : out std_logic_vector(2*twr-1 downto 0);
            t2z       : out std_logic_vector(2*twr-1 downto 0);
            t3z       : out std_logic_vector(2*twr-1 downto 0)
      );
end asj_fft_6tdp_rom;

architecture syn of asj_fft_6tdp_rom is


signal twado_0_alt,twado_1_alt : std_logic_vector(twa-3 downto 0);

begin
  
    
  gen_dual_port : if(m512=0) generate 
  
    sin_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(twr-1 downto 0),
            q_b   => t1y(twr-1 downto 0)
    );
    
    sin_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(twr-1 downto 0),
            q_b   => t1z(twr-1 downto 0)
    );
    
    

    sin_2ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs2e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t2w(twr-1 downto 0),
            q_b   => t2y(twr-1 downto 0)
    );
    
    sin_2no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs2o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t2x(twr-1 downto 0),
            q_b   => t2z(twr-1 downto 0)
    );
    
    sin_3ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs3e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t3w(twr-1 downto 0),
            q_b   => t3y(twr-1 downto 0)
    );
    
    sin_3no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs3o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t3x(twr-1 downto 0),
            q_b   => t3z(twr-1 downto 0)
    );
    
    
    cos_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(2*twr-1 downto twr),
            q_b   => t1y(2*twr-1 downto twr)
    );
    
    cos_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(2*twr-1 downto twr),
            q_b   => t1z(2*twr-1 downto twr)
    );
    
    
    cos_2ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc2e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t2w(2*twr-1 downto twr),
            q_b   => t2y(2*twr-1 downto twr)
    );
    
    cos_2no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc2o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t2x(2*twr-1 downto twr),
            q_b   => t2z(2*twr-1 downto twr)
    );

    cos_3ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc3e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t3w(2*twr-1 downto twr),
            q_b   => t3y(2*twr-1 downto twr)
    );
    
    cos_3no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc3o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t3x(2*twr-1 downto twr),
            q_b   => t3z(2*twr-1 downto twr)
    );
  
  end generate gen_dual_port;
  -----------------------------------------------------------------------------------------------
  -- If M512's are to be used, then the ROM's must be single port
  -----------------------------------------------------------------------------------------------
  gen_single_port : if(m512=1) generate 
  
    sin_1ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs1e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t1w(twr-1 downto 0)
    );
    
    sin_1ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs1e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t1y(twr-1 downto 0)
    );
    
    sin_1no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs1o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t1x(twr-1 downto 0)
    );
    
    sin_1no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs1o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t1z(twr-1 downto 0)
    );
    
    sin_2ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs2e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t2w(twr-1 downto 0)
    );
    
    sin_2ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs2e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t2y(twr-1 downto 0)
    );
    
    sin_2no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs2o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t2x(twr-1 downto 0)
    );
    
    sin_2no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs2o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t2z(twr-1 downto 0)
    );
    
    sin_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(twr-1 downto 0)
    );
    
    sin_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(twr-1 downto 0)
    );
    
    sin_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(twr-1 downto 0)
    );
    
    sin_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfs3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(twr-1 downto 0)
    );
    
    cos_1ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc1e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t1w(2*twr-1 downto twr)
    );
    
    cos_1ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc1e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t1y(2*twr-1 downto twr)
    );
    
    cos_1no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc1o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t1x(2*twr-1 downto twr)
    );
    
    cos_1no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc1o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t1z(2*twr-1 downto twr)
    );
    
    cos_2ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc2e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t2w(2*twr-1 downto twr)
    );
    
    cos_2ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc2e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t2y(2*twr-1 downto twr)
    );
    
    cos_2no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc2o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t2x(2*twr-1 downto twr)
    );
    
    cos_2no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc2o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t2z(2*twr-1 downto twr)
    );
    
    cos_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(2*twr-1 downto twr)
    );
    
    cos_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(2*twr-1 downto twr)
    );
    
    cos_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(2*twr-1 downto twr)
    );
    
    cos_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => m512,
            rf  =>rfc3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(2*twr-1 downto twr)
    );
  end generate gen_single_port;
  
  --------------------------------------------------------------------------------
  -- One bank in M4K, 2 in M512
  -------------------------------------------------------------------------------
    
  gen_m4k_sgl : if(m512=2) generate 
  
    sin_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(twr-1 downto 0),
            q_b   => t1y(twr-1 downto 0)
    );
    
    sin_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(twr-1 downto 0),
            q_b   => t1z(twr-1 downto 0)
    );
    
    sin_2ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs2e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t2w(twr-1 downto 0)
    );
    
    sin_2ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs2e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t2y(twr-1 downto 0)
    );
    
    sin_2no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs2o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t2x(twr-1 downto 0)
    );
    
    sin_2no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs2o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t2z(twr-1 downto 0)
    );
    
    sin_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(twr-1 downto 0)
    );
    
    sin_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(twr-1 downto 0)
    );
    
    sin_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(twr-1 downto 0)
    );
    
    sin_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(twr-1 downto 0)
    );
    
    cos_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(2*twr-1 downto twr),
            q_b   => t1y(2*twr-1 downto twr)
    );
    
    cos_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(2*twr-1 downto twr),
            q_b   => t1z(2*twr-1 downto twr)
    );
    
    cos_2ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc2e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t2w(2*twr-1 downto twr)
    );
    
    cos_2ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc2e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t2y(2*twr-1 downto twr)
    );
    
    cos_2no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc2o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t2x(2*twr-1 downto twr)
    );
    
    cos_2no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc2o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t2z(2*twr-1 downto twr)
    );
    
    cos_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(2*twr-1 downto twr)
    );
    
    cos_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(2*twr-1 downto twr)
    );
    
    cos_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(2*twr-1 downto twr)
    );
    
    cos_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(2*twr-1 downto twr)
    );
  end generate gen_m4k_sgl;
  
  --------------------------------------------------------------------------------
  -- Two bank in M4K, 1 in M512
  -------------------------------------------------------------------------------
    
  gen_m4k_dbl : if(m512=3) generate 
  
    sin_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(twr-1 downto 0),
            q_b   => t1y(twr-1 downto 0)
    );
    
    sin_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(twr-1 downto 0),
            q_b   => t1z(twr-1 downto 0)
    );
    
  sin_2ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs2e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t2w(twr-1 downto 0),
            q_b   => t2y(twr-1 downto 0)
    );
    
    sin_2no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfs2o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t2x(twr-1 downto 0),
            q_b   => t2z(twr-1 downto 0)
    );
    
    sin_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(twr-1 downto 0)
    );
    
    sin_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(twr-1 downto 0)
    );
    
    sin_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(twr-1 downto 0)
    );
    
    sin_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfs3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(twr-1 downto 0)
    );
    
    cos_1ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t1w(2*twr-1 downto twr),
            q_b   => t1y(2*twr-1 downto twr)
    );
    
    cos_1no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc1o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t1x(2*twr-1 downto twr),
            q_b   => t1z(2*twr-1 downto twr)
    );
    
cos_2ne : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc2e
          )
    port map(
            address_a   => twade_0,
            address_b   => twade_1,
            clock     => clk,
            q_a   => t2w(2*twr-1 downto twr),
            q_b   => t2y(2*twr-1 downto twr)
    );
    
    cos_2no : asj_fft_twid_rom_tdp 
    generic map(
            twa => twa,
            twr => twr,
            rf  =>rfc2o
          )
    port map(
            address_a   => twado_0,
            address_b   => twado_1,
            clock     => clk,
            q_a   => t2x(2*twr-1 downto twr),
            q_b   => t2z(2*twr-1 downto twr)
    );
    
    cos_3ne_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3e
          )
    port map(
            address   => twade_0,
            clock     => clk,
            q   => t3w(2*twr-1 downto twr)
    );
    
    cos_3ne_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 =>1,
            rf  =>rfc3e
          )
    port map(
            address   => twade_1,
            clock     => clk,
            q   => t3y(2*twr-1 downto twr)
    );
    
    cos_3no_0 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3o
          )
    port map(
            address   => twado_0,
            clock     => clk,
            q   => t3x(2*twr-1 downto twr)
    );
    
    cos_3no_1 : twid_rom 
    generic map(
            twa => twa,
            twr => twr,
            m512 => 1,
            rf  =>rfc3o
          )
    port map(
            address   => twado_1,
            clock     => clk,
            q   => t3z(2*twr-1 downto twr)
    );
  end generate gen_m4k_dbl;
  
  
    

    
end;