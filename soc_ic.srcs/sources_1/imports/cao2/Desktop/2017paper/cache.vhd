library ieee;
use ieee.std_logic_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;

entity l1_cache is
	port(
		Clock         : in  std_logic;
		reset         : in  std_logic;
		id_i          : in  IP_T;
		cpu_req_i     : in  MSG_T;
		snp_req_i     : in  MSG_T;
		bus_res_i     : in  BMSG_T;
		cpu_res_o     : out MSG_T     := ZERO_MSG;
		snp_hit_o     : out std_logic;
		snp_res_o     : out cacheline;
		-- goes to cache controller ask for data
		snp_req_o     : out MSG_T;
		snp_res_i     : in  cacheline;
		snp_hit_i     : in  std_logic;
		up_snp_req_i  : in  MSG_T;
		up_snp_res_o  : out MSG_T;
		up_snp_hit_o  : out std_logic;
		wb_req_o      : out BMSG_T;
		full_snpres_i : in  std_logic;
		-- FIFO flags
		crf_full_o    : out std_logic := '0'; -- Full flag from cpu_req FIFO
		srf_full_o    : out std_logic := '0'; -- Full flag from snp_req FIFO
		bsf_full_o    : out std_logic := '0'; -- Full flag from bus_req FIFO
        brf_full_o     : out std_logic:='0';
        srf_full_i: in std_logic;
        full_cache_req_i: in std_logic;
        
		full_crq_i    : in  std_logic;  -- TODO what is this? not implemented?
		full_wb_i     : in  std_logic;
		full_srs_i    : in  std_logic;  -- TODO where is this coming from? not implemented?
		bus_req_o     : out MSG_T     := ZERO_MSG -- a req going to the other cache
	);

end l1_cache;

architecture rtl of l1_cache is
	--bit organization
	--547 valid
	--546 exclusive
	--545-530 valid
	--529-512 tag
	--511-0 data
	type rom_type is array (natural(2 ** 5 - 1) downto 0) of std_logic_vector(547 downto 0);
	signal ROM_array : rom_type := (others => (others => '0'));
	type state is (a, b, c, d, e);
	-- Naming conventions:
	-- [c|s|b]rf is [cpu|snoop|bus]_req fifo
	-- [us|s]sf is [upstream-snoop|snoop]_resp fifo

	-- FIFO queues inputs
	-- write_enable signals for FIFO queues
	signal crf_we, srf_we, bsf_we, brf_we, ssf_we : std_logic := '0';
	-- read_enable signals for FIFO queues
	signal crf_re, srf_re, bsf_re, brf_re, ssf_re : std_logic;
	-- data_in signals
	signal crf_in, srf_in, ssf_in : MSG_T := ZERO_MSG;
signal tmp_res    : MSG_T;
            signal tmp_up_res : MSG_T;
            signal tmp_req   : cacheline;
                    signal tmp_req_b : BMSG_T;
                    signal tmp     : MSG_T;
                            signal snpreq  : MSG_T;
                            signal tmp_req_x: MSG_T;
                            signal tmp_cal: cacheline;
	-- Outputs from FIFO queues
	-- data_out signals
	signal out1, out3,                  -- TODO not used?
	 srf_out, ssf_out, crf_out : MSG_T := ZERO_MSG;
	signal brf_out, brf_in                                                           : MSG_T := ZERO_MSG;
	-- empty signals
	signal crf_emp, srf_emp, bsf_emp, brf_emp, ssf_emp : std_logic;
	-- full signals
	signal  ssf_full : std_logic := '0'; -- TODO not implemented yet?

	-- MCU (Memory Control Unit)

	-- Memory requests (data_out signals from FIFO queues)
	-- Naming conventions:
	-- [cpu|snp|usnp]_mem_[req|res|ack] memory (write) request, response, or ack for
	-- cpu, snoop (from cache), or upstream snoop (from bus on behalf of a device)
--	signal bus_req_s, snp_mem_req, mcu_write_req : MSG_T;
--	signal usnp_mem_req, usnp_mem_res            : MSG_T := ZERO_MSG; -- usnp reqs are longer
--	signal usnp_mem_ack                          : std_logic;
--	signal snp_mem_req_1, snp_mem_req_2          : MSG_T := ZERO_MSG;
--
--	signal snp_mem_ack1, snp_mem_ack2      : std_logic;
	signal bus_res, bsf_in                 : BMSG_T := ZERO_BMSG;
--	signal cpu_mem_res, write_res, upd_res : MSG_T  := ZERO_MSG;
--	signal snp_mem_res                     : MSG_T  := ZERO_MSG;
--	-- hit signals
--	signal cpu_mem_hit, snp_mem_hit, usnp_mem_hit : std_logic;
--	-- "done" signals
--	signal upd_ack, write_ack, cpu_mem_ack, snp_mem_ack : std_logic;
--
	signal cpu_res1, cpu_res2     : MSG_T := ZERO_MSG;
	signal ack1, ack2             : std_logic;
	signal snp_c_req1, snp_c_req2 : MSG_T := ZERO_MSG;
	signal snp_c_ack1, snp_c_ack2 : std_logic;

