
---- Description:
---- Constant Remove Component
---- постоянная составляющая не должна превышать половины всего размаха
---------------------------------------------------------------------------------

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Remove_const is
	generic (InWidth : integer := 14);
	port
	(
		clk         : in    std_logic := '0';
		rst         : in    std_logic := '0';
		en          : in    std_logic := '0';
		Inp         : in    std_logic_vector(InWidth-1 downto 0) := (others=> '0');
		Outp        : out   std_logic_vector(InWidth-1 downto 0) := (others=> '0')
	);
end Remove_const;


architecture arch of Remove_const is

	constant alpha      : signed (InWidth      downto 0):= to_signed(15564, InWidth+1);-- ?ann?eoaou 0,95 io iaeneioia oaeouae ?ac?yaiinoe   -- 15564 for 14bit --62259 for 16bit

	signal sum            : signed (InWidth+3 downto 0):=(others=>'0');
	signal sum_2         : signed (InWidth+3 downto 0):=(others=>'0');
	signal delay_sum      : signed (InWidth+3 downto 0):=(others=>'0'); 
	signal delay_2_sum      : signed (InWidth+3 downto 0):=(others=>'0');
	signal mult_result 	: signed (InWidth*2+4 downto 0) := (others => '0');

begin       
   
	
   process (rst, clk)
		
		
	begin
		
		if rst = '1' then
		
			mult_result <= (others => '0');
			sum         <= (others => '0');
			
			delay_sum   <= (others => '0');
			delay_2_sum <= (others => '0');
			sum_2       <= (others => '0');
			
			Outp <= (others => '0');
			
		elsif clk'EVENT and clk = '1' then
			
			if en = '1' then
				
				mult_result <= sum*alpha;
				sum <= resize(signed(Inp), InWidth+4) + mult_result (InWidth*2+3 downto InWidth) ;
				
				delay_sum <=  sum;
				delay_2_sum <= delay_sum;
				sum_2 <= resize(sum,InWidth+4) - resize(delay_2_sum, InWidth+4) ;
			--	sum_2 <= resize(sum,InWidth+4) - resize(delay_sum, InWidth+4) ;
				
				if sum_2 >= to_signed(2**(InWidth-1)-1, InWidth+4) then
					Outp(InWidth-1) <= '0';
					Outp(InWidth-2 downto 0) <= (others => '1');
				elsif sum_2 <= to_signed(-2**(InWidth-1), InWidth+4) then 
					Outp(InWidth-1) <= '1';
					Outp(InWidth-2 downto 0) <= (others => '0');
				else
					Outp <= std_logic_vector(sum_2(InWidth-1 downto 0));
				end if;
				
			end if;
			
		end if;
		
	end process;
	
	
end arch;