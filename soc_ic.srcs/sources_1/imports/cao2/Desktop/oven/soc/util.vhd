library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.defs.all;

package util is
  function is_pwr_cmd(msg : MSG_T) return boolean;
  function is_rw_cmd(msg : MSG_T) return boolean;
  --* returns true if adr's msb is 1
  function is_mem_req(msg: MSG_T) return boolean;

  function dst_eq(msg: MSG_T; tag: IPTAG_T) return boolean;
  
  --* delay st transition for cnt clock cycles
  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural);

  procedure delay(constant rnd : in natural;
                  variable flg : inout boolean; 
                  variable cnt: inout natural; 
                  variable st : inout natural;
                  constant next_st : in natural);
  
  --* left pad
  function pad32(v : IPTAG_T) return ADR_T;

  function rpad(v : std_logic_vector) return std_logic_vector;

  procedure to_bmsg(signal t : out BMSG_T; constant s: in MSG_t);

  procedure clr(signal s: out BMSG_T);
  procedure clr(signal s: out MSG_T);
  
  --+ Poor man's logger
  type LOG_LEVEL_T is (OFF, ERROR, INFO, DEBUG);
  constant LOG_LEVEL : LOG_LEVEL_T := DEBUG;
  procedure log(constant s : in string; constant l : in LOG_LEVEL_T);
  procedure log(constant v : in std_logic_vector);
  procedure log_chg(constant s : in string;
                    constant st : in integer;
                    variable prev_st : inout integer);

  --+ info funs: only ouptut if logging level is INFO
  procedure info(constant s : in string);
  
  --+ debugging funs: only output if logging level is DEBUG
  procedure dbg(constant s : in string);
  procedure dbg(constant v : in std_logic_vector);
  procedure dbg_chg(constant s : in string;
                    constant st : in integer;
                    variable prev_st : inout integer);

  --* log request
  procedure req(signal sig : out MSG_T;
                constant v : in MSG_T;
                constant str : in string);
  
  --+ type casting
  function str(n : integer) return string;
  function str(n : IP_T) return string;
  function nat(n : IP_T) return natural;
  function uint(v : std_logic_vector) return integer;
  function sint(v : std_logic_vector) return integer;

  function slv(m : MSG_T) return std_logic_vector;
  function slv(m: cacheline) return std_logic_vector;
  function slv(m: TST_T) return std_logic_vector;
  function slv(m : BMSG_T) return std_logic_vector;
  function slv(m: AXI_T) return std_logic_vector;
  function stt(m: IP_T) return std_logic_vector;
  function slv(m: TST_TO) return std_logic_vector;
  	function count_ones(s : std_logic_vector) return natural range 0 to 1;
  --procedure clr(signal vector : out std_logic_vector);
end util;

