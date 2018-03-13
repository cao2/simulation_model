library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity arbiter2_full is
  -- Generic (
  --   constant DATA_WIDTH  : positive := MSG_WIDTH
	-- );
  Port (
    clock: in std_logic;
    reset: in std_logic;
    
    din1: 	in MSG_T;
    ack1: 	out STD_LOGIC;
    
    din2:	in MSG_T;
    ack2:	out std_logic;
    
    dout:	out MSG_T;
    full: in std_logic
    );
end arbiter2_full;

-- version 2
architecture rtl of arbiter2_full is
signal s_ack1, s_ack2 : std_logic;
  signal s_token : integer :=0;
  signal tdout: MSG_T;
  
begin  
 process (clock,reset)
  variable st : STATE := one;
 begin
  if reset = '1' then
          s_ack1 <= '0';
          s_ack2 <= '0';
         
          dout <=  ZERO_MSG;
          tdout <= ZERO_MSG;
    elsif rising_edge(clock) then
    if st=one then
     if din1.val = '1' and s_ack1 = '0' and full/='1'  then
         tdout <= din1;
         s_ack1 <= '1';
     elsif din2.val  = '1' and s_ack2='0' and full/='1' then
         tdout <= din2;
         s_ack2 <= '1';
     else
       ---report "reset output";
       tdout <= ZERO_MSG;
       s_ack1 <= '0';
       s_ack2 <= '0';
       
       st := two;
     end if;
   elsif st= two then
       st:=three;
   elsif st= three then
        st := four;
   elsif st = four then
    st:= five;
    elsif st=five then
    st:=one;
   end if;
       dout<= tdout;
   ack1 <= s_ack1;
   ack2 <= s_ack2;
   
   end if;
 end process;
end architecture rtl;   
