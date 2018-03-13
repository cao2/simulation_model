library ieee;
use ieee.std_logic_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;
Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;
--  <-----Cut code below this line and paste into the architecture body---->

-- FIFO_SYNC_MACRO: Synchronous First-In, First-Out (FIFO) RAM Buffer
--                  Artix-7
-- Xilinx HDL Language Template, version 2017.2

-- Note -  This Unimacro model assumes the port directions to be "downto". 
--         Simulation of this model with "to" in the port directions could lead to erroneous results.

-----------------------------------------------------------------
-- DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
-- ===========|===========|============|=======================--
--   37-72    |  "36Kb"   |     512    |         9-bit         --
--   19-36    |  "36Kb"   |    1024    |        10-bit         --
--   19-36    |  "18Kb"   |     512    |         9-bit         --
--   10-18    |  "36Kb"   |    2048    |        11-bit         --
--   10-18    |  "18Kb"   |    1024    |        10-bit         --
--    5-9     |  "36Kb"   |    4096    |        12-bit         --
--    5-9     |  "18Kb"   |    2048    |        11-bit         --
--    1-4     |  "36Kb"   |    8192    |        13-bit         --
--    1-4     |  "18Kb"   |    4096    |        12-bit         --
-----------------------------------------------------------------

entity arbiter32 is
	Generic(
		constant FIFO_DEPTH : positive := 3
	);
	Port(
		CLK          : in  STD_LOGIC;
		RST          : in  STD_LOGIC;
		DataIn       : in  ALL_T;
		DataOut      : out std_logic_vector(37 downto 0);
		--A_full  : out STD_LOGIC := '0';
		control_full : out std_logic
	);
end arbiter32;

architecture rtl of arbiter32 is
	constant dpth                                                                                                                                                                                                               : positive                      := 8;
	--signal td1: std_logic_vector(31 downto 0);
	--signal td2: std_logic_vector(31 downto 0);
	signal in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31                                 : std_logic_vector(36 downto 0);
	signal tts0, tts1, tts2, tts3, tts4, tts5, tts6, tts7, tts8, tts9, tts10, tts11, tts12, tts13, tts14, tts15, tts16, tts17, tts18, tts19, tts20, tts21, tts22, tts23, tts24, tts25, tts26, tts27, tts28, tts29, tts30, tts31 : std_logic_vector(36 downto 0);
	type tts_a is array (0 to 31) of std_logic_vector(36 downto 0);
	signal tts_array                                                                                                                                                                                                            : tts_a;
	signal re, full, emp, we                                                                                                                                                                                                    : std_logic_vector(31 downto 0) := (others => '0');
	signal count                                                                                                                                                                                                                : integer                       := 0;
	--	signal layer1_1, layer1_2, layer1_3, layer1_4, layer1_5, layer1_6, layer1_7, layer1_8, layer1_9, layer1_10, layer1_11, layer1_12, layer1_13, layer1_14, layer1_15, layer1_16                                                                                : TST_TTS;
	--	signal layer2_1, layer2_2, layer2_3, layer2_4, layer2_5, layer2_6, layer2_7, layer2_8: TST_TTS;
	--	signal layer3_1, layer3_2, layer3_3, layer3_4 : TST_TTS;
	--	signal layer4_1, layer4_2 : TST_TTS;
	constant DEPTH                                                                                                                                                                                                              : positive                      := 16;
	signal control_in, control_out                                                                                                                                                                                              : std_logic_vector(31 downto 0);
	signal control_re, control_we, control_empty                                                                                                                                                                                : std_logic;
	signal ack                                                                                                                                                                                                                  : std_logic_vector(31 downto 0);
