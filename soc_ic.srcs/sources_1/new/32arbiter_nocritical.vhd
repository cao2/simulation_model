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

entity arbiter32_nocritical is
	Generic(
		constant FIFO_DEPTH : positive := 3
	);
	Port(
		CLK          : in  STD_LOGIC;
		RST          : in  STD_LOGIC;
		DataIn       : in  ALL_T;
		DataOut      : out std_logic_vector(32 downto 0);
		ranks        : in  rank_list;
		ranks_fifo   : in  rank_list;
		critical     : in  positive;
		--A_full  : out STD_LOGIC := '0';
		--control_full : out std_logic;
		data_dropped : out std_logic_vector(4 downto 0) := (others => '0')
	);
end arbiter32_nocritical;

architecture rtl of arbiter32_nocritical is

	signal in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31                                 : std_logic_vector(31 downto 0);
	signal tts0, tts1, tts2, tts3, tts4, tts5, tts6, tts7, tts8, tts9, tts10, tts11, tts12, tts13, tts14, tts15, tts16, tts17, tts18, tts19, tts20, tts21, tts22, tts23, tts24, tts25, tts26, tts27, tts28, tts29, tts30, tts31 : std_logic_vector(31 downto 0);
	type tts_a is array (0 to 31) of std_logic_vector(31 downto 0);
	signal empty_data                                                                                                                                                                                                           : std_logic_vector(31 downto 0) := (others => '0');
	signal tts_array                                                                                                                                                                                                            : tts_a;
	signal re, full, emp, we,half                                                                                                                                                                                                    : std_logic_vector(31 downto 0) := (others => '0');
	signal count                                                                                                                                                                                                                : integer                       := 0;

	constant depth                         : positive                      := 3;
	signal control_in, control_out                                                                                                                                                                                              : std_logic_vector(36 downto 0);
	signal control_re, control_we, control_empty, control_full                                                                                                                                                                  : std_logic;
	signal percent_i : integer:=0;
	--signal critical_mode                                                                                                                                                                                                        : std_logic                     := '0';
	--signal ranks: rank_list;
	signal ack                                                                                                                                                                                                                  : std_logic_vector(31 downto 0);
