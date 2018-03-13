library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity b_c_arbiter6 is
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in cacheline;
            ack1: 	out STD_LOGIC;
            
            din2:	in cacheline;
            ack2:	out std_logic;
            
            din3:	in cacheline;
            ack3:	out std_logic;
            
            din4:	in cacheline;
            ack4:	out std_logic;
            
            din5:	in cacheline;
            ack5:	out std_logic;
            
            din6:	in cacheline;
            ack6:	out std_logic;
            
            dout:	out cacheline
     );
end b_c_arbiter6;

-- version 2
architecture rtl of b_c_arbiter6 is

    
 signal s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6 : std_logic;
  signal s_token : integer :=0;
  signal tdout: cacheline;
  
begin  
  process (clock,reset)
   variable st : STATE := one;
  begin
   if reset = '1' then
           s_token <= 0;
           s_ack1 <= '0';
           s_ack2 <= '0';
           s_ack3 <= '0';
           s_ack4 <= '0';
           s_ack5 <= '0';
           s_ack6 <= '0';
           dout.val <=  '0';
           tdout.val <= '0';
     elsif rising_edge(clock) then
     if st=one then
      if din1.val = '1' and s_ack1 = '0'  then
          tdout <= din1;
          s_ack1 <= '1';
      elsif din2.val  = '1' and s_ack2='0' then
       
        report "2 here ai haofan ay a";
          tdout <= din2;
          s_ack2 <= '1';
        
      elsif din3.val  = '1' and s_ack2='0' then
          tdout <= din3;
          s_ack3 <= '1';
      elsif din4.val  = '1' and s_ack2='0'  then
          tdout <= din4;
          s_ack4 <= '1';
      elsif din5.val = '1' and s_ack2='0'  then
          tdout <= din5;
          s_ack5 <= '1';
      elsif din6.val  ='1' and s_ack2='0' and tdout.val='0' then
          tdout <= din6;
          s_ack6 <= '1';
      else
        ---report "reset output";
        tdout.val <= '0';
        s_ack1 <= '0';
        s_ack2 <= '0';
        s_ack3 <= '0';
        s_ack4 <= '0';
        s_ack5 <= '0';
        s_ack6 <= '0';
        st := two;
      end if;
    else
        st:=one;
    end if;
        dout<= tdout;
    ack1 <= s_ack1;
    ack2 <= s_ack2;
    ack3 <= s_ack3;
    ack4 <= s_ack4;
    ack5 <= s_ack5;
    ack6 <= s_ack6;
    end if;
  end process;
end architecture rtl;   