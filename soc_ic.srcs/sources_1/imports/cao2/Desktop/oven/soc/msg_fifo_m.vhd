library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

entity msg_fifo_m is
	Port(
		clock : in  std_logic;
		reset : in  std_logic;
    we_o : out std_logic;
    tofifo_o : out MSG_T;
    data_i : MSG_T
    
    );
end msg_fifo_m;

architecture rtl of msg_fifo_m is

begin
	fifo_p : process(clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
                    we_o <= '0';
                elsif (data_i.val = '1') then
				tofifo_o <= data_i;
				we_o <= '1';
			else
				we_o <= '0';
			end if;
		end if;
	end process;

end rtl;