--	signal prc          : std_logic_vector(1 downto 0);
	signal tmp_cpu_res1 : MSG_T                         := ZERO_MSG;
--	signal tmp_snp_res  : MSG_T                         := ZERO_MSG;
--	signal tmp_hit      : std_logic;
--	signal tmp_mem      : std_logic_vector(40 downto 0) := (others => '0');
----	-- -this one is important!!!!
--
--	signal tidx                 : integer  := 0;
--	signal content              : std_logic_vector(547 downto 0);
--	signal upreq                : MSG_T; -- used only by up_snp_req_handler
--	signal snpreq               : MSG_T; -- used only by cpu_req_handler
--	signal fidx                 : integer  := 0;
--	signal tcontent             : std_logic_vector(547 downto 0);
	constant DEFAULT_FIFO_DEPTH : positive := 8;

--	signal snp_wt     : MSG_T;
--	signal snp_wt_ack : std_logic;

	signal readreq : MSG_T;
	signal readres : cacheline;
	signal rd_hit  : std_logic;

	signal writereq : cacheline;
	signal writeack : std_logic;

	signal readreq1, readreq2, readreq3                                                             : MSG_T;
	signal writereq1, writereq2, writereq3, writereq4, writereq5, writereq6                         : BMSG_T;
	signal twritereq1, twritereq2, twritereq3, twritereq4, twritereq5, twritereq6                         : cacheline;
	signal treadreq1, treadreq2, treadreq3                                                             : MSG_T;
	signal rdack1, rdack2, rdack3, wtack1, wtack2, wtack3, wtack4, wtack5, wtack6, ack7, ack8, ack9 : std_logic;
	signal frontinfo: std_logic_vector(17 downto 0);
	--signal tmp_snp_req_s : MSG_T;
    --signal tmp_snp_req   : cacheline;
