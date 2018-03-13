library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
--use work.rand.all;
use work.util.all;
use work.test.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity cpu is
  Port(reset     : in  std_logic;
       Clock     : in  std_logic;

       id_i      : in IP_T;
       
       cpu_res_i : in  MSG_T;
       cpu_req_o : out MSG_T;
       full_c_i  : in  std_logic-- an input signal from cache, enabled when
       -- cache is full TODO confirm
       --TODO not implemented?
       );
end cpu;

architecture rtl of cpu is
  
begin
  --* t3: TEST(PETERSONS) executes petersons algorithm
--  cpu_test : process(reset, Clock)
--    variable st, st_nxt : natural := 0;
--    variable st_prev : integer := -1;
--    variable prev_req : MSG_T := (others => '0');
    
--    variable t3 : boolean := false;

--    variable t3_ct1, t3_ct2, t3_ct3 : natural;
--    variable t3_adr_me, t3_adr_other: ADR_T; -- flag0 and flag1
--    variable t3_dat1 : DAT_T := (0=>'1',others=>'0'); -- to cmp val of data=1
--    variable t3_rdlay : boolean := PT_DELAY_FLAG;
--    variable t3_seed : natural := nat(id_i);
--    variable t3_cont : boolean := false;
--    variable t3_reg : MSG_T;

--    -- HACKS
--    variable c1: integer := 0;
--    variable c2: integer := 200; -- offset so that cpus do not req same adr
    
--  begin
--    -- Set up tests
--    if is_tset(TEST(PETERSONS)) then
--      t3 := true;
--      -- assumming m[shared] is set to 0 TODO set in top.vhd
--      if id_i = CPU0 then
--        t3_adr_me := PT_VAR_FLAG0;
--        t3_adr_other := PT_VAR_FLAG1;
--      elsif id_i = CPU1 then
--        t3_adr_me := PT_VAR_FLAG1;
--        t3_adr_other := PT_VAR_FLAG0;
--      end if;
--    end if;
    
--    if reset = '1' then
--      cpu_req_o <= (others => '0');
--      -- Set initial rnd delays for each test
--      st := 0;
      
--    elsif (rising_edge(Clock)) then
--      dbg_chg("pcs: cpu_test, st: ", st, st_prev);
        
--      if st = 0 then -- wait
--        if t3 then
--          st := 100; -- petersons test starts in state 100
--        end if;
        
---- *** t3: Petersons algorithm starts here ***
--      elsif st = 99 then -- delay
--        --TODO remember to put back
--        --pt_delay(t3_rdlay, t3_seed, t3_ct3, st, st_nxt);
--        st := st_nxt;
--      elsif st = 100 then -- line 1 (for loop)
--        if t3_ct1 < PT_ITERATIONS then
--          pt_delay(t3_rdlay, t3_seed, t3_ct3, st, 101);
--        else
--          st := 2; -- done
----          report "done at " & integer'image(time'pos(now));
--        end if;
--      elsif st = 101 then -- line 2
--        req(cpu_req_o, "1" & WRITE_CMD
--            & t3_adr_me & t3_dat1, str(id_i)); -- flag[me] = 1; (req)
--        st := 102;
--      elsif st = 102 then -- wait_rsp
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          st := 99; -- st delay
--          st_nxt := 1022;
--        end if;
--      elsif st = 1022 then -- line 3
----        report "done! st is " & integer'image(st);
--        req(cpu_req_o, "1" & WRITE_CMD
--            & PT_VAR_TURN & t3_dat1, str(id_i)); -- turn = 1; (req)
--        st := 103;
--      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          st := 99;
--          st_nxt := 1032;
--        end if;
--      elsif st = 1032 then -- read flag[other]
--        req(cpu_req_o, "1" & READ_CMD
--            & t3_adr_other & ZEROS32, str(id_i));
--        st := 104;
--      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          report "got response" & str(id_i);
--          if (get_dat(cpu_res_i) = t3_dat1) then
--            --report str(id_i) &  "dat is 1";
--            st_nxt := 1042; --if flag[other]=1
--          else
--            st_nxt := 108; -- jump out of loop
--        end if;
--          st := 99;
--        end if;
--      elsif st = 1042 then
--        req(cpu_req_o, "1" & READ_CMD & PT_VAR_TURN & ZEROS32, str(id_i)); -- read turn
--        st := 105;
--      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          if (get_dat(cpu_res_i) = t3_dat1) then -- if turn=1
--            st_nxt := 106; --TODO*
--          else
--            st_nxt := 108; -- jump out of loop
--          end if;
--        st := 99;
--        end if;
--      elsif st = 106 then -- busy wait
--        st := 1032; -- go to loop again
--      elsif st = 108 then -- line 6 (get val of shared)
--        req(cpu_req_o, "1" & READ_CMD & PT_VAR_SHARED & ZEROS32, str(id_i));
--        st := 109;
--      elsif st = 109 then -- wait_rsp
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          st := 99; -- st delay
--          st_nxt := 1092;          
--        end if;
--      elsif st = 1092 then
--        req(cpu_req_o, "1" & WRITE_CMD & PT_VAR_SHARED &
--                       std_logic_vector(unsigned(get_dat(cpu_res_i)) +
--                                        unsigned(t3_dat1)), str(id_i));
--        st := 110;
--      elsif st = 110 then
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          st := 99;
--          st_nxt := 1102;
--        end if;
--      elsif st = 1102 then
--        req(cpu_req_o, "1" & WRITE_CMD & t3_adr_me & ZEROS32, str(id_i));
--        st := 111;
--      elsif st = 111 then -- jmp to FOR_LOOP_START
--        cpu_req_o <= ZERO_MSG;
--        if is_valid(cpu_res_i) then
--          log("got response" & str(id_i), DEBUG);
--          t3_ct1 := t3_ct1 + 1;
--          st := 99;
--          st_nxt := 100;
--          if (t3_ct1 mod 50) = 0 then
--            log("t3_ct1 is " & str(t3_ct1), DEBUG);
--          end if;
--        end if;
--      end if;
--    end if;
--  end process;    
end rtl;
