library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity cache_req_m is
	Port(
		Clock       : in    std_logic;
		reset       : in    std_logic;
		re          : inout std_logic;
		emp         : in    std_logic;
		cache_req_i : in    MSG_T;
		pwr_req_o   : out   MSG_T;
		tomem_o     : out   MSG_T;
		togfx_o     : out   MSG_T;
		touart_o    : out   MSG_T;
		tousb_o     : out   MSG_T;
		toaudio_o   : out   MSG_T;
		pwr_ack_i   : in    std_logic;
		mem_ack_i   : in    std_logic;
		gfx_ack_i   : in    std_logic;
		uart_ack_i  : in    std_logic;
		usb_ack_i   : in    std_logic;
		audio_ack_i : in    std_logic
	);
end cache_req_m;

architecture rtl of cache_req_m is
	--  signal tmp_cache_req1, tmp_cache_req2: MSG_T;
	signal cache_cmd : std_logic_vector(7 downto 0);
	signal cache_cmd1 : std_logic_vector(7 downto 0);
begin
	cache1_req_p : process( Clock)
		variable nilreq         : MSG_T                          := ZERO_MSG;
		variable tmp_cache_req1 : MSG_T;
		variable state          : integer                        := 0;
		variable count          : integer                        := 0;
		variable nildata        : std_logic_vector(543 downto 0) := (others => '0');
		variable b              : boolean                        := true;
		variable prev_st        : integer                        := -1;
	begin
		if rising_edge(Clock) then
			cache_cmd1 <= cache_req_i.cmd;
			if reset = '1' then
                        -- snp_req2 <= nilreq;
                        re <= '0';
                    elsif state = 0 then
				if re = '0' and emp = '0' then
					re    <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re <= '0';
				
				cache_cmd <= cache_req_i.cmd;
				if cache_req_i.val = '1' and is_pwr_cmd(cache_req_i) then
					--report "pwr send out, pwr_req_o! " & integer'image(to_integer(unsigned(cache_req_i.dat)));
          			pwr_req_o <= cache_req_i;
					state     := 4;
				-- TODO CHECK THE CASE BELOW, SEEMS WRONG
				-- elsif is_valid(cache_req_i) and cache_req_i.adr = adr_1 then
				-- state      := 3;
				-- ----should return to cache, let it perform snoop again!!!
				-- -----
				-- ----don't forget to fill this up
				-- -----
				-- bus_res1_7 <= '1' & "11111111" & nildata;
				elsif cache_req_i.val = '1' then
					--report "state 0";
    					 tmp_cache_req1 := cache_req_i;
					state          := 2;
				else
					state := 1;
				end if;
			elsif state = 2 then
				-- dbg("00" & tmp_cache_req1(62 downto 61));
				-- Adding tag so that we know where msg came from
				-- tmp_cache_req1.tag := cache_req_i.tag;
				if tmp_cache_req1.adr(31 downto 31) = "1" then
				--is_mem_req(tmp_cache_req1) then
					tomem_o <= tmp_cache_req1; -- TODO hard-coded cpu1 id?
					state := 5;
				elsif tmp_cache_req1.adr(30 downto 29) = "00" then
					togfx_o <= tmp_cache_req1;
					state   := 6;
				elsif tmp_cache_req1.adr(30 downto 29) = "01" then
					touart_o <= tmp_cache_req1;
					state    := 7;
				elsif tmp_cache_req1.adr(30 downto 29) = "10" then
					tousb_o <= tmp_cache_req1;
					state   := 8;
				elsif tmp_cache_req1.adr(30 downto 29) = "11" then
					toaudio_o <= tmp_cache_req1;
					state     := 9;
				end if;
			-- elsif state = 3 then
			-- if brs1_ack5 = '1' then
			-- bus_res1_7 <= (others => '0');
			-- end if;
			elsif state = 4 then        -- wait until pwr_arbiter handles request
				if pwr_ack_i = '1' then
					--report "pwr ack received";
          pwr_req_o <= ZERO_MSG;
					state     := 0;
				end if;
			elsif state = 5 then
				if mem_ack_i = '1' then
					state   := 0;
					tomem_o <= ZERO_MSG;
				end if;
			elsif state = 6 then
				if gfx_ack_i = '1' then
					state   := 0;
					togfx_o <= ZERO_MSG;
				end if;
			elsif state = 7 then        -- MERGE durw
				if uart_ack_i = '1' then
					state    := 0;
					touart_o <= ZERO_MSG;
				end if;
			elsif state = 8 then
				if usb_ack_i = '1' then
					state   := 0;
					tousb_o <= ZERO_MSG;
				end if;
			elsif state = 9 then        -- MERGE durw
				if audio_ack_i = '1' then
					state     := 0;
					toaudio_o <= ZERO_MSG;
				end if;
			end if;
		end if;
	end process;
end rtl;
