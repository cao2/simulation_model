library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity fifo_gen26 is
  Generic (
    constant B	: positive := 32;
    constant W: positive := 32
	);
  Port ( 
    clk		: in  STD_LOGIC;
    reset		: in  STD_LOGIC;
    wr	: in  STD_LOGIC;
    w_data	: in  std_logic_vector(B-1 downto 0);
    rd	: in  STD_LOGIC;
    r_data	: out std_logic_vector(B-1 downto 0);
    Empty	: out STD_LOGIC;
    Full	: out STD_LOGIC := '0'
	);
end fifo_gen26;

architecture rtl of fifo_gen26 is
 --signal td1: std_logic_vector(31 downto 0);
 --signal td2: std_logic_vector(31 downto 0);
begin
	
  -- Memory Pointer Process
  fifo_proc : process (reset,clk)
    type FIFO_Memory is
      array (0 to 2**W - 1) of std_logic_vector(B-1 downto 0);
    variable Memory : FIFO_Memory;
    
    variable Head : natural range 0 to 2**W - 1;
    variable Tail : natural range 0 to 2**W - 1;
    variable tmp_head: natural range 0 to 2**W-1;
    variable Looped,tmp_looped : boolean;
  begin
  	if rising_edge(CLK) then
  		--td2<=Memory(Tail).dat;
  		--td1<=DataIn.dat;
      if reset = '1' then
        Head := 0;
        Tail := 0;
        Looped := false;
        Full  <= '0';
        Empty <= '1';
        r_data<= (others=>'0');
    else
    	
        if (wr = '1') then
          report "fifo tries to write  "& std_logic'image(w_data(31)) & std_logic'image(w_data(30))
                    & std_logic'image(w_data(29)) & std_logic'image(w_data(28))
                    & std_logic'image(w_data(27)) & std_logic'image(w_data(26))
                    & std_logic'image(w_data(25)) & std_logic'image(w_data(24))
                    & std_logic'image(w_data(23)) & std_logic'image(w_data(22))
                    & std_logic'image(w_data(21)) & std_logic'image(w_data(20))
                    & std_logic'image(w_data(19)) & std_logic'image(w_data(18))
                    & std_logic'image(w_data(17)) & std_logic'image(w_data(16))
                    & std_logic'image(w_data(15)) & std_logic'image(w_data(14))
                    & std_logic'image(w_data(13)) & std_logic'image(w_data(12))
                    & std_logic'image(w_data(11)) & std_logic'image(w_data(10))
                    & std_logic'image(w_data(9)) & std_logic'image(w_data(8))
                    & std_logic'image(w_data(7)) & std_logic'image(w_data(6))
                    & std_logic'image(w_data(5)) & std_logic'image(w_data(4))
                    & std_logic'image(w_data(3)) & std_logic'image(w_data(2))
                    & std_logic'image(w_data(1)) & std_logic'image(w_data(0));
          if ((Looped = false) or (Head /= Tail)) then
           report "write down";
            -- Write Data to Memory
            Memory(Head) := w_data;
            
            -- Increment Head pointer as needed
            if (Head = 2**W - 1) then
              Head := 0;
              
              Looped := true;
            else
              Head := Head + 1;
            end if;
            
              if (Head = 2**w - 1) then
                    tmp_head := 0;
                    tmp_looped:= true;
                  else
                    tmp_head:= Head + 1;
                  end if;
          else
            report "fifo failed to to write  "& std_logic'image(w_data(31)) & std_logic'image(w_data(30))
                              & std_logic'image(w_data(29)) & std_logic'image(w_data(28))
                              & std_logic'image(w_data(27)) & std_logic'image(w_data(26))
                              & std_logic'image(w_data(25)) & std_logic'image(w_data(24))
                              & std_logic'image(w_data(23)) & std_logic'image(w_data(22))
                              & std_logic'image(w_data(21)) & std_logic'image(w_data(20))
                              & std_logic'image(w_data(19)) & std_logic'image(w_data(18))
                              & std_logic'image(w_data(17)) & std_logic'image(w_data(16))
                              & std_logic'image(w_data(15)) & std_logic'image(w_data(14))
                              & std_logic'image(w_data(13)) & std_logic'image(w_data(12))
                              & std_logic'image(w_data(11)) & std_logic'image(w_data(10))
                              & std_logic'image(w_data(9)) & std_logic'image(w_data(8))
                              & std_logic'image(w_data(7)) & std_logic'image(w_data(6))
                              & std_logic'image(w_data(5)) & std_logic'image(w_data(4))
                              & std_logic'image(w_data(3)) & std_logic'image(w_data(2))
                              & std_logic'image(w_data(1)) & std_logic'image(w_data(0));
          end if;
        end if;
        
        if (rd = '1') then
        report "read";
          if ((Looped = true) or (Head /= Tail)) then
            -- Update data output
            r_data <= Memory(Tail);
            
            -- Update Tail pointer as needed
           if (Tail=0) then
                           tmp_looped :=false;
                         end if;
            if (Tail = 2**W - 1) then
              Tail := 0;
              Looped := false;
            else
              Tail := Tail + 1;
            end if;
          end if;
        else 
          r_data <= (others=>'0');
        end if;
        
      report "tail is "& integer'image(Tail);
      report "head is "& integer'image(Head);
      report "tmp_head is "&integer'image(tmp_head);
        
        -- Update Empty and Full flags
        --if (tmp_head = Tail or Head=Tail) then
          if ( (tmp_head=Tail or Head=Tail) and (tmp_looped or Looped) )then
            Full <= '1';
            if (w_data(30 downto 26)="11010") then
                    report "full is set to 1 for  "& std_logic'image(w_data(31)) & std_logic'image(w_data(30))
                                & std_logic'image(w_data(29)) & std_logic'image(w_data(28))
                                & std_logic'image(w_data(27)) & std_logic'image(w_data(26))
                                & std_logic'image(w_data(25)) & std_logic'image(w_data(24))
                                & std_logic'image(w_data(23)) & std_logic'image(w_data(22))
                                & std_logic'image(w_data(21)) & std_logic'image(w_data(20))
                                & std_logic'image(w_data(19)) & std_logic'image(w_data(18))
                                & std_logic'image(w_data(17)) & std_logic'image(w_data(16))
                                & std_logic'image(w_data(15)) & std_logic'image(w_data(14))
                                & std_logic'image(w_data(13)) & std_logic'image(w_data(12))
                                & std_logic'image(w_data(11)) & std_logic'image(w_data(10))
                                & std_logic'image(w_data(9)) & std_logic'image(w_data(8))
                                & std_logic'image(w_data(7)) & std_logic'image(w_data(6))
                                & std_logic'image(w_data(5)) & std_logic'image(w_data(4))
                                & std_logic'image(w_data(3)) & std_logic'image(w_data(2))
                                & std_logic'image(w_data(1)) & std_logic'image(w_data(0));
                                end if;
          elsif (Head=Tail and (not looped)) then
            Empty <= '1';
         -- end if;
        else
          Empty	<= '0';
          Full	<= '0';
        end if;
      end if;
    end if;
  end process;
  
end rtl;