begin

	tts_map : process(clk)
	begin
		if rising_edge(clk) then
			tts_array(0)  <= tts0;
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

		variable Looped       : boolean;
		variable len          : integer               := 0;
		variable st           : natural range 0 to 31 := 0;
		variable valid        : boolean               := false;
		variable i            : natural range 0 to 32 := 0;
		variable state        : STATE                 := one;
		variable contro_v     : std_logic_vector(36 downto 0);
		variable tmp_critical : positive;
		variable emp_cont     : std_logic_vector(36 downto 0):= (others => '0');
		variable emp_msg: TST_T;
	begin
		if rising_edge(CLK) or falling_edge(CLK) then
			if RST = '1' then
				DataOut <= (others => '0');
				emp_msg.val:='1';
				emp_msg.cmd := "11111111";
				emp_msg.tag := "11111111";
				emp_msg.id := "11111111";
				emp_msg.adr :="00";
				emp_msg.linkID :="00000";
				
			else
				if state = one then
					num_val    := 0;
					i          := 0;
					if (control_empty /= '1') then
					   control_re <= '1';
					   state      := seven;
					end if;
					re         <= (others => '0');
					DataOut    <= empty_data & '1';
					--end if;
				elsif state = seven then
					
					state      := two;
					--emp_cont   
				elsif state = two then
				    control_re <= '0';
					if (control_out /= emp_cont)  then
						contro_v := control_out;
						if (contro_v(31 downto 0) /="00000000000000000000000000000000") then
						if (contro_v(0) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(0);
							num_val           := num_val + 1;
						end if;
						if (contro_v(1) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(1);
							num_val           := num_val + 1;
						end if;
						if (contro_v(2) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(2);
							num_val           := num_val + 1;
						end if;
						if (contro_v(3) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(3);
							num_val           := num_val + 1;
						end if;
						if (contro_v(4) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(4);
							num_val           := num_val + 1;
						end if;
						if (contro_v(5) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(5);
							num_val           := num_val + 1;
						end if;
						if (contro_v(6) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(6);
							num_val           := num_val + 1;
						end if;
						if (contro_v(7) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(7);
							num_val           := num_val + 1;
						end if;
						if (contro_v(8) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(8);
							num_val           := num_val + 1;
						end if;
						if (contro_v(9) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(9);
							num_val           := num_val + 1;
						end if;
						if (contro_v(10) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(10);
							num_val           := num_val + 1;
						end if;
						if (contro_v(11) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(11);
							num_val           := num_val + 1;
						end if;
						if (contro_v(12) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(12);
							num_val           := num_val + 1;
						end if;
						if (contro_v(13) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(13);
							num_val           := num_val + 1;
						end if;
						if (contro_v(14) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(14);
							num_val           := num_val + 1;
						end if;
						if (contro_v(15) = '1') then
							valid             := true;
							val_chan(num_val) := ranks(15);
							num_val           := num_val + 1;
						end if;
						if (contro_v(16) = '1') then
							valid             := true;
							val_chan(num_val) := ranks(16);
							num_val           := num_val + 1;
						end if;
						if (contro_v(17) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(17);
							num_val           := num_val + 1;
						end if;
						if (contro_v(18) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(18);
							num_val           := num_val + 1;
						end if;
						if (contro_v(19) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(19);
							num_val           := num_val + 1;
						end if;
						if (contro_v(20) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(20);
							num_val           := num_val + 1;
						end if;
						if (contro_v(21) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(21);
							num_val           := num_val + 1;
						end if;
						if (contro_v(22) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(22);
							num_val           := num_val + 1;
						end if;
						if (contro_v(23) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(23);
							num_val           := num_val + 1;
						end if;
						if (contro_v(24) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(24);
							num_val           := num_val + 1;
						end if;
						if (contro_v(25) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(25);
							num_val           := num_val + 1;
						end if;
						if (contro_v(26) = '1') then
							valid             := true;
							val_chan(num_val) := ranks(26);
							num_val           := num_val + 1;
						end if;
						if (contro_v(27) = '1') then
							valid             := true;
							val_chan(num_val) := ranks(27);
							num_val           := num_val + 1;
						end if;
						if (contro_v(28) = '1') then
							valid             := true;
							val_chan(num_val) := ranks(28);
							num_val           := num_val + 1;
						end if;
						if (contro_v(29) = '1'  ) then
							valid             := true;
							val_chan(num_val) := ranks(29);
							num_val           := num_val + 1;
						end if;
						if (contro_v(30) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(30);
							num_val           := num_val + 1;
						end if;
						if (contro_v(31) = '1' ) then
							valid             := true;
							val_chan(num_val) := ranks(31);
							num_val           := num_val + 1;
						end if;
						 re(val_chan(i)) <= '1';
                         state           := four;
						else
                                               state := one;
                                               DataOut <=slv(emp_msg)&'1';
                                               data_dropped <= contro_v(36 downto 32);                                      
						end if;
					end if;
				elsif (state =four) then
				      state := six;
				elsif (state = six) then
					re(val_chan(i)) <= '0';
					if tts_array(val_chan(i))(31 downto 31) = "1" then
						DataOut      <= tts_array(val_chan(i)) & '1';
						data_dropped <= contro_v(36 downto 32);
						---now the first data is out, check if it reaches the size
						if i + 1 < num_val then
							i     := i + 1;
                            re(val_chan(i)) <= '1';
                            state := five;
						else
							state := one;
						end if;
					end if;
                elsif (state = five) then
                data_dropped    <= (others => '0');
                                    DataOut         <= (others => '0');
                                    re(val_chan(i)) <= '0';
                    state := eight;
				elsif (state = eight) then
				    
					if tts_array(val_chan(i))(31 downto 31) = "1" then
						DataOut <= tts_array(val_chan(i)) & '0';
						if i + 1 = num_val then
							state := one;
						else
							i     := i + 1;
							re(val_chan(i)) <= '1';
							state := five;
						end if;
					end if;
				end if;
			end if;

		end if;
	end process;
	
	fifo_control : entity work.fifo_gen(rtl)
		generic map(B => 32 + 5, W => depth + 7)
		port map(clk    => clk, reset => rst, rd => control_re, percent_i => percent_i,
		         wr     => control_we, w_data => control_in,
		         empty  => control_empty, full => control_full, r_data => control_out);
	
	fifo_control_p : process(RST, CLK)
		variable tmp_in   , tmp_d     : std_logic_vector(31 downto 0);
		variable num_drop         : natural range 0 to 31 := 0;
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		---variable tmp_ful
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				control_we <= '0';
		  else		
				tmp_in := DataIn(ranks(31)).val & DataIn(ranks(30)).val & DataIn(ranks(29)).val & DataIn(ranks(28)).val 
				& DataIn(ranks(27)).val & DataIn(ranks(26)).val & DataIn(ranks(25)).val & DataIn(ranks(24)).val & DataIn(ranks(23)).val 
				& DataIn(ranks(22)).val & DataIn(ranks(21)).val & DataIn(ranks(20)).val & DataIn(ranks(19)).val & DataIn(ranks(18)).val 
				& DataIn(ranks(17)).val & DataIn(ranks(16)).val & DataIn(ranks(15)).val & DataIn(ranks(14)).val & DataIn(ranks(13)).val 
				& DataIn(ranks(12)).val & DataIn(ranks(11)).val & DataIn(ranks(10)).val & DataIn(ranks(9)).val & DataIn(ranks(8)).val 
				& DataIn(ranks(7)).val & DataIn(ranks(6)).val & DataIn(ranks(5)).val & DataIn(ranks(4)).val & DataIn(ranks(3)).val 
				& DataIn(ranks(2)).val & DataIn(ranks(1)).val & DataIn(ranks(0)).val;
				if (tmp_in /= "00000000000000000000000000000000" and control_full /= '1') then
				        report "full 26 "& integer'image(to_integer(unsigned(full(26 downto 26))));
				        report "tmp in 26 "& integer'image(to_integer(unsigned(tmp_in(26 downto 26))));
						tmp_d := full and tmp_in;
						num_drop := count_ones(tmp_d);
						tmp_in   := tmp_in and (not full);
					   -- report "tmp after in 26 "& integer'image(to_integer(unsigned(tmp_in(26 downto 26))));
					 control_in <= std_logic_vector(to_unsigned(num_drop, 5)) & tmp_in;
					 --report "control in "& integer'image(to_integer(unsigned(control_in(26 downto 26))));
					-- report "control in data drop"&  integer'image(to_integer(unsigned(control_in(35 downto 32))));
					control_we <= '1';
				else
					control_we <= '0';
				end if;
			end if;
		end if;
	end process;

	FIFO0 : entity work.fifo_gen(rtl)
		generic map(B => 32, W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(0),
		         wr     => we(0),
		         w_data => in0,
		         empty  => emp(0),
		         full   => full(0),
		         r_data => tts0
		        );
	fifo0_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(0) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(0).val = '1' and full(0) = '0') then
					in0   <= slv(DataIn(0));
					we(0) <= '1';
				else
					we(0) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO1 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(1),
		         wr     => we(1),
		         w_data => in1,
		         empty  => emp(1),
		         full   => full(1),
		         r_data => tts1
		        );
	fifo1_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(1) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(1).val = '1' and full(1) = '0') then
					in1   <= slv(DataIn(1));
					we(1) <= '1';
				else
					we(1) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO2 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(2),
		         wr     => we(2),
		         w_data => in2,
		         empty  => emp(2),
		         full   => full(2),
		         r_data => tts2
		        );
	fifo2_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(2) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(2).val = '1' and full(2) = '0') then
					in2   <= slv(DataIn(2));
					we(2) <= '1';
				else
					we(2) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO3 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(3),
		         wr     => we(3),
		         w_data => in3,
		         empty  => emp(3),
		         full   => full(3),
		         r_data => tts3
		        );
	fifo3_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(3) <= '0';
			elsif rising_edge(CLK) then
			
				if ( DataIn(3).val = '1' and full(3) = '0' ) then
					in3   <= slv(DataIn(3));
					we(3) <= '1';
				else
					we(3) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO4 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(4),
		         wr     => we(4),
		         w_data => in4,
		         empty  => emp(4),
		         full   => full(4),
		         r_data => tts4
		        );
	fifo4_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(4) <= '0';
			elsif rising_edge(CLK) then
				if ( DataIn(4).val = '1' and full(4) = '0') then
					in4   <= slv(DataIn(4));
					we(4) <= '1';
				else
					we(4) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO5 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(5),
		         wr     => we(5),
		         w_data => in5,
		         empty  => emp(5),
		         full   => full(5),
		         r_data => tts5
		        );
	fifo5_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(5) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(5).val = '1' and full(5) = '0') then
					in5   <= slv(DataIn(5));
					we(5) <= '1';
				else
					we(5) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO6 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(6),
		         wr     => we(6),
		         w_data => in6,
		         empty  => emp(6),
		         full   => full(6),
		         r_data => tts6
		        );
	fifo6_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(6) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(6).val = '1' and full(6) = '0') then
					in6   <= slv(DataIn(6));
					we(6) <= '1';
				else
					we(6) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO7 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(7),
		         wr     => we(7),
		         w_data => in7,
		         empty  => emp(7),
		         full   => full(7),
		         r_data => tts7
		        );
	fifo7_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(7) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(7).val = '1' and full(7) = '0') then
					in7   <= slv(DataIn(7));
					we(7) <= '1';
				else
					we(7) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO8 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(8),
		         wr     => we(8),
		         w_data => in8,
		         empty  => emp(8),
		         full   => full(8),
		         r_data => tts8
		        );
	fifo8_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(8) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(8).val = '1' and full(8) = '0') then
					in8   <= slv(DataIn(8));
					we(8) <= '1';
				else
					we(8) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO9 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(9),
		         wr     => we(9),
		         w_data => in9,
		         empty  => emp(9),
		         full   => full(9),
		         r_data => tts9
		        );
	fifo9_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(9) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(9).val = '1' and full(9) = '0') then
					in9   <= slv(DataIn(9));
					we(9) <= '1';
				else
					we(9) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO10 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(10),
		         wr     => we(10),
		         w_data => in10,
		         empty  => emp(10),
		         full   => full(10),
		         r_data => tts10
		        );
	fifo10_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(10) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(10).val = '1' and full(10) = '0' ) then
					in10   <= slv(DataIn(10));
					we(10) <= '1';
				else
					we(10) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO11 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(11),
		         wr     => we(11),
		         w_data => in11,
		         empty  => emp(11),
		         full   => full(11),
		         r_data => tts11
		        );
	fifo11_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(11) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(11).val = '1' and full(11) = '0' ) then
					in11   <= slv(DataIn(11));
					we(11) <= '1';
				else
					we(11) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO12 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(12),
		         wr     => we(12),
		         w_data => in12,
		         empty  => emp(12),
		         full   => full(12),
		         r_data => tts12
		        );
	fifo12_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(12) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(12).val = '1' and full(12) = '0') then
					in12   <= slv(DataIn(12));
					we(12) <= '1';
				else
					we(12) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO13 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(13),
		         wr     => we(13),
		         w_data => in13,
		         empty  => emp(13),
		         full   => full(13),
		         r_data => tts13
		        );
	fifo13_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(13) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(13).val = '1' and full(13) = '0' ) then
					in13   <= slv(DataIn(13));
					we(13) <= '1';
				else
					we(13) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO14 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(14),
		         wr     => we(14),
		         w_data => in14,
		         empty  => emp(14),
		         full   => full(14),
		         r_data => tts14
		        );
	fifo14_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(14) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(14).val = '1' and full(14) = '0' ) then
					in14   <= slv(DataIn(14));
					we(14) <= '1';
				else
					we(14) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO15 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(15),
		         wr     => we(15),
		         w_data => in15,
		         empty  => emp(15),
		         full   => full(15),
		         r_data => tts15
		        );
	fifo15_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(15) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(15).val = '1' and full(15) = '0' ) then
					in15   <= slv(DataIn(15));
					we(15) <= '1';
				else
					we(15) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO16 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(16),
		         wr     => we(16),
		         w_data => in16,
		         empty  => emp(16),
		         full   => full(16),
		         r_data => tts16
		        );
	fifo16_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(16) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(16).val = '1' and full(16) = '0' ) then
					in16   <= slv(DataIn(16));
					we(16) <= '1';
				else
					we(16) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO17 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(17),
		         wr     => we(17),
		         w_data => in17,
		         empty  => emp(17),
		         full   => full(17),
		         r_data => tts17
		        );
	fifo17_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(17) <= '0';
			elsif rising_edge(CLK) then
				if ( DataIn(17).val = '1' and full(17) = '0' ) then
					in17   <= slv(DataIn(17));
					we(17) <= '1';
				else
					we(17) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO18 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(18),
		         wr     => we(18),
		         w_data => in18,
		         empty  => emp(18),
		         full   => full(18),
		         r_data => tts18
		        );
	fifo18_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(18) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(18).val = '1' and full(18) = '0') then
					in18   <= slv(DataIn(18));
					we(18) <= '1';
				else
					we(18) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO19 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(19),
		         wr     => we(19),
		         w_data => in19,
		         empty  => emp(19),
		         full   => full(19),
		         r_data => tts19
		        );
	fifo19_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(19) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(19).val = '1' and full(19) = '0' ) then
					in19   <= slv(DataIn(19));
					we(19) <= '1';
				else
					we(19) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO20 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(20),
		         wr     => we(20),
		         w_data => in20,
		         empty  => emp(20),
		         full   => full(20),
		         r_data => tts20
		        );
	fifo20_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(20) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(20).val = '1' and full(20) = '0' ) then
					in20   <= slv(DataIn(20));
					we(20) <= '1';
				else
					we(20) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO21 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(21),
		         wr     => we(21),
		         w_data => in21,
		         empty  => emp(21),
		         full   => full(21),
		         r_data => tts21
		        );
	fifo21_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(21) <= '0';
			elsif rising_edge(CLK) then
			
				if ( DataIn(21).val = '1' and full(21) = '0' ) then
					in21   <= slv(DataIn(21));
					we(21) <= '1';
				else
					we(21) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO22 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(22),
		         wr     => we(22),
		         w_data => in22,
		         empty  => emp(22),
		         full   => full(22),
		         r_data => tts22
		        );
	fifo22_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(22) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(22).val = '1' and full(22) = '0') then
					in22   <= slv(DataIn(22));
					we(22) <= '1';
				else
					we(22) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO23 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(23),
		         wr     => we(23),
		         w_data => in23,
		         empty  => emp(23),
		         full   => full(23),
		         r_data => tts23
		        );
	fifo23_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(23) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(23).val = '1' and full(23) = '0') then
					in23   <= slv(DataIn(23));
					we(23) <= '1';
				else
					we(23) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO24 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(24),
		         wr     => we(24),
		         w_data => in24,
		         empty  => emp(24),
		         full   => full(24),
		         r_data => tts24
		        );
	fifo24_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(24) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(24).val = '1' and full(24) = '0' ) then
					in24   <= slv(DataIn(24));
					we(24) <= '1';
				else
					we(24) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO25 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(25),
		         wr     => we(25),
		         w_data => in25,
		         empty  => emp(25),
		         full   => full(25),
		         r_data => tts25
		        );
	fifo25_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(25) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(25).val = '1' and full(25) = '0' ) then
					in25   <= slv(DataIn(25));
					we(25) <= '1';
				else
					we(25) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO26 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(26),
		         wr     => we(26),
		         w_data => in26,
		         empty  => emp(26),
		         full   => full(26),
		         r_data => tts26
		        );
	fifo26_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(26) <= '0';
			elsif rising_edge(CLK) then
				

				if ( DataIn(26).val = '1' and full(26) = '0' ) then
				  --report "full 26 1 from fifo input, why?";
					in26   <= slv(DataIn(26));
