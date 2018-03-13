library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity arbiter7 is
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in BMSG_T;
            ack1: 	out STD_LOGIC;
            
            din2:	in BMSG_T;
            ack2:	out std_logic;
            
            din3:	in BMSG_T;
            ack3:	out std_logic;
            
            din4:	in BMSG_T;
            ack4:	out std_logic;
            
            din5:	in BMSG_T;
            ack5:	out std_logic;
            
            din6:	in BMSG_T;
            ack6:	out std_logic;
				
				din7:	in BMSG_T;
            ack7:	out std_logic;
            
            dout:	out BMSG_T
     );
end arbiter7;

-- version 2
architecture rtl of arbiter7 is
signal s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6,s_ack7 : std_logic;
  signal s_token : integer :=0;
  signal tdout: BMSG_T;
  
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
           s_ack7 <='0';
           dout <=  ZERO_BMSG;
           tdout <= ZERO_BMSG;
     elsif rising_edge(clock) then
     if st=one then
      if din1.val = '1' and s_ack1 = '0'  then
          tdout <= din1;
          s_ack1 <= '1';
      elsif din2.val  = '1' and s_ack2='0' then
       
          tdout <= din2;
          s_ack2 <= '1';
        
      elsif din3.val  = '1' and s_ack3='0' then
          tdout <= din3;
          s_ack3 <= '1';
      elsif din4.val  = '1' and s_ack4='0'  then
          tdout <= din4;
          s_ack4 <= '1';
      elsif din5.val = '1' and s_ack5='0'  then
          tdout <= din5;
          s_ack5 <= '1';
      elsif din6.val  ='1' and s_ack6='0'  then
          tdout <= din6;
          s_ack6 <= '1';
      elsif din7.val = '1' and s_ack7 = '0'  then
                   tdout <= din7;
                   s_ack7 <= '1';
      else
        ---report "reset output";
        tdout <= ZERO_BMSG;
        s_ack1 <= '0';
        s_ack2 <= '0';
        s_ack3 <= '0';
        s_ack4 <= '0';
        s_ack5 <= '0';
        s_ack6 <= '0';
        s_ack7<='0';
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
    ack7 <= s_ack7;
    end if;
    
    
  end process;
  
  
  
  
end architecture rtl;   
