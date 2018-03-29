

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;
use work.util.all;


entity fifo_map_process is
 Generic (
   constant B    : positive := 32;
   constant W: positive := 32
   );
 Port ( 
   clk        : in  STD_LOGIC;
   reset        : in  STD_LOGIC;
  -- wr    : in  STD_LOGIC;
  -- w_data    : in  std_logic_vector(B-1 downto 0);
   rd    : in  STD_LOGIC;
   r_data    : out std_logic_vector(B-1 downto 0);
   
   
   DataIn: in TST_T;
   Empty    : out STD_LOGIC;
   half: out std_logic
   --Full    : out STD_LOGIC := '0'
   );
end fifo_map_process;

architecture Behavioral of fifo_map_process is
 signal wr: std_logic;
 signal full: std_logic;
 signal w_data: std_logic_vector(B-1 downto 0);
begin

	FIFO0 : entity work.fifo_gen(rtl)
		generic map(B => B, W => W)
		port map(clk    => clk, 
		          reset => reset,
		         rd     => rd,
		         wr     => wr,
		         w_data => w_data,
		         empty  => empty,
		         full   => full,
		         half => half,
		         r_data => r_data
		        );
	fifo0_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if reset = '1' then
				wr <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn.val = '1' and full = '0') then
					w_data   <= slv(DataIn);
					wr <= '1';
				else
					wr <= '0';
				end if;
			end if;
		end if;
	end process;

end Behavioral;