package body util is
    
  procedure delay(variable cnt: inout natural;
                  variable st : inout natural;
                  constant next_st : in natural) is
  begin
    if cnt > 0 then
      cnt := cnt - 1;
    else
      st := next_st;
    end if;
  end;

  procedure delay(constant rnd : in natural;
                  variable flg : inout boolean;
                  variable cnt: inout natural; 
                  variable st : inout natural;
                  constant next_st : in natural) is
  begin
    if flg and st /= next_st then -- start
      cnt := rnd;
      flg := false;
      delay(cnt, st, next_st);
    elsif (flg = false) then -- count
      delay(cnt, st, next_st);
    end if;
    
    if st = next_st then -- if done, set flag back to true
      flg := true;
    end if;
  end;

        -- if dflg then
        --   dcnt := 1;
        --   dflg := false;
        -- end if;
        -- if dcnt > 0 then
        --   dcnt := dcnt - 1;
        -- else
        --   dflg := true;
        --   st := st_nxt;
        -- end if;
        --st := st_nxt;
  
  function is_pwr_cmd(msg : MSG_T) return boolean is
  begin
    if (msg.cmd = PWRUP_CMD) or
      (msg.cmd = PWRDN_CMD) then
      return true;
    end if;
    return false;
  end;

  function is_rw_cmd(msg : MSG_T) return boolean is
  begin
    if (msg.cmd = READ_CMD) or
      (msg.cmd = WRITE_CMD) then
      return true;
    end if;
    return false;
  end;
  
  function is_mem_req(msg: MSG_T) return boolean is
  begin
    if msg.val = '1' then
      return true;
    end if;
    return false;
  end;

  function dst_eq(msg: MSG_T; tag: IPTAG_T) return boolean is
  begin
    if msg.tag = tag then
      return true;
    end if;
    return false;
  end;

  function pad32(v : IPTAG_T) return ADR_T is
  begin
    return X"000000" & v;
  end;

   function rpad(v : std_logic_vector) return std_logic_vector is
     variable pad : std_logic_vector(479 downto 0) := (others => '0');
   begin
     return (v & pad);
   end;

  -- t is target
  -- s is source
  procedure to_bmsg(signal t : out BMSG_T; constant s: in MSG_t) is
  begin
    t <= (s.val, s.cmd, s.tag, s.id, s.adr, rpad(s.dat));
  end;

  procedure clr(signal s: out BMSG_T) is
  begin
    s <= ZERO_BMSG;
  end;

  procedure clr(signal s: out MSG_T) is
  begin
    s <= ZERO_MSG;
  end;
  
  procedure log(constant s : in string; constant l : in LOG_LEVEL_T) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(l) then
      report s;
    end if;
  end;

  procedure log(constant v : in std_logic_vector) is
    variable l : line;
  begin
    hwrite(l, v);
    writeline(output, l);
  end;
  
  procedure log_chg(constant s: in string;
                    constant st : in integer;
                    variable prev_st : inout integer) is
  begin
    if st /= prev_st then
      log(s & " " & str(st), INFO);
      prev_st := st;
    end if;
  end;

  procedure info(constant s : in string) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(INFO) then
      report s;
    end if;
  end;
  
  procedure dbg(constant s : in string) is
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
      report s;
    end if;
  end;

  procedure dbg(constant v : in std_logic_vector) is
    variable l : line;
  begin
    if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
      hwrite(l, v);
      writeline(output, l);
    end if;
  end;
  
  procedure dbg_chg(constant s: in string;
                    constant st : in integer;
                    variable prev_st : inout integer) is
  begin
    if st /= prev_st then
      if LOG_LEVEL_T'pos(LOG_LEVEL) >= LOG_LEVEL_T'pos(DEBUG) then
        log(s & " " & str(st), DEBUG);
      end if;
      prev_st := st;
    end if;
  end;
  
  procedure req(signal sig : out MSG_T;
                constant v : in MSG_T;
                constant str : in string) is
    variable cmd : string(1 to 2);
    variable msg : string(1 to 6);
  begin
    if v.cmd = WRITE_CMD then
      cmd := "wr";
      msg := " to M[" & str(to_integer(unsigned(v.adr))) & "]: ";
    elsif v.cmd = READ_CMD then
      cmd := "rd";
      msg := " to M[" & str(to_integer(unsigned(v.adr))) & "]: ";
    elsif v.cmd = PWRUP_CMD then
      cmd := "pu";
      msg := " " & str(to_integer(unsigned(v.adr))) &
             " -> " & str(to_integer(unsigned(v.dat))) & " : ";
    elsif v.cmd = PWRDN_CMD then
      cmd := "pd";
      msg := " " & str(to_integer(unsigned(v.adr))) &
             " -> " & str(to_integer(unsigned(v.dat))) & " : ";
    end if;

    log(cmd & msg & str, DEBUG);
    sig <= v;
  end;
  
  function str(n : integer) return string is
  begin
    return integer'image(n);
  end;

  function str(n : IP_T) return string is
  begin
    return IP_T'image(n);
  end;

  function nat(n : IP_T) return natural is
  begin
    return IP_T'pos(n);
  end;

  function uint(v : std_logic_vector) return integer is
  begin
    return to_integer(unsigned(v));
  end;

  function sint(v : std_logic_vector) return integer is
  begin
    return to_integer(signed(v));
  end;
 function stt(m: IP_T) return std_logic_vector is
 begin
    return std_logic_vector(to_unsigned(IP_T'POS(m),5));
 end;
  function slv(m : MSG_T) return std_logic_vector is
  begin
    return m.val & m.cmd & m.tag & m.id & m.adr & m.dat;
  end;
  
   function slv(m : cacheline) return std_logic_vector is
  begin
    return m.val & m.cmd & m.tag & m.id & m.adr & m.dat;
  end;
   function slv(m : TST_T) return std_logic_vector is
  begin
    return m.val & m.linkID & m.cmd & m.tag & m.id & m.adr ;
  end;

  function slv(m : BMSG_T) return std_logic_vector is
  begin
    return m.val & m.cmd & m.tag & m.id & m.adr & m.dat;
end;
 function count_ones(s : std_logic_vector) return natural range 0 to 1 is
  variable temp : natural := 0;
begin
  for i in s'range loop
    if s(i) = '1' then temp := temp + 1; 
    end if;
  end loop;
  
  return temp;
end function count_ones;
  function slv(m : AXI_T) return std_logic_vector is
  begin
    return m.val & m.linkID & m.cmd & m.tag & m.id & m.adr ;
  end;
   function slv(m : TST_TO) return std_logic_vector is
   begin
     return m.val & m.linkID & m.cmd & m.tag & m.id & m.adr&m.tim ;
   end;
  
end util;
