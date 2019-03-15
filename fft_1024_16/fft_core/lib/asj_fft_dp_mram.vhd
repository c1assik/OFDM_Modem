---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.3 $ 
--  designer name  	: $Author: djmoore $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_dp_mram.vhd,v 1.3 2004/04/08 19:48:31 djmoore Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- megafunction wizard: %ALTSYNCRAM%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altsyncram 

-- ============================================================
-- File Name: asj_fft_dp_mram.vhd
-- Megafunction Name(s):
-- 			altsyncram
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
-- ************************************************************


--Copyright (C) 1991-2003 Altera Corporation
--Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
--support information,  device programming or simulation file,  and any other
--associated  documentation or information  provided by  Altera  or a partner
--under  Altera's   Megafunction   Partnership   Program  may  be  used  only
--to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
--other  use  of such  megafunction  design,  netlist,  support  information,
--device programming or simulation file,  or any other  related documentation
--or information  is prohibited  for  any  other purpose,  including, but not
--limited to  modification,  reverse engineering,  de-compiling, or use  with
--any other  silicon devices,  unless such use is  explicitly  licensed under
--a separate agreement with  Altera  or a megafunction partner.  Title to the
--intellectual property,  including patents,  copyrights,  trademarks,  trade
--secrets,  or maskworks,  embodied in any such megafunction design, netlist,
--support  information,  device programming or simulation file,  or any other
--related documentation or information provided by  Altera  or a megafunction
--partner, remains with Altera, the megafunction partner, or their respective
--licensors. No other licenses, including any licenses needed under any third
--party's intellectual property, are provided herein.


library ieee;
use ieee.std_logic_1164.all;
library fft_lib;
use fft_lib.fft_pack.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity asj_fft_dp_mram is
	generic(
					dpr : integer :=128;
					apr : integer :=9
					);
	port
	(
		data		: in std_logic_vector (dpr-1 downto 0);
		wren		: in std_logic  := '1';
		wraddress		: in std_logic_vector (apr-1 downto 0);
		rdaddress		: in std_logic_vector (apr-1 downto 0);
		clock		: in std_logic ;
		q		: out std_logic_vector (dpr-1 downto 0)
	);
end asj_fft_dp_mram;


architecture syn of asj_fft_dp_mram is

	signal sub_wire0	: std_logic_vector (dpr-1 downto 0);



	component altsyncram
	generic (
		operation_mode		: STRING;
		width_a		: NATURAL;
		widthad_a		: NATURAL;
		numwords_a		: NATURAL;
		width_b		: NATURAL;
		widthad_b		: NATURAL;
		numwords_b		: NATURAL;
		lpm_type		: STRING;
		width_byteena_a		: NATURAL;
		outdata_reg_b		: STRING;
		indata_aclr_a		: STRING;
		wrcontrol_aclr_a		: STRING;
		address_aclr_a		: STRING;
		address_reg_b		: STRING;
		address_aclr_b		: STRING;
		outdata_aclr_b		: STRING;
		read_during_write_mode_mixed_ports		: STRING;
		ram_block_type		: STRING;
		intended_device_family		: STRING
	);
	port (
			wren_a	: in std_logic ;
			clock0	: in std_logic ;
			address_a	: in std_logic_vector (apr-1 downto 0);
			address_b	: in std_logic_vector (apr-1 downto 0);
			q_b	: out std_logic_vector (dpr-1 downto 0);
			data_a	: in std_logic_vector (dpr-1 downto 0)
	);
	end component;

begin
	q    <= sub_wire0(dpr-1 downto 0);

	altsyncram_component : altsyncram
	generic map (
		operation_mode => "DUAL_PORT",
		width_a => dpr,
		widthad_a => apr,
		numwords_a => 2**apr,
		width_b => dpr,
		widthad_b => apr,
		numwords_b => 2**apr,
		lpm_type => "altsyncram",
		width_byteena_a => 1,
		outdata_reg_b => "CLOCK0",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		address_reg_b => "CLOCK0",
		address_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		ram_block_type => "M-RAM",
		intended_device_family => "Stratix"
	)
	port map (
		wren_a => wren,
		clock0 => clock,
		address_a => wraddress,
		address_b => rdaddress,
		data_a => data,
		q_b => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: VarWidth NUMERIC "0"
-- Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "16"
-- Retrieval info: PRIVATE: MEMSIZE NUMERIC "16384"
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
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "3"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_B"
-- Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
-- Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "2"
-- Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "DUAL_PORT"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "10"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "1024"
-- Retrieval info: CONSTANT: WIDTH_B NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_B NUMERIC "10"
-- Retrieval info: CONSTANT: NUMWORDS_B NUMERIC "1024"
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
-- Retrieval info: CONSTANT: RAM_BLOCK_TYPE STRING "M-RAM"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: USED_PORT: data 0 0 16 0 INPUT NODEFVAL data[15..0]
-- Retrieval info: USED_PORT: wren 0 0 0 0 INPUT VCC wren
-- Retrieval info: USED_PORT: q 0 0 16 0 OUTPUT NODEFVAL q[15..0]
-- Retrieval info: USED_PORT: wraddress 0 0 10 0 INPUT NODEFVAL wraddress[9..0]
-- Retrieval info: USED_PORT: rdaddress 0 0 10 0 INPUT NODEFVAL rdaddress[9..0]
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: CONNECT: @data_a 0 0 16 0 data 0 0 16 0
-- Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 16 0 @q_b 0 0 16 0
-- Retrieval info: CONNECT: @address_a 0 0 10 0 wraddress 0 0 10 0
-- Retrieval info: CONNECT: @address_b 0 0 10 0 rdaddress 0 0 10 0
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all