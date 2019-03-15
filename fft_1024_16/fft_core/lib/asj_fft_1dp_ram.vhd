---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version             : $Version:     1.0 $ 
--  revision            : $Revision: 1.6 $ 
--  designer name       : $Author: djmoore $ 
--  company name        : altera corp.
--  company address     : 101 innovation drive
--                        san jose, california 95134
--                        u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_1dp_ram.vhd,v 1.6 2005/03/01 00:38:05 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-----------------------------------------------------------------------------------
-- Single Bank of Data RAM for simgle output engine variations
-- storing a real/imaginary complex data element pair
-- No special handling required for MRAM
-----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all; 
library fft_lib;
use fft_lib.fft_pack.all;
--use fft_lib.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity asj_fft_1dp_ram is
        generic(
                apr : integer :=14;
                mpr : integer :=16;
                rfd  : string :="M-RAM"
        );
        port(
                clk             : in std_logic;
                rdaddress       : in std_logic_vector(apr-1 downto 0);
                wraddress       : in std_logic_vector(apr-1 downto 0);
                data_in         : in std_logic_vector(2*mpr-1 downto 0);
                wren            : in std_logic;
                rden            : in std_logic;
                data_out        : out std_logic_vector(2*mpr-1 downto 0)
        );
end asj_fft_1dp_ram;

architecture syn of asj_fft_1dp_ram is

constant dpr : integer := 2*mpr;

signal wren_a : std_logic;
signal rden_a : std_logic;

begin
        
wren_a <= wren;
rden_a <= rden;
                        
dat_A : asj_fft_data_ram
generic map(
        apr => apr,
        dpr => dpr,
        rfd => rfd
)
port map(
        rdaddress => rdaddress,
        data      => data_in,
        wraddress => wraddress,
        wren      => wren_a,
        rden      => rden_a,
        clock     => clk,
        q         => data_out
);

end;