--					report "fifo 26 trying to write : "& std_logic'image(slv(DataIn(26))(31)) & std_logic'image(slv(DataIn(26))(30))
--                                & std_logic'image(slv(DataIn(26))(29)) & std_logic'image(slv(DataIn(26))(28))
--                                & std_logic'image(slv(DataIn(26))(27)) & std_logic'image(slv(DataIn(26))(26))
--                                & std_logic'image(slv(DataIn(26))(25)) & std_logic'image(slv(DataIn(26))(24))
--                                & std_logic'image(slv(DataIn(26))(23)) & std_logic'image(slv(DataIn(26))(22))
--                                & std_logic'image(slv(DataIn(26))(21)) & std_logic'image(slv(DataIn(26))(20))
--                                & std_logic'image(slv(DataIn(26))(19)) & std_logic'image(slv(DataIn(26))(18))
--                                & std_logic'image(slv(DataIn(26))(17)) & std_logic'image(slv(DataIn(26))(16))
--                                & std_logic'image(slv(DataIn(26))(15)) & std_logic'image(slv(DataIn(26))(14))
--                                & std_logic'image(slv(DataIn(26))(13)) & std_logic'image(slv(DataIn(26))(12))
--                                & std_logic'image(slv(DataIn(26))(11)) & std_logic'image(slv(DataIn(26))(10))
--                                & std_logic'image(slv(DataIn(26))(9)) & std_logic'image(slv(DataIn(26))(8))
--                                & std_logic'image(slv(DataIn(26))(7)) & std_logic'image(slv(DataIn(26))(6))
--                                & std_logic'image(slv(DataIn(26))(5)) & std_logic'image(slv(DataIn(26))(4))
--                                & std_logic'image(slv(DataIn(26))(3)) & std_logic'image(slv(DataIn(26))(2))
--                                & std_logic'image(slv(DataIn(26))(1)) & std_logic'image(slv(DataIn(26))(0));
					we(26) <= '1';
				else
					we(26) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO27 : entity work.fifo_gen(rtl)
		generic map(B => 32,W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(27),
		         wr     => we(27),
		         w_data => in27,
		         empty  => emp(27),
		         full   => full(27),
		         r_data => tts27
		        );
	fifo27_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(27) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(27).val = '1' and full(27) = '0' ) then
					in27   <= slv(DataIn(27));
					we(27) <= '1';
				else
					we(27) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO28 : entity work.fifo_gen(rtl)
		generic map(B => 32, W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(28),
		         wr     => we(28),
		         w_data => in28,
		         empty  => emp(28),
		         full   => full(28),
		         r_data => tts28
		        );
	fifo28_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(28) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(28).val = '1' and full(28) = '0' ) then
					in28   <= slv(DataIn(28));
					we(28) <= '1';
				else
					we(28) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO29 : entity work.fifo_gen(rtl)
		generic map(B => 32, W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(29),
		         wr     => we(29),
		         w_data => in29,
		         empty  => emp(29),
		         full   => full(29),
		         r_data => tts29
		        );
	fifo29_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(29) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(29).val = '1' and full(29) = '0' ) then
					in29   <= slv(DataIn(29));
					we(29) <= '1';
				else
					we(29) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO30 : entity work.fifo_gen(rtl)
		generic map(B => 32, W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(30),
		         wr     => we(30),
		         w_data => in30,
		         empty  => emp(30),
		         full   => full(30),
		         r_data => tts30
		        );
	fifo30_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(30) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(30).val = '1' and full(30) = '0' ) then
					in30   <= slv(DataIn(30));
					we(30) <= '1';
				else
					we(30) <= '0';
				end if;
			end if;
		end if;
	end process;
	FIFO31 : entity work.fifo_gen(rtl)
		generic map(B => 32, W => depth)
		port map(clk    => clk, reset => rst, percent_i => percent_i,
		         rd     => re(31),
		         wr     => we(31),
		         w_data => in31,
		         empty  => emp(31),
		         full   => full(31),
		         r_data => tts31
		        );
	fifo31_p : process(CLK)
		variable tmp_emp, tmp_val : std_logic_vector(11 downto 0);
		variable critical_mode    : std_logic;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				we(31) <= '0';
			elsif rising_edge(CLK) then
				
				if ( DataIn(31).val = '1' and full(31) = '0' ) then
					in31   <= slv(DataIn(31));
					we(31) <= '1';
				else
					we(31) <= '0';
				end if;
			end if;
		end if;
	end process;

end rtl;
