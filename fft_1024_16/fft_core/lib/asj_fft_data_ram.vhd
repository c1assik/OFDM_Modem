---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.12 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_data_ram.vhd,v 1.12 2004/05/03 19:27:15 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

LIBRARY ieee;
USE ieee.std_logic_1164.all;

library fft_lib;
use fft_lib.fft_pack.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;


ENTITY asj_fft_data_ram IS
	GENERIC(	dpr : integer :=16;
						apr : integer :=8;
						rfd : string :="AUTO"
						
	);
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (dpr-1 DOWNTO 0);
		wren		: IN STD_LOGIC  := '1';
		rden    : IN STD_LOGIC  := '1';
		wraddress		: IN STD_LOGIC_VECTOR (apr-1 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (apr-1 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (dpr-1 DOWNTO 0)
	);
END asj_fft_data_ram;


ARCHITECTURE SYN OF asj_fft_data_ram IS

	signal sub_wire0	: std_logic_vector (dpr-1 downto 0);
	constant numw : integer :=2**apr;
	constant memtype : integer :=0;
	

--	COMPONENT altsyncram
--	GENERIC (
--		operation_mode		: STRING;
--		width_a		: NATURAL;
--		widthad_a		: NATURAL;
--		numwords_a		: NATURAL;
--		width_b		: NATURAL;
--		widthad_b		: NATURAL;
--		numwords_b		: NATURAL;
--		lpm_type		: STRING;
--		width_byteena_a		: NATURAL;
--		outdata_reg_b		: STRING;
--		indata_aclr_a		: STRING;
--		wrcontrol_aclr_a		: STRING;
--		address_aclr_a		: STRING;
--		address_reg_b		: STRING;
--		rdcontrol_reg_b		: STRING;
--		rdcontrol_aclr_b		: STRING;
--		address_aclr_b		: STRING;
--		outdata_aclr_b		: STRING;
--		read_during_write_mode_mixed_ports		: STRING;
--		ram_block_type		: STRING;
--		--init_file         : STRING;
--		--maximum_depth		: NATURAL;
--		intended_device_family		: STRING
--	);
--	PORT (
--			wren_a	: IN STD_LOGIC ;
--			--rden_b  : IN STD_LOGIC ;
--			clock0	: IN STD_LOGIC ;
--			address_a	: IN STD_LOGIC_VECTOR (apr-1 DOWNTO 0);
--			address_b	: IN STD_LOGIC_VECTOR (apr-1 DOWNTO 0);
--			q_b	: OUT STD_LOGIC_VECTOR (dpr-1 DOWNTO 0);
--			data_a	: IN STD_LOGIC_VECTOR (dpr-1 DOWNTO 0)
--	);
--	END COMPONENT;

BEGIN
		q(dpr-1 downto 0)    <= sub_wire0(dpr-1 DOWNTO 0);
		
	
gen_M4K : if(rfd="AUTO" or rfd="M4K") generate

	altsyncram_component : altsyncram
	GENERIC MAP (
		operation_mode => "DUAL_PORT",
		width_a => dpr,
		widthad_a => apr,
		numwords_a => numw,
		width_b => dpr,
		widthad_b => apr,
		numwords_b => numw,
		lpm_type => "altsyncram",
		width_byteena_a => 1,
		outdata_reg_b => "CLOCK0",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		address_reg_b => "CLOCK0",
		rdcontrol_reg_b => "CLOCK0",
		rdcontrol_aclr_b => "NONE",
		address_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		ram_block_type => rfd,
--		init_file => "",
--		maximum_depth => numw,
		intended_device_family => "Stratix"
	)
	PORT MAP (
		wren_a => wren,
	--	rden_b => rden,
		clock0 => clock,
		address_a => wraddress,
		address_b => rdaddress,
		data_a => data,
		q_b => sub_wire0
	);

end generate gen_M4K;

gen_Mega : if(rfd="M-RAM") generate

	altsyncram_component : altsyncram
	GENERIC MAP (
		operation_mode => "DUAL_PORT",
		width_a => dpr,
		widthad_a => apr,
		numwords_a => numw,
		width_b => dpr,
		widthad_b => apr,
		numwords_b => numw,
		lpm_type => "altsyncram",
		width_byteena_a => 1,
		outdata_reg_b => "CLOCK0",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		address_reg_b => "CLOCK0",
		rdcontrol_reg_b => "CLOCK0",
		rdcontrol_aclr_b => "NONE",
		address_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		ram_block_type => "M-RAM",
--		init_file => "",
--		maximum_depth => numw,
		intended_device_family => "Stratix"
	)
	PORT MAP (
		wren_a => wren,
		--rden_b => rden,
		clock0 => clock,
		address_a => wraddress,
		address_b => rdaddress,
		data_a => data,
		q_b => sub_wire0
	);

end generate gen_Mega;	
END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: VarWidth NUMERIC "0"
-- Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "32"
-- Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "32"
-- Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "32"
-- Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "32"
-- Retrieval info: PRIVATE: MEMSIZE NUMERIC "8192"
-- Retrieval info: PRIVATE: Clock NUMERIC "0"
-- Retrieval info: PRIVATE: rden NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE_A NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE_B NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
-- Retrieval info: PRIVATE: Clock_A NUMERIC "0"
-- Retrieval info: PRIVATE: Clock_B NUMERIC "0"
-- Retrieval info: PRIVATE: REGdata NUMERIC "1"
-- Retrieval info: PRIVATE: REGwraddress NUMERIC "1"
-- Retrieval info: PRIVATE: REGwren NUMERIC "1"
-- Retrieval info: PRIVATE: REGrdaddress NUMERIC "1"
-- Retrieval info: PRIVATE: REGrren NUMERIC "1"
-- Retrieval info: PRIVATE: REGq NUMERIC "0"
-- Retrieval info: PRIVATE: INDATA_REG_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRADDR_REG_B NUMERIC "0"
-- Retrieval info: PRIVATE: OUTDATA_REG_B NUMERIC "1"
-- Retrieval info: PRIVATE: CLRdata NUMERIC "0"
-- Retrieval info: PRIVATE: CLRwren NUMERIC "0"
-- Retrieval info: PRIVATE: CLRwraddress NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrdaddress NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrren NUMERIC "0"
-- Retrieval info: PRIVATE: CLRq NUMERIC "0"
-- Retrieval info: PRIVATE: BYTEENA_ACLR_A NUMERIC "0"
-- Retrieval info: PRIVATE: INDATA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRCTRL_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRADDR_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: OUTDATA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: BYTEENA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: enable NUMERIC "0"
-- Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_MIXED_PORTS NUMERIC "2"
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
-- Retrieval info: PRIVATE: MIFfilename STRING ""
-- Retrieval info: PRIVATE: UseLCs NUMERIC "0"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "256"
-- Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
-- Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "2"
-- Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "DUAL_PORT"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "32"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "8"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "256"
-- Retrieval info: CONSTANT: WIDTH_B NUMERIC "32"
-- Retrieval info: CONSTANT: WIDTHAD_B NUMERIC "8"
-- Retrieval info: CONSTANT: NUMWORDS_B NUMERIC "256"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
-- Retrieval info: CONSTANT: OUTDATA_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: INDATA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: WRCONTROL_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: READ_DURING_WRITE_MODE_MIXED_PORTS STRING "DONT_CARE"
-- Retrieval info: CONSTANT: RAM_BLOCK_TYPE STRING "AUTO"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: USED_PORT: data 0 0 32 0 INPUT NODEFVAL data[31..0]
-- Retrieval info: USED_PORT: wren 0 0 0 0 INPUT VCC wren
-- Retrieval info: USED_PORT: q 0 0 32 0 OUTPUT NODEFVAL q[31..0]
-- Retrieval info: USED_PORT: wraddress 0 0 8 0 INPUT NODEFVAL wraddress[7..0]
-- Retrieval info: USED_PORT: rdaddress 0 0 8 0 INPUT NODEFVAL rdaddress[7..0]
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: CONNECT: @data_a 0 0 32 0 data 0 0 32 0
-- Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 32 0 @q_b 0 0 32 0
-- Retrieval info: CONNECT: @address_a 0 0 8 0 wraddress 0 0 8 0
-- Retrieval info: CONNECT: @address_b 0 0 8 0 rdaddress 0 0 8 0
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all