library IEEE;
use ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;
use work.util.all;

entity fifo32_at is
	Generic(
		constant FIFO_DEPTH : positive := 3
	);
	Port(
		CLK     : in  STD_LOGIC;
		RST     : in  STD_LOGIC;
		--WriteEn	: in  STD_LOGIC;
		--DataVal: in ALL_T;
		--DataLen: in std_logic_vector(4 downto 0);
		--Valid_32: in std_logic_vector(31 downto 0);
		DataIn  : in  ALL_T;
		--ReadEn : in STD_LOGIC;
		DataOut : out std_logic_vector(37 downto 0);
		Full    : out STD_LOGIC := '0'
	);
end fifo32_at;

architecture rtl of fifo32_at is
begin

	-- Memory Pointer Process
	fifo_proc : process(clk, rst)
		type ram_t is array (0 to FIFO_DEPTH - 1) of ALL_T;
		variable Memory   : ram_t;
		variable num_val  : natural range 0 to 31;
		type val_c is array (0 to 31) of natural range 0 to 31;
		variable val_chan : val_c;
		variable Head     : natural range 0 to FIFO_DEPTH - 1;
		variable Tail     : natural range 0 to FIFO_DEPTH - 1;

		variable Looped       : boolean;
		variable len          : integer := 0;
		variable i            : integer := 0;
		variable first        : boolean := true;
		variable tmp_all_read : ALL_T;
		variable amount       : integer := 0;
		variable tmp_all      : ALL_T;
		variable st           :STATE:=one;
		variable valid        : boolean := false;
		variable tmp_valid : std_logic_vector(31 downto 0);
		variable Valid_32: std_logic_vector(31 downto 0);
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				Head        := 0;
				Tail        := 0;
				Looped      := false;
				Full        <= '0';
				--        Empty <= '1';
				DataOut<= (others => '0');
			else 

            Valid_32 := DataIn(31).val &DataIn(30).val &DataIn(29).val &DataIn(28).val &DataIn(27).val &DataIn(26).val &DataIn(25).val &DataIn(24).val &DataIn(23).val &DataIn(22).val &DataIn(21).val &DataIn(20).val &DataIn(19).val &DataIn(18).val &DataIn(17).val &DataIn(16).val &DataIn(15).val &DataIn(14).val &DataIn(13).val &DataIn(12).val &DataIn(11).val &DataIn(10).val &DataIn(9).val &DataIn(8).val &DataIn(7).val &DataIn(6).val &DataIn(5).val &DataIn(4).val &DataIn(3).val &DataIn(2).val &DataIn(1).val &DataIn(0).val;
                                
			if (Valid_32/="00000000000000000000000000000000") then	
					if (((Looped = false) or (Head /= Tail))) and DataIn(i).val = '1' then
							Memory(Head) := DataIn;
						if (Head = FIFO_DEPTH - 1) then
							Head   := 0;
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
					amount := amount + 1;
					if (Head = Tail) then
						if Looped then
							Full <= '0';
							report "the fifo is too small, it is full!!!!!!!!!!!!";
						else
							DataOut<=(others=>'0');
						end if;
					else
						Full <= '0';
					end if;
				end if;
                ---now the data is stored, travese through the valid bit and decide the output
				if (st = one) then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update data output
						tmp_all_read := Memory(Tail);
						amount       := amount - 1;
						-- Update Tail pointer as needed
						if (Tail = FIFO_DEPTH - 1) then
							Tail := 0;
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
						---now that we have the data, output it
						-- this size is always bigger than 1
					  first := true;
					  tmp_valid:= tmp_all_read(31).val &tmp_all_read(30).val &tmp_all_read(29).val &tmp_all_read(28).val &tmp_all_read(27).val &tmp_all_read(26).val &tmp_all_read(25).val &tmp_all_read(24).val &tmp_all_read(23).val &tmp_all_read(22).val &tmp_all_read(21).val &tmp_all_read(20).val &tmp_all_read(19).val &tmp_all_read(18).val &tmp_all_read(17).val &tmp_all_read(16).val &tmp_all_read(15).val &tmp_all_read(14).val &tmp_all_read(13).val &tmp_all_read(12).val &tmp_all_read(11).val &tmp_all_read(10).val &tmp_all_read(9).val &tmp_all_read(8).val &tmp_all_read(7).val &tmp_all_read(6).val &tmp_all_read(5).val &tmp_all_read(4).val &tmp_all_read(3).val &tmp_all_read(2).val &tmp_all_read(1).val &tmp_all_read(0).val;
					  if (tmp_valid(i)='1') then
					       if (first=true) then
					           DataOut<=slv(tmp_all_read(i))&'1';
					       else
					           DataOut<=slv(tmp_all_read(i))&'0';
					       end if;
					       tmp_valid(i):='0';
					  end if;
					  if (tmp_valid/="00000000000000000000000000000000") then
					       st := two;
					       i:= i+1;
					  end if;
			    end if;
			    elsif (st = two) then
				     if (tmp_valid(i)='1') then
                                          if (first=true) then
                                              DataOut<=slv(tmp_all_read(i))&'1';
                                          else
                                              DataOut<=slv(tmp_all_read(i))&'0';
                                          end if;
                                          tmp_valid(i):='0';
                                     end if;
                     if (tmp_valid="00000000000000000000000000000000") then
                                          st := one;
                                     else
                                          i:= i+1;
                                     end if;
			end if;
		end if;
		 end if; 
	end process;

end rtl;