begin
	tts_map : process(clk)
	begin
		if rising_edge(clk) then
			tts_array(1)  <= tts1;
			tts_array(2)  <= tts2;
			tts_array(3)  <= tts3;
			tts_array(4)  <= tts4;
			tts_array(5)  <= tts5;
			tts_array(6)  <= tts6;
			tts_array(7)  <= tts7;
			tts_array(8)  <= tts8;
			tts_array(9)  <= tts9;
			tts_array(10) <= tts10;
			tts_array(11) <= tts11;
			tts_array(12) <= tts12;
			tts_array(13) <= tts13;
			tts_array(14) <= tts14;
			tts_array(15) <= tts15;
			tts_array(16) <= tts16;
			tts_array(17) <= tts17;
			tts_array(18) <= tts18;
			tts_array(19) <= tts19;
			tts_array(20) <= tts20;
			tts_array(21) <= tts21;
			tts_array(22) <= tts22;
			tts_array(23) <= tts23;
			tts_array(24) <= tts24;
			tts_array(25) <= tts25;
			tts_array(26) <= tts26;
			tts_array(27) <= tts27;
			tts_array(28) <= tts28;
			tts_array(29) <= tts29;
			tts_array(30) <= tts30;
			tts_array(31) <= tts31;

		end if;
	end process;
	fifo_proc : process(clk, rst)
		-- type ram_t is array (0 to FIFO_DEPTH - 1) of ALL_T;
		-- variable Memory   : ram_t;
		variable num_val  : natural range 0 to 31;
		type val_c is array (0 to 31) of natural range 0 to 31;
		variable val_chan : val_c;
		variable Head     : natural range 0 to FIFO_DEPTH - 1;
		variable Tail     : natural range 0 to FIFO_DEPTH - 1;

		variable Looped   : boolean;
		variable len      : integer               := 0;
		--variable i            : integer := 0;
		--variable first        : boolean := true;
		---variable tmp_all_read : ALL_T;
		--variable amount       : integer := 0;
		-- variable tmp_all      : ALL_T;
		variable st       : natural range 0 to 31 := 0;
		variable valid    : boolean               := false;
		variable i        : natural range 0 to 32 := 0;
		variable state    : STATE                 := one;
		variable contro_v : std_logic_vector(31 downto 0);
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				DataOut <= (others => '0');
			else
				if state = one then
					num_val    := 0;
					i          := 0;
					control_re <= '1';
					state      := two;
				elsif state = two then
					control_re <= '0';
					if control_out /= "00000000000000000000000000000000" then
						contro_v := control_out;

						if (contro_v(0) = '1') then
							valid             := true;
							val_chan(num_val) := 0;
							num_val           := num_val + 1;
						end if;
						if (contro_v(1) = '1') then
							valid             := true;
							val_chan(num_val) := 1;
							num_val           := num_val + 1;
						end if;
						if (contro_v(2) = '1') then
							valid             := true;
							val_chan(num_val) := 2;
							num_val           := num_val + 1;
						end if;
						if (contro_v(3) = '1') then
							valid             := true;
							val_chan(num_val) := 3;
							num_val           := num_val + 1;
						end if;
						if (contro_v(4) = '1') then
							valid             := true;
							val_chan(num_val) := 4;
							num_val           := num_val + 1;
						end if;
						if (contro_v(5) = '1') then
							valid             := true;
							val_chan(num_val) := 5;
							num_val           := num_val + 1;
						end if;
						if (contro_v(6) = '1') then
							valid             := true;
							val_chan(num_val) := 6;
							num_val           := num_val + 1;
						end if;
						if (contro_v(7) = '1') then
							valid             := true;
							val_chan(num_val) := 7;
							num_val           := num_val + 1;
						end if;
						if (contro_v(8) = '1') then
							valid             := true;
							val_chan(num_val) := 8;
							num_val           := num_val + 1;
						end if;
						if (contro_v(9) = '1') then
							valid             := true;
							val_chan(num_val) := 9;
							num_val           := num_val + 1;
						end if;
						if (contro_v(10) = '1') then
							valid             := true;
							val_chan(num_val) := 10;
							num_val           := num_val + 1;
						end if;
						if (contro_v(11) = '1') then
							valid             := true;
							val_chan(num_val) := 11;
							num_val           := num_val + 1;
						end if;
						if (contro_v(12) = '1') then
							valid             := true;
							val_chan(num_val) := 12;
							num_val           := num_val + 1;
						end if;
						if (contro_v(13) = '1') then
							valid             := true;
							val_chan(num_val) := 13;
							num_val           := num_val + 1;
						end if;
						if (contro_v(14) = '1') then
							valid             := true;
							val_chan(num_val) := 14;
							num_val           := num_val + 1;
						end if;
						if (contro_v(15) = '1') then
							valid             := true;
							val_chan(num_val) := 15;
							num_val           := num_val + 1;
						end if;
						if (contro_v(16) = '1') then
							valid             := true;
							val_chan(num_val) := 16;
							num_val           := num_val + 1;
						end if;
						if (contro_v(17) = '1') then
							valid             := true;
							val_chan(num_val) := 17;
							num_val           := num_val + 1;
						end if;
						if (contro_v(18) = '1') then
							valid             := true;
							val_chan(num_val) := 18;
							num_val           := num_val + 1;
						end if;
						if (contro_v(19) = '1') then
							valid             := true;
							val_chan(num_val) := 19;
							num_val           := num_val + 1;
						end if;
						if (contro_v(20) = '1') then
							valid             := true;
							val_chan(num_val) := 20;
							num_val           := num_val + 1;
						end if;
						if (contro_v(21) = '1') then
							valid             := true;
							val_chan(num_val) := 21;
							num_val           := num_val + 1;
						end if;
						if (contro_v(22) = '1') then
							valid             := true;
							val_chan(num_val) := 22;
							num_val           := num_val + 1;
						end if;
						if (contro_v(23) = '1') then
							valid             := true;
							val_chan(num_val) := 23;
							num_val           := num_val + 1;
						end if;
						if (contro_v(24) = '1') then
							valid             := true;
							val_chan(num_val) := 24;
							num_val           := num_val + 1;
						end if;
						if (contro_v(25) = '1') then
							valid             := true;
							val_chan(num_val) := 25;
							num_val           := num_val + 1;
						end if;
						if (contro_v(26) = '1') then
							valid             := true;
							val_chan(num_val) := 26;
							num_val           := num_val + 1;
						end if;
						if (contro_v(27) = '1') then
							valid             := true;
							val_chan(num_val) := 27;
							num_val           := num_val + 1;
						end if;
						if (contro_v(28) = '1') then
							valid             := true;
							val_chan(num_val) := 28;
							num_val           := num_val + 1;
						end if;
						if (contro_v(29) = '1') then
							valid             := true;
							val_chan(num_val) := 29;
							num_val           := num_val + 1;
						end if;
						if (contro_v(30) = '1') then
							valid             := true;
							val_chan(num_val) := 30;
							num_val           := num_val + 1;
						end if;
						if (contro_v(31) = '1') then
							valid             := true;
							val_chan(num_val) := 31;
							num_val           := num_val + 1;
						end if;
						state := three;
					end if;
				elsif state = three then
					re(val_chan(i)) <= '1';
					state           := four;
				elsif (state = four) then
					re(val_chan(i)) <= '0';
					if tts_array(val_chan(i))(36 downto 36) = "1" then
						DataOut <= tts_array(val_chan(i)) & '1';
						---now the first data is out, check if it reaches the size
						if i + 1 < num_val then
							i     := i + 1;
							state := five;
						else
							state := one;
						end if;
					end if;

				elsif (state = five) then
					re(val_chan(i)) <= '1';
					state           := six;
				elsif (state = six ) then
					re(val_chan(i)) <= '0';
					if tts_array(val_chan(i))(36 downto 36) = "1" then
						DataOut <= tts_array(val_chan(i)) & '0';
						---ack(val_chan(1)) <= '1';
						if i + 1 = num_val then
							state := one;
						else
							i     := i + 1;
							state := five;
						end if;
					end if;

				end if;
			end if;

		end if;
	end process;
	fifo_control : entity work.fifo_uart(arch)
		generic map(B => 32, W => dpth)
		port map(clk    => clk, reset => rst, rd => control_re,
		         wr     => control_we, w_data => control_in,
		         empty  => control_empty, full => control_full, r_data => control_out);
	--    FIFO_control : work.fifo_uart(arch)
	--            generic map(
	--                B <= 36,
	--                w<= 4
	--            port map(
	--                -- ALMOSTEMPTY => ,   -- 1-bit output almost empty
	--               -- ALMOSTFULL => control_full,     -- 1-bit output almost full
	--                DO    => control_out,               -- Output data, width defined by DATA_WIDTH parameter
	--                empty => control_empty,              -- 1-bit output empty
	--               full  => control_full,             -- 1-bit output full
	--                --  RDCOUNT => RDCOUNT,           -- Output read count, width determined by FIFO depth
	--                --  RDERR => RDERR,               -- 1-bit output read error
	--                --  WRCOUNT => WRCOUNT,           -- Output write count, width determined by FIFO depth
	--                -- WRERR => WRERR,               -- 1-bit output write error
	--                CLK   => CLK,               -- 1-bit input clock
	--                DI    => control_in,              -- Input data, width defined by DATA_WIDTH parameter
	--                RDEN  => control_re,             -- 1-bit input read enable
	--                RST   => RST,               -- 1-bit input reset
	--                WREN  => control_we                -- 1-bit input write enable
	--            );

	fifo_control_p : process(CLK)
		variable tmp_in : std_logic_vector(31 downto 0);
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				control_we <= '0';
			else
				tmp_in := DataIn(31).val & DataIn(30).val & DataIn(29).val & DataIn(28).val & DataIn(27).val & DataIn(26).val & DataIn(25).val & DataIn(24).val & DataIn(23).val & DataIn(22).val & DataIn(21).val & DataIn(20).val & DataIn(19).val & DataIn(18).val & DataIn(17).val & DataIn(16).val & DataIn(15).val & DataIn(14).val & DataIn(13).val & DataIn(12).val & DataIn(11).val & DataIn(10).val & DataIn(9).val & DataIn(8).val & DataIn(7).val & DataIn(6).val & DataIn(5).val & DataIn(4).val & DataIn(3).val & DataIn(2).val & DataIn(1).val & DataIn(0).val;
				if (tmp_in /= "00000000000000000000000000000000") then
					control_in <= tmp_in;
					control_we <= '1';
				else
					control_we <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO0 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(0),
		         wr     => we(0),
		         w_data => in0,
		         empty  => emp(0),
		         full   => full(0),
		         r_data => tts0
		        );
	fifo0_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(0) <= '0';
			elsif DataIn(0).val = '1' then
				in0   <= slv(DataIn(0));
				we(0) <= '1';
			else
				we(0) <= '0';
			end if;
		end if;
	end process;
	FIFO1 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(1),
		         wr     => we(1),
		         w_data => in1,
		         empty  => emp(1),
		         full   => full(1),
		         r_data => tts1
		        );
	fifo1_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(1) <= '0';
			elsif DataIn(1).val = '1' then
				in1   <= slv(DataIn(1));
				we(1) <= '1';
			else
				we(1) <= '0';
			end if;
		end if;
	end process;
	FIFO2 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(2),
		         wr     => we(2),
		         w_data => in2,
		         empty  => emp(2),
		         full   => full(2),
		         r_data => tts2
		        );
	fifo2_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(2) <= '0';
			elsif DataIn(2).val = '1' then
				in2   <= slv(DataIn(2));
				we(2) <= '1';
			else
				we(2) <= '0';
			end if;
		end if;
	end process;
	FIFO3 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(3),
		         wr     => we(3),
		         w_data => in3,
		         empty  => emp(3),
		         full   => full(3),
		         r_data => tts3
		        );
	fifo3_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(3) <= '0';
			elsif DataIn(3).val = '1' then
				in3   <= slv(DataIn(3));
				we(3) <= '1';
			else
				we(3) <= '0';
			end if;
		end if;
	end process;
	FIFO4 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(4),
		         wr     => we(4),
		         w_data => in4,
		         empty  => emp(4),
		         full   => full(4),
		         r_data => tts4
		        );
	fifo4_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(4) <= '0';
			elsif DataIn(4).val = '1' then
				in4   <= slv(DataIn(4));
				we(4) <= '1';
			else
				we(4) <= '0';
			end if;
		end if;
	end process;
	FIFO5 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(5),
		         wr     => we(5),
		         w_data => in5,
		         empty  => emp(5),
		         full   => full(5),
		         r_data => tts5
		        );
	fifo5_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(5) <= '0';
			elsif DataIn(5).val = '1' then
				in5   <= slv(DataIn(5));
				we(5) <= '1';
			else
				we(5) <= '0';
			end if;
		end if;
	end process;
	FIFO6 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(6),
		         wr     => we(6),
		         w_data => in6,
		         empty  => emp(6),
		         full   => full(6),
		         r_data => tts6
		        );
	fifo6_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(6) <= '0';
			elsif DataIn(6).val = '1' then
				in6   <= slv(DataIn(6));
				we(6) <= '1';
			else
				we(6) <= '0';
			end if;
		end if;
	end process;
	FIFO7 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(7),
		         wr     => we(7),
		         w_data => in7,
		         empty  => emp(7),
		         full   => full(7),
		         r_data => tts7
		        );
	fifo7_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(7) <= '0';
			elsif DataIn(7).val = '1' then
				in7   <= slv(DataIn(7));
				we(7) <= '1';
			else
				we(7) <= '0';
			end if;
		end if;
	end process;
	FIFO8 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(8),
		         wr     => we(8),
		         w_data => in8,
		         empty  => emp(8),
		         full   => full(8),
		         r_data => tts8
		        );
	fifo8_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(8) <= '0';
			elsif DataIn(8).val = '1' then
				in8   <= slv(DataIn(8));
				we(8) <= '1';
			else
				we(8) <= '0';
			end if;
		end if;
	end process;
	FIFO9 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(9),
		         wr     => we(9),
		         w_data => in9,
		         empty  => emp(9),
		         full   => full(9),
		         r_data => tts9
		        );
	fifo9_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(9) <= '0';
			elsif DataIn(9).val = '1' then
				in9   <= slv(DataIn(9));
				we(9) <= '1';
			else
				we(9) <= '0';
			end if;
		end if;
	end process;
	FIFO10 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(10),
		         wr     => we(10),
		         w_data => in10,
		         empty  => emp(10),
		         full   => full(10),
		         r_data => tts10
		        );
	fifo10_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(10) <= '0';
			elsif DataIn(10).val = '1' then
				in10   <= slv(DataIn(10));
				we(10) <= '1';
			else
				we(10) <= '0';
			end if;
		end if;
	end process;
	FIFO11 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(11),
		         wr     => we(11),
		         w_data => in11,
		         empty  => emp(11),
		         full   => full(11),
		         r_data => tts11
		        );
	fifo11_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(11) <= '0';
			elsif DataIn(11).val = '1' then
				in11   <= slv(DataIn(11));
				we(11) <= '1';
			else
				we(11) <= '0';
			end if;
		end if;
	end process;
	FIFO12 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(12),
		         wr     => we(12),
		         w_data => in12,
		         empty  => emp(12),
		         full   => full(12),
		         r_data => tts12
		        );
	fifo12_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(12) <= '0';
			elsif DataIn(12).val = '1' then
				in12   <= slv(DataIn(12));
				we(12) <= '1';
			else
				we(12) <= '0';
			end if;
		end if;
	end process;
	FIFO13 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(13),
		         wr     => we(13),
		         w_data => in13,
		         empty  => emp(13),
		         full   => full(13),
		         r_data => tts13
		        );
	fifo13_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(13) <= '0';
			elsif DataIn(13).val = '1' then
				in13   <= slv(DataIn(13));
				we(13) <= '1';
			else
				we(13) <= '0';
			end if;
		end if;
	end process;
	FIFO14 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(14),
		         wr     => we(14),
		         w_data => in14,
		         empty  => emp(14),
		         full   => full(14),
		         r_data => tts14
		        );
	fifo14_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(14) <= '0';
			elsif DataIn(14).val = '1' then
				in14   <= slv(DataIn(14));
				we(14) <= '1';
			else
				we(14) <= '0';
			end if;
		end if;
	end process;
	FIFO15 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(15),
		         wr     => we(15),
		         w_data => in15,
		         empty  => emp(15),
		         full   => full(15),
		         r_data => tts15
		        );
	fifo15_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(15) <= '0';
			elsif DataIn(15).val = '1' then
				in15   <= slv(DataIn(15));
				we(15) <= '1';
			else
				we(15) <= '0';
			end if;
		end if;
	end process;
	FIFO16 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(16),
		         wr     => we(16),
		         w_data => in16,
		         empty  => emp(16),
		         full   => full(16),
		         r_data => tts16
		        );
	fifo16_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(16) <= '0';
			elsif DataIn(16).val = '1' then
				in16   <= slv(DataIn(16));
				we(16) <= '1';
			else
				we(16) <= '0';
			end if;
		end if;
	end process;
	FIFO17 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(17),
		         wr     => we(17),
		         w_data => in17,
		         empty  => emp(17),
		         full   => full(17),
		         r_data => tts17
		        );
	fifo17_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(17) <= '0';
			elsif DataIn(17).val = '1' then
				in17   <= slv(DataIn(17));
				we(17) <= '1';
			else
				we(17) <= '0';
			end if;
		end if;
	end process;
	FIFO18 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(18),
		         wr     => we(18),
		         w_data => in18,
		         empty  => emp(18),
		         full   => full(18),
		         r_data => tts18
		        );
	fifo18_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(18) <= '0';
			elsif DataIn(18).val = '1' then
				in18   <= slv(DataIn(18));
				we(18) <= '1';
			else
				we(18) <= '0';
			end if;
		end if;
	end process;
	FIFO19 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(19),
		         wr     => we(19),
		         w_data => in19,
		         empty  => emp(19),
		         full   => full(19),
		         r_data => tts19
		        );
	fifo19_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(19) <= '0';
			elsif DataIn(19).val = '1' then
				in19   <= slv(DataIn(19));
				we(19) <= '1';
			else
				we(19) <= '0';
			end if;
		end if;
	end process;
	FIFO20 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(20),
		         wr     => we(20),
		         w_data => in20,
		         empty  => emp(20),
		         full   => full(20),
		         r_data => tts20
		        );
	fifo20_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(20) <= '0';
			elsif DataIn(20).val = '1' then
				in20   <= slv(DataIn(20));
				we(20) <= '1';
			else
				we(20) <= '0';
			end if;
		end if;
	end process;
	FIFO21 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(21),
		         wr     => we(21),
		         w_data => in21,
		         empty  => emp(21),
		         full   => full(21),
		         r_data => tts21
		        );
	fifo21_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(21) <= '0';
			elsif DataIn(21).val = '1' then
				in21   <= slv(DataIn(21));
				we(21) <= '1';
			else
				we(21) <= '0';
			end if;
		end if;
	end process;
	FIFO22 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(22),
		         wr     => we(22),
		         w_data => in22,
		         empty  => emp(22),
		         full   => full(22),
		         r_data => tts22
		        );
	fifo22_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(22) <= '0';
			elsif DataIn(22).val = '1' then
				in22   <= slv(DataIn(22));
				we(22) <= '1';
			else
				we(22) <= '0';
			end if;
		end if;
	end process;
	FIFO23 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(23),
		         wr     => we(23),
		         w_data => in23,
		         empty  => emp(23),
		         full   => full(23),
		         r_data => tts23
		        );
	fifo23_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(23) <= '0';
			elsif DataIn(23).val = '1' then
				in23   <= slv(DataIn(23));
				we(23) <= '1';
			else
				we(23) <= '0';
			end if;
		end if;
	end process;
	FIFO24 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(24),
		         wr     => we(24),
		         w_data => in24,
		         empty  => emp(24),
		         full   => full(24),
		         r_data => tts24
		        );
	fifo24_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(24) <= '0';
			elsif DataIn(24).val = '1' then
				in24   <= slv(DataIn(24));
				we(24) <= '1';
			else
				we(24) <= '0';
			end if;
		end if;
	end process;
	FIFO25 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(25),
		         wr     => we(25),
		         w_data => in25,
		         empty  => emp(25),
		         full   => full(25),
		         r_data => tts25
		        );
	fifo25_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(25) <= '0';
			elsif DataIn(25).val = '1' then
				in25   <= slv(DataIn(25));
				we(25) <= '1';
			else
				we(25) <= '0';
			end if;
		end if;
	end process;
	FIFO26 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(26),
		         wr     => we(26),
		         w_data => in26,
		         empty  => emp(26),
		         full   => full(26),
		         r_data => tts26
		        );
	fifo26_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(26) <= '0';
			elsif DataIn(26).val = '1' then
				in26   <= slv(DataIn(26));
				we(26) <= '1';
			else
				we(26) <= '0';
			end if;
		end if;
	end process;
	FIFO27 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(27),
		         wr     => we(27),
		         w_data => in27,
		         empty  => emp(27),
		         full   => full(27),
		         r_data => tts27
		        );
	fifo27_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(27) <= '0';
			elsif DataIn(27).val = '1' then
				in27   <= slv(DataIn(27));
				we(27) <= '1';
			else
				we(27) <= '0';
			end if;
		end if;
	end process;
	FIFO28 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(28),
		         wr     => we(28),
		         w_data => in28,
		         empty  => emp(28),
		         full   => full(28),
		         r_data => tts28
		        );
	fifo28_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(28) <= '0';
			elsif DataIn(28).val = '1' then
				in28   <= slv(DataIn(28));
				we(28) <= '1';
			else
				we(28) <= '0';
			end if;
		end if;
	end process;
	FIFO29 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(29),
		         wr     => we(29),
		         w_data => in29,
		         empty  => emp(29),
		         full   => full(29),
		         r_data => tts29
		        );
	fifo29_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(29) <= '0';
			elsif DataIn(29).val = '1' then
				in29   <= slv(DataIn(29));
				we(29) <= '1';
			else
				we(29) <= '0';
			end if;
		end if;
	end process;
	FIFO30 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(30),
		         wr     => we(30),
		         w_data => in30,
		         empty  => emp(30),
		         full   => full(30),
		         r_data => tts30
		        );
	fifo30_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(30) <= '0';
			elsif DataIn(30).val = '1' then
				in30   <= slv(DataIn(30));
				we(30) <= '1';
			else
				we(30) <= '0';
			end if;
		end if;
	end process;
	FIFO31 : entity work.fifo_uart(arch)
		generic map(B => 37, W => dpth)
		port map(clk    => clk, reset => rst,
		         rd     => re(31),
		         wr     => we(31),
		         w_data => in31,
		         empty  => emp(31),
		         full   => full(31),
		         r_data => tts31
		        );
	fifo31_p : process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(31) <= '0';
			elsif DataIn(31).val = '1' then
				in31   <= slv(DataIn(31));
				we(31) <= '1';
			else
				we(31) <= '0';
			end if;
		end if;
	end process;

	--	FIFO0 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES", -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES" 
	--			ALMOST_FULL_OFFSET  => X"0008", -- Sets almost full threshold
	--			ALMOST_EMPTY_OFFSET => X"0008", -- Sets the almost empty threshold
	--			DATA_WIDTH          => 37,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
	--			FIFO_SIZE           => "36Kb") -- Target BRAM, "18Kb" or "36Kb" 
	--		port map(
	--			-- ALMOSTEMPTY => ,   -- 1-bit output almost empty
	--			--ALMOSTFULL => ALMOSTFULL,     -- 1-bit output almost full
	--			DO    => in0,               -- Output data, width defined by DATA_WIDTH parameter
	--			EMPTY => emp(0),              -- 1-bit output empty
	--			FULL  => full(0),             -- 1-bit output full
	--			--  RDCOUNT => RDCOUNT,           -- Output read count, width determined by FIFO depth
	--			--  RDERR => RDERR,               -- 1-bit output read error
	--			--  WRCOUNT => WRCOUNT,           -- Output write count, width determined by FIFO depth
	--			-- WRERR => WRERR,               -- 1-bit output write error
	--			CLK   => CLK,               -- 1-bit input clock
	--			DI    => tts0,              -- Input data, width defined by DATA_WIDTH parameter
	--			RDEN  => en(0),             -- 1-bit input read enable
	--			RST   => RST,               -- 1-bit input reset
	--			WREN  => we0                -- 1-bit input write enable
	--		);

	--	fifo0_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we0 <= '0';
	--			elsif DataIn(0).val = '1' then -- if req is valid
	--				in0 <= slv(DataIn(0));
	--				we0 <= '1';
	--			else
	--				we0 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO1 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in1,
	--			EMPTY => emp(1),
	--			FULL  => full(1),
	--			CLK   => CLK,
	--			DI    => tts1,
	--			RDEN  => en(1),
	--			RST   => RST,
	--			WREN  => we1
	--		);
	--	fifo1_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we1 <= '0';
	--			elsif DataIn(1).val = '1' then
	--				in1 <= slv(DataIn(1));
	--				we1 <= '1';
	--			else
	--				we1 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO2 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in2,
	--			EMPTY => emp(2),
	--			FULL  => full(2),
	--			CLK   => CLK,
	--			DI    => tts2,
	--			RDEN  => en(2),
	--			RST   => RST,
	--			WREN  => we2
	--		);
	--	fifo2_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we2 <= '0';
	--			elsif DataIn(2).val = '1' then
	--				in2 <= slv(DataIn(2));
	--				we2 <= '1';
	--			else
	--				we2 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO3 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in3,
	--			EMPTY => emp(3),
	--			FULL  => full(3),
	--			CLK   => CLK,
	--			DI    => tts3,
	--			RDEN  => en(3),
	--			RST   => RST,
	--			WREN  => we3
	--		);
	--	fifo3_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we3 <= '0';
	--			elsif DataIn(3).val = '1' then
	--				in3 <= slv(DataIn(3));
	--				we3 <= '1';
	--			else
	--				we3 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO4 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in4,
	--			EMPTY => emp(4),
	--			FULL  => full(4),
	--			CLK   => CLK,
	--			DI    => tts4,
	--			RDEN  => en(4),
	--			RST   => RST,
	--			WREN  => we4
	--		);
	--	fifo4_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we4 <= '0';
	--			elsif DataIn(4).val = '1' then
	--				in4 <= slv(DataIn(4));
	--				we4 <= '1';
	--			else
	--				we4 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO5 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in5,
	--			EMPTY => emp(5),
	--			FULL  => full(5),
	--			CLK   => CLK,
	--			DI    => tts5,
	--			RDEN  => en(5),
	--			RST   => RST,
	--			WREN  => we5
	--		);
	--	fifo5_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we5 <= '0';
	--			elsif DataIn(5).val = '1' then
	--				in5 <= slv(DataIn(5));
	--				we5 <= '1';
	--			else
	--				we5 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO6 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in6,
	--			EMPTY => emp(6),
	--			FULL  => full(6),
	--			CLK   => CLK,
	--			DI    => tts6,
	--			RDEN  => en(6),
	--			RST   => RST,
	--			WREN  => we6
	--		);
	--	fifo6_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we6 <= '0';
	--			elsif DataIn(6).val = '1' then
	--				in6 <= slv(DataIn(6));
	--				we6 <= '1';
	--			else
	--				we6 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO7 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in7,
	--			EMPTY => emp(7),
	--			FULL  => full(7),
	--			CLK   => CLK,
	--			DI    => tts7,
	--			RDEN  => en(7),
	--			RST   => RST,
	--			WREN  => we7
	--		);
	--	fifo7_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we7 <= '0';
	--			elsif DataIn(7).val = '1' then
	--				in7 <= slv(DataIn(7));
	--				we7 <= '1';
	--			else
	--				we7 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO8 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in8,
	--			EMPTY => emp(8),
	--			FULL  => full(8),
	--			CLK   => CLK,
	--			DI    => tts8,
	--			RDEN  => en(8),
	--			RST   => RST,
	--			WREN  => we8
	--		);
	--	fifo8_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we8 <= '0';
	--			elsif DataIn(8).val = '1' then
	--				in8 <= slv(DataIn(8));
	--				we8 <= '1';
	--			else
	--				we8 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO9 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in9,
	--			EMPTY => emp(9),
	--			FULL  => full(9),
	--			CLK   => CLK,
	--			DI    => tts9,
	--			RDEN  => en(9),
	--			RST   => RST,
	--			WREN  => we9
	--		);
	--	fifo9_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we9 <= '0';
	--			elsif DataIn(9).val = '1' then
	--				in9 <= slv(DataIn(9));
	--				we9 <= '1';
	--			else
	--				we9 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO10 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in10,
	--			EMPTY => emp(10),
	--			FULL  => full(10),
	--			CLK   => CLK,
	--			DI    => tts10,
	--			RDEN  => en(10),
	--			RST   => RST,
	--			WREN  => we10
	--		);
	--	fifo10_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we10 <= '0';
	--			elsif DataIn(10).val = '1' then
	--				in10 <= slv(DataIn(10));
	--				we10 <= '1';
	--			else
	--				we10 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO11 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in11,
	--			EMPTY => emp(11),
	--			FULL  => full(11),
	--			CLK   => CLK,
	--			DI    => tts11,
	--			RDEN  => en(11),
	--			RST   => RST,
	--			WREN  => we11
	--		);
	--	fifo11_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we11 <= '0';
	--			elsif DataIn(11).val = '1' then
	--				in11 <= slv(DataIn(11));
	--				we11 <= '1';
	--			else
	--				we11 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO12 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in12,
	--			EMPTY => emp(12),
	--			FULL  => full(12),
	--			CLK   => CLK,
	--			DI    => tts12,
	--			RDEN  => en(12),
	--			RST   => RST,
	--			WREN  => we12
	--		);
	--	fifo12_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we12 <= '0';
	--			elsif DataIn(12).val = '1' then
	--				in12 <= slv(DataIn(12));
	--				we12 <= '1';
	--			else
	--				we12 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO13 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in13,
	--			EMPTY => emp(13),
	--			FULL  => full(13),
	--			CLK   => CLK,
	--			DI    => tts13,
	--			RDEN  => en(13),
	--			RST   => RST,
	--			WREN  => we13
	--		);
	--	fifo13_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we13 <= '0';
	--			elsif DataIn(13).val = '1' then
	--				in13 <= slv(DataIn(13));
	--				we13 <= '1';
	--			else
	--				we13 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO14 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in14,
	--			EMPTY => emp(14),
	--			FULL  => full(14),
	--			CLK   => CLK,
	--			DI    => tts14,
	--			RDEN  => en(14),
	--			RST   => RST,
	--			WREN  => we14
	--		);
	--	fifo14_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we14 <= '0';
	--			elsif DataIn(14).val = '1' then
	--				in14 <= slv(DataIn(14));
	--				we14 <= '1';
	--			else
	--				we14 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO15 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in15,
	--			EMPTY => emp(15),
	--			FULL  => full(15),
	--			CLK   => CLK,
	--			DI    => tts15,
	--			RDEN  => en(15),
	--			RST   => RST,
	--			WREN  => we15
	--		);
	--	fifo15_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we15 <= '0';
	--			elsif DataIn(15).val = '1' then
	--				in15 <= slv(DataIn(15));
	--				we15 <= '1';
	--			else
	--				we15 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO16 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in16,
	--			EMPTY => emp(16),
	--			FULL  => full(16),
	--			CLK   => CLK,
	--			DI    => tts16,
	--			RDEN  => en(16),
	--			RST   => RST,
	--			WREN  => we16
	--		);
	--	fifo16_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we16 <= '0';
	--			elsif DataIn(16).val = '1' then
	--				in16 <= slv(DataIn(16));
	--				we16 <= '1';
	--			else
	--				we16 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO17 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in17,
	--			EMPTY => emp(17),
	--			FULL  => full(17),
	--			CLK   => CLK,
	--			DI    => tts17,
	--			RDEN  => en(17),
	--			RST   => RST,
	--			WREN  => we17
	--		);
	--	fifo17_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we17 <= '0';
	--			elsif DataIn(17).val = '1' then
	--				in17 <= slv(DataIn(17));
	--				we17 <= '1';
	--			else
	--				we17 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO18 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in18,
	--			EMPTY => emp(18),
	--			FULL  => full(18),
	--			CLK   => CLK,
	--			DI    => tts18,
	--			RDEN  => en(18),
	--			RST   => RST,
	--			WREN  => we18
	--		);
	--	fifo18_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we18 <= '0';
	--			elsif DataIn(18).val = '1' then
	--				in18 <= slv(DataIn(18));
	--				we18 <= '1';
	--			else
	--				we18 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO19 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in19,
	--			EMPTY => emp(19),
	--			FULL  => full(19),
	--			CLK   => CLK,
	--			DI    => tts19,
	--			RDEN  => en(19),
	--			RST   => RST,
	--			WREN  => we19
	--		);
	--	fifo19_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we19 <= '0';
	--			elsif DataIn(19).val = '1' then
	--				in19 <= slv(DataIn(19));
	--				we19 <= '1';
	--			else
	--				we19 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO20 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in20,
	--			EMPTY => emp(20),
	--			FULL  => full(20),
	--			CLK   => CLK,
	--			DI    => tts20,
	--			RDEN  => en(20),
	--			RST   => RST,
	--			WREN  => we20
	--		);
	--	fifo20_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we20 <= '0';
	--			elsif DataIn(20).val = '1' then
	--				in20 <= slv(DataIn(20));
	--				we20 <= '1';
	--			else
	--				we20 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO21 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in21,
	--			EMPTY => emp(21),
	--			FULL  => full(21),
	--			CLK   => CLK,
	--			DI    => tts21,
	--			RDEN  => en(21),
	--			RST   => RST,
	--			WREN  => we21
	--		);
	--	fifo21_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we21 <= '0';
	--			elsif DataIn(21).val = '1' then
	--				in21 <= slv(DataIn(21));
	--				we21 <= '1';
	--			else
	--				we21 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO22 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in22,
	--			EMPTY => emp(22),
	--			FULL  => full(22),
	--			CLK   => CLK,
	--			DI    => tts22,
	--			RDEN  => en(22),
	--			RST   => RST,
	--			WREN  => we22
	--		);
	--	fifo22_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we22 <= '0';
	--			elsif DataIn(22).val = '1' then
	--				in22 <= slv(DataIn(22));
	--				we22 <= '1';
	--			else
	--				we22 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO23 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in23,
	--			EMPTY => emp(23),
	--			FULL  => full(23),
	--			CLK   => CLK,
	--			DI    => tts23,
	--			RDEN  => en(23),
	--			RST   => RST,
	--			WREN  => we23
	--		);
	--	fifo23_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we23 <= '0';
	--			elsif DataIn(23).val = '1' then
	--				in23 <= slv(DataIn(23));
	--				we23 <= '1';
	--			else
	--				we23 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO24 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in24,
	--			EMPTY => emp(24),
	--			FULL  => full(24),
	--			CLK   => CLK,
	--			DI    => tts24,
	--			RDEN  => en(24),
	--			RST   => RST,
	--			WREN  => we24
	--		);
	--	fifo24_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we24 <= '0';
	--			elsif DataIn(24).val = '1' then
	--				in24 <= slv(DataIn(24));
	--				we24 <= '1';
	--			else
	--				we24 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO25 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in25,
	--			EMPTY => emp(25),
	--			FULL  => full(25),
	--			CLK   => CLK,
	--			DI    => tts25,
	--			RDEN  => en(25),
	--			RST   => RST,
	--			WREN  => we25
	--		);
	--	fifo25_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we25 <= '0';
	--			elsif DataIn(25).val = '1' then
	--				in25 <= slv(DataIn(25));
	--				we25 <= '1';
	--			else
	--				we25 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO26 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in26,
	--			EMPTY => emp(26),
	--			FULL  => full(26),
	--			CLK   => CLK,
	--			DI    => tts26,
	--			RDEN  => en(26),
	--			RST   => RST,
	--			WREN  => we26
	--		);
	--	fifo26_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we26 <= '0';
	--			elsif DataIn(26).val = '1' then
	--				in26 <= slv(DataIn(26));
	--				we26 <= '1';
	--			else
	--				we26 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO27 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in27,
	--			EMPTY => emp(27),
	--			FULL  => full(27),
	--			CLK   => CLK,
	--			DI    => tts27,
	--			RDEN  => en(27),
	--			RST   => RST,
	--			WREN  => we27
	--		);
	--	fifo27_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we27 <= '0';
	--			elsif DataIn(27).val = '1' then
	--				in27 <= slv(DataIn(27));
	--				we27 <= '1';
	--			else
	--				we27 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO28 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in28,
	--			EMPTY => emp(28),
	--			FULL  => full(28),
	--			CLK   => CLK,
	--			DI    => tts28,
	--			RDEN  => en(28),
	--			RST   => RST,
	--			WREN  => we28
	--		);
	--	fifo28_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we28 <= '0';
	--			elsif DataIn(28).val = '1' then
	--				in28 <= slv(DataIn(28));
	--				we28 <= '1';
	--			else
	--				we28 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO29 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in29,
	--			EMPTY => emp(29),
	--			FULL  => full(29),
	--			CLK   => CLK,
	--			DI    => tts29,
	--			RDEN  => en(29),
	--			RST   => RST,
	--			WREN  => we29
	--		);
	--	fifo29_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we29 <= '0';
	--			elsif DataIn(29).val = '1' then
	--				in29 <= slv(DataIn(29));
	--				we29 <= '1';
	--			else
	--				we29 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO30 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in30,
	--			EMPTY => emp(30),
	--			FULL  => full(30),
	--			CLK   => CLK,
	--			DI    => tts30,
	--			RDEN  => en(30),
	--			RST   => RST,
	--			WREN  => we30
	--		);
	--	fifo30_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we30 <= '0';
	--			elsif DataIn(30).val = '1' then
	--				in30 <= slv(DataIn(30));
	--				we30 <= '1';
	--			else
	--				we30 <= '0';
	--			end if;
	--		end if;
	--	end process;
	--	FIFO31 : FIFO_SYNC_MACRO
	--		generic map(
	--			DEVICE              => "7SERIES",
	--			ALMOST_FULL_OFFSET  => X"0008",
	--			ALMOST_EMPTY_OFFSET => X"0008",
	--			DATA_WIDTH          => 37,
	--			FIFO_SIZE => "36Kb")
	--		port map(
	--			DO    => in31,
	--			EMPTY => emp(31),
	--			FULL  => full(31),
	--			CLK   => CLK,
	--			DI    => tts31,
	--			RDEN  => en(31),
	--			RST   => RST,
	--			WREN  => we31
	--		);
	--	fifo31_p : process(CLK)
	--	begin
	--		if rising_edge(CLK) then
	--			if RST = '1' then
	--				we31 <= '0';
	--			elsif DataIn(31).val = '1' then
	--				in31 <= slv(DataIn(31));
	--				we31 <= '1';
	--			else
	--				we31 <= '0';
	--			end if;
	--		end if;
	--	end process;

end rtl;
