library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;
use ieee.numeric_std.ALL;
entity monitor_customized is
	Port(
		clk           : in  STD_LOGIC;
		rst           : in  STD_LOGIC;
		----Configurations
        cmd_en : in  std_logic_vector (4 downto 0);
        tag_en : in  std_logic_vector (7 downto 0);
        id_en : in  std_logic_vector (7 downto 0);
		link_id : in std_logic_vector(4 downto 0);
		msg_i         : in  MSG_T;
		msg_o         : out MSG_T;
		transaction_o : out TST_T
	);
end monitor_customized;

architecture Behavioral of monitor_customized is
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
				tmp_t.linkID   := link_id;
				tmp_t.tag := msg_i.tag;
				if msg_i.adr = adr then
					tmp_t.adr := "00";
				elsif unsigned(msg_i.adr) - unsigned(adr) = 1 or unsigned(adr) - unsigned(msg_i.adr) = 1 then
					tmp_t.adr := "01";
				else
					tmp_t.adr := "10";
				end if;
                tmp_t.id := msg_i.id;
                if (((msg_i.tag and tag_en)=msg_i.tag) 
                               and ((msg_i.id and id_en)=msg_i.id) and
                ((cmd_en(0)='1' and msg_i.cmd="01000000") or (cmd_en(1)='1' and msg_i.cmd="10000000")
                or (cmd_en(2)='1' and msg_i.cmd="00100000") or (cmd_en(3)='1' and msg_i.cmd="00010000")  )) then
				    transaction_o <= tmp_t;
		        end if;
			end if;

		end if;
	end process;

end Behavioral;
