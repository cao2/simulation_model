library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;

package test is
  -- enable/disable tracing
  constant GEN_TRACE1 : boolean := true;
  
  -- TESTS ***********************************
  constant TDW : positive := 8;
  subtype TEST_T is std_logic_vector(TDW-1 downto 0);
  type TCASE_T is (NONE, CPU1R, CPU2W, CPUW20,
                   RW, UREQ, PWR, PETERSONS);
  type TEST_MAP_T is array(TCASE_T) of TEST_T;
  constant TEST : TEST_MAP_T := (x"00", x"01", x"02", x"04",
                                 x"08", x"10", x"20", x"40");

  --******************************************
  --* Tests description:
  --* (tests started from cpus)
  --* CPU1R: cpu1 sends 1 read req
  --* CPU2W: cpu2 sends 1 write req
  --* CPUW20: each cpu sends 20 rand write reqs
  --* PWR: each cpu sends PWRT_CNT power req(s)
  --* RW: each cpu sends RWT_CNT rnd(r/w) req(s) w/rnd delays
  --* PETERSONS: each cpu runs a thread of petersons algorithm
  --* (tests started from peripherals)
  --* UREQ: peripherals send UREQT_CNT up rnd(r/w) requests

  --********* GLOBAL TEST OPTS ***************
  constant MEM_DELAY : natural := 10;
  -- test delay flag, used by rnd_dlay fun to re-enable rndmz_flg 
  constant TDLAY_FLG : boolean := false;

  --********* PWR TEST OPTS ******************
  constant PWRT_CNT : natural := 5;
  constant PWRT_SRC : IP_VECT_T := --ip_enc(CPU0) or
                                   ip_enc(CPU1);
  --constant PWRT_MAXDELAY : natural := 0;  --NOT IMPLEMENTED YET
  
  --********* RW TEST OPTS *******************
  constant RWT_CNT : natural := 2;
  constant RWT_SRC : IP_VECT_T := ip_enc(CPU0) or ip_enc(CPU1);
  --constant RWT_DST : IP_VECT_T := ip_enc(GFX); -- NOT IMPLEMENTED YET
  --constant RWT_MAXDELAY : natural := 10;  -- NOT IMPLEMENTED YET
  constant RWT_WAITRES : boolean := false;
  constant RWT_CMD : CMD_T := READ_CMD or
                              WRITE_CMD;

  --********* UREQ TEST OPTS *****************
  constant UREQT_CNT : natural := 2;
  constant UREQT_SRC : IP_VECT_T := ip_enc(USB) or ip_enc(GFX) or ip_enc(UART) or ip_enc(AUDIO);
  
  --********* PETERSONS TEST OPTS ************
  constant PT_DELAY_FLAG : boolean := true;
  constant PT_ITERATIONS : natural := 500;
  -- petersons' shared variables
  constant PT_VAR_FLAG0 : ADR_T := (0=>'1', others=>'0'); -- M[1]
  constant PT_VAR_FLAG1 : ADR_T := (1=>'1', others=>'0'); -- M[2]
  constant PT_VAR_TURN : ADR_T := (1=>'1', 0=>'1', others=>'0'); -- M[3]
  constant PT_VAR_SHARED : ADR_T := (2=>'1', others=>'0'); -- M[4]
  procedure pt_delay(variable rndmz_dlay : inout boolean;
                     variable seed: inout natural;
                     variable cnt: inout natural;
                     variable st : inout natural;
                     constant next_st : in natural);

  --********************************************************************
  --* Warning: don't enable tests that are triggered on the same signals
  constant RUN_TEST : TEST_T :=TEST(RW)
   or
--                                TEST(PWR) or
                            TEST(UREQ);
                                --TEST(PETERSONS);
                                --TEST(NONE);
  --********************************************************************

  -- TODO should rm this fun from here
  procedure rnd_dlay(variable rndmz_dlay : inout boolean; 
                     variable seed : inout natural;
                     variable cnt: inout natural; 
                     variable st : inout natural;
                     constant next_st : in natural);
  
  --* Checks if test is enabled
  function is_tset(test: TEST_T) return boolean;
  function is_tset(tc: TCASE_T) return std_logic;
  
  --procedure check_inv(variable timer : inout time;
  --                    constant mark : in time;
  --                    constant cond : in boolean;
  --                    constant msg : in string);
end test;

package body test is
  procedure pt_delay(variable rndmz_dlay : inout boolean;
                     variable seed : inout natural;
                     variable cnt: inout natural;
                     variable st : inout natural;
                     constant next_st : in natural) is
  begin
    if rndmz_dlay and st /= next_st then -- start
      --report "start";
      cnt := 1;
      seed := seed + 1;
      rndmz_dlay := false;
--      report "pt_delay.cnt" & integer'image(cnt);
      delay(cnt, st, next_st);
    elsif (rndmz_dlay = false) then -- count
      --report "count";
      delay(cnt, st, next_st);
    end if;
    
    if st = next_st and PT_DELAY_FLAG then -- if done, set flag back to true
      --report "done";
      rndmz_dlay := true;
    end if;
  end;

  -- A generalized version of pt_delay
  -- @rndmz_dlay : flag, indicates if rndmly select value for cnt or start from
  -- current value of cnt; turned off while counting; turned on when done (if
  -- TDLAY_FLG is set)
  -- @seed : a num to offset rnd assignment, will be incremented once (if
  -- rmdmz_dlay is set)
  -- @cnt : counter current val will be read/written to cnt
  -- @st : current st
  -- @next_st : where to jump when done
  --
  -- Usage example:
  --   f := true;
  --   s := 0;
  --   st := 0;
  --   nxt_st := 1;
  --   rnd_dlay(f, s, c, st, nxt_st); 
  procedure rnd_dlay(variable rndmz_dlay : inout boolean; 
                     variable seed : inout natural;
                     variable cnt: inout natural; 
                     variable st : inout natural;
                     constant next_st : in natural) is
  begin
  --cnt := 1;
    if rndmz_dlay and st /= next_st then -- start
      cnt :=1;
      seed := seed + 1;
      rndmz_dlay := false;
      delay(cnt, st, next_st);
    elsif (rndmz_dlay = false) then -- count
      delay(cnt, st, next_st);
    end if;
    
    if st = next_st and TDLAY_FLG then -- if done, set flag back to true
      rndmz_dlay := true;
    end if;
  end;
  
  function is_tset(test: TEST_T) return boolean is
  begin
    if (RUN_TEST and test) /= x"00" then
      return true;
    end if;
    return false;
  end function;

  function is_tset(tc: TCASE_T) return std_logic is
  begin
    if (RUN_TEST and TEST(tc)) /= x"00" then
      return '1';
    end if;
    return '0';
  end function;
  
  --procedure check_inv(variable timer : inout time;
  --                    constant mark : in time;
  --                    constant cond : in boolean;
  --                    constant msg : in string) is
  --begin
  --  --wait for mark - timer;
  --  timer := mark;
  --  assert cond report msg severity error;
  --end;
end test;
        
