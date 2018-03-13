library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

entity arbiter6_ack is
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in MSG_T;
            ack1_o: out STD_LOGIC;
            
            din2:	in MSG_T;
            ack2_o:	out std_logic;
            
            din3:	in MSG_T;
            ack3_o:	out std_logic;
            
            din4:	in MSG_T;
            ack4_o:	out std_logic;
            
            din5:	in MSG_T;
            ack5_o:	out std_logic;
            
            din6:	in MSG_T;
            ack6_o:	out std_logic;
            
            dout:	out MSG_T;
            ack_i: 	in std_logic
     );
end arbiter6_ack;

-- version 2
architecture rtl of arbiter6_ack is

    
    signal s_token : integer :=0;
		
begin  
 	process (clock,reset)
 		variable nilreq : MSG_T := ZERO_MSG;
 		variable state : integer:=0;
 		variable s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6 : std_logic;
    begin
       if rising_edge(clock) then
        	 if reset = '1' then
                  s_token <= 0;
                  s_ack1 := '0';
                  s_ack2 := '0';
                  s_ack3 := '0';
                  s_ack4 := '0';
                  s_ack5 := '0';
                  s_ack6 := '0';
                  dout <=  nilreq;
              elsif state = 0 then
					dout <= nilreq;
	            s_ack1 := '0';
	            s_ack2 := '0';   
	            s_ack3 := '0'; 
	            s_ack4 := '0';
	            s_ack5 := '0';   
	            s_ack6 := '0'; 
	            if din1.val = '1' and s_ack1 ='0' then
	            		dout <= din1;
	            		state := 1;
	            elsif din2.val = '1' and s_ack2 ='0' then
	            		dout <= din2;
	            		state :=2;
	         	elsif din3.val = '1' and s_ack3 ='0' then
	            		dout <= din3;
	            		state :=3;
	            elsif din4.val = '1' and s_ack4 ='0' then
	            		dout <= din4;
	            		state :=4;
	            elsif din5.val = '1' and s_ack5 ='0'  then
	            		dout <= din5;
	            		state :=5;
	            elsif din6.val = '1' and s_ack6 ='0'  then
	            		dout <= din6;
	            		state :=6;
	            end if;
	    elsif state =1 then
			dout <= nilreq;
			if ack_i ='1' then
	    		s_ack1 := '1';
				state :=7;
			end if;
	    elsif state =2 then
		 dout <= nilreq;
	    		if ack_i ='1' then
	    		s_ack2 := '1';
				state :=7;
			end if;								
	    elsif state =3 then
		 dout <= nilreq;
	    		if ack_i ='1' then
	    		s_ack3 := '1';
				state :=7;
			end if;
	    elsif state =4 then
		 dout <= nilreq;
	    	if ack_i ='1' then
	    		s_ack4 := '1';
				state :=7;
			end if;
	    elsif state =5 then
		 dout <= nilreq;
	    	if ack_i ='1' then
	    		s_ack5 := '1';
				state :=7;
			end if;
	    elsif state =6 then
		 dout <= nilreq;
	    	if ack_i ='1' then
	    		s_ack6 := '1';
				state :=7;
			end if;
		elsif state =7 then
		  state :=0;
	    end if;
        end if;
        ack1_o <= s_ack1;
        ack2_o <= s_ack2;
        ack3_o <= s_ack3;
        ack4_o <= s_ack4;
        ack5_o <= s_ack5;
        ack6_o <= s_ack6;
    end process;
end architecture rtl;   
