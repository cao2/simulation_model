library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;
use work.util.all;

entity fifo32 is
  Generic (
    constant FIFO_DEPTH	: positive := 8
	);
  Port ( 
    CLK		: in  STD_LOGIC;
    RST		: in  STD_LOGIC;
    DataIn	: in  ALL_T;
    DataOut	: out std_logic_vector(37 downto 0);
    Full	: out STD_LOGIC := '0'
	);
end fifo32;

architecture rtl of fifo32 is
 signal i: natural range 0 to 32 :=0;
   signal first: boolean := true;
begin
  fifo_proc : process (clk,rst)
    type ram_t is
      array (0 to FIFO_DEPTH - 1) of std_logic_vector(37 downto 0);
    variable Memory : ram_t;
    variable Head : natural range 0 to FIFO_DEPTH - 1;
    variable Tail : natural range 0 to FIFO_DEPTH - 1;
    variable Looped : boolean;
   -- variable len: integer :=0;
   
    variable amount: integer :=0;
  begin
  	if rising_edge(CLK) then
      if RST = '1' then
        Head := 0;
        Tail := 0;
        i <= 0;
        Looped := false;
        Full  <= '0';
--        Empty <= '1';
        DataOut<= (others=>'0');
    else
        first  <= true;
       --- while (i<32) loop
           if (((Looped = false) or (Head /= Tail))) and DataIn(0).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(0))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(0))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(1).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(1))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(1))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(2).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(2))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(2))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(3).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(3))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(3))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(4).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(4))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(4))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(5).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(5))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(5))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(6).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(6))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(6))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(7).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(7))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(7))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(8).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(8))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(8))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(9).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(9))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(9))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(10).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(10))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(10))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(11).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(11))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(11))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(12).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(12))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(12))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(13).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(13))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(13))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(14).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(14))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(14))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(15).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(15))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(15))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(16).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(16))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(16))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(17).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(17))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(17))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(18).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(18))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(18))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(19).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(19))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(19))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(20).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(20))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(20))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(21).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(21))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(21))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(22).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(22))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(22))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(23).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(23))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(23))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(24).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(24))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(24))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(25).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(25))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(25))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(26).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(26))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(26))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(27).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(27))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(27))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(28).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(28))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(28))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(29).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(29))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(29))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(30).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(30))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(30))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;
       if (((Looped = false) or (Head /= Tail))) and DataIn(31).val='1' then
                 if (first=true) then
                     Memory(Head) := slv(DataIn(31))&'1' ;
             first <= false;
         else
          Memory(Head) := slv(DataIn(31))&'0' ;
         end if;
            if (Head = FIFO_DEPTH - 1) then
          Head := 0;
                 Looped := true;
         else
           Head := Head + 1;
         end if;
     end if;

                     
          amount := amount +1;
          if (Head = Tail) then
                    if Looped then
                      Full <= '0';
                      report "the fifo is too small, it is full!!!!!!!!!!!!";
                    else
                      DataOut<= (others=>'0'); 
                    end if;
                  else
                    Full    <= '0';
                  end if;
                  
     ---  end loop;

          if ((Looped = true) or (Head /= Tail)) then
            -- Update data output
            DataOut <= Memory(Tail);
            amount := amount -1;
            -- Update Tail pointer as needed
            if (Tail = FIFO_DEPTH - 1) then
              Tail := 0;
              
              Looped := false;
            else
              Tail := Tail + 1;
            end if;
          end if;
     
      end if;
   end if;
  end process;
  
end rtl;
