------------------------------------------------------------------------------------------------------------------------
----------------------------------------
------------------------------------------
--  version   : $Version: 1.0 $
--  revision    : $Revision: 1.40 $
--  designer name   : $Author: djmoore $
--  company name    : altera corp.
--  company address : 101 innovation drive
--                      san jose, california 95134
--                      u.s.a.
--
--  copyright altera corp. 2003
--
--
--  $Header: /ipbu/cvs/dsp/projects/fft/source/vhdl/asj_fft_bfp_ctrl.vhd,v 1.40 2005/03/24 02:47:28 djmoore Exp $
--  $log$
------------------------------------------------------------------------------------------------------------------------

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library fft_lib;
use fft_lib.fft_pack.all;


entity asj_fft_bfp_ctrl is
    generic (
             nps : integer :=1024;
             nume : integer :=2;
             fpr : integer := 4;
             cont : integer :=0;
             arch : integer :=1
    );
    port (
         clk           : in std_logic;
         clken         : in std_logic;
         reset         : in std_logic;
         next_pass     : in std_logic;
         next_blk      : in std_logic;
         exp_en        : in std_logic;
         alt_slb_i       : in std_logic_vector(3*nume-1 downto 0);
         alt_slb_o       : out std_logic_vector(2 downto 0);
         blk_exp_o     : out std_logic_vector(fpr+1 downto 0)
         );
end asj_fft_bfp_ctrl;

architecture syn of asj_fft_bfp_ctrl is

  function sgn_ex(inval : std_logic_vector; w : integer; b : integer) return std_logic_vector is
  -- sign extend input std_logic_vector of width w by b bits
  variable temp :   std_logic_vector(w+b-1 downto 0);
  begin
    temp(w+b-1 downto w-1):=(w+b-1 downto w-1 => inval(w-1));
    temp(w-2 downto 0) := inval(w-2 downto 0);
  return temp;
  end sgn_ex;

  function int2ustd(value : integer; width : integer) return std_logic_vector is
  -- convert integer to unsigned std_logicvector
  variable temp :   std_logic_vector(width-1 downto 0);
  begin
  if (width>0) then
      temp:=conv_std_logic_vector(conv_unsigned(value, width ), width);
  end if ;
  return temp;
  end int2ustd;

  -- last_pass_radix = 0 => radix 4
  -- last_pass_radix = 1 => radix 2
  constant last_pass_radix : integer :=(LOG4_CEIL(nps))-(LOG4_FLOOR(nps));
  constant n_passes : integer := LOG4_CEIL(nps);
	constant blk_exp_init    : integer :=(-3*(n_passes-1))-2+last_pass_radix;
	constant blk_exp_init_sgl    : integer :=(-3*n_passes)+last_pass_radix;


  -- Split alt_slb_i into distinct vector and get max first


  signal slb_w             : std_logic_vector(2 downto 0);
  signal slb_x             : std_logic_vector(2 downto 0);
  signal slb_y             : std_logic_vector(2 downto 0);
  signal slb_z             : std_logic_vector(2 downto 0);

  signal slb_st1x          : std_logic_vector(2 downto 0);
  signal slb_st1y          : std_logic_vector(2 downto 0);


  signal slb_last          : std_logic_vector(2 downto 0);
  signal slb_x_accum       : std_logic_vector(2 downto 0);

  signal last_slb_1pt      : std_logic_vector(2 downto 0);
  signal next_pass_d       : std_logic;
  signal next_pass_d2      : std_logic;
  signal blk_exp_acc       : std_logic_vector(fpr+1 downto 0);
  signal blk_exp           : std_logic_vector(fpr+1 downto 0);
  signal en_slb            : std_logic;




