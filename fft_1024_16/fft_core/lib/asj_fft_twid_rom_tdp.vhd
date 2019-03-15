---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.8 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_twid_rom_tdp.vhd,v 1.8 2004/06/07 23:36:49 djmoore Exp $ 
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

ENTITY asj_fft_twid_rom_tdp IS
	GENERIC(
						twr : integer := 16;
						twa : integer := 5;
						m512 : integer := 0;
						rf  : string  :="rf.hex"
	);
	PORT
	(
		clock		: IN STD_LOGIC ;
		address_a		: IN STD_LOGIC_VECTOR (twa-1 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (twa-1 DOWNTO 0);
		q_a		: OUT STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (twr-1 DOWNTO 0)
	);
END asj_fft_twid_rom_tdp;


ARCHITECTURE SYN OF asj_fft_twid_rom_tdp IS
  constant numw : integer :=2**twa;
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3_bv	: BIT_VECTOR (twr-1 DOWNTO 0);
	SIGNAL sub_wire3	: STD_LOGIC_VECTOR (twr-1 DOWNTO 0);

	constant mems : string :="AUTO";

	COMPONENT altsyncram
	GENERIC (
		width_byteena_a		: NATURAL;
		width_byteena_b		: NATURAL;
		outdata_reg_a		: STRING;
		outdata_aclr_a		: STRING;
		outdata_reg_b		: STRING;
		indata_aclr_a		: STRING;
		wrcontrol_aclr_a		: STRING;
		address_aclr_a		: STRING;
		indata_reg_b		: STRING;
		address_reg_b		: STRING;
		wrcontrol_wraddress_reg_b		: STRING;
		indata_aclr_b		: STRING;
		wrcontrol_aclr_b		: STRING;
		address_aclr_b		: STRING;
		outdata_aclr_b		: STRING;
		read_during_write_mode_mixed_ports		: STRING;
		ram_block_type		: STRING;
		init_file		: STRING;
		--maximum_depth		: NATURAL;
		intended_device_family		: STRING;
		operation_mode		: STRING;
		width_a		: NATURAL;
		widthad_a		: NATURAL;
		numwords_a		: NATURAL;
		width_b		: NATURAL;
		widthad_b		: NATURAL;
		numwords_b		: NATURAL;
		lpm_type		: STRING
	);
	PORT (
			wren_a	: IN STD_LOGIC ;
			wren_b	: IN STD_LOGIC ;
			clock0	: IN STD_LOGIC ;
			address_a	: IN STD_LOGIC_VECTOR (twa-1 DOWNTO 0);
			address_b	: IN STD_LOGIC_VECTOR (twa-1 DOWNTO 0);
			q_a	: OUT STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
			q_b	: OUT STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
			data_a	: IN STD_LOGIC_VECTOR (twr-1 DOWNTO 0);
			data_b	: IN STD_LOGIC_VECTOR (twr-1 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire2    <= '0';
	sub_wire3_bv(twr-1 DOWNTO 0) <= (twr-1 downto 0 =>'0');
	sub_wire3    <= To_stdlogicvector(sub_wire3_bv);
	q_a    <= sub_wire0(twr-1 DOWNTO 0);
	q_b    <= sub_wire1(twr-1 DOWNTO 0);
	
	
		altsyncram_component : altsyncram
		GENERIC MAP (
			width_byteena_a => 1,
			width_byteena_b => 1,
			outdata_reg_a => "CLOCK0",
			outdata_aclr_a => "NONE",
			outdata_reg_b => "CLOCK0",
			indata_aclr_a => "NONE",
			wrcontrol_aclr_a => "NONE",
			address_aclr_a => "NONE",
			indata_reg_b => "CLOCK0",
			address_reg_b => "CLOCK0",
			wrcontrol_wraddress_reg_b => "CLOCK0",
			indata_aclr_b => "NONE",
			wrcontrol_aclr_b => "NONE",
			address_aclr_b => "NONE",
			outdata_aclr_b => "NONE",
			read_during_write_mode_mixed_ports => "DONT_CARE",
			ram_block_type => mems,
			init_file => rf,
	--	maximum_depth => 256,
			intended_device_family => "Stratix",
  		operation_mode => "BIDIR_DUAL_PORT",
  		--operation_mode => "ROM",
			width_a => twr,
			widthad_a => twa,
			numwords_a => numw,
			width_b => twr,
			widthad_b => twa,
			numwords_b => numw,
			lpm_type => "altsyncram"
		)
		PORT MAP (
			wren_a => sub_wire2,
			wren_b => sub_wire2,
			clock0 => clock,
			address_a => address_a,
			address_b => address_b,
			data_a => sub_wire3,
			data_b => sub_wire3,
			q_a => sub_wire0,
			q_b => sub_wire1
		);
		
	
	


END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: Clock NUMERIC "0"
-- Retrieval info: PRIVATE: rden NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE_A NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE_B NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "1"
-- Retrieval info: PRIVATE: Clock_A NUMERIC "0"
-- Retrieval info: PRIVATE: Clock_B NUMERIC "0"
-- Retrieval info: PRIVATE: REGdata NUMERIC "1"
-- Retrieval info: PRIVATE: REGwraddress NUMERIC "1"
-- Retrieval info: PRIVATE: REGwren NUMERIC "1"
-- Retrieval info: PRIVATE: REGrdaddress NUMERIC "0"
-- Retrieval info: PRIVATE: REGrren NUMERIC "0"
-- Retrieval info: PRIVATE: REGq NUMERIC "1"
-- Retrieval info: PRIVATE: INDATA_REG_B NUMERIC "1"
-- Retrieval info: PRIVATE: WRADDR_REG_B NUMERIC "1"
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
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "0"
-- Retrieval info: PRIVATE: MIFfilename STRING "ddd.hex"
-- Retrieval info: PRIVATE: UseLCs NUMERIC "0"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "256"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
-- Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
-- Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "3"
-- Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: PRIVATE: VarWidth NUMERIC "0"
-- Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "16"
-- Retrieval info: PRIVATE: MEMSIZE NUMERIC "4096"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_B NUMERIC "1"
-- Retrieval info: CONSTANT: OUTDATA_REG_A STRING "CLOCK0"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: OUTDATA_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: INDATA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: WRCONTROL_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: INDATA_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: ADDRESS_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: WRCONTROL_WRADDRESS_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: INDATA_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: WRCONTROL_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: READ_DURING_WRITE_MODE_MIXED_PORTS STRING "DONT_CARE"
-- Retrieval info: CONSTANT: RAM_BLOCK_TYPE STRING "AUTO"
-- Retrieval info: CONSTANT: INIT_FILE STRING "ddd.hex"
-- Retrieval info: CONSTANT: MAXIMUM_DEPTH NUMERIC "256"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "BIDIR_DUAL_PORT"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "8"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "256"
-- Retrieval info: CONSTANT: WIDTH_B NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_B NUMERIC "8"
-- Retrieval info: CONSTANT: NUMWORDS_B NUMERIC "256"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: q_a 0 0 16 0 OUTPUT NODEFVAL q_a[15..0]
-- Retrieval info: USED_PORT: q_b 0 0 16 0 OUTPUT NODEFVAL q_b[15..0]
-- Retrieval info: USED_PORT: address_a 0 0 8 0 INPUT NODEFVAL address_a[7..0]
-- Retrieval info: USED_PORT: address_b 0 0 8 0 INPUT NODEFVAL address_b[7..0]
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @data_a 0 0 16 0 GND 0 0 16 0
-- Retrieval info: CONNECT: @wren_a 0 0 0 0 GND 0 0 0 0
-- Retrieval info: CONNECT: q_a 0 0 16 0 @q_a 0 0 16 0
-- Retrieval info: CONNECT: q_b 0 0 16 0 @q_b 0 0 16 0
-- Retrieval info: CONNECT: @address_a 0 0 8 0 address_a 0 0 8 0
-- Retrieval info: CONNECT: @address_b 0 0 8 0 address_b 0 0 8 0
-- Retrieval info: CONNECT: @data_b 0 0 16 0 GND 0 0 16 0
-- Retrieval info: CONNECT: @wren_b 0 0 0 0 GND 0 0 0 0
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all