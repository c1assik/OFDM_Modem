----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  version		: $Version:	1.0 $
--  revision		: $Revision: 1.15 $
--  designer name  	: $Author: djmoore $
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
--
--  copyright altera corp. 2003
--
--
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_3dp_rom.vhd,v 1.15 2005/03/03 21:40:59 djmoore Exp $
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
-- Standard 3-bank Single Port ROM for twiddle factor storage for Quad-output FFT Engine
-- Stores 1n,2n,3n.
-- For the case of M512 usage, the banks are put to M512 by setting the generic M512=1
-- Allows for distribution of ROMs between M4K and M512 according to the following distribution
-- 100 % M4K, 66% M4K, 33% M4K 0 % M4K
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

entity asj_fft_3dp_rom is
generic(
          twr : integer :=18;
          twa : integer :=10;
          m512 : integer :=1;
          rfc1 : string :="rm.hex";
          rfc2 : string :="rm.hex";
          rfc3 : string :="rm.hex";
          rfs1 : string :="rm.hex";
          rfs2 : string :="rm.hex";
          rfs3 : string :="rm.hex"
);
port(			clk 						: in std_logic;
          twad   	  : in std_logic_vector(twa-1 downto 0);
          t1r				: out std_logic_vector(twr-1 downto 0);
          t2r				: out std_logic_vector(twr-1 downto 0);
          t3r				: out std_logic_vector(twr-1 downto 0);
          t1i				: out std_logic_vector(twr-1 downto 0);
          t2i				: out std_logic_vector(twr-1 downto 0);
          t3i				: out std_logic_vector(twr-1 downto 0)
);
end asj_fft_3dp_rom;

architecture syn of asj_fft_3dp_rom is

begin

	gen_M4K : if(m512=0) generate

	sin_1n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfs1
	)
	port map(
  	address		=> twad,
  	clock		  => clk,
  	q		=> t1i
	);

	sin_2n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfs2
	)
	port map(
  	address		=> twad,
  	clock		  => clk,
  	q		=> t2i
	);

	sin_3n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfs3
	)
	port map(
  	address		=> twad,
  	clock		  => clk,
  	q		=> t3i
	);

	cos_1n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfc1
	)
	port map(
  	address		=> twad,
  	clock		  => clk,
  	q		=> t1r
	);

	cos_2n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfc2
	)
	port map(
  	address		=> twad,
  	clock		  => clk,
  	q		=> t2r
	);

	cos_3n : twid_rom
	generic map(
  	twa => twa,
  	twr => twr,
  	m512 => m512,
  	rf  =>rfc3
	)
	port map(
	address		=> twad,
	clock		  => clk,
	q		=> t3r
	);

end generate gen_M4K;

gen_m512 : if(m512=1) generate

  sin_1n : twid_rom
  generic map(
    twa => twa,
    twr => twr,
    m512 => m512,
    rf  =>rfs1
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		=> t1i
  );
  
  sin_2n : twid_rom
  generic map(
    twa => twa,
    twr => twr,
    m512 => m512,
    rf  =>rfs2
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		=> t2i
  );
  
  sin_3n : twid_rom
  generic map(
    twa => twa,
    twr => twr,
    m512 => m512,
    rf  =>rfs3
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		=> t3i
  );
  
  cos_1n : twid_rom
  generic map(
    twa => twa,
    twr => twr,
    m512 => m512,
    rf  =>rfc1
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		=> t1r
  );
  
  cos_2n : twid_rom
  generic map(
    twa => twa,
    twr => twr,
    m512 => m512,
    rf  =>rfc2
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		      => t2r
  );
  
  cos_3n : twid_rom
  generic map(
    twa   => twa,
    twr   => twr,
    m512  => m512,
    rf    =>rfc3
  )
  port map(
    address		=> twad,
    clock		  => clk,
    q		      => t3r
  );

end generate gen_m512;
-----------------------------------------------------------------------------------------------
-- 1 Bank in M4K
-- 2 in M512
-----------------------------------------------------------------------------------------------
gen_M4K_sgl : if(m512=2) generate

sin_1n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfs1
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t1i
);

sin_2n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfs2
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t2i
);

sin_3n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfs3
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t3i
);

cos_1n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfc1
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t1r
);

cos_2n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfc2
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t2r
);

cos_3n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfc3
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t3r
);

end generate gen_M4K_sgl;


gen_M4K_dbl : if(m512=3) generate

sin_1n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfs1
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t1i
);

sin_2n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfs2
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t2i
);

sin_3n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfs3
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t3i
);

cos_1n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfc1
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t1r
);

cos_2n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 0,
  rf  =>rfc2
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t2r
);

cos_3n : twid_rom
generic map(
  twa => twa,
  twr => twr,
  m512 => 1,
  rf  =>rfc3
)
port map(
  address		=> twad,
  clock		  => clk,
  q		=> t3r
);

end generate gen_M4K_dbl;


end;