begin
  alt_slb_o <= slb_last;
  -----------------------------------------------------------------------------------------------
  -- Quad Ouput Engine
  -----------------------------------------------------------------------------------------------
  -- Streaming Architecture
  -----------------------------------------------------------------------------------------------
  gen_quad_str_ctrl : if(arch=0) generate
  -----------------------------------------------------------------------------------------------
      blk_exp_o <= blk_exp;
      en_slb <=next_pass_d;
   
      gen_se_bfp : if(nume=1) generate
        slb_x <= alt_slb_i(2 downto 0);
        -----------------------------------------------------------------------------------------------  
        gen_4bit_accum : if(fpr=4) generate
        -----------------------------------------------------------------------------------------------
          gen_cont : if(cont=1) generate
          -----------------------------------------------------------------------------------------------
            delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 11
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
       
            delay_next_pass2 : asj_fft_tdl_bit_rst
            generic map(
                        del   => 1
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass_d,
                        data_out  => next_pass_d2
                );
           
       
              accum_exp : process(clk,reset,exp_en,slb_last,blk_exp_acc,blk_exp,next_pass) is
                begin
                  if(rising_edge(clk)) then
                    if(reset='1') then
                      blk_exp_acc <= int2ustd(blk_exp_init,6);
                      blk_exp <= (others=>'0');
                    else
                      if(next_pass_d2 = '1') then
                        blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                        blk_exp <= blk_exp;
                      elsif(exp_en='1') then
                        blk_exp_acc <= int2ustd(blk_exp_init,6);
                        blk_exp <= blk_exp_acc;
                      else
                        blk_exp <= blk_exp;
                        blk_exp_acc <= blk_exp_acc;
                      end if;
                    end if;
                  end if;
                end process accum_exp;
             
              reg_exp : process(clk,reset,en_slb,next_blk,slb_x,slb_last) is
                begin
                  if(rising_edge(clk)) then
                    if(reset='1') then
                      slb_last <= (others=>'0');
                    else
                      if(en_slb = '1') then
                        slb_last <= slb_x;
                      elsif(next_blk='1') then
                        slb_last <= (others=>'0');
                      else
                        slb_last <= slb_last;
                      end if;
                    end if;
                  end if;
                end process reg_exp;
               
          end generate gen_cont;
          -----------------------------------------------------------------------------------------------
        gen_disc : if(cont=0) generate
        -----------------------------------------------------------------------------------------------
          delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 9
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
     
          delay_next_pass2 : asj_fft_tdl_bit_rst
            generic map(
                        del   => 1
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass_d,
                        data_out  => next_pass_d2
                );
     
     
       
          accum_exp : process(clk,reset,exp_en,slb_last,en_slb,blk_exp_acc,blk_exp) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init,6);
                  blk_exp <= (others=>'0');
                else
                  if(next_pass_d2 = '1') then
                    blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                    blk_exp <= blk_exp;
                  elsif(exp_en='1') then
                    blk_exp_acc <= int2ustd(blk_exp_init,6);
                    blk_exp <= blk_exp_acc;
                  else
                    blk_exp <= blk_exp;
                    blk_exp_acc <= blk_exp_acc;
                  end if;
                end if;
              end if;
            end process accum_exp;
        -----------------------------------------------------------------------------------------------
          reg_exp : process(clk,reset,en_slb,next_blk,slb_x,slb_last) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  slb_last <= (others=>'0');
                else
                  if(en_slb = '1') then
                    slb_last <= slb_x;
                  elsif(next_blk='1') then
                    slb_last <= (others=>'0');
                  else
                    slb_last <= slb_last;
                  end if;
                end if;
              end if;
            end process reg_exp;
          end generate gen_disc;
        -----------------------------------------------------------------------------------------------
        end generate gen_4bit_accum;
        -----------------------------------------------------------------------------------------------
     
      end generate gen_se_bfp;
      -----------------------------------------------------------------------------------------------
      gen_de_bfp : if(nume=2) generate
      -----------------------------------------------------------------------------------------------  

   
        delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 10
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
       
     
          slb_x <= alt_slb_i(2 downto 0);
          slb_y <= alt_slb_i(5 downto 3);
     
          gen_4bit_accum : if(fpr=4) generate
       
          accum_exp : process(clk,reset,next_pass_d,slb_x,slb_y,exp_en,blk_exp_acc,slb_last) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init,6);
                  slb_last <= (others=>'0');
                else
                  if(next_pass_d = '1') then
                    -- dual engine select
                    if(slb_x > slb_y) then
                      slb_last <= slb_y;
                    else
                      slb_last <= slb_x;
                    end if;
                    blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                  elsif(exp_en='1') then
                    blk_exp_acc <= int2ustd(blk_exp_init,6);
                    slb_last    <= (others=>'0');
                  else
                    blk_exp_acc <= blk_exp_acc;
                    --slb_last <= slb_last;
                  end if;
                end if;
              end if;
            end process accum_exp;
         
            reg_exp_acc : process(clk,reset,exp_en, blk_exp_acc,blk_exp) is
              begin
                if(rising_edge(clk)) then
                  if(reset='1') then
                    blk_exp <= (others=>'0');
                  else
                    if(exp_en='1') then
                      blk_exp <= blk_exp_acc;
                    else
                      blk_exp <= blk_exp;
                    end if;
                  end if;
                end if;
              end process reg_exp_acc;
          end generate gen_4bit_accum;
   
          -----------------------------------------------------------------------------------------------
      end generate gen_de_bfp;
      -----------------------------------------------------------------------------------------------
    end generate gen_quad_str_ctrl;
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -- Burst Architectures
  -----------------------------------------------------------------------------------------------
  gen_quad_burst_ctrl : if(arch=1 or arch=2) generate
  -----------------------------------------------------------------------------------------------
      blk_exp_o <= blk_exp;
      en_slb <= next_pass_d;
   
      gen_se_bfp : if(nume=1) generate
      
        slb_x <= alt_slb_i(2 downto 0);
        -----------------------------------------------------------------------------------------------  
        gen_4bit_accum : if(fpr=4) generate
        -----------------------------------------------------------------------------------------------
          delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 10
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
     
       
          accum_exp : process(clk,reset,exp_en,slb_last,en_slb,blk_exp_acc,blk_exp) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init,6);
                  blk_exp <= (others=>'0');
                else
                  if(en_slb = '1') then
                    blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                    blk_exp <= blk_exp;
                  elsif(exp_en='1') then
                    blk_exp_acc <= int2ustd(blk_exp_init,6);
                    blk_exp <= blk_exp_acc;
                  else
                    blk_exp <= blk_exp;
                    blk_exp_acc <= blk_exp_acc;
                  end if;
                end if;
              end if;
            end process accum_exp;
         
          reg_exp : process(clk,reset,en_slb,next_blk,slb_x,slb_last) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  slb_last <= (others=>'0');
                else
                  if(en_slb = '1') then
                    slb_last <= slb_x;
                  elsif(next_blk='1') then
                    slb_last <= (others=>'0');
                  else
                    slb_last <= slb_last;
                  end if;
                end if;
              end if;
            end process reg_exp;
        -----------------------------------------------------------------------------------------------
        end generate gen_4bit_accum;
        -----------------------------------------------------------------------------------------------
        -- Don't Support 5 bit (or larger) Block Floating Point....
        -- but just look how easy the extensions are if we did!
        -- Would need corresponding changes to Engine BFP algorithms
        gen_5bit_accum : if(fpr=5) generate
     
        accum_exp : process(clk,reset,slb_x,blk_exp_acc,en_slb,slb_last,next_blk) is
          begin
            if(rising_edge(clk)) then
              if(reset='1') then
                blk_exp_acc <= (others=>'1');
                slb_last <= (others=>'0');
              else
                if(en_slb = '1') then
                  slb_last <= slb_x;
                  blk_exp_acc <= blk_exp_acc + ("0000" & slb_last(2 downto 0));
                elsif(next_blk='1') then
                  blk_exp_acc <= (others=>'1');
                else
                  blk_exp_acc <= blk_exp_acc;
                end if;
              end if;
            end if;
          end process accum_exp;
     
        end generate gen_5bit_accum;
     
      end generate gen_se_bfp;
      -----------------------------------------------------------------------------------------------
      gen_de_bfp : if(nume=2) generate
      -----------------------------------------------------------------------------------------------  
        delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 10
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
       
     
          slb_x <= alt_slb_i(2 downto 0);
          slb_y <= alt_slb_i(5 downto 3);
     
          gen_4bit_accum : if(fpr=4) generate
       
          accum_exp : process(clk,reset,next_pass_d,slb_x,slb_y,exp_en,blk_exp_acc,slb_last) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init,6);
                  slb_last <= (others=>'0');
                else
                  if(next_pass_d = '1') then
                    if(slb_x > slb_y) then
                      slb_last <= slb_y;
                    else
                      slb_last <= slb_x;
                    end if;
                    blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                  elsif(exp_en='1') then
                    blk_exp_acc <= int2ustd(blk_exp_init,6);                 
                    slb_last    <= (others=>'0');
                  else
                    blk_exp_acc <= blk_exp_acc;
                    slb_last <= slb_last;
                  end if;
                end if;
              end if;
            end process accum_exp;
         
            reg_exp_acc : process(clk,reset,exp_en, blk_exp_acc,blk_exp) is
              begin
                if(rising_edge(clk)) then
                  if(reset='1') then
                    blk_exp <= (others=>'0');
                  else
                    if(exp_en='1') then
                      blk_exp <= blk_exp_acc;
                    else
                      blk_exp <= blk_exp;
                    end if;
                  end if;
                end if;
              end process reg_exp_acc;
          end generate gen_4bit_accum;
      -----------------------------------------------------------------------------------------------
      end generate gen_de_bfp;
      -----------------------------------------------------------------------------------------------
      -- Quad Engine, Quad Output
      -----------------------------------------------------------------------------------------------
      gen_qe_bfp : if(nume=4) generate
      -----------------------------------------------------------------------------------------------  
        delay_next_pass : asj_fft_tdl_bit_rst
            generic map(
                        del   => 10
                    )
            port map(
                        clk   => clk,
                        reset => reset,
                        data_in   => next_pass,
                        data_out  => next_pass_d
                );
            delay_next_pass_2 : asj_fft_tdl_bit
            generic map(
                        del   => 1
                    )
            port map(
                        clk   => clk,
                        data_in   => next_pass_d,
                        data_out  => next_pass_d2
                ); 
       
          slb_w <= alt_slb_i(2 downto 0);
          slb_x <= alt_slb_i(5 downto 3);
          slb_y <= alt_slb_i(8 downto 6);
          slb_z <= alt_slb_i(11 downto 9);
     
          gen_4bit_accum : if(fpr=4) generate
       
          accum_exp : process(clk) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init,6);
                  slb_last <= (others=>'0');
                else
                  if(next_pass_d = '1') then
                    -- dual engine select
                    if(slb_w > slb_x) then
                      slb_st1x <= slb_x;
                    else
                      slb_st1x <= slb_w;
                    end if;
                    if(slb_y > slb_z) then
                      slb_st1y <= slb_z;
                    else
                      slb_st1y <= slb_y;
                    end if;
                  elsif(next_pass_d2='1') then
                    if(slb_st1x > slb_st1y) then
                      slb_last <= slb_st1y;
                    else
                      slb_last <= slb_st1x;
                    end if;
                    blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                  elsif(exp_en='1') then
                    blk_exp_acc <= int2ustd(blk_exp_init,6);
                    slb_last    <= (others=>'0');
                  else
                    blk_exp_acc <= blk_exp_acc;
                    slb_last <= slb_last;
                  end if;
                end if;
              end if;
            end process accum_exp;
         
            reg_exp_acc : process(clk,reset,exp_en, blk_exp_acc,blk_exp) is
              begin
                if(rising_edge(clk)) then
                  if(reset='1') then
                    blk_exp <= (others=>'0');
                  else
                    if(exp_en='1') then
                      blk_exp <= blk_exp_acc;
                    else
                      blk_exp <= blk_exp;
                    end if;
                  end if;
                end if;
              end process reg_exp_acc;
          end generate gen_4bit_accum;
          -----------------------------------------------------------------------------------------------  
      end generate gen_qe_bfp;
      -----------------------------------------------------------------------------------------------
    end generate gen_quad_burst_ctrl;
    -----------------------------------------------------------------------------------------------
    -- Single Output Engine BFP Control
    -----------------------------------------------------------------------------------------------
    gen_so_crtl : if(arch>=3) generate
    -----------------------------------------------------------------------------------------------
      blk_exp_o <= blk_exp;
      en_slb <= next_pass_d;
      -----------------------------------------------------------------------------------------------
      -- Single Output
      -----------------------------------------------------------------------------------------------
      gen_se_so : if(nume=1) generate
   
      slb_x <= alt_slb_i(2 downto 0);
   
      delay_next_pass : asj_fft_tdl_bit_rst
        generic map(
                    -- Do we really need a 14+ bit SR for this control?
                    -- We need the function, but could implement a smaller control block based on a 4-bit 
                    --counter
                    del   => 13+last_pass_radix
                )
        port map(
                    clk   => clk,
                    reset => reset,
                    data_in   => next_pass,
                    data_out  => next_pass_d
            );
      delay_next_pass_2 : asj_fft_tdl_bit
        generic map(
                    del   => 1
                )
        port map(
                    clk   => clk,
                    data_in   => next_pass,
                    data_out  => next_pass_d2
            );
   
      accum_exp : process(clk,reset,exp_en,blk_exp_acc,blk_exp) is
        begin
          if(rising_edge(clk)) then
            if(reset='1') then
              blk_exp <= (others=>'0');
            else
              if(exp_en='1') then
                blk_exp <= blk_exp_acc;
              else
                blk_exp <= blk_exp;
              end if;
            end if;
          end if;
        end process accum_exp;
   
      
     
      reg_exp : process(clk,reset,en_slb,exp_en,next_pass_d2,next_blk,slb_x,slb_last,blk_exp_acc) is
        begin
          if(rising_edge(clk)) then
            if(reset='1') then
              slb_last <= (others=>'0');
              blk_exp_acc <= int2ustd(blk_exp_init_sgl,6);
            else
              if(en_slb = '1' and exp_en='0') then
                slb_last <= slb_x;
                blk_exp_acc <= blk_exp_acc;
              elsif(next_pass_d2='1') then
                blk_exp_acc <= blk_exp_acc + ("000" & slb_x(2 downto 0));
                slb_last <= slb_last;
              elsif(next_blk='1') then
                blk_exp_acc <= int2ustd(blk_exp_init_sgl,6);
                slb_last <= (others=>'0');
              else
                slb_last <= slb_last;
                blk_exp_acc <= blk_exp_acc;
              end if;
            end if;
          end if;
        end process reg_exp;
      end generate gen_se_so;
      -----------------------------------------------------------------------------------------------
      -- Dual Output
      -----------------------------------------------------------------------------------------------
      gen_de_so : if(nume=2) generate
   
        slb_x <= alt_slb_i(2 downto 0);
        slb_y <= alt_slb_i(5 downto 3);
     
        delay_next_pass : asj_fft_tdl_bit_rst
        generic map(
                    del   => 13+last_pass_radix
                )
        port map(
                    clk   => clk,
                    reset => reset,
                    data_in   => next_pass,
                    data_out  => next_pass_d
            );
         
        delay_next_pass_2 : asj_fft_tdl_bit
        generic map(
                    del   => 1
                )
        port map(
                    clk   => clk,
                    data_in   => next_pass_d,
                    data_out  => next_pass_d2
            );
     
     
        accum_exp : process(clk,reset,next_pass_d,next_pass_d2,next_blk,slb_x,slb_y,blk_exp_acc,slb_last) is
          begin
            if(rising_edge(clk)) then
              if(reset='1') then
                blk_exp_acc <= int2ustd(blk_exp_init_sgl,6);
                slb_last <= (others=>'0');
              else
                if(next_pass_d = '1') then
                  -- dual engine select
                  if(slb_x > slb_y) then
                    slb_last <= slb_y;
                  else
                    slb_last <= slb_x;
                  end if;
                  blk_exp_acc <= blk_exp_acc;
                elsif(next_pass_d2='1') then
                  blk_exp_acc <= blk_exp_acc + ("000" & slb_last(2 downto 0));
                elsif(next_blk='1') then
                  blk_exp_acc <= int2ustd(blk_exp_init_sgl,6);
                  slb_last    <= (others=>'0');
                else
                  blk_exp_acc <= blk_exp_acc;
                  slb_last <= slb_last;
                end if;
              end if;
            end if;
          end process accum_exp;
       
          reg_exp_acc : process(clk,reset,exp_en, blk_exp_acc,blk_exp) is
            begin
              if(rising_edge(clk)) then
                if(reset='1') then
                  blk_exp <= (others=>'0');
                else
                  if(exp_en='1') then
                    blk_exp <= blk_exp_acc;
                  else
                    blk_exp <= blk_exp;
                  end if;
                end if;
              end if;
            end process reg_exp_acc;
        end generate gen_de_so;
      -----------------------------------------------------------------------------------------------
      end generate gen_so_crtl;
      -----------------------------------------------------------------------------------------------
end syn;