library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;
use ieee.numeric_std.ALL;
entity monitor_customized_B is
	Port(
		clk           : in  STD_LOGIC;
		rst           : in  STD_LOGIC;

		master_id     : in IP_T;
		slave_id      : in  IP_T;
		msg_i         : in  BMSG_T;
		msg_o         : out BMSG_T;
		transaction_o : out TST_T
	);
end monitor_customized_B;

architecture Behavioral of monitor_customized_B is
begin
	process(clk)
		variable adr   : std_logic_vector(31 downto 0) := (others => '0');
		variable id    : std_logic_vector(7 downto 0)  := (others => '0');
		variable tmp_t : TST_T;
	begin
		if rising_edge(clk) then
			transaction_o.val <= '0';
			msg_o             <= msg_i;
			if msg_i.val = '1' then
				tmp_t.val      := '1';
				tmp_t.cmd      := msg_i.cmd;
				tmp_t.sender   := master_id;
				tmp_t.receiver := slave_id;
				tmp_t.tag := msg_i.tag;
				if msg_i.adr = adr then
					tmp_t.adr := "00";
				elsif unsigned(msg_i.adr) - unsigned(adr) = 1 or unsigned(adr) - unsigned(msg_i.adr) = 1 then
					tmp_t.adr := "01";
				else
					tmp_t.adr := "10";
				end if;

--				if msg_i.id = id then
--					tmp_t.id := "00";
--				elsif unsigned(msg_i.id) - unsigned(id) = 1 or unsigned(id) - unsigned(msg_i.id) = 1 then
--					tmp_t.id := "01";
--				else
--					tmp_t.id := "10";
--				end if;
tmp_t.id := msg_i.id;
				transaction_o <= tmp_t;
			end if;

		end if;
	end process;

end Behavioral;
