library ieee;
use ieee.std_logic_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;
entity arbiter_2layer is
	Port(
		clock : in  std_logic;
		reset : in  std_logic;
		din1  : in  TST_TTS;
		din2  : in  TST_TTS;
		dout  : out TST_TTS
	);
end arbiter_2layer;

-- version 2
architecture rtl of arbiter_2layer is
begin
	process(clock)
		variable st : STATE := one;
	begin
		if reset = '1' then
			dout.val <= '0';
		elsif rising_edge(clock) then
			if din1.val = '1' and din2.val = '0' then
				dout <= din1;
			elsif din2.val = '1' and din1.val = '0' then
				dout <= din2;
			elsif din1.val = '1' and din2.val = '1' then
				if din1.tim < din2.tim then
					dout <= din1;
				else
					dout <= din2;
				end if;
			else
				dout.val <= '0';
			end if;

		end if;
	end process;
end architecture rtl;