begin

	
	ureq_fifo : entity work.fifo(rtl)   -- req from device
		generic map(
			FIFO_DEPTH => 300
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => brf_in,
			WriteEn => brf_we,
			ReadEn  => brf_re,
			DataOut => readreq3,
			Full    => brf_full_o,
			Empty   => brf_emp
		);

	ureq_fifo_p : process(clock, reset)
	begin
		if reset = '1' then
			brf_we <= '0';
		elsif rising_edge(Clock) then
			if up_snp_req_i.val = '1' then
				brf_in <= up_snp_req_i;
				brf_we <= '1';
			else
				brf_we <= '0';
			end if;
		end if;
	end process;

	snp_req_fifo : entity work.fifo(rtl)
		generic map(
			FIFO_DEPTH => 18
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => srf_in,
			WriteEn => srf_we,
			ReadEn  => srf_re,
			DataOut => readreq2,
			Full    => srf_full_o,
			Empty   => srf_emp
		);
	bus_res_fifo : entity work.b_fifo(rtl)
		generic map(
			FIFO_DEPTH => 8
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => bsf_in,
			WriteEn => bsf_we,
			ReadEn  => bsf_re,
			DataOut => writereq2,
			Full    => bsf_full_o,
			Empty   => bsf_emp
		);
	cpu_res_arbiter : entity work.arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => cpu_res1,
			ack1  => ack1,
			din2  => cpu_res2,
			ack2  => ack2,              -- o
			dout  => cpu_res_o
		);
	snp_c_req_arbiter : entity work.arbiter2_full(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => snp_c_req1,
			ack1  => snp_c_ack1,
			din2  => snp_c_req2,
			ack2  => snp_c_ack2,
			dout  => snp_req_o,
			full   => srf_full_i
		);

	readreq_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => treadreq1,
			ack1  => rdack1,
			din2  => treadreq2,
			ack2  => rdack2,
			din3  => treadreq3,
			ack3  => rdack3,
			din4  => ZERO_MSG,
			ack4  => ack7,
			din5  => ZERO_MSG,
			ack5  => ack8,
			din6  => ZERO_MSG,
			ack6  => ack9,
			dout  => readreq
		);

	writereq_arbiter : entity work.b_c_arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => twritereq1,
			ack1  => wtack1,
			din2  => twritereq2,
			ack2  => wtack2,
			din3  => twritereq3,
			ack3  => wtack3,
			din4  => twritereq4,
			ack4  => wtack4,
			din5  => twritereq5,
			ack5  => wtack5,
			din6  => twritereq6,
			ack6  => wtack6,
			dout  => writereq
		);
	cpu_req_fifo : entity work.fifo(rtl)
		generic map(
			FIFO_DEPTH => 18
		)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => crf_in,
			WriteEn => crf_we,
			ReadEn  => crf_re,
			DataOut => readreq1,
			Full    => crf_full_o,
			Empty   => crf_emp
		);

	-- * Stores cpu requests into fifo
	-- * cpu_req_i;; -> ;crf_in, crf_we;
	cpu_req_fifo_p : process(clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
                    crf_we <= '0';
                elsif cpu_req_i.val = '1' then -- if req is valid
					crf_in <= cpu_req_i;
					crf_we <= '1';
				
			else
				crf_we <= '0';
			end if;
		end if;
	end process;

	-- * Stores snoop requests into fifo
	-- * snp_req_i;; -> ;srf_in, srf_we;
	snp_req_fifo_p : process(clock)
	begin
		if rising_edge(Clock) then
			if reset = '1' then
                    srf_we <= '0';
            elsif snp_req_i.val = '1' then
				srf_in <= snp_req_i;
				srf_we <= '1';
			else
				srf_we <= '0';
			end if;
		end if;
	end process;

	-- * Stores bus response into fifo
	-- * bus_res_i;; -> ;bsf_in, bsf_we;
	bus_res_fifo_p : process(clock)
	begin
		if rising_edge(Clock) then
		if reset='1' then
		  bsf_we <='0';
		
			elsif bus_res_i.val = '1' then

				bsf_in <= bus_res_i;
				bsf_we <= '1';
			else
				bsf_we <= '0';
			end if;
		end if;
	end process;

	
	-- * Process requests from cpu
	-- * snp_res_i,snp_hit_i;cpu_mem_res;
	-- *  -> ;cpu_res1, mcu_write_req, crf_re, snp_c_req1, cpu_mem_ack, cpu_mem_hit,
	-- *      tmp_cpu_res1, cpu_res1, snp_req, snp_c_ack1;
	-- *     bus_req_o
	cpu_req_p : process( clock)
		-- TODO should they be signals instead of variables?
		variable st      : integer := 0;
		variable prev_st : integer := -1;
		variable idx     : integer := 0;
		variable saved_adr : std_logic_vector(31 downto 0);
		variable tmp_front: std_logic_vector(35 downto 0);
		variable tmp_bus_req: MSG_T;
	begin
		
		-- tmp_write_req <= nilreq;
		if rising_edge(Clock) then
		if (reset = '1') then
                    -- reset signals
                    cpu_res1      <= ZERO_MSG;
                    bus_req_o     <= ZERO_MSG;
                    crf_re        <= '0';
                    snp_c_req1    <= ZERO_MSG;
			elsif st = 0 then              -- wait_fifo
				bus_req_o <= ZERO_MSG;
				if crf_re = '0' and crf_emp = '0' then
					crf_re <= '1';
					st     := 1;
				end if;
			elsif st = 1 then           -- access
				crf_re <= '0';
				if is_pwr_cmd(cpu_req_i) then -- if power request
                    bus_req_o <= cpu_req_i;
                end if;
				if readreq1.val='1' then
					treadreq1 <= readreq1;
					--tmp_req_x <= readreq1;
				end if;
				if rdack1 = '1' then
					st := 2;
					treadreq1.val<='0';
				end if;
			elsif st = 2 then
				if readres.val = '1' then
					if rd_hit = '1' then
						if readres.cmd = WRITE_CMD then
							tmp_cal <= readres;
							tmp_cal.frontinfo(35 downto 35)<="1";--its dirty now
							twritereq3    <= tmp_cal;
							---here need to use the index to get the correct data 
							tmp_cpu_res1 <= (readres.val,readres.cmd, readres.tag,readres.id,readres.adr, readres.dat(31 downto 0));
							st           := 3;
						else            -- read cmd
							cpu_res1 <= (readres.val,readres.cmd, readres.tag,readres.id,readres.adr, readres.dat(31 downto 0));
							st       := 4;
						end if;
					else  
					  snp_c_req1 <= (readres.val,readres.cmd, readres.tag,readres.id,readres.adr, readres.dat(31 downto 0));
                      saved_adr := readres.adr;
                      st         := 5;
					end if;
			end if;
			
			elsif st = 3 then           -- get_resp_from_mcu
				if wtack3 = '1' then
					-- once the write is send out, won't wait for write acknowledge, cauze dont care anymore
					twritereq3.val <= '0';
					cpu_res1  <= tmp_cpu_res1;
					st        := 4;
				end if;
			elsif st = 4 then           -- output_resp
				if ack1 = '1' then
					cpu_res1 <= ZERO_MSG;
					st       := 0;
				end if;
			elsif st = 5 then           -- get_snp_req_ack
				if snp_c_ack1 = '1' then
					snp_c_req1 <= ZERO_MSG;
					st         := 6;
				end if;
			-- now we wait for the snoop response
			elsif st = 6 then           -- get_snp_resp
				if snp_res_i.val = '1' then
					-- if we get a snoop response  and the address is the same  => 
					if snp_res_i.adr =saved_adr and (snp_res_i.tag = CPU0_TAG or snp_res_i.tag = CPU1_TAG) then
						if snp_hit_i = '1' then
							st := 7;
							if snp_res_i.cmd=WRITE_CMD then
								tmp_front := "111111111111111111"&snp_res_i.adr(31 downto 14);
							else
								tmp_front := "001111111111111111"&snp_res_i.adr(31 downto 14);
							end if;
							-- the data inside snp-res-i need to be slightly changed, as the exclusive, need to change
							twritereq3 <= (snp_res_i.val, snp_res_i.cmd, snp_res_i.tag, snp_res_i.id, snp_res_i.adr,snp_res_i.dat,tmp_front);
							tmp       <= (snp_res_i.val, snp_res_i.cmd, snp_res_i.tag, snp_res_i.id, snp_res_i.adr,snp_res_i.dat(31 downto 0));
							
						else
							tmp_bus_req := (snp_res_i.val, snp_res_i.cmd, snp_res_i.tag, snp_res_i.id, snp_res_i.adr,snp_res_i.dat(31 downto 0));
							st        := 8;
						end if;
					end if;
				end if;
				elsif st =8 then
				 if full_cache_req_i/='1' then
				 bus_req_o<= tmp_bus_req;
				 st :=0;
				 end if;
				
			elsif st = 7 then
				if wtack3 = '1' then
					twritereq3.val <= '0';
					-- once receive the data from other cache, write to its own memory, then don't care,
					-- send the cpu response 
					cpu_res1 <= tmp;
					st       := 4;
				end if;
			end if;
		end if;
	end process;

	-- * Process snoop requests (from another cache)
	snp_req_p : process( clock)
		variable addr          : ADR_T;
		variable state         : integer := 0;
		
		variable tmp_hit       : std_logic;
		variable idx: integer;
		variable tmp_front: std_logic_vector(35 downto 0);
		variable tmp_snp_req: cacheline;
		variable tmp_snp_req_s: MSG_T;
	begin
		
		if rising_edge(Clock) then
		if (reset = '1') then
                    -- reset signals
                    snp_res_o     <= ZERO_c;
                    snp_hit_o     <= '0';
                    srf_re        <= '0';
                    --snp_mem_req_1 <= ZERO_c;
			elsif state = 0 then           -- wait_fifo
				snp_res_o <= ZERO_c;
				if srf_re = '0' and srf_emp = '0' then
					srf_re <= '1';
					state  := 1;
				end if;
			elsif state = 1 then
				if readreq2.val = '1' then
					tmp_snp_req_s := readreq2;
					treadreq2 <= readreq2;
				end if;
				srf_re <= '0';
				if rdack2 = '1' then
					treadreq2.val <='0';
					state := 2;
				end if;
			elsif state = 2 then
				if readres.val = '1' then
					tmp_hit       := rd_hit;
					tmp_snp_req   := (readres.val, readres.cmd, readres.tag, readres.id, readres.adr, readres.dat,readres.frontinfo);
					if readres.cmd = WRITE_CMD then
						-- modify the data
						-- invalidate the data
						idx :=to_integer(unsigned(readres.adr(3 downto 0)));
						tmp_snp_req.dat(511-idx*16 downto 511-idx*16-31) := tmp_snp_req_s.dat;
						--set the invalid to 0
						tmp_snp_req.frontinfo(33-idx) :='0';
					else                -- read command
					-- set the exclusive bit to 1
						tmp_snp_req.frontinfo(34 downto 34):="0";
					end if;
					--twritereq4 <= tmp_snp_req;
					twritereq4 <= tmp_snp_req;
					---twritereq4 <= (readres.val, readres.cmd, readres.tag, readres.id, readres.adr, tmp_snp_req.dat,tmp_snp_req.frontinfo);
					addr          := tmp_snp_req.adr;
					state         := 3;
					
				end if;
				---reportort "cache state 2";
			elsif state = 3 then        -- get_ack
				if wtack4 = '1' then
					twritereq4.val <= '0';
					state         := 4;
				end if;
				---reportort "cache state 3";
			elsif state = 4 then  
			 ---reportort "cache state 4";     
				if writeack = '1' then
				    
					snp_res_o <= ('1', tmp_snp_req.cmd, tmp_snp_req.tag, tmp_snp_req.id, tmp_snp_req.adr, tmp_snp_req.dat,tmp_snp_req.frontinfo);
					snp_hit_o <= tmp_hit;
					state     := 0;
				end if;
			end if;
		end if;
	end process;

	-- * Process upstream snoop requests (from bus on behalf of devices)
	-- the difference --with snp_req-- is that when it's  uprequest snoop, once it
	-- fails (a miss), it will go to the other cache snoop
	-- also when found, the write will be operated here directly, and return
	-- nothing
	-- if it's read, then the data will be returned to request source
	ureq_req_p : process( clock)
		variable state      : integer := 0;
		variable tmp_h      : std_logic;
		variable tmp_snp_res: cacheline;
		variable tmp_up_snp_res: MSG_T;
	begin
		
		if rising_edge(Clock) then
		      if (reset = '1') then
                    state        := 0;
                    up_snp_res_o <= ZERO_MSG;
                    up_snp_hit_o <= '1';        -- TODO should it be 0?
                    brf_re       <= '0';
                    snp_c_req2   <= ZERO_MSG;
			elsif state = 0 then           -- wait_fifo
				up_snp_res_o <= ZERO_MSG;
				--up_snp_hit_o <= '0';
				if brf_re = '0' and brf_emp = '0' then
					brf_re <= '1';
					state  := 1;
				end if;
			elsif state = 1 then        -- access
				brf_re <= '0';
				if readreq3.val='1' then
					treadreq3 <= readreq3;
				end if;
				if rdack3 = '1' then
					treadreq3.val <='0';
					state := 6;
				end if;
			elsif state = 6 then
				if readres.val = '1' then -- if hit
					tmp_up_res <= (readres.val, readres.cmd, readres.tag, readres.id, readres.adr, readres.dat(31 downto 0));
					if rd_hit = '1' then
					   state :=7;
					   tmp_up_snp_res :=(readres.val, readres.cmd, readres.tag, readres.id, readres.adr, readres.dat(31 downto 0));
					-- -here we may need to modify it :: meaning the exclusive bit, the valid bit and everything, not sure we should worry this for
					-- upstream request, 
					-- maybe not  =>  if it is read, we dont care, not cache coherency=> if write, already done in read process
					else                -- it's a miss
					-- -----reportort "miss form cache 0, now send to cache1";
					snp_c_req2 <= (readres.val, readres.cmd, readres.tag, readres.id, readres.adr, readres.dat(31 downto 0));
                                            state      := 2;
					end if;
					end if;
			elsif state =7 then
			if full_snpres_i /= '1' then
			         up_snp_res_o <= tmp_up_snp_res; 
                     up_snp_hit_o <= '1';
                     state :=0;
                end if;
					
			elsif state = 2 then        -- wait_peer
				if snp_c_ack2 = '1' then
					-- -----reportort "sent";
					snp_c_req2 <= ZERO_MSG;
					state      := 3;
				end if;
			elsif state = 3 then        -- output_resp
				if snp_res_i.val = '1' then
					-- if we get a snoop response and the address is the same  => 
					-- -return it to the bus
					if snp_res_i.adr = tmp_up_res.adr then
						tmp_res <= (snp_res_i.val, snp_res_i.cmd,
						            snp_res_i.tag, snp_res_i.id,
						            snp_res_i.adr, snp_res_i.dat(31 downto 0));
						-- TODO upreq is updated after pcs is finished. Is this a problem?
						tmp_h := snp_hit_i;
						state := 5;
					end if;
				end if;
			elsif state = 5 then
				if full_snpres_i /= '1' then
					up_snp_res_o <= tmp_res;
					up_snp_hit_o <= tmp_h;
					-----reportort "1 cache send out";
					state        := 0;
				end if;
			end if;
		end if;
	end process;

	-- * Process pwr response
	-- pwr_res_p : process(reset,clock)
	-- variable tmp_msg : MSG_T;
	-- begin
	-- if reset='1' then
	-- elsif rising_edge(Clock) then
	-- tmp_msg := bus_res(BMSG_WIDTH-1 downto BMSG_WIDTH - MSG_WIDTH);
	-- if is_valid(tmp_msg) and is_pwr_cmd(tmp_msg) then
	-- -----reportort integer'image(BMSG_WIDTH - MSG_WIDTH);
	-- cpu_res2 <= tmp_msg; -- TODO should be cpu_res3
	-- end if;
	-- end if;
	-- end process;

	-- * Process snoop response (to snoop request issued by this cache)
	bus_res_p : process(clock)
		variable state     : integer := 0;
		
	begin
		if rising_edge(Clock) then
		  if reset = '1' then
                    -- reset signals
                    cpu_res2 <= ZERO_MSG;
                    -- upd_req <= nilreq;
                    bsf_re <= '0';
			elsif state = 0 then           -- wait_fifo
				if bsf_re = '0' and bsf_emp = '0' then
					bsf_re <= '1';
					state  := 1;
				end if;
			elsif state = 1 then
				if writereq2.val = '1' then
					tmp_req_b <= writereq2;
					twritereq2 <= (writereq2.val,writereq2.cmd,writereq2.tag,writereq2.id,writereq2.adr,writereq2.dat,"011111111111111111"&writereq2.adr(31 downto 14));
				end if;
				bsf_re <= '0';
				if wtack2 = '1' then
					-- the data content here is not correct
					-- need to consider the index
					twritereq2.val <='0';
					--tmp_req  := (tmp_req_b.val, tmp_req_b.cmd, tmp_req_b.tag, tmp_req_b.id, tmp_req_b.adr, tmp_req_b.dat(31 downto 0));
					cpu_res2 <= (tmp_req_b.val, tmp_req_b.cmd, tmp_req_b.tag, tmp_req_b.id, tmp_req_b.adr, tmp_req_b.dat(31 downto 0));
					state    := 2;
				end if;
			elsif state = 2 then        --
				if ack2 = '1' then      -- TODO ack2 from cpu_resp_arbiter? meaning?
					cpu_res2 <= ZERO_MSG;
					state    := 0;
				end if;
			end if;

		end if;
	end process;

	-- * Deals with cache memory
	-- * full_wb_i;
	-- * bus_req_s, snp_mem_req, usnp_mem_req,
	-- *   mcu_write_req, bus_res, ;
	-- *   -> ;
	-- *      ROM_array, write_ack, write_res, upd_ack, upd_res
	-- *        cpu_mem_ack, cpu_mem_hit, cpu_mem_res,
	-- *        snp_mem_ack, snp_mem_hit, snp_mem_res,
	-- *        usnp_mem_ack, usnp_mem_hit, usnp_mem_res;
	-- *      wb_req_o

	mem_read : process(clock)
		variable idx     : integer;
		variable memcont : std_logic_vector(547 downto 0);
		variable offset : integer;
	begin
		if rising_edge(clock) then
			readres<=ZERO_c;
				if readreq.val = '1' then
					idx     := to_integer(unsigned(readreq.adr(8 downto 0)));
					offset :=idx mod 16;
					idx := idx/16;
					memcont := ROM_array(idx);
					readres <= (readreq.val, readreq.cmd, readreq.tag, readreq.id, 
					readreq.adr, memcont(511 downto 0),memcont(547 downto 512));
--                    readres.val <= '1';
                   -- readres.cmd <= readreq.cmd;
--                    readres.tag <= readreq.tag;
--                    readres.id <= readreq.tag;
--                    readres.adr <= readreq.adr;
--                    readres.dat <= memcont(511 downto 0);
--                    readres.frontinfo <= memcont(547 downto 512);
					if memcont(547-offset downto 547-offset) = "0" then -- 31 to 14
						rd_hit <= '0';
					elsif  readreq.cmd = READ_CMD and memcont(546 downto 546) = "0" then
					    rd_hit <='0';
                    elsif readreq.cmd = WRITE_CMD then
                        rd_hit <='0';
                    elsif  memcont(529 downto 512) /= readreq.adr(31 downto 14) then
                        rd_hit <='0';
					else
						rd_hit <= '1';
					end if;
--					--not consider for now
----					if readreq.cmd=WRITE_CMD then
----						---here need to consider the index => .add to TODO
----						memcont(511-16*offset downto 479-offset*16) := readreq.dat;
----						memcont(547 downto 547):="1";--it is dirty now
----						twritereq4 <= (readreq.val, readreq.cmd, readreq.tag, readreq.id, readreq.addr, memcont(511 downto 0),memcont(547 downto 512),);
----						st := b;
----					end if;
				end if;
--			elsif st = b then
--				if wtack4='1' then
--					writereq4.val<='0';
--					st := a;
--				end if;
			end if;
	end process;
	
	
	mem_write: process(clock)
		variable idx     : integer;
		variable memcont : std_logic_vector(547 downto 0);
		
		variable st      : state := a;
	begin
		if rising_edge(clock) then
			writeack <='0';			
			if writereq.val = '1' then
					idx     := to_integer(unsigned(writereq.adr(4 downto 0)));
					ROM_array(idx)<=writereq.frontinfo&writereq.dat;
					writeack <='1';
			end if;
		end if;
	end process;




















--	mem_control_unit : process(reset, clock)
--		variable idx     : integer;
--		variable memcont : std_logic_vector(547 downto 0);
--	begin
--		if (reset = '1') then
--			-- reset signals;
--			cpu_mem_res <= ZERO_MSG;
--			turn        := 0;
--		elsif rising_edge(Clock) then
--			cpu_mem_res <= ZERO_MSG;
--			-- cpu memory request
--			if bus_req_s.val = '1' then
--				cpu_mem_ack <= '0';
--				idx         := to_integer(unsigned(bus_req_s.adr(14 downto 0)));
--				memcont     := ROM_array(idx);
--				-- if we can't find it in memory
--				if memcont(52 downto 52) = "0" or (bus_req_s.cmd = READ_CMD and memcont(50 downto 50
--) = "0") or bus_req_s.cmd = WRITE_CMD or memcont(49 downto 32) /= bus_req_s.adr(31 downto 14) then -- 31 to 14
--					cpu_mem_ack <= '1';
--					cpu_mem_hit <= '0';
--					cpu_mem_res <= bus_req_s;
--				else                    -- it's a hit
--					cpu_mem_ack <= '1';
--					cpu_mem_hit <= '1';
--					if bus_req_s.cmd = WRITE_CMD then
--						cpu_mem_res <= bus_req_s;
--					else
--						cpu_mem_res <= (bus_req_s.val, bus_req_s.cmd, bus_req_s.tag,
--						                bus_req_s.id, bus_req_s.adr, memcont(31 downto 0));
--					end if;
--				end if;
--
--			end if;
--		end if;
--	end process;
--	mem_2 : process(reset, clock)
--		variable idx     : integer;
--		variable memcont : std_logic_vector(547 downto 0);
--	begin
--		if (reset = '1') then
--			-- reset signals;
--			snp_mem_res <= ZERO_MSG;
--		elsif rising_edge(Clock) then
--			snp_mem_res <= ZERO_MSG;
--			-- snoop memory request
--			if snp_mem_req.val = '1' then
--				idx         := to_integer(unsigned(snp_mem_req.adr(13 downto 0)));
--				memcont     := ROM_array(idx);
--				snp_mem_ack <= '0';
--				-- if we can't find it in memory
--				if memcont(52 downto 52) = "0" or -- it's a miss
--					 memcont(49 downto 32) /= snp_mem_req.adr(31 downto 14) then -- cmp 
--					snp_mem_ack <= '1';
--					snp_mem_hit <= '0';
--					snp_mem_res <= snp_mem_req;
--				else
--					snp_mem_ack <= '1';
--					snp_mem_hit <= '1';
--					-- if it's write, invalidate the cache line
--					if snp_mem_req.cmd = WRITE_CMD then
--						ROM_array(idx)(52)          <= '0'; -- it's a miss
--						ROM_array(idx)(31 downto 0) <= snp_mem_req.dat;
--						snp_mem_req.dat             <= ROM_array(idx)(31 downto 0);
--						snp_mem_res                 <= snp_mem_req;
--					else
--						-- if it's read, mark the exclusive as 0
--						ROM_array(idx)(50) <= '0';
--						snp_mem_res        <= ('1', snp_mem_req.cmd, snp_mem_req.tag,
--						                snp_mem_req.id, snp_mem_req.adr,
--						                ROM_array(idx)(31 downto 0));
--					end if;
--
--				end if;
--			end if;
--		end if;
--	end process;
--
--	mem3 : process(reset, clock)
--		variable idx     : integer;
--		variable memcont : std_logic_vector(547 downto 0);
--		variable shifter : boolean := false;
--		variable turn    : integer := 0;
--	begin
--		if (reset = '1') then
--			-- reset signals;
--
--			upd_ack <= '0';
--		elsif rising_edge(Clock) then
--
--			upd_ack <= '0';
--
--		-- cpu memory request
--		-- -- upstream snoop req
--		-- elsif usnp_mem_req.val = '1' then
--		-- idx     := to_integer(unsigned(usnp_mem_req.adr(13 downto 0))); -- index
--		-- memcont := ROM_array(idx);
--		-- usnp_mem_ack <= '0';
--		-- -- if we can't find it in memory
--		-- -- invalide  ---or tag different
--		-- -- or its write, but not exclusive
--		-- if memcont(52 downto 52) = "0" or -- mem not found
--		-- (bus_req_s.cmd = WRITE_CMD and memcont(50 downto 50) = "0") or -- TODO what is this bit?
--		-- memcont(49 downto 32) /= usnp_mem_req.adr(31 downto 14) then
--		-- usnp_mem_ack <= '1';
--		-- usnp_mem_hit <= '0';
--		-- usnp_mem_res <= usnp_mem_req;
--		-- else                    -- it's a hit
--		-- usnp_mem_ack <= '1';
--		-- usnp_mem_hit <= '1';
--		-- -- if it's write, write it directly
--		-- -- ---this need to be changed TODO ?
--		-- if usnp_mem_req.cmd = WRITE_CMD then
--		-- ROM_array(idx)(52)          <= '0';
--		-- ROM_array(idx)(31 downto 0) <= usnp_mem_req.dat;
--		-- usnp_mem_res                <= ('1', usnp_mem_req.cmd, usnp_mem_req.tag,
--		-- usnp_mem_req.id, usnp_mem_req.adr,
--		-- ROM_array(idx)(31 downto 0));
--		-- else
--		-- -- if it's read, mark the exclusive as 0
--		-- -- -not for this situation, because it is shared by other ips
--		-- -- -ROM_array(idx)(54) <= '0';
--		-- usnp_mem_res <= ('1', usnp_mem_req.cmd, usnp_mem_req.tag,
--		-- usnp_mem_req.id, usnp_mem_req.adr,
--		-- ROM_array(idx)(31 downto 0));
--		-- end if;
--		-- end if;
--
--		-- snp_wt_ack <= '0';
--		-- content    <= ROM_array(7967);
--		end if;
--	end process;
--	mem4 : process(reset, clock)
--		variable idx     : integer;
--		variable memcont : std_logic_vector(547 downto 0);
--		variable shifter : boolean := false;
--		variable turn    : integer := 0;
--	begin
--		if (reset = '1') then
--			-- reset signals;
--
--			write_ack <= '0';
--			turn      := 0;
--		elsif rising_edge(Clock) then
--
--			write_ack <= '0';
--			upd_ack   <= '0';
--			wb_req_o  <= ZERO_BMSG;
--
--		-- cpu memory request
--		-- elsif mcu_write_req.val = '1' then
--		-- idx            := to_integer(unsigned(mcu_write_req.adr(13 downto 0)));
--		-- ROM_array(idx) <= "110" & mcu_write_req.adr(31 downto 14) & mcu_write_req.dat;
--		-- write_ack      <= '1';
--		-- upd_ack        <= '0';
--		-- write_res      <= mcu_write_req;
--		-- turn           := 0;
--		-- elsif snp_wt.val = '1' then
--		-- turn           := 0;
--		-- idx            := to_integer(unsigned(snp_wt.adr(13 downto 0)));
--		-- ROM_array(idx) <= "100" & snp_wt.adr(31 downto 14) & snp_wt.dat;
--		-- snp_wt_ack     <= '1';
--		-- turn           := 0;
--		-- elsif bus_res.val = '1' then
--		-- turn    := 0;
--		-- idx     := to_integer(unsigned(bus_res.adr(13 downto 0))) /16 * 16;
--		-- tidx    <= to_integer(unsigned(bus_res.adr(13 downto 0)));
--		-- memcont := ROM_array(idx);
--
--		-- -- if tags do not match, dirty bit is 1,
--		-- -- and write_back fifo in BUS is not full,
--		-- if memcont(52 downto 52) = "1" and memcont(51 downto 51) = "1" and memcont(49 downto 32) /= bus_res.adr(31 downto 14) and full_wb_i /= '1' then
--		-- wb_req_o <= ('1', WRITE_CMD, ZERO_TAG, ZERO_ID, bus_res.adr,
--		-- ROM_array(idx + 15)(31 downto 0) & ROM_array(idx + 14)(31 downto 0) & ROM_array(idx + 13)(31 downto 0)
-- & ROM_array(idx + 12)(31 downto 0) & ROM_array(idx + 11)(31 downto 0) & ROM_array(idx + 10)(31 downto 0) &
-- ROM_array(idx + 9)(31 downto 0) & ROM_array(idx + 8)(31 downto 0) & ROM_array(idx + 7)(31 downto 0) & 
--ROM_array(idx + 6)(31 downto 0) & ROM_array(idx + 5)(31 downto 0) & ROM_array(idx + 4)(31 downto 0) &
-- ROM_array(idx + 3)(31 downto 0) & ROM_array(idx + 2)(31 downto 0) & ROM_array(idx + 1)(31 downto 0) & ROM_array(idx)(31 downto 0));
--		-- end if;
--		-- ROM_array(idx + 15) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(511 downto 480);
--		-- ROM_array(idx + 14) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(479 downto 448);
--		-- ROM_array(idx + 13) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(447 downto 416);
--		-- ROM_array(idx + 12) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(415 downto 384);
--		-- ROM_array(idx + 11) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(383 downto 352);
--		-- ROM_array(idx + 10) <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(351 downto 320);
--		-- ROM_array(idx + 9)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(319 downto 288);
--		-- ROM_array(idx + 8)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(287 downto 256);
--		-- ROM_array(idx + 7)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(255 downto 224);
--		-- ROM_array(idx + 6)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(223 downto 192);
--		-- ROM_array(idx + 5)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(191 downto 160);
--		-- ROM_array(idx + 4)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(159 downto 128);
--		-- ROM_array(idx + 3)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(127 downto 96);
--		-- ROM_array(idx + 2)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(95 downto 64);
--		-- ROM_array(idx + 1)  <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(63 downto 32);
--		-- ROM_array(idx)      <= "101" & bus_res.adr(31 downto 14) & bus_res.dat(31 downto 0);
--		-- upd_ack             <= '1';
--		-- upd_res             <= (bus_res.val, bus_res.cmd, bus_res.tag, bus_res.id, bus_res.adr,
--		-- bus_res.dat(to_integer(unsigned(bus_res.adr(3 downto 0)))
--		-- * 32 + 31 downto to_integer(unsigned(bus_res.adr(3 downto 0))) * 32));
--		-- write_ack           <= '0';
--		end if;
--	-- end if;
--	end process;

end rtl;
