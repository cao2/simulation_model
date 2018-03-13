library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity b_arbiter2 is
  -- Generic (
  --   constant DATA_WIDTH  : positive := MSG_WIDTH
	-- );
  Port (
    clock: in std_logic;
    reset: in std_logic;
    
    din1: 	in BMSG_T;
    ack1: 	out STD_LOGIC;
    
    din2:	in BMSG_T;
    ack2:	out std_logic;
    
    dout:	out BMSG_T
    );
end b_arbiter2;

-- version 2
architecture rtl of b_arbiter2 is
signal s_ack1, s_ack2 : std_logic;
  signal s_token : integer :=0;
  signal tdout: BMSG_T;
  
begin  
 process (clock)
  variable st : STATE := one;
 begin
  if reset = '1' then
          s_ack1 <= '0';
          s_ack2 <= '0';
         
          dout <=  ZERO_BMSG;
          tdout <= ZERO_BMSG;
    elsif rising_edge(clock) then
    if st=one then
     if din1.val = '1' and s_ack1 = '0'  then
         tdout <= din1;
         s_ack1 <= '1';
     elsif din2.val  = '1' and s_ack2='0' then
      
       report "2 here ai haofan ay a";
         tdout <= din2;
         s_ack2 <= '1';
      
     else
       ---report "reset output";
       tdout <= ZERO_BMSG;
       s_ack1 <= '0';
       s_ack2 <= '0';
       
       st := two;
     end if;
   else
       st:=one;
   end if;
       dout<= tdout;
   ack1 <= s_ack1;
   ack2 <= s_ack2;
   
   end if;
 end process;
end architecture rtl;   
