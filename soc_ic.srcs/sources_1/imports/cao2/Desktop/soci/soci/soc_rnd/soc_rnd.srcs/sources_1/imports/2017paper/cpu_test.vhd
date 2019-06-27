library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;
use work.test.all;
--use work.rand.all;

entity cpu_test is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    en           : in  std_logic;
    
    id_i         : in IP_T;

    cpu_req_o    : out MSG_T;
    cpu_res_i    : in MSG_T;
    cpu_req_ack_i: in std_logic;
    restart_i    : in std_logic;
    seed_i       : in natural;
    done_o       : out std_logic
    );

end cpu_test;

architecture rwt of cpu_test is
  signal sim_end : std_logic := '0';
  signal r : std_logic_vector(31 downto 0);
  signal tag: IPTAG_T:= ZERO_TAG;
  constant overall_delay: positive := 20;
  constant seed: integer := to_integer(unsigned(TEST(RW))) + seed_i;
begin
  set_tag: process(rst)
	begin
		if rst='1' then
			if id_i = CPU0 then
      			tag <= CPU0_TAG;
     		elsif id_i=CPU1 then
     			tag <= CPU1_TAG;
     		end if;
		end if;
	end process;
	
   rndgen_ent : entity work.rndgen(rtl) port map (
     clk    => clk,
     rst    => rst,
     en     => en,
     seed_i => seed,
     rnd_o  => r
     );

  done_o <= (not en) or sim_end;

 
  clk_counter : process(clk, en, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if en = '1' and sim_end = '1' and b then
      info("rwt ended in cpu " & str(id_i) & ", clock cycles is " & str(count));
      b := false;
    elsif en = '1' and (rising_edge(clk)) then
      count := count + 1;
    end if;
  end process;
  
-----------  * t7: TEST(RW)
  rwt_p : process(rst, clk)
    variable st, st_nxt : natural := 1;
    variable st_prev : integer := -1;
    variable prev_req : MSG_T := ZERO_MSG;
    
    variable t7 : boolean := false;
    
    -- t7 vars
    variable dcnt : natural := 0;
    variable dflg : boolean := true;
    
    variable t7_f : boolean := true;
    variable t7_s : natural := nat(id_i) + seed_i;
    variable t7_ct, t7_c, t7_r : natural := 0;
    variable t7_cmd : CMD_T;
    variable t7_adr : ADR_T;
    variable d_cnt: natural := nat(id_i)+15;
    -- HACKS
    variable c1: integer := 0;
    variable c2: integer := 200; -- offset so that cpus do not req same adr

    variable seqid: integer := -1;
    
  begin
    if en = '1' and rst = '1' then
      cpu_req_o <= ZERO_MSG;
      st := 1;
    elsif en = '1' and (rising_edge(clk)) then
      if (restart_i = '1') then
            t7_ct := 0;
            sim_end <= '0';
            st := 1;
      end if;
      --dbg_chg("rwt_p, st: ", st, st_prev);
      if st = 0 then -- DELAY
        rnd_dlay(t7_f, t7_s, t7_c, st, st_nxt);
        st := 1;
        --delay(sint(r) mod RWT_MAXDELAY, dflg, dcnt, st, st_nxt);
        delay(d_cnt, st, st_nxt);
       st := st_nxt;
      elsif st = 1 then -- START
        if t7_ct < RWT_CNT then
          t7_ct := t7_ct + 1;
          st_nxt := 3;
          st := 0;
        else
          st := 2;
        end if;
      elsif st = 2 then -- DONE
        sim_end <= '1';
        cpu_req_o <= ZERO_MSG;
        
      elsif st = 3 then -- SND (r|w req)

        -- get a random number
        t7_s := t7_s + 1;
        -- rndmz cmd
        t7_r := to_integer(unsigned(r)) + t7_s;
        --report str(id_i) & ", r is " & integer'image(t7_r);

        -- if read and write are enabled, randomly select one of them
        if RWT_CMD = (READ_CMD or WRITE_CMD) then
          if (t7_r mod 2) = 1 then
            t7_cmd := READ_CMD;
          else
            t7_cmd := WRITE_CMD;
          end if;
        else
          t7_cmd := RWT_CMD;
        end if;
        -- HACK1 force each cpu to request different addresses
        if id_i = CPU0 then
          t7_adr :=  std_logic_vector(to_unsigned(t7_r mod 7, 3)) &  std_logic_vector(to_unsigned(c1, t7_adr'length - 3));
          c1 := c1 + 1;
        else
          t7_adr := std_logic_vector(to_unsigned(t7_r mod 7, 3)) &  std_logic_vector(to_unsigned(c2, t7_adr'length - 3));
          c2 := c2 + 1;
        end if; 
        -- HACK2 force them to go to memory or gfx
        --if (t7_r mod 2) = 1 then
          t7_adr := t7_adr or X"80000000"; -- mem
        --else
        --  t7_adr := t7_adr and X"1FFFFFFF"; -- gfx --TODO need to change gfx
        --end if;

        -- set sequence id
        seqid := seqid + 1;
        
        cpu_req_o <= ('1', t7_cmd, tag, std_logic_vector(to_unsigned(seqid, 8)),
                      t7_adr, t7_adr);
        dbg(t7_cmd & t7_adr & t7_adr);
        prev_req := ('1', t7_cmd, tag, std_logic_vector(to_unsigned(seqid, 8)),
                     t7_adr, t7_adr);
        st := 4;
      elsif st = 4 then
        if cpu_req_ack_i = '1' then
          cpu_req_o <= ZERO_MSG;
          st := 5;
        end if;
      elsif st = 5 then -- WAIT_RES
        cpu_req_o <= ZERO_MSG;
        delay(d_cnt, st, st_nxt);
        if (not RWT_WAITRES) or -- if no need to wait for resp
          is_rw_cmd(cpu_res_i) then -- or need to wait for resp and resp has arrived
          st_nxt := 1;
          --dbg("000" & cpu_res_i);
          st := 0;
        end if;
      end if;
    end if;
  end process;
  
end architecture rwt;

architecture pwrt of cpu_test is
  signal r : std_logic_vector(31 downto 0);
  signal sim_end : std_logic := '0';
  signal tag: IPTAG_T:= ZERO_TAG;
begin  -- architecture pwrtx
	set_tag: process(clk)
	begin
	if rising_edge(clk) then
		if rst='1' then
			if id_i = CPU0 then
      			tag <= CPU0_TAG;
     		elsif id_i=CPU1 then
     			tag <= CPU1_TAG;
     		end if;
		end if;
	end if;
	end process;
	
	
   rndgen_ent : entity work.rndgen(rtl) port map (
     clk    => clk,
     rst    => rst,
     en     => en,
     seed_i => to_integer(unsigned(TEST(PWR))),
     rnd_o  => r
     );

  done_o <= (not en) or sim_end;
  
  clk_counter : process(clk, en)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if en = '1' and sim_end = '1' and b then
      info("pwrt ended in cpu " & str(id_i) & ", clock cycles is " & str(count));
      b := false;
      -- done_o <= '1';
    elsif sim_end = '0' and en = '1' and (rising_edge(clk)) then
      count := count + 1;
    end if;
  end process;
  
--  * t6: TEST(PWR)
 pwrt_p : process(rst, clk, en)
   variable st, st_nxt : natural := 1;
   variable st_prev : integer := -1;
   variable prev_req : MSG_T := ZERO_MSG;
    
   variable t6 : boolean := false;

   variable dflg : boolean := true;
   variable dcnt : natural := 0;
   
   -- t6 vars
   variable t6_f : boolean := true;
   variable t6_c, t6_tc, t6_r : natural := 0;
   variable t6_s : natural := nat(id_i) + seed_i;
   -- _s is seed, _c is cnt, _tc is tot cnt
   variable t6_cpuid : IPTAG_T;
   variable t6_cmd : CMD_T;
   variable t6_devid : IPTAG_T;

   -- HACKS
   variable c1: integer := 0;
   variable c2: integer := 200; -- offset so that cpus do not req same adr
    
 begin
    if en = '1' and rst = '1' then
      cpu_req_o <= ZERO_MSG;
      st := 1;
      
    elsif en = '1' and (rising_edge(clk)) then
      --dbg_chg("pwrt_p", st, st_prev);
      if st = 0 then -- DELAY
        rnd_dlay(t6_f, t6_s, t6_c, st, st_nxt);
        --delay(sint(r) mod PWRT_MAXDELAY, dflg, dcnt, st, st_nxt);
      elsif st = 1 then -- START
        if t6_tc < PWRT_CNT then
          t6_tc := t6_tc + 1;
          st_nxt := 3;
          st := 0;
        else
          st := 2;
        end if;
      elsif st = 2 then
        --sim_end <= '1';
      elsif st = 3 then -- SND pwr req

        -- set cpu id vect
        if id_i = CPU0 then
          t6_cpuid := CPU0_TAG;
        else
          t6_cpuid := CPU1_TAG;
        end if;
        
        -- rnmz pwr cmd
        t6_r := to_integer(unsigned(r)) + t6_s;
        if (t6_r mod 2) = 1 then
          -- report str(id_i) & "up";
          t6_cmd := PWRUP_CMD;
        else
          -- report str(id_i) & "dn";
          t6_cmd := PWRDN_CMD;
        end if;

        -- calc devid
        --  (t6_r % 4) + 1 since there are 4 peripherals and their ids start at 1
        t6_devid := std_logic_vector(to_unsigned((t6_r mod 4) + 1, t6_devid'length));
        
        cpu_req_o <= ('1', t6_cmd, tag, ZERO_ID, pad32(t6_cpuid), pad32(t6_devid));
        report "cpu is power requesint data: "& integer'image(to_integer(unsigned(pad32(t6_devid))));
        st := 4;
      elsif st = 4 then -- WAIT RES
        cpu_req_o <= ZERO_MSG;
        --if is_valid(cpu_res_i) then
        --  st := 60;
        --end if;

        -- do not wait for resp, dlay for rnd time and continue
        st_nxt := 1;
        st := 0;
      end if;
    end if;                             -- end rising_edge if
 end process;

end architecture pwrt;

